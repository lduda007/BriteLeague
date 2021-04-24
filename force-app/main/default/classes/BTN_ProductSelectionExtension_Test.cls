@isTest
private class BTN_ProductSelectionExtension_Test {
//
//	@isTest static void productListSetConAndGettersSettersTester() {
//		BTN_TestDataFactory.getPricebook();
//		Id pbId = Test.getStandardPricebookId();
//		Pricebook2 myPB = BTN_TestDataFactory.getPricebook();
//		List<Product2> prods = BTN_TestDataFactory.getProduct();
//		BTN_TestDataFactory.getPriceBookEntries(myPB, prods);
//		Opportunity newOppo = BTN_TestDataFactory.getOpportunity(myPB.Id);
//
//		BTN_TestDataFactory.getUtilCS();
//		PageReference pageTest = Page.BTN_OpportunityProductEditAll;
//		Test.setCurrentPage(pageTest);
//		ApexPages.StandardController stdC = new ApexPages.StandardController(newOppo);
//		BTN_ProductSelectionExtension controller = new BTN_ProductSelectionExtension(stdC);
//		System.assertEquals(null, controller.goToStep2());
//		controller.first();
//		controller.last();
//		controller.previous();
//		controller.next();
//		controller.nullPagination();
//		controller.checkedItem = controller.checkedItem;
//		controller.productsOnView = controller.productsOnView;
//		controller.selectedProductsOnView = controller.selectedProductsOnView;
//		controller.changedLineItem = controller.changedLineItem;
//		controller.hasNext = controller.hasNext;
//		controller.hasPrevious = controller.hasPrevious;
//		controller.pageNumber = controller.pageNumber;
//		controller.priceItem = controller.priceItem;
//		controller.mysObject.Pricebook2Id = null;
//		controller.getStandardPricebook();
//		System.assertEquals('SELECT Id, Name, Description, Level__c, ProductCode, Family, Technology__c,(SELECT UnitPrice, FixedPrice__c, CurrencyIsoCode FROM PricebookEntries WHERE Pricebook2Id = \''+ controller.standardPricebook +'\') FROM Product2 WHERE Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook AND IsActive = true) ORDER BY Name'
//			, controller.getbasicQuery());
//		System.assertEquals(String.format(System.Label.AddProductsFormSec, new String[]{String.valueOf(newOppo.Name), newOppo.Pricebook2.Name})
//			, controller.getdynTitle());
//		System.assertEquals('/'+newOppo.Id, controller.cancelToOppo().getURL());
//		System.assertEquals('/apex/BTN_ProductSelectionListView?addTo=' + newOppo.Id + '&id='+ newOppo.Id, controller.cancelFromStep2().getURL());
//	}
//
//	@isTest static void productListConstructorTester() {
//		List<BTN_ProductSelectionWrapper> products;
//		List<BTN_ProductSelectionWrapper> selectedProductsToAdd;
//		List<BTN_OpportunityLineItemWrapper> oppoProducts;
//
//		BTN_TestDataFactory.getPricebook();
//		Id pbId = Test.getStandardPricebookId();
//		Pricebook2 myPB = BTN_TestDataFactory.getPricebook();
//		List<Product2> prods = BTN_TestDataFactory.getProduct();
//		BTN_TestDataFactory.getPriceBookEntries(myPB, prods);
//		Opportunity newOppo = BTN_TestDataFactory.getOpportunity(myPB.Id);
//		BTN_TestDataFactory.getUtilCS();
//		// item selection 1 step scenario.
//		PageReference pageTest = Page.BTN_OpportunityProductEditAll;
//		Test.setCurrentPage(pageTest);
//		ApexPages.StandardController stdC = new ApexPages.StandardController(newOppo);
//		BTN_ProductSelectionExtension controller = new BTN_ProductSelectionExtension(stdC);
//		BTN_ProductSelectionExtension controllerDummy = new BTN_ProductSelectionExtension();
//
//		String standardPricebook = controller.standardPricebook;
//		System.assertEquals(controller.standardPricebook, myPB.Id);
//
//		controller.getselectedProducts();
//		System.assert(!controller.getProducts().isEmpty());
//		controller.selectedProductsToAdd.add(controller.productsOnView.get(0));
//		System.assertNotEquals(null, controller.goToStep2());
//
//		products = controller.productsOnView;
//		selectedProductsToAdd = controller.selectedProductsToAdd;
//		oppoProducts = controller.selectedProductsOnView;
//		controller.priceItem = 0;
//		controller.setNullFixedPrice();
//		controller.setNullUnitPrice();
//		System.assertEquals(0, controller.selectedProductsOnView.get(controller.priceItem).lineItem.FixedPrice__c);
//		System.assertEquals(0, controller.selectedProductsOnView.get(controller.priceItem).lineItem.Hourly_Rate__c);
//
//		for (BTN_OpportunityLineItemWrapper item : controller.selectedProductsOnView) {
//			item.lineItem.Hourly_Rate__c = 66;
//			item.lineItem.Quantity = 6;
//		}
//		System.assertEquals(new PageReference('/' + newOppo.Id).getURL(), controller.saveOpportunityLineItems().getURL());
//
//		System.assertEquals(null, controller.refresh());
//
//		pageTest = Page.BTN_OpportunityProductEditAll;
//		Test.setCurrentPage(pageTest);
//		pageTest.getParameters().put('oppId', newOppo.Id);
//		//pageTest.getParameters().put('singleEdit',  controller.selectedProductsOnView.get(0).lineItem.Id);
//		controller = new BTN_ProductSelectionExtension(stdC);
//		System.assertEquals(String.format(System.Label.EditProductsFormSec, new String[]{String.valueOf(controller.mysObject.Name), controller.mysObject.Pricebook2.Name})
//			, controller.getdynTitle());
//		controller.selectedProductsToAdd = selectedProductsToAdd;
//		controller.productsOnView = products;
//		controller.checkedItem = prods.get(1).Id;
//		//add element(id = controller.checkedItem) and remove from selectedProductsToAdd.
//		controller.toggleItem();
//		controller.toggleItem();
//		for (BTN_OpportunityLineItemWrapper item : controller.selectedProductsOnView) {
//			item.lineItem.FixedPrice__c = 100;
//			item.lineItem.Quantity = 2;
//		}
//		System.debug(controller.selectedProductsOnView);
//		System.assertEquals(new PageReference('/' + newOppo.Id).getURL(), controller.saveOpportunityLineItems().getURL());
//		// wrap product exception;
//		System.assert(controller.wrapProductList([SELECT Id, Name, Description, Level__c, ProductCode, Family, Technology__c
//			FROM Product2 LIMIT 25]).isEmpty());
//		System.assertEquals((new PageReference('/'+newOppo.Id).getURL()), controller.cancelFromStep2().getURL());
//	}
}