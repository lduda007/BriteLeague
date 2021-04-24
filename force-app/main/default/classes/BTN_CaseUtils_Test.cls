/**
 * @author Mateusz Przywara
 * @date   2016-08-31
 * @description BTN_CaseUtils_Test Test Class for Case Utilities
*/
@isTest
private class BTN_CaseUtils_Test {
    private static String TESTPROJECTROLE = 'Tester';
    private static String TESTCITY = 'Kozyrevsk';
    private static String TESTSTREET = 'Unnamed Road';
    private static String TESTZIPCODE = '684405';
    private static String TESTEMAIL = '2' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL;

    /**
     * @author Mateusz Przywara
     * @date   2016-08-31
     * @description Prepare data for tests
    */
    @testSetup static void createDataStructure() {
        BTN_TestDataFactory.getNewBssDummyConnections();
        Account acc = BTN_TestDataFactory.getBriteNetAccount();
        BTN_TestDataFactory.getRequestorInternalContact(acc.Id);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-31
     * @description  Insert Internal
     * Onboarding Case and run Service method to Retrieve Response from Britesheet
     */
    @isTest
    static void testMethodCreatingContactBasedOnMapAndBSUserId() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Id britenetAccountId = new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id;
            Contact testContact = new BTN_DAO_Contact().findInternals().get(0);
            Contact testLeaderContact =
                    BTN_TestDataFactory.getRequestorInternalContact(
                            britenetAccountId
                    );
            Contact testGuardianContact =
                    BTN_TestDataFactory.getRequestorInternalContact(
                            britenetAccountId
                    );
            Case testCase = BTN_TestDataFactory.getInternalOnboardingCase(testLeaderContact.Id);
            // Method creates Internal Contact based on Map - created from Case data.
            BTN_CaseUtils.updateInternalContactBSExternalId(
                    testContact.Id,
                    BTN_BSS_Mockup.NEW_BS_USER_RESPONSE_BS_USER_ID,
                    testCase
            );
            System.assertNotEquals(
                    null,
                    new BTN_DAO_Contact().findContacByBSExternalId(BTN_BSS_Mockup.NEW_BS_USER_RESPONSE_BS_USER_ID)
            );
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-31
     * @description  Insert Internal
     * Onboarding Case and run Service method to Retrieve Response from Britesheet
     */
    @isTest
    static void testUpdateCaseContactInfo() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Case testCase = BTN_TestDataFactory.getInternalOnboardingCase();
            Contact con1 = BTN_TestDataFactory.getRequestorInternalContact(
                    new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id
            );
            System.assertEquals(null, testCase.ContactId);
            BTN_CaseUtils.updateCaseContactInfo(
                    testCase,
                    con1.Id
            );
            System.assertNotEquals(null, testCase.ContactId);
        }
    }
}