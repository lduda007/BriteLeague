/*
 * @author Dariusz Chmiela
 * @date 2016-08-12
 * @description BTN_AccountBuilderHelper Builder for SFDC Account
*/
public with sharing class BTN_AccountBuilderHelper implements BTN_BuilderHelper{
    // record
    private Account record;
    private String name = 'Test__Solaris';
    private String status;
    private Id recordTypeId;
    public final static String DEFAULT_NAME = 'TEST_DEFAULT_BRITENET';
    public final static String DEFAULT_CURRENCY_ISO_CODE = Account.CurrencyIsoCode.getDescribe().getPicklistValues().get(0).value;
    public final static String DEFAULT_SOURCE = Account.AccountSource.getDescribe().getPicklistValues().get(0).value;
    public final static String DEFAULT_STATUS = Account.Status__c.getDescribe().getPicklistValues().get(0).value;
    public final static String DEFAULT_INDUSTRY = Account.Industry.getDescribe().getPicklistValues().get(0).value;
    public final static String DEFAULT_OWNERSHIP = Account.Ownership.getDescribe().getPicklistValues().get(0).value;
    public final static String DEFAULT_RATING = Account.Rating.getDescribe().getPicklistValues().get(0).value;
    public final static String DEFAULT_EMPLOYEES = Account.Employees__c.getDescribe().getPicklistValues().get(0).value;
    public final static String DEFAULT_TYPE = Account.Type.getDescribe().getPicklistValues().get(0).value;
    public final static String DEFAULT_INTERNAL_COMPANY = Account.InternalCompany__c.getDescribe().getPicklistValues().get(0).value;
    public final static Id DEFAULT_RECORD_TYPE_ID = BTN_RecordTypeUtils.getRecordTypeAccountBritenet().Id;
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWithBritenetRecordType Method builds Account sObject with Britenet record type
     * @return BTN_AccountBuilderHelper - current instance
    */
    public static BTN_AccountBuilderHelper buildWithBritenetRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeAccountBritenet().Id);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWithPublicSectorRecordType Method builds Account sObject with Public Sector record type
     * @return BTN_AccountBuilderHelper - current instance
    */
    public static BTN_AccountBuilderHelper buildWithPublicSectorRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeAccountPublicSector().Id);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWithPrivateSectorRecordType Method builds Account sObject with Private Sector record type
     * @return BTN_AccountBuilderHelper - current instance
    */
    public static BTN_AccountBuilderHelper buildWithPrivateSectorRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeAccountPrivateSector().Id);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWith Method builds Account sObject with given Record Type
     * @param String - given record type to set
     * @return BTN_AccountBuilderHelper - current instance
    */
    private static BTN_AccountBuilderHelper buildWith(String recordTypeId){
        BTN_AccountBuilderHelper accountBuilderHelper = new BTN_AccountBuilderHelper();
        accountBuilderHelper.record = applyDefaults(recordTypeId);
        return accountBuilderHelper;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description applyDefaults Method applies default values to record for given Record Type
     * @param String - Record Type Id to set
     * @return Account
    */
    private static Account applyDefaults(String recordTypeId) {
        return new Account(
                Name = DEFAULT_NAME,
                CurrencyIsoCode = DEFAULT_CURRENCY_ISO_CODE,
                AccountSource = DEFAULT_SOURCE,
                Status__c =  DEFAULT_STATUS,
                Industry = DEFAULT_INDUSTRY,
                Ownership = DEFAULT_OWNERSHIP,
                Rating = DEFAULT_RATING,
                Employees__c = DEFAULT_EMPLOYEES,
                Type = DEFAULT_TYPE,
                InternalCompany__c = DEFAULT_INTERNAL_COMPANY,
                RecordTypeId = recordTypeId
        );
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withName Method set up Account Name
     * @return BTN_AccountBuilderHelper - instance of Builder
    */
    public BTN_AccountBuilderHelper withName(String name) {
        record.Name = name;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withStatus Method set up Account Status__c
     * @return BTN_AccountBuilderHelper - instance of Builder
    */
    public BTN_AccountBuilderHelper withStatus(String status) {
        record.Status__c = status;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description save Method saves record
     * @return Account - current instance of builder
    */
    public Account save(){
        insert record;
        return record;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description get Method gets building record
     * @return Account building record
    */
    public Account get(){
        return record;
    }
}