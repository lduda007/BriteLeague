public with sharing class BTN_ProductSelectionExtension {
//	public Opportunity mysObject;
//	public String checkedItem{set; get;}
//	public Integer numberOfRecords{set; get;}
//	public Integer size{set; get;}
//	public List<BTN_ProductSelectionWrapper> productsOnView{set; get;}
//	// items checked by user
//	public List<BTN_ProductSelectionWrapper> selectedProductsToAdd{set; get;}
//	// items on step2 form or edit all form
//	public List<BTN_OpportunityLineItemWrapper> selectedProductsOnView{set; get;}
//	public String standardPricebook{get; set;}
//	public String changedLineItem{set; get;}
//	public Integer priceItem{set; get;}
//	public ApexPages.StandardSetController setCon {
//		get{
//			if(setCon == NULL) {
//				setCon = new ApexPages.StandardSetController(Database.getQueryLocator(getBasicQuery()));
//				setCon.setPageSize(size);
//				numberOfRecords = setCon.getResultSize();
//			}
//			return setCon;
//		}set;}
//	public Boolean hasNext {
//		get{
//			return setCon.getHasNext();}
//		set;}
//
//	public Boolean hasPrevious {
//		get{
//			return setCon.getHasPrevious();}
//		set;}
//
//	public Integer pageNumber {
//		get {
//			return setCon.getPageNumber();}
//		set;}
//
//	public BTN_ProductSelectionExtension() {}
//
//	public BTN_ProductSelectionExtension(ApexPages.StandardController stdController) {
//		this.mysObject = (Opportunity)stdController.getRecord();
//		Integer i = 0;
//		selectedProductsToAdd = new List<BTN_ProductSelectionWrapper>();
//		if(isEdit()) {
//			String oneItemEdition = '';
//			mysObject = [SELECT Id, Name, Pricebook2.Name, Pricebook2Id, CVLanguage__c, ContractStart__c, ContractEnd__c FROM Opportunity WHERE Id = :mysObject.Id LIMIT 1].get(0);
//			selectedProductsOnView = new List<BTN_OpportunityLineItemWrapper>();
//			for(OpportunityLineItem item : [SELECT Id, OpportunityId, Quantity, FixedPrice__c, Hourly_Rate__c, MainSkill__c, SecondarySkills__c
//				, CurrencyIsoCode, PricebookEntryId, PricebookEntry.Product2Id, TotalPrice
//				, PricebookEntry.Product2.Name, PricebookEntry.CurrencyIsoCode
//					FROM OpportunityLineItem WHERE OpportunityId = :mysObject.Id ORDER BY PricebookEntry.Product2.Name]) {
//				if (!(ApexPages.currentPage().getParameters().keyset().contains('singleEdit'))) {
//				selectedProductsOnView.add(
//					new BTN_OpportunityLineItemWrapper(item,
//						new Product2(Id = item.PricebookEntry.Product2Id, Name = item.PricebookEntry.Product2.Name),
//						new PricebookEntry(Id = item.PricebookEntryId, CurrencyIsoCode = item.PricebookEntry.CurrencyIsoCode)));
//				} else {
//					if (ApexPages.currentPage().getParameters().get('singleEdit') == item.Id) {
//						selectedProductsOnView.add(
//							new BTN_OpportunityLineItemWrapper(item,
//								new Product2(Id = item.PricebookEntry.Product2Id, Name = item.PricebookEntry.Product2.Name),
//								new PricebookEntry(Id = item.PricebookEntryId, CurrencyIsoCode = item.PricebookEntry.CurrencyIsoCode)));
//					}
//				}
//			}
//			for (BTN_OpportunityLineItemWrapper item : selectedProductsOnView) {
//				item.rowNum = i;
//				i++;
//			}
//		} else {
//			getStandardPricebook();
//			size = BTN_Utils.getIntegerValueFromCS('productsPerPage');
//			if (size == null) {
//				size = 10;
//			}
//		}
//	}
//
//	public void getStandardPricebook() {
//		if(mysObject.Pricebook2Id == null) {
//			try {
//				if (Test.isRunningTest()) {
//					standardPricebook = Test.getStandardPricebookId();
//				} else {
//					standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].get(0).Id;
//				}
//			}catch(Exception e) {
//				System.debug('No standard PriceBook');
//			}
//		} else {
//			standardPricebook = mysObject.Pricebook2Id;
//		}
//	}
//
//	public String getBasicQuery() {
//		return 'SELECT Id, Name, Description, Level__c, ProductCode, Family, Technology__c,(SELECT UnitPrice, FixedPrice__c, CurrencyIsoCode FROM PricebookEntries WHERE Pricebook2Id = \'' + standardPricebook + '\') FROM Product2 WHERE Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook AND IsActive = true) ORDER BY Name';
//	}
//
//	public List<BTN_ProductSelectionWrapper> wrapProductList(List<Product2> products) {
//		List<BTN_ProductSelectionWrapper> wrappedList = new List<BTN_ProductSelectionWrapper>();
//		Boolean isExist = false;
//		for(Product2 item : products) {
//			try {
//				for (BTN_ProductSelectionWrapper item2 : selectedProductsToAdd) {
//					if (item2.product.Id.equals(item.Id)) {
//						isExist = true;
//					}
//				}
//				wrappedList.add(new BTN_ProductSelectionWrapper(isExist, item, item.PriceBookEntries.get(0).UnitPrice, item.PriceBookEntries.get(0).FixedPrice__c, item.PriceBookEntries.get(0).Id, item.PriceBookEntries.get(0).CurrencyIsoCode, BTN_ProductsGenerator.PRODUCTS_ORDER1_5.get(item.Name)));
//				isExist = false;
//			}catch(Exception e) {
//				System.debug('error when wrapping product' + e.getMessage());
//				continue;
//			}
//		}
//		return wrappedList;
//	}
//
//	public List<BTN_ProductSelectionWrapper> getProducts() {
//		productsOnView = wrapProductList((List<Product2>)setCon.getRecords());
//		productsOnView.sort(); // sort by specified order
//		return productsOnView;
//	}
//
//	public void first() {
//		setCon.first();
//	}
//
//	public void last() {
//		setCon.last();
//	}
//
//	public void previous() {
//		setCon.previous();
//	}
//
//	public void next() {
//		setCon.next();
//	}
//
//	public void nullPagination() {
//		this.setCon = NULL;
//	}
//
//	public PageReference refresh() {
//		setCon = NULL;
//		getProducts();
//		setCon.setPageNumber(1);
//		return NULL;
//	}
//
//	public PageReference goToStep2() {
//		if(selectedProductsToAdd.isEmpty()) {
//			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.NoProducts));
//			return NULL;
//		}
//		selectedProductsOnView = getselectedProducts();
//		for (priceItem = 0; priceItem < selectedProductsOnView.size(); priceItem++) {
//			setTotalPrice();
//		}
//		PageReference p = new PageReference('/apex/BTN_AddProductsFinalForm?id='+mysObject.Id+'&retURL=/apex/BTN_ProductSelectionListView?addTo='+mysObject.Id);
//		p.setRedirect(false);
//		return p;
//	}
//
//	public String getdynTitle() {
//		if(isEdit()) {
//			return String.format(System.Label.EditProductsFormSec, new String[]{String.valueOf(mysObject.Name),mysObject.Pricebook2.Name});
//		} else {
//			return String.format(System.Label.AddProductsFormSec, new String[]{String.valueOf(mysObject.Name),mysObject.Pricebook2.Name});
//		}
//	}
//
//	public List<BTN_OpportunityLineItemWrapper> getselectedProducts() {
//		List<BTN_OpportunityLineItemWrapper> products;
//		Integer i = 0;
//		if(selectedProductsOnView != NULL) {
//			return selectedProductsOnView;
//		}
//		try {
//			products = new List<BTN_OpportunityLineItemWrapper>();
//			List<String> entries = new List<String>();
//			for(BTN_ProductSelectionWrapper item : selectedProductsToAdd) {
//				entries.add(item.product.Id);
//			}
//			List<PricebookEntry> usedEntries = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry WHERE Product2Id IN :entries AND Pricebook2Id = :standardPricebook];
//			BTN_OpportunityLineItemWrapper lineItemWrapped;
//			for(BTN_ProductSelectionWrapper item : selectedProductsToAdd) {
//				lineItemWrapped = new BTN_OpportunityLineItemWrapper();
//				lineItemWrapped.lineItem = new OpportunityLineItem(FixedPrice__c = item.fixedPrice, Hourly_Rate__c = item.unitPrice, Quantity = 1
//					, OpportunityId = mysObject.Id, PricebookEntryId = item.priceBookEntry, TotalPrice = 0);
//				lineItemWrapped.entry = getEntry(item.product.Id, usedEntries);
//				lineItemWrapped.product = item.product;
//				lineItemWrapped.rowNum = i;
//				products.add(lineItemWrapped);
//				i++;
//			}
//			return products;
//		}catch(Exception e) {
//			return products;
//		}
//	}
//
//	public PageReference saveOpportunityLineItems() {
//		for (priceItem = 0; priceItem < selectedProductsOnView.size(); priceItem++) {
//			setTotalPrice();
//		}
//		if (!hasMessagesWithError()) {
//			if (isEdit()) {
//				return updateLineItems();
//			}
//			List<OpportunityLineItem> toInsert = new List<OpportunityLineItem>();
//			for (BTN_OpportunityLineItemWrapper item : selectedProductsOnView) {
//				toInsert.add(item.lineItem);
//			}
//			PageReference p;
//			try {
//				INSERT toInsert;
//				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.ProductsAdded));
//				String tmpId = mysObject.Id;
//				if(tmpId != NULL) {
//					p = new PageReference('/'+tmpId);
//					p.setRedirect(true);
//					return p;
//				}
//			}catch(Exception e) {
//				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.ProductsAddedErr));
//			}
//		}
//		return NULL;
//	}
//
//	public PricebookEntry getEntry(String itemId, List<PricebookEntry> entries) {
//		for(PricebookEntry item : entries) {
//			if(itemId.equals(item.Product2Id)) {
//				return item;
//			}
//		}
//		return NULL;
//	}
//
//	public PageReference cancelFromStep2() {
//		PageReference p;
//		if (!isEdit()) {
//			p = new PageReference('/apex/BTN_ProductSelectionListView?addTo='+mysObject.Id+'&id='+mysObject.Id);
//			p.setRedirect(true);
//			return p;
//		} else {
//			p = new PageReference('/'+mysObject.Id);
//			p.setRedirect(true);
//			return p;
//		}
//	}
//
//	public PageReference cancelToOppo() {
//		PageReference p = new PageReference('/'+mysObject.Id);
//		p.setRedirect(true);
//		return p;
//	}
//
//	public PageReference updateLineItems() {
//		List<OpportunityLineItem> toUpdate = new List<OpportunityLineItem>();
//		for (BTN_OpportunityLineItemWrapper item : selectedProductsOnView) {
//			toUpdate.add(item.lineItem);
//		}
//		try {
//			Database.update(toUpdate);
//			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.OppoLineItemUpdateActionSuccesfull));
//			return new PageReference('/'+mysObject.Id);
//		}catch(Exception e) {
//			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.ProductsAddedErr));
//			return NULL;
//		}
//	}
//
//	public void toggleItem() {
//		BTN_ProductSelectionWrapper selectedItem;
//		Integer i = 0;
//		Boolean isExist = false;
//		for (BTN_ProductSelectionWrapper item : productsOnView) {
//			if (checkedItem.equals(item.product.Id)) {
//				selectedItem = item;
//				break;
//			}
//		}
//		if ((selectedProductsToAdd != null) && (!selectedProductsToAdd.isEmpty()) && (selectedItem != null)) {
//			for (BTN_ProductSelectionWrapper item : selectedProductsToAdd) {
//				if (item.product.Id.equals(selectedItem.product.Id)) {
//					selectedProductsToAdd.remove(i);
//					isExist = true;
//					break;
//				}
//				i++;
//			}
//		}
//		if ((!isExist) && (selectedProductsToAdd != null)) {
//			selectedProductsToAdd.add(selectedItem);
//		}
//	}
//
//	public Boolean isEdit() {
//		return ApexPages.currentPage().getParameters().keyset().contains('oppId');
//	}
//
//	public void setNullFixedPrice() {
//		selectedProductsOnView.get(priceItem).lineItem.FixedPrice__c = 0;
//		setTotalPrice();
//	}
//
//	public void setNullUnitPrice() {
//		selectedProductsOnView.get(priceItem).lineItem.Hourly_Rate__c = 0;
//		setTotalPrice();
//	}
//
//	public void setTotalPrice() {
//		if ((selectedProductsOnView.get(priceItem).lineItem.Quantity == null) || (selectedProductsOnView.get(priceItem).lineItem.Quantity == 0)) {
//			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, String.format(System.Label.QuantityRowNum
//				, new String[]{String.valueOf(priceItem + 1)})));
//		} else {
//			if (((mysObject.ContractStart__c != null) || (mysObject.ContractEnd__c != null)) && ((selectedProductsOnView.get(priceItem).lineItem.FixedPrice__c == null) || (selectedProductsOnView.get(priceItem).lineItem.FixedPrice__c == 0))) {
//				selectedProductsOnView.get(priceItem).lineItem.TotalPrice = (BTN_DateUtils.getDiffBusinessDays(mysObject.ContractStart__c, mysObject.ContractEnd__c) * 8) * selectedProductsOnView.get(priceItem).lineItem.Hourly_Rate__c * selectedProductsOnView.get(priceItem).lineItem.Quantity;
//			} else if ((selectedProductsOnView.get(priceItem).lineItem.FixedPrice__c != null) && (selectedProductsOnView.get(priceItem).lineItem.FixedPrice__c != 0)){
//				selectedProductsOnView.get(priceItem).lineItem.TotalPrice = selectedProductsOnView.get(priceItem).lineItem.FixedPrice__c * selectedProductsOnView.get(priceItem).lineItem.Quantity;
//			}
//		}
//	}
//
//	private Boolean hasMessagesWithError() {
//		Boolean res = false;
//		System.debug(ApexPages.getMessages());
//		for (ApexPages.Message itemM : ApexPages.getMessages()) {
//			if (ApexPages.severity.FATAL == itemM.getSeverity()) {
//				res = true;
//			}
//		}
//		return res;
//	}
}