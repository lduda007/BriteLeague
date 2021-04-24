@isTest
private class BTN_ProductListComponentController_Test {
//
//	@isTest static void setConTest() {
//		Id pb = Test.getStandardPricebookId();
//		Pricebook2 myPb = BTN_TestDataFactory.getPricebook();
//		List<Product2> prod = BTN_TestDataFactory.getProduct(200);
//		List<PricebookEntry> pbEntry = BTN_TestDataFactory.getPriceBookEntries(myPb, prod);
//		Opportunity newOppo = BTN_TestDataFactory.getOpportunity(myPb.Id);
//
//		List<OpportunityLineItem> newProductInOppo = new List<OpportunityLineItem>();
//		for (PricebookEntry item : pbEntry) {
//			newProductInOppo.add(new OpportunityLineItem(Quantity = 20, PricebookEntryId = item.Id, Hourly_Rate__c = 15, OpportunityId = newOppo.Id, TotalPrice = 1));
//		}
//		insert newProductInOppo;
//
//		PageReference pageTest = Page.BTN_ProductListPage;
//		Test.setCurrentPage(pageTest);
//		ApexPages.StandardController stdC = new ApexPages.StandardController(
//			[SELECT Id, Name, Pricebook2Id, Pricebook2.Name, RecordTypeId, StageName, RecordType.Name FROM Opportunity WHERE Id = :newOppo.Id LIMIT 1]);
//		BTN_ProductListComponentController controller = new BTN_ProductListComponentController(stdC);
//
//		System.assert(controller.hasNext);
//		System.assert(!controller.hasPrevious);
//		System.assertEquals(1, controller.pageNumber);
//		System.assertEquals(0, controller.getOffset());
//		System.assertEquals(newProductInOppo.size(), controller.numberOfRecords);
//		System.assertEquals(controller.size, controller.size);
//		controller.first();
//		controller.last();
//		System.assertEquals(controller.getLastPage(), controller.pageNumber);
//		System.assert(!controller.hasNext);
//		controller.previous();
//		System.assertEquals(controller.getLastPage() - 1, controller.pageNumber);
//		controller.next();
//		System.assertEquals(controller.getLastPage(), controller.pageNumber);
//		controller.refresh();
//		System.assertEquals(1, controller.pageNumber);
//		controller.getOpportunityId();
//	}
//
//	@isTest static void referenceTest() {
//		Id pb = Test.getStandardPricebookId();
//		Pricebook2 myPb = BTN_TestDataFactory.getPricebook();
//		List<Product2> prod = BTN_TestDataFactory.getProduct(200);
//		List<PricebookEntry> pbEntry = BTN_TestDataFactory.getPriceBookEntries(myPb, prod);
//		Opportunity newOppo = BTN_TestDataFactory.getOpportunity(myPb.Id);
//
//		List<OpportunityLineItem> newProductInOppo = new List<OpportunityLineItem>();
//		for (PricebookEntry item : pbEntry) {
//			newProductInOppo.add(new OpportunityLineItem(Quantity = 20, PricebookEntryId = item.Id, Hourly_Rate__c = 15, OpportunityId = newOppo.Id, TotalPrice = 1));
//		}
//		insert newProductInOppo;
//
//		PageReference pageTest = Page.BTN_ProductListPage;
//		Test.setCurrentPage(pageTest);
//		ApexPages.StandardController stdC = new ApexPages.StandardController(
//			[SELECT Id, Name, Pricebook2Id, Pricebook2.Name, RecordTypeId, StageName, RecordType.Name FROM Opportunity WHERE Id = :newOppo.Id LIMIT 1]);
//		BTN_ProductListComponentController controller = new BTN_ProductListComponentController(stdC);
//
//		PageReference addProduct = new PageReference('/apex/BTN_ProductSelectionListView');
//		addProduct.getParameters().put('addTo',  newOppo.Id);
//		addProduct.getParameters().put('retURL', '/' + newOppo.Id);
//		addProduct.getParameters().put('Id',  newOppo.Id);
//		System.assertEquals(addProduct.getUrl(), controller.addProduct().getUrl());
//
//		PageReference choosePB = new PageReference('/oppitm/choosepricebook.jsp');
//		choosePB.getParameters().put('id',  newOppo.Id);
//		choosePB.getParameters().put('retURL', '/' +  newOppo.Id);
//		choosePB.getParameters().put('saveURL', '/' +  newOppo.Id);
//		System.assertEquals(choosePB.getUrl(), controller.choosePriceBook().getUrl());
//
//		PageReference editAllProd = new PageReference('/apex/BTN_AddProductsFinalForm');
//		editAllProd.getParameters().put('oppId',  newOppo.Id);
//		editAllProd.getParameters().put('retURL', '/' +  newOppo.Id);
//		editAllProd.getParameters().put('Id',  newOppo.Id);
//		System.assertEquals(editAllProd.getUrl(), controller.editAllProduct().getUrl());
//	}
}