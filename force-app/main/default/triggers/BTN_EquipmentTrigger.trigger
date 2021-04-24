trigger BTN_EquipmentTrigger on BTN_Equipment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!BTN_TriggerUtils.skipTrigger('BTN_EquipmentTrigger') && !System.isFuture() && !System.isBatch()) {
        TriggerFactory.createHandler(BTN_Equipment__c.SObjectType);
    }
}