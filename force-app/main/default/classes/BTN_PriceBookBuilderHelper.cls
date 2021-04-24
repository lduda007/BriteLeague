/*
 * @author Dariusz Chmiela
 * @date 2016-08-18
 * @description BTN_PriceBookBuilderHelper Builder for PriceBook2
*/
public with sharing class BTN_PriceBookBuilderHelper {
    //Pricebook2 myPB = new Pricebook2(Name = 'testPB', CurrencyIsoCode = BTN_TestDataFactory.testCurrency, IsActive = true);
    private Boolean isActive = true;
    private String description = 'PriceBook Description ' + System.currentTimeMillis();
    private String name = 'PriceBook Name ' + System.currentTimeMillis();
    private String currencyIsoCode = 'PLN';
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description build Method builds Pricebook2
     * @return Pricebook2
    */
    public Pricebook2 build() {
        return new Pricebook2(
                Name = name,
                Description = description,
                IsActive = isActive,
                CurrencyIsoCode = currencyIsoCode
        );
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withName Method set up PriceBook2 Name
     * @return BTN_PriceBookBuilderHelper - instance of Builder
    */
    public BTN_PriceBookBuilderHelper withName(String name) {
        this.name = name;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withDescription Method set up PriceBook2 Description
     * @return BTN_PriceBookBuilderHelper - instance of Builder
    */
    public BTN_PriceBookBuilderHelper withDescription(String description) {
        this.description = description;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withCurrencyIsoCode Method set up PriceBook2 CurrencyIsoCode
     * @return BTN_PriceBookBuilderHelper - instance of Builder
    */
    public BTN_PriceBookBuilderHelper withCurrencyIsoCode(String currencyIsoCode) {
        this.currencyIsoCode = currencyIsoCode;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description active Method set up PriceBook2 IsActive
     * @return BTN_PriceBookBuilderHelper - instance of Builder
    */
    public BTN_PriceBookBuilderHelper active(Boolean isActive) {
        this.isActive = isActive;
        return this;
    }
}