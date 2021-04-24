@isTest
private class BTN_OpportunityViewExtension_Test {
	
	@isTest static void oppoViewConstructorExtensionTest() {
		Id pb = Test.getStandardPricebookId();
		Pricebook2 myPb = BTN_TestDataFactory.getPricebook();
		PageReference pageTest = Page.BTN_OpportunityEditView;
		Test.setCurrentPage(pageTest);
		Opportunity newOppo = BTN_TestDataFactory.getOpportunity(myPb.Id);
		ApexPages.StandardController stdC = new ApexPages.StandardController(
			[SELECT Id, Name, Pricebook2Id, Pricebook2.Name, StageName FROM Opportunity WHERE Id = :newOppo.Id LIMIT 1]);
		BTN_OpportunityViewExtension controller = new BTN_OpportunityViewExtension(stdC);
		System.assert(!controller.getHasProducts());
		controller.mysObject.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
		System.assertEquals(1, controller.getRelatedContactsToAccount().size());
		List<Product2> prod = BTN_TestDataFactory.getProduct();
		List<PricebookEntry> pbEntry = BTN_TestDataFactory.getPriceBookEntries(myPb, prod);
		controller.setPriceBookByAccountCurrency();
		OpportunityLineItem newProductInOppo = new OpportunityLineItem(Quantity = 20, PricebookEntryId = pbEntry.get(0).Id, Hourly_Rate__c = 15, OpportunityId = newOppo.Id, TotalPrice = 1);
		insert newProductInOppo;

		System.assert(controller.getHasProducts());
		controller.setPriceBookByAccountCurrency();
		System.assertEquals([SELECT count() FROM Pricebook2], controller.getpricebookOptionList().size());
		controller.setOppoCurrency();
		controller.probStages = controller.probStages;
		controller.probStages = controller.probStages;
		controller.setOpportunityProbability();
		Account acc = [SELECT Id FROM Account LIMIT 1];
		controller.setPriceBookByAccountCurrency();
	}
}