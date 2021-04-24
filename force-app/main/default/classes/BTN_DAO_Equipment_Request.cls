public with sharing class BTN_DAO_Equipment_Request extends BTN_DAO {

    public BTN_DAO_Equipment_Request() {

    }

    public BTN_DAO_Equipment_Request(List<SObjectField> customFields) {
        setCustomFields(customFields);
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                BTN_Equipment_Request__c.Name,
                BTN_Equipment_Request__c.Contact__c,
                BTN_Equipment_Request__c.Due_Date__c,
                BTN_Equipment_Request__c.Requested_Equipment__c,
                BTN_Equipment_Request__c.Requested_Equipment_Comments__c,
                BTN_Equipment_Request__c.Ready__c
        };
    }

    public BTN_Equipment_Request__c findEquipmentRequestById(Id equipmentRequestId) {
        return (BTN_Equipment_Request__c) findSObjectById(equipmentRequestId);
    }

    public override SObjectType getSObjectType() {
        return BTN_Equipment_Request__c.SObjectType;
    }

}