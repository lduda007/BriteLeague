@isTest
private class BTN_ProductsGenerator_Test {
//
//	@isTest static void testDataFixVer15() {
//		//setup enviroment with products, pricebooks, pricebook entries.
//		BTN_PriceBookGenerator.setupPricebooksWithProductsAndProductEntries();
//		//Add new products 1.4 -> 1.5
//		BTN_ProductsGenerator.generateStandardPriceBookEntries(BTN_ProductsGenerator.generateProducts(BTN_ProductsGenerator.PRODUCTS1_5.keySet()));
//		BTN_ProductsGenerator.generatePriceBookEntries();
//		//add new additional products(2) not related with data setup and without pricebook entries.
//		BTN_TestDataFactory.getProduct();
//		//Update prices
//		BTN_ProductsGenerator.setupAllProductsPrices();
//		for (PricebookEntry itemEntry : [SELECT Id, FixedPrice__c, CurrencyIsoCode, UnitPrice, Product2.Name FROM PricebookEntry WHERE Pricebook2Id = :Test.getStandardPricebookId() AND CurrencyIsoCode = 'PLN' AND Product2.Name IN :BTN_ProductsGenerator.PRODUCTS1_5.keySet()]) {
//			System.assertEquals(BTN_ProductsGenerator.PRODUCTS1_5.get(itemEntry.Product2.Name).hourlyRate, itemEntry.UnitPrice);
//			System.assertEquals(BTN_ProductsGenerator.PRODUCTS1_5.get(itemEntry.Product2.Name).fixedPrice, itemEntry.FixedPrice__c);
//		}
//		// + 1 for unsoqlable Standard Price Book.
//		System.assertEquals((BTN_ProductsGenerator.PRODUCTS1_5.keySet().size() * (([SELECT count() FROM Pricebook2 WHERE IsDeleted = false]) + [SELECT count() FROM CurrencyType WHERE IsActive = true]))
//			, [SELECT Id, FixedPrice__c, CurrencyIsoCode, UnitPrice, Product2.Name FROM PricebookEntry WHERE Product2.Name IN :BTN_ProductsGenerator.PRODUCTS1_5.keySet()].size());
//	}
}