/**
 * @author Dariusz Chmiela
 * @date 2016-08-18
 * @description BTN_ResourceRequestBuilderHelper test
*/
@isTest
public with sharing class BTN_ResourceRequestBuilderHelper_Test {
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description test saving BTN_ResourceRequest__c
    */
    @isTest
    private static void saveRRTest(){
        // given
        BTN_ResourceRequest__c rr = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().get();
        // when
        Test.startTest();
        insert rr;
        Test.stopTest();
        // then
        System.assertEquals(1, [
                SELECT Id
                FROM BTN_ResourceRequest__c
                WHERE ContractDuration__c = :rr.ContractDuration__c LIMIT 3].size());
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description test saving BTN_ResourceRequest__c with given fields
    */
    @isTest
    private static void saveContactWithGivenFieldsTest(){
        String contractDuration = '2';
        String accountName = 'BRITENET';
        Account acc = BTN_AccountBuilderHelper.buildWithBritenetRecordType()
                .withName(accountName)
                .save();
        Contact requestorContact = BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .withAccount(acc.Id)
                .withEmail('a' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL)
                .get();
        System.assertEquals(
                requestorContact.RecordTypeId,
                BTN_RecordTypeUtils.getRecordTypeContactInternal().Id );
        System.assertEquals(
                BTN_RecordTypeUtils.getRecordTypeAccountBritenet().Id,
                [SELECT RecordTypeId FROM Account WHERE Id = :requestorContact.AccountId LIMIT 1].RecordTypeId);
        insert requestorContact;
        String customerAccount = 'Britenet';
        String position = 'JAVA DEVELOPER';
        String location = 'Warszawa';
        Date deliveryDeadline = Date.today().addDays(-1);
        String description = 'Description';
        String secondarySkills = 'Secondary skills';
        Date contractStart = Date.today().addDays(2);
        Decimal customerRate = 100;
        Integer quantity = 100;
        String language = 'Polish';
        String expirienceLevel = 'BEGINER';
        RecordType recordType = BTN_RecordTypeUtils.getRecordTypeResourceRequestManual();
        Opportunity opp = BTN_OpportunityBuilderHelper.buildWithFixedPriceRecordType().save();
        User requestorUser = BTN_UserBuilderHelper.buildUserWithDefaults().get();
        BTN_ResourceRequest__c rr = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType()
                .withContractDuration(contractDuration)
                .withPosition(position)
                .withLocation(location)
                .withDeliveryDeadline(deliveryDeadline)
                .withDescription(description)
                .withSecondarySkills(secondarySkills)
                .withContractStart(contractStart)
                .withCustomerRate(customerRate)
                .withQuantity(quantity)
                .withLanguage(language)
                .withExpirienceLevel(expirienceLevel)
                .withOpportunityType(opp.Type)
                .withOpportunity(opp.Id)
                .withRequestorUser(requestorUser.Id)
                .get();
        Test.startTest();
        insert rr;
        Test.stopTest();
        // then
        System.assertEquals(1, [
                SELECT Id
                FROM BTN_ResourceRequest__c
                WHERE ContractDuration__c = :String.valueOf(contractDuration) AND RecordTypeId = :recordType.Id LIMIT 3].size());
    }
}