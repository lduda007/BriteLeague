/**
 * @author Dariusz Chmiela
 * @date 2016-08-12
 * @description Test BTN_ContactBuilderHelper
*/
@isTest
public with sharing class BTN_ContactBuilderHelper_Test {
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description test get Contact
    */
    @isTest
    private static void getContactTest(){
        // given
        Contact contact  = BTN_ContactBuilderHelper.buildWithBusinessRecordType().get();
        // when
        Test.startTest();
        insert contact;
        Test.stopTest();
        // then
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description test saving Contact
    */
    @isTest
    private static void saveContactTest(){
        // given
        Contact contact;
        // when
        Test.startTest();
        contact = BTN_ContactBuilderHelper.buildWithBusinessRecordType().save();
        Test.stopTest();
        // then
    }
    @isTest
    private static void saveContactWithSetMostOfFieldsTest(){
        // given
        Account acc = BTN_AccountBuilderHelper.buildWithBritenetRecordType().save();
        String email = 'test1234@britenet.com.pl';
        String firstName = 'Monika';
        String lastName = 'Jaworska';
        RecordType recordType = BTN_RecordTypeUtils.getRecordTypeContactInternal();
        Contact contact  = BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .withAccount(acc.Id)
                .withEmail(email)
                .withFirstName(firstName)
                .withLastName(lastName)
                .get();
        // when
        Test.startTest();
        insert contact;
        Test.stopTest();
        // then
        System.assertEquals(
                1,
                [SELECT Name
                FROM Contact
                WHERE FirstName = :firstName AND LastName = :lastName AND RecordTypeId = :recordType.Id LIMIT 3].size());
    }
}