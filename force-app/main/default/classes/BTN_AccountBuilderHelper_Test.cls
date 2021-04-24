/**
 * @author Dariusz Chmiela
 * @date 2016-08-16
 * @description Test BTN_AccountBuilderHelper
*/
@isTest
public with sharing class BTN_AccountBuilderHelper_Test {
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description test get Account method
    */
    @isTest
    private static void getAccountTest(){
        // given
        Account account  = BTN_AccountBuilderHelper.buildWithBritenetRecordType().get();
        // when
        Test.startTest();
        insert account;
        Test.stopTest();
        // then
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description test saving Account
    */
    @isTest
    private static void saveAccountTest(){
        // given
        Account account;
        // when
        Test.startTest();
        account = BTN_AccountBuilderHelper.buildWithPublicSectorRecordType().save();
        Test.stopTest();
        // then
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description test saving Account with given fields
    */
    @isTest
    private static void saveAccountWithGivenFieldsTest(){
        // given
        String name = 'Solaris__Test';
        String status = Account.Status__c.getDescribe().getPicklistValues().get(0).value;
        RecordType recordType = BTN_RecordTypeUtils.getRecordTypeAccountPrivateSector();
        Account acc  = BTN_AccountBuilderHelper.buildWithPrivateSectorRecordType()
                .withName(name)
                .withStatus(status)
                .get();
        // when
        Test.startTest();
        insert acc;
        Test.stopTest();
        // then
        System.assertEquals(
                1,
                [SELECT Name
                FROM Account
                WHERE Name = : name AND Status__c = :status AND RecordTypeId = : recordType.Id LIMIT 3].size());
    }
}