/**
 * @author Mateusz Przywara
 * @date   2016-09-06
 * @description BTN_CaseRecordTypeSelectionController Test for Controller for Page with Record Type dropdown list.
*/
@isTest
private class BTN_CaseRTSelectionController_Test {
    private static final String TEST_RETURL = 'exampleretURL';
    private static final String TEST_RETURL_PARAM = 'retURL';
    /**
     * @author Mateusz Przywara
     * @date   2016-09-07
     * @description testControllerConstructor
    */
    testMethod static private void testControllerConstructor() {
        Account acc = BTN_TestDataFactory.getBriteNetAccount();
        System.RunAs(new BTN_DAO_User().findTestUserByProfileName(BTN_ConstantRepo.RESOURCE_MANAGER_PROFILE_NAME)) {
            PageReference pageTest = Page.BTN_CaseRecordTypeSelectionPage;
            Test.setCurrentPage(pageTest);
            pageTest.getParameters().put(TEST_RETURL_PARAM, TEST_RETURL);
            BTN_CaseRecordTypeSelectionController controller = new BTN_CaseRecordTypeSelectionController();
            controller.selectedRecordType = BTN_RecordTypeUtils.getRecordTypeCaseInternalOnBoarding().Id;
            System.assertNotEquals(null, controller.selectedRecordType);
            controller.getCaseRecordTypes();
            System.assertNotEquals(null, controller.recordTypeMap);
            controller.redirectToNewCaseForm();
            System.assertEquals(TEST_RETURL, controller.getRetURL());
            System.assertNotEquals(null, controller.cancel());
        }
    }
}