/**
 * @author Mateusz Przywara
 * @date   2016-07-01
 * @description BTN_SendEmailPageTemplateController_Test test rendering of template for SendEmailPage.
 */
@isTest
private class BTN_SendEmailPageTemplateController_Test {
    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description Prepare data for tests
    */
    @testSetup static void createDataStructure() {
        //BTN_TestDataFactory.createDataStructureForBriteRM();
        Account britenetAccount = BTN_TestDataFactory.getBriteNetAccount();
        Opportunity oppo = BTN_TestDataFactory.getOpportunity(Test.getStandardPricebookId());
        BTN_TestDataFactory.getAutoResourceRequest(oppo);
        User user = BTN_TestDataFactory.getCommunityUser();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Test if page can be rendered and the page controller has required Contact data.
     * @return void
     */
    @isTest static void testIfPageRendersWithoutErrors() {
        BTN_ResourceRequest__c resreqT = new BTN_DAO_ResourceRequest().findAutoResourceRequests().get(0);
        User user = BTN_TestDataFactory.getActiveExternalSiteResourceRequestUser();
        Contact hrContact = BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .withAccount(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id)
                .withEmail('hruser' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL)
                .withFirstName('Donald')
                .withLastName('Tusk')
                .get();
        insert hrContact;
        //System.RunAs(user) {
            PageReference pageTest = Page.BTN_SendEmailPageTemplate;
            pageTest.getParameters().put(BTN_SendEmailController.ID_PARAMETER_NAME, resreqT.Id);
            pageTest.getParameters().put(BTN_ConstantRepo.CONTACT_PARAMETER_NAME, hrContact.Id);
            Test.setCurrentPage(pageTest);
            ApexPages.StandardController stdC = new ApexPages.StandardController(resreqT);
            BTN_SendEmailPageTemplateController controller = new BTN_SendEmailPageTemplateController(stdC);
            System.assertEquals(hrContact.Id, controller.contactPerson.Id);
            System.assertEquals(hrContact.FirstName, controller.contactPerson.FirstName);
        //}
    }
}