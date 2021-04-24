@isTest
private class BTN_EquipmentFactory_Test {

    @testSetup static void createDataStructure() {
        BTN_TestDataFactory.getHRCollaborationGroup();
        BTN_TestDataFactory.getBriteNetAccount();
    }

    testMethod static void testCreateGearParamsFromEquipment() {
        Contact equipmentContact = BTN_TestDataFactory.getInternalContact(BTN_TestDataFactory.getBriteNetAccount().Id);
        BTN_Equipment__c equipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);
        equipment.Contact__c = equipmentContact.Id;

        Test.startTest();
        BTN_EquipmentFactory equipmentFactory = new BTN_EquipmentFactory(new List<BTN_Equipment__c> { equipment });
        Map<String, String> result = equipmentFactory.createGearParamsFromEquipment(equipment, true);
        Test.stopTest();

        System.assert(!result.isEmpty());
    }

    testMethod static void testCreateGearFromEquipment() {
        BTN_Equipment__c equipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);

        Test.startTest();
        BTN_EquipmentFactory equipmentFactory = new BTN_EquipmentFactory(new List<BTN_Equipment__c> { equipment });
        BTN_BSS_DTO.Gear result = equipmentFactory.createGearFromEquipment(equipment);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    testMethod static void testCreateEquipmentFromGear() {
        Contact equipmentContact = BTN_TestDataFactory.getInternalContact(BTN_TestDataFactory.getBriteNetAccount().Id);
        BTN_Equipment__c equipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);
        equipment.Contact__c = equipmentContact.Id;

        Test.startTest();
        BTN_EquipmentFactory equipmentFactory = new BTN_EquipmentFactory();
        BTN_BSS_DTO.Gear gear = equipmentFactory.createGearFromEquipment(equipment);
        BTN_Equipment__c result = equipmentFactory.createEquipmentFromGear(gear);
        Test.stopTest();

        System.assertEquals(equipment.Type__c, result.Type__c);
    }

}