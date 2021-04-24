public without sharing class BTN_ProductsGenerator {
//
//	class Price {
//		public Integer hourlyRate{set; get;}
//		public Integer fixedPrice{set; get;}
//		Price(Integer hP, Integer fP) {
//			this.hourlyRate = hP;
//			this.fixedPrice = fP;
//		}
//	}
//	// ALL Hourly Rates and Fixed Prices in PLN !!!
//	public static final Map<String, Price> PRODUCTS1_5 = new Map<String, Price>{
//		'Administrator' => new Price(100, 0),
//		'Analyst junior' => new Price(90, 0),
//		'Analyst senior' => new Price(125, 0),
//		'Architect' => new Price(140, 0),
//		'Tester junior' => new Price(70, 0),
//		'Tester professional' => new Price(90, 0),
//		'Tester senior' => new Price(110, 0),
//		'Developer junior' => new Price(80, 0),
//		'Developer professional' => new Price(100, 0),
//		'Developer senior' => new Price(125, 0),
//		'Project Manager junior' => new Price(100, 0),
//		'Project Manager senior' => new Price(140, 0),
//		'Fixed price project' => new Price(0, 0),
//		'Support monthly' => new Price(0, 5000),
//		'Support Support OnCall' => new Price(0, 15)
//	};
//
//	public static final Map<String, Integer> PRODUCTS_ORDER1_5 = new Map<String, Integer>{
//		'Administrator' => 10,
//		'Analyst junior' => 7,
//		'Analyst senior' => 8,
//		'Architect' => 9,
//		'Tester junior' => 4,
//		'Tester professional' => 5,
//		'Tester senior' => 6,
//		'Developer junior' => 1,
//		'Developer professional' => 2,
//		'Developer senior' => 3,
//		'Project Manager junior' => 11,
//		'Project Manager senior' => 12,
//		'Fixed price project' => 13,
//		'Support monthly' => 14,
//		'Support Support OnCall' => 15
//	};
//
//	public static final Set<String> PRODUCTS1_4 = new Set<String>{'Administrator', 'Analyst', 'Architect', 'Developer junior'
//		, 'Developer professional', 'Developer senior', 'Project Manager', 'Tester junior', 'Tester professional'
//		, 'Tester senior', 'Training', 'Support', 'Fixed price project'};
//
//	// adjusted for 1.4. Adding just not existing products.
//	public static List<Product2> generateProducts() {
//		return BTN_ProductsGenerator.generateProducts(PRODUCTS1_4);
//	}
//
//	public static List<Product2> generateProducts(Set<String> prodsSet) {
//		List<Product2> products = new List<Product2>();
//		List<Product2> existingProducts = new List<Product2>([SELECT Id, Name FROM Product2]);
//		Set<String> existingProductsNames = new Set<String>();
//		Product2 prd2;
//		for (Product2 item : existingProducts) {
//			existingProductsNames.add(item.Name);
//		}
//		for (String name : prodsSet) {
//			if (!existingProductsNames.contains(name)) {
//				prd2 = new Product2();
//				prd2.Name = name;
//				prd2.ProductCode = name;
//				prd2.Family = '';
//				prd2.Technology__c = '';
//				prd2.Level__c = '-';
//				prd2.Description = '';
//				prd2.IsActive = true;
//				products.add(prd2);
//			}
//		}
//		insert products;
//		return products;
//	}
//
//	//method may be used to recalculate values with new ConversionRates.
//	public static void setupAllProductsPrices() {
//		Price tmp;
//		List<CurrencyType> conversionRates = new List<CurrencyType>([SELECT IsoCode, ConversionRate FROM CurrencyType WHERE IsActive = true]);
//		List<PricebookEntry> entries = new List<PricebookEntry>([SELECT Id, CurrencyIsoCode, Product2.Name, UnitPrice, FixedPrice__c
//			FROM PricebookEntry WHERE IsActive = true AND IsDeleted = false AND Product2.Name IN :PRODUCTS1_5.keySet()]);
//		for (PricebookEntry entryItem : entries) {
//			for (CurrencyType curItem : conversionRates) {
//				if (entryItem.CurrencyIsoCode.equals(curItem.IsoCode)) {
//					tmp = PRODUCTS1_5.get(entryItem.Product2.Name);
//					entryItem.FixedPrice__c = tmp.fixedPrice * curItem.ConversionRate;
//					entryItem.UnitPrice = tmp.hourlyRate * curItem.ConversionRate;
//				}
//			}
//		}
//		update entries;
//	}
//
//	public static void generateStandardPriceBookEntries(List<Product2> products) {
//		List<PricebookEntry> pbEntries = new List<PricebookEntry>();
//		Id pb2;
//		if (Test.isRunningTest()) {
//			pb2 = Test.getStandardPricebookId();
//		} else {
//			pb2 = [SELECT Id, Name, IsStandard FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
//		}
//		for (Product2 pd2 : products) {
//			for (String curr : BTN_PriceBookGenerator.currencySet) {
//				PricebookEntry pbEntry = new PricebookEntry(UseStandardPrice = false, CurrencyIsoCode = curr, Product2Id = pd2.Id, Pricebook2Id = pb2, UnitPrice = 40
//					, IsActive = true);
//				pbEntries.add(pbEntry);
//			}
//		}
//		Database.insert(pbEntries, false);
//	}
//
//	public static void generatePriceBookEntries(List<String> priceBookIds) {
//		List<Product2> products = [SELECT Id, Name, Level__c FROM Product2 WHERE IsActive = true];
//		List<PricebookEntry> pbEntries = new List<PricebookEntry>();
//		for (Pricebook2 pb2 : [SELECT Id, Name, CurrencyIsoCode FROM Pricebook2 WHERE Id IN :priceBookIds]) {
//			for (Product2 pd2 : products) {
//				pbEntries.add(new PricebookEntry(UseStandardPrice = false, CurrencyIsoCode = pb2.CurrencyIsocode
//					, Product2Id = pd2.Id, Pricebook2Id = pb2.Id, UnitPrice = 40, FixedPrice__c = 0
//					, IsActive = true));
//			}
//		}
//		insert pbEntries;
//	}
//
//	public static List<PricebookEntry> generatePriceBookEntries() {
//		Boolean isExist = false;
//		List<Product2> products = [SELECT Id, Name, Level__c,(SELECT Id, Pricebook2Id, Product2Id, Product2.Name, CurrencyIsoCode FROM PricebookEntries) FROM Product2 WHERE IsActive = true];
//		List<PricebookEntry> pbEntriesToInsert = new List<PricebookEntry>();
//		List<Pricebook2> pbs = new List<Pricebook2>([SELECT Id, Name, CurrencyIsoCode FROM Pricebook2]);
//		for (Product2 prodItem : products) {
//			for (Pricebook2 pbItem : pbs) {
//				for (PricebookEntry entryItem : prodItem.PricebookEntries) {
//					if (entryItem.Pricebook2Id.equals(pbItem.Id)) {
//						isExist = true;
//					}
//				}
//				if (!isExist) {
//					pbEntriesToInsert.add(new PricebookEntry(UseStandardPrice = false, CurrencyIsoCode = pbItem.CurrencyIsocode, Product2Id = prodItem.Id, Pricebook2Id = pbItem.Id, UnitPrice = 40
//					, IsActive = true));
//				}
//				isExist = false;
//			}
//		}
//		insert pbEntriesToInsert;
//		return pbEntriesToInsert;
//	}
//
//	public static void removePriceBookEntries(List<String> pricebooks) {
//		delete [SELECT Id FROM PricebookEntry WHERE PriceBook2Id IN :pricebooks];
//	}
//
//	public static void removeProducts() {
//		List<OpportunityLineItem> lineItemz = new List<OpportunityLineItem>([SELECT Id, PricebookEntry.Product2.Name FROM OpportunityLineItem WHERE PricebookEntry.Product2.Name NOT IN :BTN_ProductsGenerator.PRODUCTS1_4]);
//		delete lineItemz;
//		delete [SELECT Id FROM Product2];
//	}
}