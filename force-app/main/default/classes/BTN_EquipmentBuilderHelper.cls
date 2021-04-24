public with sharing class BTN_EquipmentBuilderHelper implements BTN_BuilderHelper {

    private BTN_Equipment__c record;

    public static BTN_EquipmentBuilderHelper buildWithEquipmentRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);
    }

    public static BTN_EquipmentBuilderHelper buildWithLicenseRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);
    }

    public static BTN_EquipmentBuilderHelper buildWithPhoneContractRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeEquipmentPhoneContract().Id);
    }

    public BTN_Equipment__c get() {
        return record;
    }

    public BTN_Equipment__c save() {
        insert record;
        return record;
    }

    public static BTN_EquipmentBuilderHelper buildFrom(BTN_Equipment__c equipment) {
        BTN_EquipmentBuilderHelper equipmentBuilderHelper = new BTN_EquipmentBuilderHelper();
        equipmentBuilderHelper.record = equipment;
        return equipmentBuilderHelper;
    }

    private static BTN_EquipmentBuilderHelper buildWith(String recordTypeId) {
        BTN_EquipmentBuilderHelper equipmentBuilderHelper = new BTN_EquipmentBuilderHelper();
        equipmentBuilderHelper.record = new BTN_Equipment__c(
                RecordTypeId = recordTypeId
        );
        return equipmentBuilderHelper;
    }

    private BTN_EquipmentBuilderHelper buildWithDefaults(String recordTypeId) {
        BTN_EquipmentBuilderHelper equipmentBuilderHelper = buildWith(recordTypeId);
        applyDefaults();
        return equipmentBuilderHelper;
    }

    public BTN_EquipmentBuilderHelper applyDefaults() {
        record.Active__c = true;
        record.Reserved__c = false;
        return this;
    }

    public BTN_EquipmentBuilderHelper withType(String type) {
        record.Type__c = type;
        return this;
    }

    public BTN_EquipmentBuilderHelper withManufacturer(String manufacturer) {
        record.Manufacturer__c = manufacturer;
        return this;
    }

    public BTN_EquipmentBuilderHelper withModel(String model) {
        record.Model__c = model;
        return this;
    }

    public BTN_EquipmentBuilderHelper withSerialNumber(String serialNumber) {
        record.Serial_Number__c = serialNumber;
        return this;
    }

    public BTN_EquipmentBuilderHelper withBritenetId(String britenetId) {
        record.Britenet_ID__c = britenetId;
        return this;
    }

    public BTN_EquipmentBuilderHelper withLicenseName(String licenseName) {
        record.License_Name__c = licenseName;
        return this;
    }

    public BTN_EquipmentBuilderHelper withLicenseType(String licenseType) {
        record.License_Type__c = licenseType;
        return this;
    }

    public BTN_EquipmentBuilderHelper withExpirationDate(Date expirationDate) {
        record.Expiration_Date__c = expirationDate;
        return this;
    }

    public BTN_EquipmentBuilderHelper withPhoneNumber(String phoneNumber) {
        record.Phone_Number__c = phoneNumber;
        return this;
    }

    public BTN_EquipmentBuilderHelper withContact(Id contactId) {
        record.Contact__c = contactId;
        return this;
    }

    public BTN_EquipmentBuilderHelper withEquipment(Id equipmentId) {
        record.Equipment__c = equipmentId;
        return this;
    }

    public BTN_EquipmentBuilderHelper withPhoneContract(Id phoneContractId) {
        record.Phone_Contract__c = phoneContractId;
        return this;
    }

}