public with sharing class BTN_PhoneContractBuilderHelper implements BTN_BuilderHelper {

    private BTN_Phone_Contract__c record;

    public BTN_Phone_Contract__c get() {
        return record;
    }

    public BTN_PhoneContractBuilderHelper save() {
        insert record;
        return this;
    }

    public static BTN_PhoneContractBuilderHelper build() {
        BTN_PhoneContractBuilderHelper phoneContractBuilderHelper = new BTN_PhoneContractBuilderHelper();
        phoneContractBuilderHelper.record = new BTN_Phone_Contract__c();
        return phoneContractBuilderHelper;
    }

}