public with sharing class BTN_ProductListComponentController {
//	private Opportunity mysObject;
//	public List<OpportunityLineItem> relatedProductsOnView{set; get;}
//	public Integer numberOfRecords{set; get;}
//	public Integer size{set; get;}
//
//	public Boolean hasNext {
//		get{
//			return (pageNumber <= (Math.ceil(numberOfRecords / size)));
//		}
//		set;}
//
//	public Boolean hasPrevious {
//		get{
//			return (pageNumber > 1);
//		} set;}
//
//	public Integer pageNumber {get; set;}
//
//	public BTN_ProductListComponentController(ApexPages.StandardController stdController) {
//		this.mysObject = (Opportunity)stdController.getRecord();
//		size = 5;
//		pageNumber = 1;
//		numberOfRecords = [SELECT count() FROM OpportunityLineItem WHERE OpportunityId = :mysObject.Id];
//	}
//
//	public List<OpportunityLineItem> getProducts() {
//		relatedProductsOnView = getRecordsByPage();
//		return relatedProductsOnView;
//	}
//
//	public PageReference addProduct() {
//		PageReference p = new PageReference('/apex/BTN_ProductSelectionListView');
//		p.getParameters().put('addTo', mysObject.Id);
//		p.getParameters().put('retURL', '/' + mysObject.Id);
//		p.getParameters().put('Id', mysObject.Id);
//		p.setRedirect(true);
//		return p;
//	}
//
//	public PageReference choosePriceBook() {
//		PageReference p = new PageReference('/oppitm/choosepricebook.jsp');
//		p.getParameters().put('id', mysObject.Id);
//		p.getParameters().put('retURL', '/' + mysObject.Id);
//		p.getParameters().put('saveURL', '/' + mysObject.Id);
//		p.setRedirect(true);
//		return p;
//	}
//
//	public PageReference editAllProduct() {
//		PageReference p = new PageReference('/apex/BTN_AddProductsFinalForm');
//		p.getParameters().put('oppId', mysObject.Id);
//		p.getParameters().put('retURL', '/' + mysObject.Id);
//		p.getParameters().put('Id', mysObject.Id);
//		p.setRedirect(true);
//		return p;
//	}
//
//	private List<OpportunityLineItem> getRecordsByPage() {
//		Integer recOffset = getOffset();
//		return [SELECT Id, PricebookEntry.Product2.Name, Quantity, Hourly_Rate__c, TotalPrice, ListPrice FROM OpportunityLineItem
//			WHERE OpportunityId = :mysObject.Id ORDER BY PricebookEntry.Product2.Name
//			LIMIT :size
//			OFFSET :recOffset];
//	}
//
//	public Integer getOffset() {
//		return ((pageNumber - 1) * size);
//	}
//
//	public void first() {
//		pageNumber = 1;
//		getProducts();
//	}
//
//	public void last() {
//		pageNumber = getLastPage();
//		getProducts();
//	}
//
//	public Integer getLastPage() {
//		return (Integer) Math.ceil(numberOfRecords / size) + 1;
//	}
//
//	public void previous() {
//		pageNumber--;
//		getProducts();
//	}
//
//	public void next() {
//		pageNumber++;
//		getProducts();
//	}
//
//	public PageReference refresh() {
//		pageNumber = 1;
//		return NULL;
//	}
//
//	public Id getOpportunityId() {
//		return ApexPages.currentPage().getParameters().get('Id');
//	}
}