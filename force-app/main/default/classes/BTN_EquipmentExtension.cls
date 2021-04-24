public with sharing class BTN_EquipmentExtension {

    public BTN_Equipment__c equipment { get; set; }
    public ApexPages.StandardController stdController;

    public BTN_EquipmentExtension(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String> {
                    String.valueOf(BTN_Equipment__c.Name),
                    String.valueOf(BTN_Equipment__c.Type__c),
                    String.valueOf(BTN_Equipment__c.Contact__c),
                    String.valueOf(BTN_Equipment__c.Serial_Number__c),
                    String.valueOf(BTN_Equipment__c.Contact__c),
                    String.valueOf(BTN_Equipment__c.Company__c),
                    String.valueOf(BTN_Equipment__c.Equipment__c),
                    String.valueOf(BTN_Equipment__c.Equipment_Request__c),
                    String.valueOf(BTN_Equipment__c.Location__c),
                    String.valueOf(BTN_Equipment__c.Manufacturer__c),
                    String.valueOf(BTN_Equipment__c.Model__c),
                    String.valueOf(BTN_Equipment__c.Britenet_ID__c),
                    String.valueOf(BTN_Equipment__c.Description__c),
                    String.valueOf(BTN_Equipment__c.Reserved__c),
                    String.valueOf(BTN_Equipment__c.Active__c),
                    String.valueOf(BTN_Equipment__c.Vendor__c),
                    String.valueOf(BTN_Equipment__c.License_Type__c),
                    String.valueOf(BTN_Equipment__c.License_Name__c),
                    String.valueOf(BTN_Equipment__c.Subscription_Type__c),
                    String.valueOf(BTN_Equipment__c.Phone_Number__c),
                    String.valueOf(BTN_Equipment__c.Phone_Contract__c),
                    String.valueOf(BTN_Equipment__c.Expiration_Date__c)
            });
        }
        this.equipment = (BTN_Equipment__c) stdController.getRecord();
        equipment.Active__c = true;
        queryContactFromEquipment();
        queryContactLocationAndPhone();
        queryContactFromEquipmentRequest();
    }

    public Boolean getIsEquipment() {
        return BTN_RecordTypeUtils.isEquipmentEquipment(equipment);
    }

    public Boolean getIsLicense() {
        return BTN_RecordTypeUtils.isEquipmentLicense(equipment);
    }

    public Boolean getIsPhoneContract() {
        return BTN_RecordTypeUtils.isEquipmentPhoneContract(equipment);
    }

    public void queryContactLocationAndPhone() {
        if (equipment.Contact__c != null) {
            Contact relatedContact = new BTN_DAO_Contact(new List<SObjectField> {
                    Contact.Location__c,
                    Contact.MobilePhone
            }).findContactById(equipment.Contact__c);
            equipment.Location__c = relatedContact.Location__c;
            if (getIsPhoneContract() && String.isBlank(equipment.Phone_Number__c) && String.isNotBlank(relatedContact.MobilePhone)) {
                equipment.Phone_Number__c = relatedContact.MobilePhone;
            }
        }
    }

    public void queryContactFromEquipment() {
        if (equipment.Equipment__c != null) {
            BTN_Equipment__c relatedEquipment = new BTN_DAO_Equipment(new List<SObjectField> {
                    BTN_Equipment__c.Contact__c
            }).findEquipmentById(equipment.Equipment__c);
            equipment.Contact__c = relatedEquipment.Contact__c;
        }
    }

    public void queryContactFromEquipmentRequest() {
        if (equipment.Equipment_Request__c != null) {
            BTN_Equipment_Request__c relatedEquipmentRequest = new BTN_DAO_Equipment_Request(new List<SObjectField> {
                    BTN_Equipment_Request__c.Contact__c
            }).findEquipmentRequestById(equipment.Equipment_Request__c);
            equipment.Contact__c = relatedEquipmentRequest.Contact__c;
        }
    }

    public PageReference saveAndNew() {
        if (stdController.save() == null) {
            return null;
        }
        equipment = new BTN_Equipment__c(
                RecordTypeId = equipment.RecordTypeId,
                Type__c = equipment.Type__c,
                Active__c = true
        );
        return Page.BTN_EquipmentEdit;
    }

}