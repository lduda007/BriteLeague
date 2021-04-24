@isTest
private class BTN_EquipmentTriggerHandler_Test {

    testMethod static void testSendingNewGearToBSAfterInsertingEquipment() {
        BTN_BSS_DTO.GearResponseStatus response;
        System.runAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(
                    BTN_BSS_Mockup.SET_NEW_GEAR_MODE,
                    BTN_BSS_Mockup.SUCCESS_STATUS_CODE)
            );
            BTN_Equipment__c equipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);
        }
    }

    testMethod static void testUpdatingGearToBSAfterInsertingEquipment() {
        BTN_BSS_DTO.GearResponseStatus response;
        System.runAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(
                    BTN_BSS_Mockup.SET_NEW_GEAR_MODE,
                    BTN_BSS_Mockup.SUCCESS_STATUS_CODE)
            );
            BTN_Equipment__c equipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);
            equipment.Type__c = 'Monitor';
            update equipment;
        }
    }

}