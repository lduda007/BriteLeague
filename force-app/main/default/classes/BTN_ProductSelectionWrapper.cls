public class BTN_ProductSelectionWrapper implements Comparable {
	public Boolean isChecked{get; set;}
	public Product2 product{get; set;}
	public Decimal unitPrice{get; set;}
	public String priceBookEntry{get; set;}
	public transient String currencyEntry{get; set;}
	public Decimal fixedPrice{set; get;}
	public Integer order{set; get;}

	public BTN_ProductSelectionWrapper(Boolean defCheck, Product2 item, Decimal price, Decimal fixedPrice, String entryId, String curr, Integer order) {
		this.product = item;
		this.isChecked = defCheck;
		this.unitPrice = price;
		this.priceBookEntry =  entryId;
		this.currencyEntry = curr;
		this.fixedPrice = fixedPrice;
		this.order = order;
	}

	public BTN_ProductSelectionWrapper(Product2 item, Decimal price, Decimal fixedPrice, String entryId, String curr, Integer order) {
		this(false, item, price, fixedPrice, entryId, curr, order);
	}

	public Integer compareTo(Object compareTo) {
		BTN_ProductSelectionWrapper obj = (BTN_ProductSelectionWrapper) compareTo;
		Integer res = 0;
		if ((this.order < obj.order) || (obj.order == null)) {
			res = -1;
		} else if ((this.order > obj.order) || (this.order == null)) {
			res = 1;
		}
		return res;
	}
}