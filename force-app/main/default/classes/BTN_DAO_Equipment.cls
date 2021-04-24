public with sharing class BTN_DAO_Equipment extends BTN_DAO {

    public BTN_DAO_Equipment() {

    }

    public BTN_DAO_Equipment(List<SObjectField> customFields) {
        setCustomFields(customFields);
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                BTN_Equipment__c.Name,
                BTN_Equipment__c.Active__c,
                BTN_Equipment__c.Britenet_ID__c,
                BTN_Equipment__c.Company__c,
                BTN_Equipment__c.Contact__c,
                BTN_Equipment__c.Description__c,
                BTN_Equipment__c.Equipment__c,
                BTN_Equipment__c.Expiration_Date__c,
                BTN_Equipment__c.License_Name__c,
                BTN_Equipment__c.License_Type__c,
                BTN_Equipment__c.Location__c,
                BTN_Equipment__c.Manufacturer__c,
                BTN_Equipment__c.Model__c,
                BTN_Equipment__c.Reserved__c,
                BTN_Equipment__c.Serial_Number__c,
                BTN_Equipment__c.Subscription_Type__c,
                BTN_Equipment__c.Type__c,
                BTN_Equipment__c.Vendor__c
        };
    }

    public BTN_Equipment__c findEquipmentById(Id equipmentId) {
        return (BTN_Equipment__c) findSObjectById(equipmentId);
    }

    public override SObjectType getSObjectType() {
        return BTN_Equipment__c.SObjectType;
    }

}