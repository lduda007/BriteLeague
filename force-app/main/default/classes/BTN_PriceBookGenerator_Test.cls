@isTest (SeeAllData = false)
private class BTN_PriceBookGenerator_Test {
//	@isTest static void testPricebookEntryAndPricebookEntriesGenerator() {
//		List<String> testPbs = BTN_PriceBookGenerator.setupPricebooksWithProductsAndProductEntries();
//		System.assert([SELECT count() FROM Pricebook2 WHERE IsActive = true LIMIT 1] > 0);
//		System.assert([SELECT count() FROM Product2 WHERE IsActive = true LIMIT 1] > 0);
//
//		for (Pricebook2 item : [SELECT Id, (SELECT Id FROM PricebookEntries LIMIT 1) FROM Pricebook2 WHERE IsActive = true]) {
//			System.assert(!item.PricebookEntries.isEmpty());
//		}
//		BTN_ProductsGenerator.removePriceBookEntries(testPbs);
//		System.assert([SELECT Id FROM PricebookEntry WHERE PriceBook2Id IN :testPbs].isEmpty());
//	}
//
//	@isTest static void testRemoveMethods() {
//		BTN_ProductsGenerator.generateProducts();
//		System.assert(![SELECT Id FROM Product2 LIMIT 1].isEmpty());
//		delete [SELECT Id FROM Opportunity];
//		BTN_ProductsGenerator.removeProducts();
//		System.assert([SELECT Id FROM Product2 LIMIT 1].isEmpty());
//		BTN_PriceBookGenerator.generatePricebooks(BTN_PriceBookGenerator.currencySet);
//		BTN_PriceBookGenerator.removePriceBooks();
//		System.assert([SELECT Id FROM Pricebook2 WHERE IsStandard = false LIMIT 1].isEmpty());
//	}
}