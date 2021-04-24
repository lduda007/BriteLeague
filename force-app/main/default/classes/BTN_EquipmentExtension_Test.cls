@isTest
private class BTN_EquipmentExtension_Test {

    private static final String CONTACT_PHONE_NUMBER = '123456789';
    private static final String CONTACT_LOCATION = 'Lublin Morwowa';
    private static final String EQUIPMENT_SERIAL_NUMBER = 'ABCD-EFGH-IJKL-MNOP';
    private static final String EQUIPMENT_BRITENET_ID = 'BTN 1234';

    @testSetup static void createDataStructure() {
        BTN_TestDataFactory.getHRCollaborationGroup();
        Account britenetAccount = BTN_TestDataFactory.getBriteNetAccount();
        Contact internalContact = BTN_TestDataFactory.getInternalContact(britenetAccount.Id);
        internalContact.MobilePhone = CONTACT_PHONE_NUMBER;
        internalContact.Location__c = CONTACT_LOCATION;
        update internalContact;
    }

    @isTest static void testSavingEquipmentWithoutContactAssigned() {
        BTN_Equipment__c baseEquipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);

        Test.startTest();
        BTN_EquipmentExtension extension = new BTN_EquipmentExtension(new ApexPages.StandardController(baseEquipment));
        extension.equipment.Location__c = CONTACT_LOCATION;
        extension.stdController.save();
        Test.stopTest();

        Integer equipmentCount = new BTN_DAO_Equipment().countSObjectsBy(new List<BTN_DAO.SearchCondition>{
                new BTN_DAO.SearchCondition(String.valueOf(BTN_Equipment__c.Location__c), '=', CONTACT_LOCATION)
        });
        System.assertEquals(1, equipmentCount, 'Equipment should have Location from Contact');
    }

    @isTest static void testSavingEquipmentWithContactAssigned() {
        Contact internalContact = (Contact) new BTN_DAO_Contact(new List<SObjectField>{
                Contact.Id, Contact.Name
        }).findSObjectsBy(new List<BTN_DAO.SearchCondition>{
                new BTN_DAO.SearchCondition(String.valueOf(Contact.Location__c), '=', CONTACT_LOCATION)
        }).get(0);
        BTN_Equipment__c baseEquipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);

        Test.startTest();
        BTN_EquipmentExtension extension = new BTN_EquipmentExtension(new ApexPages.StandardController(baseEquipment));
        extension.equipment.Contact__c = internalContact.Id;
        extension.queryContactLocationAndPhone();
        extension.stdController.save();
        Test.stopTest();

        Integer equipmentCount = new BTN_DAO_Equipment().countSObjectsBy(new List<BTN_DAO.SearchCondition>{
                new BTN_DAO.SearchCondition(String.valueOf(BTN_Equipment__c.Location__c), '=', CONTACT_LOCATION)
        });
        System.assertEquals(1, equipmentCount);
    }

    @isTest static void testSavingEquipmentWithDuplicatedBritenetId() {
        BTN_Equipment__c baseEquipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);

        Test.startTest();
        BTN_EquipmentExtension extension = new BTN_EquipmentExtension(new ApexPages.StandardController(baseEquipment));
        extension.equipment.Britenet_ID__c = EQUIPMENT_BRITENET_ID;
        extension.stdController.save();
        Test.stopTest();

        Integer equipmentCount = new BTN_DAO_Equipment().countSObjectsBy(new List<BTN_DAO.SearchCondition>{
                new BTN_DAO.SearchCondition(String.valueOf(BTN_Equipment__c.Britenet_ID__c), '=', EQUIPMENT_BRITENET_ID)
        });
        System.assertEquals(1, equipmentCount);
    }

    @isTest static void testSavingEquipmentWithDuplicatedSerialNumber() {
        BTN_Equipment__c baseEquipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);

        Test.startTest();
        BTN_EquipmentExtension extension = new BTN_EquipmentExtension(new ApexPages.StandardController(baseEquipment));
        extension.equipment.Serial_Number__c = EQUIPMENT_SERIAL_NUMBER;
        extension.stdController.save();
        Test.stopTest();

        Integer equipmentCount = new BTN_DAO_Equipment().countSObjectsBy(new List<BTN_DAO.SearchCondition>{
                new BTN_DAO.SearchCondition(String.valueOf(BTN_Equipment__c.Serial_Number__c), '=', EQUIPMENT_SERIAL_NUMBER)
        });
        System.assertEquals(1, equipmentCount);
    }

    @isTest static void testSavingLicenseWithEquipmentAssigned() {
        BTN_Equipment__c baseEquipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentLicense().Id);
        BTN_Equipment__c parentEquipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id);

        Test.startTest();
        BTN_EquipmentExtension extension = new BTN_EquipmentExtension(new ApexPages.StandardController(baseEquipment));
        extension.equipment.Equipment__c = parentEquipment.Id;
        extension.stdController.save();
        Test.stopTest();

        Integer equipmentCount = new BTN_DAO_Equipment().countSObjectsBy(new List<BTN_DAO.SearchCondition>{
                new BTN_DAO.SearchCondition(String.valueOf(BTN_Equipment__c.Equipment__c), '=', parentEquipment.Id),
                new BTN_DAO.SearchCondition(String.valueOf(BTN_Equipment__c.Contact__c), '=', parentEquipment.Contact__c)
        }, '{0} AND {1}');
        System.assertEquals(1, equipmentCount);
    }

    @isTest static void testSavingPhoneContractWithContactAssigned() {
        Contact internalContact = (Contact) new BTN_DAO_Contact(new List<SObjectField>{
                Contact.Id, Contact.Name, Contact.MobilePhone, Contact.Location__c
        }).findSObjectsBy(new List<BTN_DAO.SearchCondition>{
                new BTN_DAO.SearchCondition(String.valueOf(Contact.MobilePhone), '=', CONTACT_PHONE_NUMBER),
                new BTN_DAO.SearchCondition(String.valueOf(Contact.Location__c), '=', CONTACT_LOCATION)
        }, '{0} AND {1}').get(0);
        Id equipmentRecordTypeId = BTN_RecordTypeUtils.getRecordTypeEquipmentPhoneContract().Id;
        BTN_Equipment__c baseEquipment = BTN_TestDataFactory.getEquipment(equipmentRecordTypeId);

        Test.startTest();
        BTN_EquipmentExtension extension = new BTN_EquipmentExtension(new ApexPages.StandardController(baseEquipment));
        extension.equipment.Contact__c = internalContact.Id;
        extension.equipment.Phone_Number__c = '';
        extension.queryContactLocationAndPhone();
        extension.stdController.save();
        Test.stopTest();

        Integer equipmentCount = new BTN_DAO_Equipment().countSObjectsBy(new List<BTN_DAO.SearchCondition>{
                new BTN_DAO.SearchCondition(String.valueOf(BTN_Equipment__c.Phone_Number__c), '=', CONTACT_PHONE_NUMBER),
                new BTN_DAO.SearchCondition(String.valueOf(BTN_Equipment__c.Location__c), '=', CONTACT_LOCATION)
        }, '{0} AND {1}');
        System.assertEquals(1, equipmentCount);
    }

    @isTest static void testSavingPhoneContractWithoutContactAssigned() {
        BTN_Equipment__c baseEquipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentPhoneContract().Id);

        Test.startTest();
        BTN_EquipmentExtension extension = new BTN_EquipmentExtension(new ApexPages.StandardController(baseEquipment));
        extension.stdController.save();
        Test.stopTest();

        Integer equipmentCount = new BTN_DAO_Equipment().countSObjects();
        System.assertEquals(1, equipmentCount);
    }

    @isTest static void testSaveAndNew() {
        BTN_Equipment__c baseEquipment = BTN_TestDataFactory.getEquipment(BTN_RecordTypeUtils.getRecordTypeEquipmentPhoneContract().Id);

        Test.startTest();
        BTN_EquipmentExtension extension = new BTN_EquipmentExtension(new ApexPages.StandardController(baseEquipment));
        PageReference result = extension.saveAndNew();
        Test.stopTest();

        Integer equipmentCount = new BTN_DAO_Equipment().countSObjects();
        System.assertEquals(1, equipmentCount);
        System.assertEquals(result.getUrl(), Page.BTN_EquipmentEdit.getUrl());
    }

}