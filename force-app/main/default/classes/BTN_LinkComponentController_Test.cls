/**
 * @author Mateusz Przywara
 * @date   2016-07-15
 * @description Test access to Link Controller and generation of link
*/
@isTest
private class BTN_LinkComponentController_Test {
    private static String ACCOUNT = 'Account';

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description Prepare data for tests
     */
    @testSetup static void createDataStructure() {
        BTN_TestDataFactory.getNewBssDummyConnections();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description test link generation as Resource Manager
    */
    @isTest static void testIfControllerBuildLinkCorrectlyAsRMUser() {
        System.RunAs(BTN_TestDataFactory.getActiveResourceManagerUser()) {
            Account acc = new Account(
                    Name = BTN_ConstantRepo.BRITENET_ACCOUNT_NAME,
                    CurrencyIsoCode = BTN_TestDataFactory.TESTCURRENCY,
                    RecordTypeId = BTN_RecordTypeUtils.getRecordTypeAccountPrivateSector().Id
            );
            insert acc;

            BTN_LinkComponentController controller = new BTN_LinkComponentController();
            Opportunity oppo = BTN_TestDataFactory.getOpportunity(Test.getStandardPricebookId(), acc.Id);
            controller.mysObject = oppo.Id;
            controller.mysObject = controller.mysObject; //getters coverage
            controller.mysObjectName = oppo.Name;
            controller.mysObjectName = controller.mysObjectName;

            System.assertEquals(
                    System.URL.getSalesforceBaseUrl().getHost().remove('-api') + '/' + oppo.Id, controller.getLink());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description test link generation as Sales User
    */
    @isTest static void testIfControllerBuildLinkCorrectlyAsSalesUser() {
        System.RunAs(BTN_TestDataFactory.getActiveSalesUser()) {
            Account acc = new Account(
                    Name = BTN_ConstantRepo.BRITENET_ACCOUNT_NAME,
                    CurrencyIsoCode = BTN_TestDataFactory.TESTCURRENCY,
                    RecordTypeId = BTN_RecordTypeUtils.getRecordTypeAccountPrivateSector().Id
            );
            insert acc;

            BTN_LinkComponentController controller = new BTN_LinkComponentController();
            Opportunity oppo = BTN_TestDataFactory.getOpportunity(Test.getStandardPricebookId(), acc.Id);
            controller.mysObject = oppo.Id;
            controller.mysObject = controller.mysObject; //getters coverage
            controller.mysObjectName = oppo.Name;
            controller.mysObjectName = controller.mysObjectName;

            System.assertEquals(
                    System.URL.getSalesforceBaseUrl().getHost().remove('-api') + '/' + oppo.Id, controller.getLink());
        }
    }
}