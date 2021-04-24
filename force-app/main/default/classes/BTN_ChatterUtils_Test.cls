/**
 * @author Mateusz Przywara
 * @date   2016-10-12
 * @description BTN_ChatterUtils_Test test class for Chatter Utility methods
*/
@isTest
private class BTN_ChatterUtils_Test {
    private static String TEST_STRING = 'dzordz';
    private static String FIELD_SET_ERROR = 'FIELD SET ON CONTACT EMPTY';
    private static final String PHONE_TEST_VALUE = '0700';
    private static final String PHONE_TEST_VALUE_2 = '0800';
    private static final String CONTACT_TEST_FIELD_API_NAME = 'FirstName';
    private static final String CONTACT_TEST_FIELD_NEW_VALUE = 'krasnal team';
    private static String TEST_TEXT = 'TEST_REICHSNER';

    /**
     * @author Mateusz Przywara
     * @date   2016-10-12
     * @description Prepare data for tests
    */
    @testSetup
    static void createDataStructure() {

        System.RunAs(BTN_Utils.getCurrentUser()) {
            // prepare Group for HR
            BTN_TestDataFactory.getHRCollaborationGroup();
            Account britenetAcc = BTN_TestDataFactory.getBriteNetAccount();
            Contact internalCont = BTN_TestDataFactory.getRequestorInternalContact(britenetAcc.Id);
            BTN_ResourceRequest__c rr = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().save();
            rr.Resource_Manager__c = internalCont.Id;
            update rr;
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-12
     * @description Method test insertion of Feed Items with Event
    */
    @isTest
    static void testPostOnContactAndRelatedCandidates() {
        //internal Contact on his feed msg will be posted
        Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
        // Resource Request required to connect Candidates to Contact
        BTN_ResourceRequest__c resourceRequest =
                (BTN_ResourceRequest__c) new BTN_DAO_ResourceRequest().findSObjects().get(0);
        BTN_Event__c event;

        //Prepare user for this test
        User currUser = getCommunityUser(internalContact.BSexternalId__c+1);
        insert currUser;
        //assign HR permset
        BTN_PermissionSetUtils.assignPermissionSetToUser(BTN_ConstantRepo.PERM_SET_NAME_HR, currUser);

        //Share ResourceRequest - required for Candidate
        insert new BTN_ResourceRequest__Share(
                UserOrGroupId = currUser.Id,
                RowCause = BTN_ResourceRequest__Share.RowCause.Requestor__c,
                ParentId = resourceRequest.Id,
                AccessLevel = 'Edit'
        );

        // Candidates
        BTN_CV__c dummyCandidate1;
        BTN_CV__c dummyCandidate2;

        System.RunAs(currUser) {
            Test.startTest();
                //Candidates are private
                dummyCandidate1 = BTN_TestDataFactory.getCV(resourceRequest.Id, internalContact.Id);
                event = BTN_TestDataFactory.getGeneralEvent(internalContact.Id, true);
            Test.stopTest();
        }

        System.assertEquals(1, [SELECT count() FROM FeedItem WHERE ParentId = :internalContact.Id]);
        System.assertEquals(1, [SELECT count() FROM FeedItem WHERE ParentId = :dummyCandidate1.Id]);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-17
     * @description Test processContactInsertsToFeedItems Method from chatter utils - post info on community Chatter
     * feed for new Recruits
    */
    @isTest
    static void testProcessContactInsertsToFeedItemsMethod() {
        Contact recruit = new BTN_ContactBuilderHelper()
                .buildWithRecruitRecordType()
                .buildWithDefaultAddress()
                .withLastName(TEST_STRING)
                .withFirstName(TEST_STRING)
                .withEmail(TEST_STRING + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL)
                .withAccount(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id)
                                .save();
        Test.startTest();
            System.assertEquals(
                1,
                BTN_ChatterUtils.postInsertsOnHumanResourcesGroup(
                        new Map<Id, Contact>{recruit.Id => recruit},
                        CONTACT_TEST_FIELD_API_NAME
                ).size());
        Test.stopTest();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-17
     * @description Test processContactUpdatesToFeedItems Method from chatter utils - post info on community Chatter
     * feed for updated Recruits
    */
    @isTest
    static void testProcessContactUpdatesToFeedItemsMethod() {
        Contact recruitTestContactOld =
                        new BTN_ContactBuilderHelper()
                                .buildWithRecruitRecordType()
                                .buildWithDefaultAddress()
                                .withLastName(TEST_STRING)
                                .withEmail(TEST_STRING + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL)
                                .withAccount(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id)
                                .save();
        // Cloning to stay with 2 same sObject with differenct reference.
        Contact recruitTestContactNew = recruitTestContactOld.clone();
        // Add Id
        recruitTestContactNew.Id = recruitTestContactOld.Id;
        // Create list with ref. to records before changes
        List<Contact> oldContacts = new List<Contact>{
                recruitTestContactOld
        };
        // Create Map with ref. to records after changes
        Map<Id, Contact> newContactMap = new Map<Id, Contact>(new List<Contact>{recruitTestContactNew});
        //No Selected field changes do standard update info
        Id feedItemId = BTN_ChatterUtils.postChangesOnHumanResourcesGroup(
                oldContacts,
                newContactMap,
                new Set<String> {CONTACT_TEST_FIELD_API_NAME},
                CONTACT_TEST_FIELD_API_NAME
        ).get(0).getId();
        System.assert([SELECT Body FROM FeedItem WHERE Id = :feedItemId].Body.contains(System.Label.hasBeenUpdated));
        // change selected field.
        recruitTestContactNew.put(
                CONTACT_TEST_FIELD_API_NAME,
                CONTACT_TEST_FIELD_NEW_VALUE
        );
        feedItemId = BTN_ChatterUtils.postChangesOnHumanResourcesGroup(
                oldContacts,
                newContactMap,
                new Set<String> {CONTACT_TEST_FIELD_API_NAME},
                CONTACT_TEST_FIELD_API_NAME
        ).get(0).getId();
        System.assert([SELECT Body FROM FeedItem WHERE Id = :feedItemId].Body.contains(CONTACT_TEST_FIELD_NEW_VALUE));
    }


    @isTest
    static void shouldNotChangeStatusWhenInterviewCreatedFromContactPage() {
        //internal Contact on his feed msg will be posted
        Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
        //Prepare user for this test
        User currUser = getCommunityUser(internalContact.BSexternalId__c+1);
        insert currUser;
        // Resource Request required to connect Candidates to Contact
        BTN_ResourceRequest__c resourceRequest = prepareResourceRequest(currUser);
        //Event
        BTN_Event__c event;
        // Candidates
        BTN_CV__c dummyCandidate;

        System.RunAs(currUser) {
            Test.startTest();
                //Candidates are private
                dummyCandidate = BTN_TestDataFactory.getCV(resourceRequest.Id, internalContact.Id);

                System.assert([SELECT Id, Status__c FROM  BTN_CV__c where Id = :dummyCandidate.Id].Status__c == 'Open');
                event = getInterviewWithCandidate(internalContact.Id, true,null);
                System.assert([SELECT Id,Status__c FROM  BTN_CV__c where Id = :dummyCandidate.Id].Status__c == 'Open');
            Test.stopTest();
        }
    }
    @isTest
    static void shouldNotChangeStatusWhenGeneralCreated() {
        //internal Contact on his feed msg will be posted
        Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
        //Prepare user for this test
        User currUser = getCommunityUser(internalContact.BSexternalId__c+1);
        insert currUser;
        // Resource Request required to connect Candidates to Contact
        BTN_ResourceRequest__c resourceRequest = prepareResourceRequest(currUser);
        //Event
        BTN_Event__c event;
        // Candidates
        BTN_CV__c dummyCandidate;

        System.RunAs(currUser) {
            Test.startTest();
                //Candidates are private
                dummyCandidate = BTN_TestDataFactory.getCV(resourceRequest.Id, internalContact.Id);
                System.assert([SELECT Id, Status__c FROM  BTN_CV__c where Id = :dummyCandidate.Id].Status__c == 'Open');
                event = getGeneralEvent(internalContact.Id, true);
                System.assert([SELECT Id,Status__c FROM  BTN_CV__c where Id = :dummyCandidate.Id].Status__c == 'Open');
            Test.stopTest();
        }

    }
    @isTest
    static void shouldNotChangeStatusWhenGeneralCreatedWithCandidate() {
        //internal Contact on his feed msg will be posted
        Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
        //Prepare user for this test
        User currUser = getCommunityUser(internalContact.BSexternalId__c+1);
        insert currUser;
        // Resource Request required to connect Candidates to Contact
        BTN_ResourceRequest__c resourceRequest = prepareResourceRequest(currUser);
        //Event
        BTN_Event__c event;
        // Candidates
        BTN_CV__c dummyCandidate;

        System.RunAs(currUser) {
            Test.startTest();
            //Candidates are private
            dummyCandidate = BTN_TestDataFactory.getCV(resourceRequest.Id, internalContact.Id);
            System.assert([SELECT Id, Status__c FROM  BTN_CV__c where Id = :dummyCandidate.Id].Status__c == 'Open');
            event = getGeneralEvent(internalContact.Id, true, dummyCandidate.Id );
            System.assert([SELECT Id,Status__c FROM  BTN_CV__c where Id = :dummyCandidate.Id].Status__c == 'Open');
            Test.stopTest();
        }

    }
    @isTest
    static void shouldChangeStatusWhenInterviewCreatedFromCandidatePage() {
        //internal Contact on his feed msg will be posted
        Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
        //Prepare user for this test
        User currUser = getCommunityUser(internalContact.BSexternalId__c+1);
        insert currUser;
        // Resource Request required to connect Candidates to Contact
        BTN_ResourceRequest__c resourceRequest = prepareResourceRequest(currUser);
        //Event
        BTN_Event__c event;
        // Candidates
        BTN_CV__c dummyCandidate;

        System.RunAs(currUser) {
            Test.startTest();
                //Candidates are private
                dummyCandidate = BTN_TestDataFactory.getCV(resourceRequest.Id, internalContact.Id);
                System.assert([SELECT Id, Status__c FROM  BTN_CV__c where Id = :dummyCandidate.Id].Status__c == 'Open');
                //when
                event = getInterviewWithCandidate(internalContact.Id, true,dummyCandidate.Id);
                //then
                System.assert([SELECT Id, Name, Candidate__c FROM  BTN_Event__c where Id = :event.Id].Candidate__c != null);
                System.assert([SELECT Id,Status__c FROM  BTN_CV__c where Id = :dummyCandidate.Id].Status__c == 'Interview-in-progress');
            Test.stopTest();
        }
    }

    @isTest
    static void shouldAddLinkAtTheEndWhenObjectInSetting() {
        BTN_BriteCRM_settings__c setting = new BTN_BriteCRM_settings__c();
        setting.Name = 'ObjectsWithChatterLink';
        setting.Value__c = 'Contact';
        insert setting;
        Contact recruitTestContactOld =
        new BTN_ContactBuilderHelper()
        .buildWithRecruitRecordType()
        .buildWithDefaultAddress()
        .withLastName(TEST_STRING)
        .withEmail(TEST_STRING + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL)
        .withAccount(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id)
        .save();
        // Cloning to stay with 2 same sObject with differenct reference.
        Contact recruitTestContactNew = recruitTestContactOld.clone();
        // Add Id
        recruitTestContactNew.Id = recruitTestContactOld.Id;
        // Create list with ref. to records before changes
        List<Contact> oldContacts = new List<Contact>{
                recruitTestContactOld
        };
        // Create Map with ref. to records after changes
        Map<Id, Contact> newContactMap = new Map<Id, Contact>(new List<Contact>{recruitTestContactNew});
        //No Selected field changes do standard update info
        Id feedItemId = BTN_ChatterUtils.postChangesOnHumanResourcesGroup(
                oldContacts,
                newContactMap,
                new Set<String> {CONTACT_TEST_FIELD_API_NAME},
                CONTACT_TEST_FIELD_API_NAME
        ).get(0).getId();
        FeedItem fItem = [SELECT Body FROM FeedItem WHERE Id = :feedItemId];
        System.assert(fItem.Body.contains(System.Label.hasBeenUpdated));
        System.assert(fItem.Body.contains(recruitTestContactNew.Id));
    }
    @isTest
    static void shouldNotAddLinkAtTheEndWhenObjectNotInSetting() {
        BTN_BriteCRM_settings__c setting = new BTN_BriteCRM_settings__c();
        setting.Name = 'ObjectsWithChatterLink';
        setting.Value__c = 'Not Contact';
        insert setting;
        Contact recruitTestContactOld =
        new BTN_ContactBuilderHelper()
        .buildWithRecruitRecordType()
        .buildWithDefaultAddress()
        .withLastName(TEST_STRING)
        .withEmail(TEST_STRING + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL)
        .withAccount(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id)
        .save();
        // Cloning to stay with 2 same sObject with differenct reference.
        Contact recruitTestContactNew = recruitTestContactOld.clone();
        // Add Id
        recruitTestContactNew.Id = recruitTestContactOld.Id;
        // Create list with ref. to records before changes
        List<Contact> oldContacts = new List<Contact>{
                recruitTestContactOld
        };
        // Create Map with ref. to records after changes
        Map<Id, Contact> newContactMap = new Map<Id, Contact>(new List<Contact>{recruitTestContactNew});
        //No Selected field changes do standard update info
        Id feedItemId = BTN_ChatterUtils.postChangesOnHumanResourcesGroup(
                oldContacts,
                newContactMap,
                new Set<String> {CONTACT_TEST_FIELD_API_NAME},
                CONTACT_TEST_FIELD_API_NAME
        ).get(0).getId();
        FeedItem fItem = [SELECT Body FROM FeedItem WHERE Id = :feedItemId];
        System.assert(fItem.Body.contains(System.Label.hasBeenUpdated));
        System.assert(!fItem.Body.contains(recruitTestContactNew.Id));
    }
    private static User  getCommunityUser(Decimal bSexternalId ){
        Contact relatedContact =  BTN_TestDataFactory.getRequestorInternalContact(
                new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id,(Integer)bSexternalId);
        return BTN_TestDataFactory.getCommunityUser(relatedContact.Id, relatedContact.Email);
    }
    private static BTN_ResourceRequest__c  prepareResourceRequest(User currUser ){

        // Resource Request required to connect Candidates to Contact
        BTN_ResourceRequest__c resourceRequest =
                (BTN_ResourceRequest__c) new BTN_DAO_ResourceRequest().findSObjects().get(0);

        //assign HR permset
        BTN_PermissionSetUtils.assignPermissionSetToUser(BTN_ConstantRepo.PERM_SET_NAME_HR, currUser);
        //Share ResourceRequest - required for Candidate
        insert new BTN_ResourceRequest__Share(
                UserOrGroupId = currUser.Id,
                RowCause = BTN_ResourceRequest__Share.RowCause.Requestor__c,
                ParentId = resourceRequest.Id,
                AccessLevel = 'Edit'
        );
        return resourceRequest;

    }
    public static BTN_Event__c getGeneralEvent(Id contactId, Boolean postOnCandidates) {
        return getGeneralEvent(contactId, postOnCandidates,null );
    }
    public static BTN_Event__c getGeneralEvent(Id contactId, Boolean postOnCandidates,Id candidateId ) {
        BTN_Event__c result = creatEvent(contactId,postOnCandidates);
        result.RecordTypeId = BTN_RecordTypeUtils.getRecordTypeCustomEventGeneral().Id;
        result.Candidate__c = candidateId;
        insert result;
        return result;
    }
    public static BTN_Event__c getInterviewWithCandidate(Id contactId, Boolean postOnCandidates, Id candidateId) {
        BTN_Event__c result = creatEvent(contactId,postOnCandidates);
        result.RecordTypeId = BTN_RecordTypeUtils.getRecordTypeCustomEventInterview().Id;
        result.Candidate__c = candidateId;
        insert result;
        return result;
    }
    private static BTN_Event__c creatEvent(Id contactId,Boolean postOnCandidates) {
        return new BTN_Event__c( Interviewed__c = contactId, Description__c = TEST_TEXT, PostOnRelatedCandidates__c = postOnCandidates);
    }
}