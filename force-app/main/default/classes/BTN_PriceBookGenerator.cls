public class BTN_PriceBookGenerator {
//
//	public static final Set<String> currencySet = new Set<String>{'PLN',
//		'CHF', 'EUR', 'USD', 'GBP'};
//
//	//adjusted to 1.4.
//	public static List<Pricebook2> generatePricebooks(Set<String> currencySet1) {
//		List<Pricebook2> pricebooks = new List<Pricebook2>();
//		List<Pricebook2> existingPricebooks = new List<Pricebook2>([SELECT Id, Name, CurrencyIsoCode FROM Pricebook2 WHERE IsStandard = false]);
//		Set<String> existingCurrencies = new Set<String>();
//		for (Pricebook2 item : existingPricebooks) {
//			existingCurrencies.add(item.CurrencyIsoCode);
//		}
//		for (String currencyItem : currencySet1) {
//			if (!existingCurrencies.contains(currencyItem)) {
//				pricebooks.add(new Pricebook2(Name = String.format(System.Label.PriceBookNameFormat,
//					new String[]{currencyItem}), Description = '', CurrencyIsoCode = currencyItem, IsActive = true));
//			}
//		}
//		INSERT pricebooks;
//		return pricebooks;
//	}
//
//	public static void removePriceBooks() {
//		DELETE [SELECT Id FROM Pricebook2 WHERE IsStandard = false];
//	}
//	// 1.4
//	//modified generator logic.
//	//Script will generate only not existing Price Books
//	//Script will generate standard price book entries only for new Product2 List.
//	//It will also add entries for all products to new Pricebook.
//	//new standard entries just for new added items - easy way to win.
//	//new entries in all PB's for everything.
//	public static List<String> setupPricebooksWithProductsAndProductEntries() {
//		List<String> pricebooksIds = BTN_Utils.getSObjectIds((List<sObject>) BTN_PriceBookGenerator.generatePricebooks(
//			BTN_Utils.getAvailableCurrencyIsoCodeList(true)));
//		List<Product2> newProds = BTN_ProductsGenerator.generateProducts();
//		BTN_ProductsGenerator.generateStandardPriceBookEntries(newProds);
//		BTN_ProductsGenerator.generatePriceBookEntries(pricebooksIds);
//		BTN_ProductsGenerator.generatePriceBookEntries();
//		return pricebooksIds;
//	}
}