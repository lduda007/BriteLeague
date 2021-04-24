public with sharing class BTN_EquipmentTriggerHandler implements TriggerHandler {

    private Map<Id, BTN_Equipment__c> newEquipment = new Map<Id, BTN_Equipment__c>();
    private Set<Id> equipmentOwnersIds = new Set<Id>();
    private BTN_EquipmentFactory equipmentFactory;

    public void bulkBefore() {

    }

    public void bulkAfter() {
        if (Trigger.isInsert) {
            newEquipment = (Map<Id, BTN_Equipment__c>) Trigger.newMap;
        } else if (Trigger.isUpdate) {
            for (Id equipmentId : Trigger.newMap.keySet()) {
                if (BTN_ValidationHandler.isChanged(Trigger.newMap.get(equipmentId), Trigger.oldMap.get(equipmentId))) {
                    newEquipment.put(equipmentId, (BTN_Equipment__c) Trigger.newMap.get(equipmentId));
                }
            }
        }
        equipmentFactory = new BTN_EquipmentFactory(newEquipment.values());
    }

    public void beforeInsert(SObject equipment) {

    }

    public void beforeUpdate(SObject oldEquipment, SObject equipment) {

    }

    public void beforeDelete(SObject equipment) {

    }

    public void afterInsert(SObject equipment) {
        Map<String, String> gearParams = equipmentFactory.createGearParamsFromEquipment((BTN_Equipment__c) equipment, Trigger.isUpdate);
        setGear(gearParams, equipment.Id);
    }

    public void afterUpdate(SObject oldEquipment, SObject equipment) {
        Map<String, String> gearParams = equipmentFactory.createGearParamsFromEquipment((BTN_Equipment__c) equipment, Trigger.isUpdate);
        gearParams.put('gear_id', equipment.Id);
        setGear(gearParams, equipment.Id);
    }

    public void afterDelete(SObject equipment) {

    }

    public void andFinally() {

    }

    @future(Callout=true)
    public static void setGear(Map<String, String> gearParams, Id equipmentId) {
        BTN_BSS_DTO.GearResponseStatus response = BTN_BSS_Service.setGear(gearParams);
        if (response != null && response.status == BTN_BSS_DTO.STATUS_SUCCESS) {
            BTN_Equipment__c equipment = [SELECT Id, BS_External_Id__c FROM BTN_Equipment__c WHERE Id = :equipmentId];
            equipment.BS_External_Id__c = response.gear_id;
            update equipment;
        }
    }

}