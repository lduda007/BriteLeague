/**
 * @author Mateusz Przywara
 * @date   2016-11-03
 * @description BTN_EventController_Test Test Class for Event Edit Page Controller
 */
@isTest
private class BTN_EventController_Test {
    private static String TEST_USER_FIRST_NAME = 'first';
    private static String TEST_USER_LAST_NAME = 'last';
    /**
     * @author Mateusz Przywara
     * @date   2016-11-07
     * @description Prepare data for tests
    */
    @TestSetup static void createDataStructure() {
        CollaborationGroup cg = BTN_TestDataFactory.getHRCollaborationGroup();
        BTN_TestDataFactory.getNewBssDummyConnections();
        Account acc = BTN_TestDataFactory.getBriteNetAccount();
        Contact internalCon = BTN_TestDataFactory.getRequestorInternalContact(acc.Id);
        BTN_ResourceRequest__c rr = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().save();
        rr.Resource_Manager__c = internalCon.Id;
        update rr;
        BTN_TestDataFactory.getCV(
                rr.Id,
                internalCon.Id
        );
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-11-07
     * @description testConstruction
    */
    testMethod static private void testConstructionGeneral() {
        User testUser = BTN_TestDataFactory.getActiveUser(
                TEST_USER_FIRST_NAME,
                TEST_USER_LAST_NAME,
                null,
                BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME)
        );

        System.runAs(testUser){
            PageReference pageTest = Page.BTN_EventPage;
            Test.setCurrentPage(pageTest);
            BTN_CV__c candidate = new BTN_DAO_Candidate().findCandidates().get(0);
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_RECORDTYPE_ID,
                    BTN_RecordTypeUtils.getRecordTypeCustomEventGeneral().Id
            );
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_CONTACT_ID,
                    candidate.Contact__c
            );
            ApexPages.StandardController stdController = new ApexPages.StandardController(new BTN_Event__c());
            BTN_EventController controller = new BTN_EventController(stdController);

            System.assertEquals(BTN_RecordTypeUtils.CUSTOMEVENT_GENERAL_RECORDTYPE, controller.RT_General);
            System.assertEquals(BTN_RecordTypeUtils.CUSTOMEVENT_INTERVIEW_RECORDTYPE, controller.RT_Interview);
            controller.beforeSaveValidation();
            System.assertNotEquals(null, controller.doSaveAfterValidation());
            List<BTN_Event__c> resultEvents = [SELECT RecordTypeId,RecordType.Name, Type__c, Interviewed__c, Candidate__c, Start_Time__c, End_Time__c, Profiling_date__c FROM BTN_Event__c];
            System.assert(resultEvents.size() == 1);
            BTN_Event__c resultEvent = resultEvents[0];
            System.assertEquals(BTN_RecordTypeUtils.CUSTOMEVENT_GENERAL_RECORDTYPE,resultEvent.RecordType.Name);
        }
    }
    testMethod static private void testValidateBeforeSave() {
        User testUser = BTN_TestDataFactory.getActiveUser(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME, null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));

        System.runAs(testUser) {
            String toLong = BTN_TestDataFactory.getGeneratedString(BTN_EventController.DESCRIPTION_MAX_LENGTH + 1);
            PageReference pageTest = Page.BTN_EventPage;
            Test.setCurrentPage(pageTest);
            BTN_CV__c candidate = new BTN_DAO_Candidate().findCandidates().get(0);
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_RECORDTYPE_ID,
                    BTN_RecordTypeUtils.getRecordTypeCustomEventGeneral().Id
            );
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_CONTACT_ID,
                    candidate.Contact__c
            );
            //when
            ApexPages.StandardController stdController = new ApexPages.StandardController(new BTN_Event__c());
            BTN_EventController controller = new BTN_EventController(stdController);
            controller.myEvent.Description__c = toLong;
            controller.myEvent.DescriptionTechnical__c = toLong;
            //then
            controller.beforeSaveValidation();
            System.assert(!controller.shouldSave);
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            Boolean desMessExist = false;
            Boolean techDesMessExist = false;
            for (Apexpages.Message msg:msgs) {
                if ((msg.getSummary().contains(String.format(Label.MaximumFieldLengthError, new String[]{
                        SObjectType.BTN_Event__c.fields.Description__c.label,
                        String.valueOf(BTN_EventController.DESCRIPTION_MAX_LENGTH)
                }))) && (msg.getSeverity() == ApexPages.Severity.Error)) {
                    desMessExist = true;
                }
                if ((msg.getSummary().contains(String.format(Label.MaximumFieldLengthError, new String[]{
                        SObjectType.BTN_Event__c.fields.DescriptionTechnical__c.label,
                        String.valueOf(BTN_EventController.DESCRIPTION_MAX_LENGTH)
                }))) && (msg.getSeverity() == ApexPages.Severity.Error)) {
                    techDesMessExist = true;
                }

            }
            System.assert(desMessExist);
            System.assert(techDesMessExist);
            System.assertEquals(null, controller.doSaveAfterValidation());
        }
    }
    testMethod static private void mainSectionLabelShouldContainCandidateInformation() {
        User testUser = BTN_TestDataFactory.getActiveUser(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME, null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));

        System.runAs(testUser) {
            PageReference pageTest = Page.BTN_EventPage;
            Test.setCurrentPage(pageTest);
            BTN_CV__c candidate = new BTN_DAO_Candidate().addResourceRequestFields().findCandidates().get(0);
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_RECORDTYPE_ID,
                    BTN_RecordTypeUtils.getRecordTypeCustomEventGeneral().Id
            );

            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_CANDIDATE_ID,
                    candidate.Id
            );
            ApexPages.StandardController stdController = new ApexPages.StandardController(new BTN_Event__c());
            BTN_EventController controller = new BTN_EventController(stdController);
            System.assert(controller.getMainSectionLabel().contains(String.format(System.Label.InterviewSectionLabel, new String[]{
                    candidate.ResourceRequest__r.Position_frm__c,
                    candidate.ResourceRequestName_frm__c
            })));
            controller.beforeSaveValidation();
            System.assertNotEquals(null, controller.doSaveAfterValidation());
        }
    }
    testMethod static private void testTimeGetters() {
        User testUser = BTN_TestDataFactory.getActiveUser(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME, null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));

        System.runAs(testUser) {
            PageReference pageTest = Page.BTN_EventPage;
            Test.setCurrentPage(pageTest);
            BTN_CV__c candidate = new BTN_DAO_Candidate().addResourceRequestFields().findCandidates().get(0);
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_RECORDTYPE_ID,
                    BTN_RecordTypeUtils.getRecordTypeCustomEventGeneral().Id
            );
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_CANDIDATE_ID,
                    candidate.Id
            );
            ApexPages.StandardController stdController = new ApexPages.StandardController(new BTN_Event__c());
            BTN_EventController controller = new BTN_EventController(stdController);
            DateTime testTime = System.now();
            controller.startTime = testTime;
            controller.endTime = testTime;
            controller.myEvent.Profiling_date__c = testTime;
            System.assertEquals(System.now().format('dd.MM.YYYY HH:mm'), controller.getStartTimeString());
            System.assertEquals(System.now().format('dd.MM.YYYY HH:mm'), controller.getEndTimeString());
            System.assertEquals(System.now().format('dd.MM.YYYY HH:mm'), controller.getProfilingTimeString());
            controller.profilingDate = testTime;
            System.assertEquals(System.now().format('dd.MM.YYYY HH:mm'), controller.getProfilingTimeString());
        }
    }
    testMethod static private void mainSectionLabelWithoutCandidate() {
        User testUser = BTN_TestDataFactory.getActiveUser(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME, null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));

        System.runAs(testUser) {
            PageReference pageTest = Page.BTN_EventPage;
            Test.setCurrentPage(pageTest);
            BTN_CV__c candidate = new BTN_DAO_Candidate().addResourceRequestFields().findCandidates().get(0);
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_RECORDTYPE_ID,
                    BTN_RecordTypeUtils.getRecordTypeCustomEventGeneral().Id
            );
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_CONTACT_ID,
                    candidate.Contact__c
            );
            ApexPages.StandardController stdController = new ApexPages.StandardController(new BTN_Event__c());
            BTN_EventController controller = new BTN_EventController(stdController);
            System.assert(!controller.getMainSectionLabel().contains(candidate.ResourceRequestName_frm__c));
        }
    }
    testMethod static private void testOnLoadRedirectForPeriodicAssessmentWithEvent() {
        User testUser = BTN_TestDataFactory.getActiveUser(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME, null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));

        System.runAs(testUser) {
            Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
            BTN_Event__c event = new BTN_Event__c();
            event.RecordTypeId = BTN_RecordTypeUtils.getRecordTypeCustomEventPeriodicAssessment().Id;
            insert event;
            ApexPages.StandardController stdController = new ApexPages.StandardController(event);
            BTN_EventController controller = new BTN_EventController(stdController);
            BTN_Event__c ev2 = [select RecordType.Name from BTN_Event__c where Id = :event.Id];
            controller.myEvent = ev2;
            //when
            PageReference redirectPage = controller.onLoadAction();
            //then
            System.assert(redirectPage.getUrl().contains(event.Id));
            System.assert(redirectPage.getUrl().contains('?id'));
        }
    }
    testMethod static private void testOnLoadRedirectForPeriodicAssessmentWithoutEvent() {
        User testUser = BTN_TestDataFactory.getActiveUser(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME, null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));

        System.runAs(testUser) {
            Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
            BTN_Event__c event = new BTN_Event__c();
            event.RecordTypeId = BTN_RecordTypeUtils.getRecordTypeCustomEventPeriodicAssessment().Id;
            insert event;
            ApexPages.StandardController stdController = new ApexPages.StandardController(event);
            BTN_EventController controller = new BTN_EventController(stdController);
            BTN_Event__c ev2 = [select Id, RecordType.Name from BTN_Event__c where Id = :event.Id];
            ev2.Id = null;
            controller.myEvent = ev2;
            //when
            PageReference redirectPage = controller.onLoadAction();
            //then
            System.assert(redirectPage != null);
            System.assert(!redirectPage.getUrl().contains(event.Id));
            System.assert(!redirectPage.getUrl().contains('?id'));
        }
    }
    testMethod static private void testOnLoadRedirectWithoutEventForNotPeriodicAssessment() {
        User testUser = BTN_TestDataFactory.getActiveUser(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME, null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));

        System.runAs(testUser) {
            Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
            BTN_Event__c event = new BTN_Event__c();
            event.RecordTypeId = BTN_RecordTypeUtils.getRecordTypeCustomEventGeneral().Id;
            insert event;
            ApexPages.StandardController stdController = new ApexPages.StandardController(event);
            BTN_EventController controller = new BTN_EventController(stdController);
            BTN_Event__c ev2 = [select Id, RecordType.Name from BTN_Event__c where Id = :event.Id];
            //when
            PageReference redirectPage = controller.onLoadAction();
            //then
            System.assert(redirectPage == null);
        }
    }

    testMethod static private void testBeforeSaveValidationForInterview() {
        //given
        User testUser = BTN_TestDataFactory.getActiveUser(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME, null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));

        System.runAs(testUser) {
            prepareInterview();
            PageReference pageTest = Page.BTN_EventPage;
            Test.setCurrentPage(pageTest);
            BTN_CV__c candidate = new BTN_DAO_Candidate().findCandidates().get(0);
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_RECORDTYPE_ID,
                    BTN_RecordTypeUtils.getRecordTypeCustomEventInterview().Id
            );
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_CANDIDATE_ID,
                    candidate.Id
            );
            //when
            ApexPages.StandardController stdController = new ApexPages.StandardController(new BTN_Event__c());
            BTN_EventController controller = new BTN_EventController(stdController);
            controller.myEvent.Location__c = 'Lublin Morwowa';
            controller.refreshAvailableMeetingRooms();
            controller.chosenRoom = 'Salka .NET';
            //then
            Test.startTest();
            Test.setMock(
                    HttpCalloutMock.class,
                    new BTN_GoogleCalendarMock(BTN_GoogleCalendarMock.TEST_CALENDAR_ID)
            );
            controller.beforeSaveValidation();

            Test.stopTest();
            System.assert(controller.shouldSave);
            System.assertEquals(BTN_GoogleCalendarMock.TEST_CALENDAR_ID, controller.calendarId);
        }
    }

    testMethod static private void testBeforeSaveValidationForInterviewWithEvents() {
        //given
        User testUser = BTN_TestDataFactory.getActiveUser(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME, null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));

        System.runAs(testUser) {
            prepareInterview();
            PageReference pageTest = Page.BTN_EventPage;
            Test.setCurrentPage(pageTest);
            BTN_CV__c candidate = new BTN_DAO_Candidate().findCandidates().get(0);
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_RECORDTYPE_ID,
                    BTN_RecordTypeUtils.getRecordTypeCustomEventInterview().Id
            );
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_CANDIDATE_ID,
                    candidate.Id
            );
            //when
            ApexPages.StandardController stdController = new ApexPages.StandardController(new BTN_Event__c());
            BTN_EventController controller = new BTN_EventController(stdController);
            controller.myEvent.Location__c = 'Lublin Morwowa';
            controller.refreshAvailableMeetingRooms();
            controller.chosenRoom = 'Salka PHP';
            //then
            Test.startTest();
            Test.setMock(
                    HttpCalloutMock.class,
                    new BTN_GoogleCalendarMock(BTN_GoogleCalendarMock.TEST_CALENDAR_ID_WITH_EVENTS)
            );
            controller.beforeSaveValidation();

            Test.stopTest();
            System.assertEquals(null, controller.calendarId);
            System.assert(!controller.shouldSave);
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            Boolean messExist = false;
            for (Apexpages.Message msg:msgs) {
                if ((msg.getSummary().contains(Label.Event_Meeting_Room_Warning)) && (msg.getSeverity() == ApexPages.Severity.FATAL)) {
                    messExist = true;
                }

            }
            system.assert(messExist);
        }
    }
    testMethod static private void testBeforeSaveValidationForInterviewWithoutCustomSettings() {
        User testUser = BTN_TestDataFactory.getActiveUser(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME, null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));

        System.runAs(testUser) {
            //given
            User current = BTN_Utils.getCurrentUser();
            current.GoogleTokenExpiresIn__c = 60;
            current.GoogleTokenDate__c = System.now();
            update current;
            PageReference pageTest = Page.BTN_EventPage;
            Test.setCurrentPage(pageTest);
            BTN_CV__c candidate = new BTN_DAO_Candidate().findCandidates().get(0);
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_RECORDTYPE_ID,
                    BTN_RecordTypeUtils.getRecordTypeCustomEventInterview().Id
            );
            pageTest.getParameters().put(
                    BTN_ConstantRepo.URL_PARAM_CANDIDATE_ID,
                    candidate.Id
            );
            //when
            ApexPages.StandardController stdController = new ApexPages.StandardController(new BTN_Event__c());
            BTN_EventController controller = new BTN_EventController(stdController);
            //then
            Test.startTest();
            Test.setMock(
                    HttpCalloutMock.class,
                    new BTN_GoogleCalendarMock(BTN_GoogleCalendarMock.TEST_CALENDAR_ID)
            );
            controller.beforeSaveValidation();

            Test.stopTest();
            System.assert(controller.shouldSave);
            System.assertNotEquals(BTN_GoogleCalendarMock.TEST_CALENDAR_ID, controller.calendarId);
            System.assertEquals(null, controller.save());
        }
    }
    private static List<BTN_Meeting_Room__c> prepareInterview (){
        User current = BTN_Utils.getCurrentUser();
        current.GoogleTokenExpiresIn__c = 60;
        current.GoogleTokenDate__c  = System.now().addDays(-2);
        update current;
        BTN_GoogleCalendarMock.prepareGoogleCalendarSettings();
        List<BTN_Meeting_Room__c> roomList = new List<BTN_Meeting_Room__c>();
        roomList.add(new BTN_Meeting_Room__c(Name='Salka .NET', Active__c=true, CurrencyIsoCode='PLN', Location__c='Lublin Morwowa', Priority__c=7));
        roomList.add(new BTN_Meeting_Room__c(Name='Salka Salesforce', Active__c=true, CurrencyIsoCode='PLN', Location__c='Lublin Morwowa', Priority__c=7));
        roomList.add(new BTN_Meeting_Room__c(Name='Salka Script', Active__c=true, CurrencyIsoCode='PLN', Location__c='Lublin Morwowa', Priority__c=4));
        roomList.add(new BTN_Meeting_Room__c(Name='Salka Eweliny', Active__c=true, CurrencyIsoCode='PLN', Location__c='Lublin Morwowa', Priority__c=2));
        roomList.add(new BTN_Meeting_Room__c(Name='Salka PHP', Active__c=true, CurrencyIsoCode='PLN', Location__c='Lublin Morwowa', Priority__c=1));
        roomList.add(new BTN_Meeting_Room__c(Name='test', Active__c=true, CurrencyIsoCode='PLN', Location__c='Kielce IX Wieków', Priority__c=2));
        roomList.add(new BTN_Meeting_Room__c(Name='Salka C++', Active__c=true, CurrencyIsoCode='PLN', Location__c='Lublin Morwowa', Priority__c=5));
        roomList.add(new BTN_Meeting_Room__c(Name='Salka Java', Active__c=true, CurrencyIsoCode='PLN', Location__c='Lublin Morwowa', Priority__c=6));
        insert roomList;
        return roomList;
    }
}