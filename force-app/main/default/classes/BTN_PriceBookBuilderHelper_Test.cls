/**
 * @author Dariusz Chmiela
 * @date 2016-08-18
 * @description BTN_PriceBookBuilderHelper test
*/
@isTest
public with sharing class BTN_PriceBookBuilderHelper_Test {
    private static BTN_PriceBookBuilderHelper priceBookBuilderHelper = new BTN_PriceBookBuilderHelper();
    /**
    * @author Dariusz Chmiela
    * @date 2016-08-12
    * @description test saving PriceBook2
    */
    @isTest
    private static void savePriceBookTest(){
        // given
        Pricebook2 pricebook = priceBookBuilderHelper.build();
        // when
        Test.startTest();
        insert pricebook;
        Test.stopTest();
        // then
        System.assertEquals(1, [SELECT Id FROM Pricebook2 WHERE id = :pricebook.Id LIMIT 3].size());
    }
    /**
    * @author Dariusz Chmiela
    * @date 2016-08-12
    * @description test saving PriceBook2 with given fields
    */
    @isTest
    private static void savePriceBookWithGivenFieldsTest(){
        // given
        Boolean isActive = true;
        String description = 'PriceBook Description ' + System.currentTimeMillis();
        String name = 'PriceBook Name ' + System.currentTimeMillis();
        String currencyIsoCode = 'PLN';

        Pricebook2 pricebook = priceBookBuilderHelper
                .withName(name)
                .withDescription(description)
                .withCurrencyIsoCode(currencyIsoCode)
                .build();
        // when
        Test.startTest();
        insert pricebook;
        Test.stopTest();
        // then
        System.assertEquals(pricebook, [SELECT
                Id,
                Name,
                Description,
                CurrencyIsoCode,
                IsActive
        FROM Pricebook2
        WHERE id = :pricebook.Id LIMIT 3].get(0));
    }
}