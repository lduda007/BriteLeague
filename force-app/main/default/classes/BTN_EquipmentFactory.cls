public with sharing class BTN_EquipmentFactory {

    private static final String EQUIPMENT_TYPE_LICENSE = 'Licencja';
    private static final String EQUIPMENT_TYPE_PHONE_CONTRACT = 'Karta SIM';

    private List<BTN_Equipment__c> equipmentList = new List<BTN_Equipment__c>();
    private Map<Id, Integer> contactIdToBSIdMap = new Map<Id, Integer>();
    private Map<Integer, Id> contactBSIdToIdMap = new Map<Integer, Id>();
    private List<Contact> equipmentContacts = new List<Contact>();

    public BTN_EquipmentFactory(List<BTN_Equipment__c> equipment) {
        this.equipmentList = equipment;
        this.equipmentContacts = getEquipmentContacts(equipment);
        createContactToBSIdMap(this.equipmentContacts);
    }

    public BTN_EquipmentFactory() {
        createContactToBSIdMap(new BTN_DAO_Contact(new List<SObjectField> {
                Contact.Id,
                Contact.BSexternalId__c
        }).getAllContacts());
    }

    public Map<String, String> createGearParamsFromEquipment(BTN_Equipment__c equipment, Boolean isUpdate) {
        Map<String, String> gearParams = new Map<String, String>{
                'gear_geartype_name' => setParam(equipment.Type__c),
                'gear_company_name' => setParam(equipment.Company__c),
                'gear_serial' => setParam(equipment.Serial_Number__c),
                'gear_btno' => setParam(equipment.Britenet_ID__c),
                'gear_phone_no' => setParam(equipment.Phone_Number__c),
                'gear_model' => getGearModel(equipment),
                'gear_desc' => setParam(equipment.Description__c)
        };
        if (isUpdate) {
            gearParams.put('gear_id', equipment.Id);
        }
        if (!BTN_ValidationHandler.isNull(equipment.Contact__c)) {
            gearParams.put('user_id', String.valueOf(contactIdToBSIdMap.get(equipment.Contact__c)));
        } else {
            gearParams.put('user_id', '');
        }
        return gearParams;
    }

    public BTN_BSS_DTO.Gear createGearFromEquipment(BTN_Equipment__c equipment) {
        BTN_BSS_DTO.Gear gear = new BTN_BSS_DTO.Gear();
        gear.geartype_description = equipment.Type__c;
        gear.gear_company_name = equipment.Company__c;
        gear.gear_serial = equipment.Serial_Number__c;
        gear.gear_btno = equipment.Britenet_ID__c;
        gear.gear_phone_no = equipment.Phone_Number__c;
        gear.gear_model = getGearModel(equipment);
        gear.gear_desc = equipment.Description__c;
        gear.usergear_user_id = contactIdToBSIdMap.get(equipment.Contact__c);
        gear.gear_deleted = !equipment.Active__c;
        return gear;
    }

    public BTN_Equipment__c createEquipmentFromGear(BTN_BSS_DTO.Gear gear) {
        BTN_Equipment__c equipment = new BTN_Equipment__c(
                BS_External_Id__c = Integer.valueOf(gear.gear_id),
                Type__c = gear.geartype_description,
                Company__c = gear.gear_company_name,
                Serial_Number__c = gear.gear_serial,
                Britenet_ID__c = gear.gear_btno,
                Phone_Number__c = gear.gear_phone_no,
                Description__c = gear.gear_desc,
                Active__c = !gear.gear_deleted
        );
        if (!BTN_ValidationHandler.isNull(gear.usergear_user_id)) {
            equipment.Contact__c = contactBSIdToIdMap.get(gear.usergear_user_id);
        }
        if (String.isNotBlank(gear.gear_model)) {
            List<String> modelParts = gear.gear_model.split(' ');
            equipment.Manufacturer__c = modelParts.get(0);
            modelParts.remove(0);
            equipment.Model__c = String.join(modelParts, ' ');
        }
        if (String.isBlank(equipment.Company__c)) {
            equipment.Company__c = BTN_ConstantRepo.EQUIPMENT_COMPANY_DEFAULT;
        }
        if (equipment.Type__c == EQUIPMENT_TYPE_PHONE_CONTRACT) {
            equipment.RecordTypeId = BTN_RecordTypeUtils.getRecordTypeEquipmentPhoneContract().Id;
        } else if (equipment.Type__c == EQUIPMENT_TYPE_LICENSE) {
            equipment.RecordTypeId = BTN_RecordTypeUtils.getRecordTypeEquipmentLicense().Id;
        }
        return equipment;
    }

    private String getGearModel(BTN_Equipment__c equipment) {
        List<String> modelParts = new List<String>();
        if (!BTN_ValidationHandler.isNull(equipment.Manufacturer__c)) {
            modelParts.add(equipment.Manufacturer__c);
        }
        if (!BTN_ValidationHandler.isNull(equipment.License_Name__c)) {
            modelParts.add(equipment.License_Name__c);
        }
        if (!BTN_ValidationHandler.isNull(equipment.Model__c)) {
            modelParts.add(equipment.Model__c);
        }
        return String.join(modelParts, ' ');
    }

    public void createContactToBSIdMap(List<Contact> contacts) {
        contactIdToBSIdMap = new Map<Id, Integer>();
        contactBSIdToIdMap = new Map<Integer, Id>();
        for (Contact contactItem : contacts) {
            Integer contactBSId = Integer.valueOf(contactItem.BSexternalId__c);
            contactIdToBSIdMap.put(contactItem.Id, contactBSId);
            contactBSIdToIdMap.put(contactBSId, contactItem.Id);
        }
    }

    public List<Contact> getEquipmentContacts(List<BTN_Equipment__c> equipment) {
        Set<Id> equipmentContacts = new Set<Id>();
        for (BTN_Equipment__c singleEquipment : equipment) {
            if (!BTN_ValidationHandler.isNull(singleEquipment.Contact__c)) {
                equipmentContacts.add(singleEquipment.Contact__c);
            }
        }
        return new BTN_DAO_Contact(new List<Schema.SObjectField>{
                Contact.Id,
                Contact.BSexternalId__c
        }).findContactsByIds(equipmentContacts);
    }

    private String setParam(String value) {
        return String.isNotBlank(value) ? value : '';
    }

}