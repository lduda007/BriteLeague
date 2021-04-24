@isTest
private class BTN_ProductSelectionWrapper_Test {
	
	@isTest static void productSelectionWrapperContructionTester() {
		Id pbId = Test.getStandardPricebookId();
		Product2 prod = new Product2(ProductCode = 'amelinium', Name = 'tmpTestProduct2', Level__c = 'Junior', Family = 'Developer', Technology__c = 'Android');
		insert prod;
		PricebookEntry pbEntry = new PricebookEntry(CurrencyIsoCode = 'PLN', UnitPrice = 50, FixedPrice__c = 0, Product2Id = prod.Id, Pricebook2Id = pbId, IsActive = true);
		insert pbEntry;

		BTN_ProductSelectionWrapper wrappedProduct2 = new BTN_ProductSelectionWrapper(prod
			, 25, 0, pbEntry.Id, 'PLN', 1);
		System.assert(true);
	}
}