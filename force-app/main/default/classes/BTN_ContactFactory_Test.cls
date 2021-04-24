@isTest
private class BTN_ContactFactory_Test {

    @testSetup static void createDataStructure() {
        BTN_TestDataFactory.getHRCollaborationGroup();
        BTN_TestDataFactory.getBriteNetAccount();
    }

    @isTest
    static void testCreateContactFromBSUser() {
        BTN_BSS_DTO.User userFromBS = createValidBSUser();

        Test.startTest();
        Contact result = BTN_ContactFactory.createContactFromBSUser(userFromBS);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(userFromBS.user_id, result.BSexternalId__c);
    }

    @isTest
    static void testCreateContactsFromBSUsers() {
        List<BTN_BSS_DTO.User> usersFromBS = new List<BTN_BSS_DTO.User>{
                createValidBSUser(), createValidBSUser(), createValidBSUser()
        };

        Test.startTest();
        List<Contact> result = BTN_ContactFactory.createContactsFromBSUsers(usersFromBS);
        Test.stopTest();

        System.assert(!result.isEmpty());
    }

    @isTest
    static void testCreateContactFromBSUserWithLeaderAndGuardian() {
        List<BTN_BSS_DTO.User> usersFromBS = new List<BTN_BSS_DTO.User>{
                createValidBSUser(), createInvalidBSUser()
        };
        Contact guardian = BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .withFirstName('Test')
                .withLastName('Guardian')
                .withEmail(BTN_TestDataFactory.getRandomEmail())
                .get();
        guardian.BSexternalId__c = usersFromBS[0].user_guardian_id;
        insert guardian;

        Contact leader = BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .withFirstName('Test')
                .withLastName('Leader')
                .withEmail(BTN_TestDataFactory.getRandomEmail())
                .get();
        leader.BSexternalId__c = usersFromBS[0].user_leader_id;
        insert leader;

        Test.startTest();
        List<Contact> result = BTN_ContactFactory.createContactsFromBSUsers(usersFromBS);
        Test.stopTest();

        System.assertEquals(guardian.Id, result[0].Guardian__c);
        System.assertEquals(leader.Id, result[0].Leader__c);
    }

    private static BTN_BSS_DTO.User createValidBSUser() {
        BTN_BSS_DTO.User userFromBS = new BTN_BSS_DTO.User();
        userFromBS.user_id = BTN_TestDataFactory.getGeneratedInteger(10, 2000);
        userFromBS.user_fname = BTN_TestDataFactory.getGeneratedString(6);
        userFromBS.user_lname = BTN_TestDataFactory.getGeneratedString(6);
        userFromBS.user_phone = BTN_TestDataFactory.getRandomPhone();
        userFromBS.user_mail = BTN_TestDataFactory.getRandomEmail();
        userFromBS.user_location = 'Morwowa';
        userFromBS.user_join_date = BTN_TestDataFactory.getBSSRandomDate();
        userFromBS.user_end_date = BTN_TestDataFactory.getBSSRandomDate();
        userFromBS.user_lastatwork_date = BTN_TestDataFactory.getBSSRandomDate();
        userFromBS.user_leader_id = BTN_TestDataFactory.getGeneratedInteger(10, 2000);
        userFromBS.user_guardian_id = BTN_TestDataFactory.getGeneratedInteger(10, 2000);
        userFromBS.projectrole_desc = BTN_TestDataFactory.getGeneratedString(200);
        userFromBS.user_deleted = false;

        return userFromBs;
    }

    private static BTN_BSS_DTO.User createInvalidBSUser() {
        BTN_BSS_DTO.User userFromBS = new BTN_BSS_DTO.User();
        userFromBS.user_id = BTN_TestDataFactory.getGeneratedInteger(10, 2000);
        userFromBS.user_fname = BTN_TestDataFactory.getGeneratedString(6);
        userFromBS.user_lname = BTN_TestDataFactory.getGeneratedString(6);
        userFromBS.user_phone = BTN_TestDataFactory.getRandomPhone();
        userFromBS.user_mail = BTN_TestDataFactory.getRandomEmail();
        userFromBS.user_location = 'Morwowa';
        userFromBS.user_join_date = '2017/03/02';
        userFromBS.user_end_date = '2017.03.21';
        userFromBS.user_lastatwork_date = '21-12-2014';
        userFromBS.user_leader_id = null;
        userFromBS.user_guardian_id = BTN_TestDataFactory.getGeneratedInteger(10, 2000);
        userFromBS.projectrole_desc = BTN_TestDataFactory.getGeneratedString(200);
        userFromBS.user_deleted = false;

        return userFromBs;
    }

}