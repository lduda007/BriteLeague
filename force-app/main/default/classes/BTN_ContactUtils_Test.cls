/**
 * @author Mateusz Przywara
 * @date   2016-08-19
 * @description BTN_ContactUtils_Test test utils class BTN_ContactUtils_Test
*/
@isTest
private class BTN_ContactUtils_Test {
    private static BTN_ContactUtils btnContactUtils = new BTN_ContactUtils();
    private static BTN_DAO_Contact daoContact = new BTN_DAO_Contact();
    private static final String TEST_SKILLS = 'liczenie na liczydle i .Net';
    private static final String TEST_SKILLS2 = 'liczenie monet do pięć';

    /**
     * @author Mateusz Przywara
     * @date   2016-10-12
     * @description Prepare data for tests
    */
    @testSetup static void createDataStructure() {
        // prepare Group for HR
        BTN_TestDataFactory.getHRCollaborationGroup();
        Account britenetAcc = BTN_TestDataFactory.getBriteNetAccount();
        Contact internalCont = BTN_TestDataFactory.getRecruitContactWithSkills(britenetAcc.Id, TEST_SKILLS);
    }

    @isTest
    public static void testCovarage(){
        // given
        BTN_ContactUtils.MAP_PROJECT_ROLE_DESC_BY_ID.isEmpty();
        Contact contact =
                BTN_ContactBuilderHelper.buildWithInternalRecordType()
                        .withEmail('a' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL)
                        .get();
        
        Test.startTest();
            BTN_ContactUtils.addContact(contact);
        Test.stopTest();
        
        System.assertEquals(1,daoContact.findContacByEmail(contact.Email).size());
    }


    /**
     * @author Mateusz Przywara
     * @date   2016-10-24
     * @description testSearchFragmentInsert Insert Search Fragments
    */
    @isTest
    public static void testSearchFragmentInsertAndDelete() {
        Contact testContact = BTN_TestDataFactory.getRecruitContactWithSkills(
                new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id,
                TEST_SKILLS
        );
        List<Contact> contacts = new List<Contact>{testContact};
        Test.startTest();
        testContact.Skills__c = BTN_ContactUtils_Test.TEST_SKILLS2;
        update testContact;
        Test.stopTest();
        System.assert(
                !(new BTN_DAO_SearchFragment().findSearchFragmentsForContact(new Set<Id>{testContact.Id})).isEmpty()
        );
        BTN_ContactUtils.deleteSearchFragmentsForContacts(new Set<Id>{testContact.Id});
    }
}