@isTest
private class BTN_GoogleCalendarHandler_Test{

	private static String TEST_USER_FIRST_NAME = 'first';
	private static String TEST_USER_LAST_NAME = 'last';

    @TestSetup static void createDataStructure() {
        BTN_BriteCRM_TriggerException__c skipper = BTN_TestDataFactory.getTriggerSkipperCustomSetting();
        skipper.BTN_CustomEventTrigger__c = true;
        update skipper;
        CollaborationGroup cg = BTN_TestDataFactory.getHRCollaborationGroup();
        BTN_TestDataFactory.getNewBssDummyConnections();
        Account acc = BTN_TestDataFactory.getBriteNetAccount();
        Contact requestor = BTN_TestDataFactory.getRequestorInternalContact(acc.Id);
        BTN_TestDataFactory.getProjectRolesCustomSetting();

        BTN_ResourceRequest__c rr = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().get();
        BTN_DAO_ResourceRequest rDao = new BTN_DAO_ResourceRequest();
        Contact contact  = BTN_TestDataFactory.getRequestorInternalContact(acc.Id,null);
        contact.FirstName = TEST_USER_FIRST_NAME;
        contact.LastName = TEST_USER_LAST_NAME;
        update contact;
        rr.NumberOfCVs1__c=0;
        rr.Resource_Manager__c = requestor.Id;
        insert rr;
        rr = rDao.findResourceRequestsById(rr.id);
        system.assert(rr.NumberOfCVs1__c==0);
        BTN_CV__c cv = BTN_TestDataFactory.getCV(rr.Id,contact.Id);
        User testUser = BTN_TestDataFactory.getActiveUser(
                TEST_USER_FIRST_NAME,
                TEST_USER_LAST_NAME,
                null,
                BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.RESOURCE_MANAGER_PROFILE_NAME)
        );
        testUser.GoogleAccessToken__c = 'fakeToken';
        insert testUser;
        BTN_Event__c ev = new BTN_Event__c();
        ev.Title__c = 'testEvent00001';
        ev.End_Time__c = system.now().addDays(7);
        ev.Start_Time__c = system.now().addDays(1);
        ev.RecordTypeId = BTN_RecordTypeUtils.getRecordTypeCustomEventInterview().Id;
        ev.Interviewer_user__c = testUser.Id;
        ev.Interviewer_Contact__c = contact.Id;
        ev.Interviewed__c = BTN_TestDataFactory.getRecruitContact(acc.Id).Id;
        insert ev;
    }

     testMethod static private void testCreateEventNoGoogleConfiguration() {
         BTN_CV__c cv = new BTN_DAO_Candidate().findCandidates()[0];
         BTN_Event__c e = [select id,Interviewer_user__c from BTN_Event__c where title__c = 'testEvent00001' limit 1];
         User currentUser = [Select Id from User where Id = :e.Interviewer_user__c ];
         System.runAs(currentUser){
             List<BTN_Event__c > eventsList = new List<BTN_Event__c >();
             eventsList.add(e);
             system.assert(e != null);
             system.assert(e.Id != null);
             //no google configuration
             BTN_GoogleCalendarHandler gHandler = new BTN_GoogleCalendarHandler(eventsList, BTN_GoogleCalendarHandler.IS_INSERT);
             system.assert(!gHandler.googleConfSet);
         }
     }

    testMethod static private void testCreateEventWithSuccess() {
        BTN_Event__c eventTest = prepareEventData();
        User currentUser = [Select Id from User where Id = :eventTest.Interviewer_user__c ];
        eventTest.Title__c = 'testEvent00001Test';
        eventTest.Interviewer_user__c = null;
        update eventTest;
        System.runAs(currentUser){
            system.assert(eventTest.GoogleId__c==null);
            List<BTN_Event__c > eventsList = new List<BTN_Event__c >();
            eventsList.add(eventTest);

            BTN_GoogleCalendarHandler gHandler = new BTN_GoogleCalendarHandler(eventsList, BTN_GoogleCalendarHandler.IS_INSERT);
            Test.setMock(
                    HttpCalloutMock.class,
                    new BTN_GoogleCalendarMock (BTN_GoogleCalendarMock.OP_CREATE_EVENT_SUCCESS )
            );

            BTN_DAO_Event eventDao = new BTN_DAO_Event();
            eventDao.addInterviewedContactFields().addIntegratedUserFields().addInterviewerUsersFields();
            List<BTN_Event__c> events = eventDao.findEventsByIds((new Map<Id,BTN_Event__c>(eventsList )).keySet());
            Test.startTest();
            gHandler.createGoogleEvents(events);
            Test.stopTest();
            system.assert(gHandler.googleConfSet);

            eventTest = [select id, GoogleId__c from  BTN_Event__c where id=:eventTest.id];
            system.assert(eventTest.GoogleId__c==null);
        }
    }
    testMethod static private void testUpdateEventWithSuccess() {
        BTN_Event__c eventTest = prepareEventData();
        eventTest.GoogleId__c = BTN_GoogleCalendarMock.TEST_CALENDAR_ID;
        eventTest.UserUsedForGoogleIntegration__c = eventTest.Interviewer_user__c;
        update eventTest;
        User currentUser = [Select Id from User where Id = :eventTest.Interviewer_user__c ];
        System.runAs(currentUser) {

            List<BTN_Event__c > eventsList = new List<BTN_Event__c >();
            eventsList.add(eventTest);
            BTN_GoogleCalendarHandler gHandler = new BTN_GoogleCalendarHandler(eventsList, BTN_GoogleCalendarHandler.IS_UPDATE);
            Test.setMock(
                    HttpCalloutMock.class,
                    new BTN_GoogleCalendarMock(BTN_GoogleCalendarHandler.HTTP_METHOD_PUT)
            );

            BTN_DAO_Event eventDao = new BTN_DAO_Event();
            eventDao.addInterviewedContactFields().addIntegratedUserFields().addInterviewerUsersFields();
            List<BTN_Event__c> events = eventDao.findEventsByIds((new Map<Id, BTN_Event__c>(eventsList)).keySet());
            Test.startTest();
            gHandler.updateGoogleEvents(events);
            Test.stopTest();

            system.assert(gHandler.googleConfSet);
            eventTest = [select id, GoogleId__c from BTN_Event__c where id = :eventTest.id];
            system.assert(eventTest.GoogleId__c != null);
        }
    }
    testMethod static private void testDeleteEventWithSuccess() {
        BTN_Event__c eventTest = prepareEventData();
        eventTest.GoogleId__c = BTN_GoogleCalendarMock.TEST_CALENDAR_ID;
        eventTest.UserUsedForGoogleIntegration__c = eventTest.Interviewer_user__c;
        update eventTest;
        User currentUser = [Select Id from User where Id = :eventTest.Interviewer_user__c ];
        System.runAs(currentUser) {
            List<BTN_Event__c > eventsList = new List<BTN_Event__c >();
            eventsList.add(eventTest);
            BTN_GoogleCalendarHandler gHandler = new BTN_GoogleCalendarHandler(eventsList, BTN_GoogleCalendarHandler.IS_DELETE);
            Test.setMock(
                    HttpCalloutMock.class,
                    new BTN_GoogleCalendarMock(BTN_GoogleCalendarHandler.HTTP_METHOD_DELETE)
            );

            Test.startTest();
            gHandler.deleteGoogleEvents(eventsList);
            Test.stopTest();
            system.assert(gHandler.googleConfSet);
        }

    }
    testMethod static private void testDeleteEventWithFail() {
        BTN_Event__c eventTest = prepareEventData();
        eventTest.GoogleId__c = BTN_GoogleCalendarMock.TEST_CALENDAR_ID;
        eventTest.UserUsedForGoogleIntegration__c = eventTest.Interviewer_user__c;
        update eventTest;
        User currentUser = [Select Id from User where Id = :eventTest.Interviewer_user__c ];
        System.runAs(currentUser) {
            List<BTN_Event__c > eventsList = new List<BTN_Event__c >();
            eventsList.add(eventTest);
            BTN_GoogleCalendarHandler gHandler = new BTN_GoogleCalendarHandler(eventsList, BTN_GoogleCalendarHandler.IS_DELETE);
            Test.setMock(
                    HttpCalloutMock.class,
                    new BTN_GoogleCalendarMock(BTN_GoogleCalendarMock.OP_CREATE_EVENT_AUTH_FAIL)
            );

            Test.startTest();
            gHandler.deleteGoogleEvents(eventsList);
            Test.stopTest();
            system.assert(gHandler.googleConfSet);
        }
    }
    testMethod static private void testGetEvents() {
        Test.setMock(
                HttpCalloutMock.class,
                new BTN_GoogleCalendarMock (BTN_GoogleCalendarMock.TEST_CALENDAR_ID_WITH_EVENTS)
        );
        Test.startTest();
        String res = BTN_GoogleCalendarHandler.getEvents(BTN_Utils.getCurrentUser(),BTN_GoogleCalendarMock.TEST_CALENDAR_ID);
        Test.stopTest();
        System.assert(String.isNotBlank(res));

    }
    private static BTN_Event__c prepareEventData(){
        BTN_Event__c eventTest = [select id,GoogleId__c,RecordTypeId,Start_Time__c,End_Time__c,Interviewed__c, Interviewer_user__c,Interviewer_user__r.GoogleAccessToken__c,Interviewer_user__r.Email from BTN_Event__c where title__c = 'testEvent00001' limit 1];
        eventTest.Title__c = 'testEvent00001Test';
        system.assert(eventTest.GoogleId__c==null);
        List<BTN_Event__c > eventsList = new List<BTN_Event__c >();
        eventsList.add(eventTest);
        BTN_GoogleCalendarMock.prepareGoogleCalendarSettings ();
        return eventTest;
    }
}