/**
 * @author Mateusz Przywara
 * @date   2016-07-13
 * @description Utils class for Record Type
 */
public class BTN_RecordTypeUtils {
    public static final String SOBJECT_NAME_ACCOUNT = Account.getSObjectType().getDescribe().getName();
    public static final String SOBJECT_NAME_CASE = Case.getSObjectType().getDescribe().getName();
    public static final String SOBJECT_NAME_CONTACT = Contact.getSObjectType().getDescribe().getName();
    public static final String SOBJECT_NAME_BTN_CV = BTN_CV__c.getSObjectType().getDescribe().getName();
    public static final String SOBJECT_NAME_BTN_RESOURCE_REQUEST = BTN_ResourceRequest__c.getSObjectType().getDescribe().getName();
    public static final String SOBJECT_NAME_OPPORTUNITY = Opportunity.getSObjectType().getDescribe().getName();
    public static final String SOBJECT_NAME_EVENT = Event.getSObjectType().getDescribe().getName();
    public static final String SOBJECT_NAME_CUSTOMEVENT = BTN_Event__c.getSObjectType().getDescribe().getName();
    public static final String SOBJECT_NAME_EQUIPMENT = BTN_Equipment__c.getSObjectType().getDescribe().getName();
    public static final String ACCOUNT_BRITENET_RECORDTYPE = 'Britenet';
    public static final String ACCOUNT_PRIVATE_SECTOR_RECORDTYPE = 'Private Sector';
    public static final String ACCOUNT_PUBLIC_SECTOR_RECORDTYPE = 'Public Sector';
    public static final String RESOURCE_REQUEST_AUTO_RECORDTYPE = 'Auto';
    public static final String RESOURCE_REQUEST_MANUAL_RECORDTYPE = 'Manual';
    public static final String CASE_EXTERNAL_OFFBOARDING_RECORDTYPE = 'External Offboarding';
    public static final String CASE_EXTERNAL_ONBOARDING_RECORDTYPE = 'External Onboarding';
    public static final String CASE_INTERNAL_OFFBOARDING_RECORDTYPE = 'Internal Offboarding';
    public static final String CASE_INTERNAL_ONBOARDING_RECORDTYPE = 'Internal Onboarding';
    public static final String CONTACT_BUSINESS_RECORDTYPE = 'Business';
    public static final String CONTACT_INTERNAL_RECORDTYPE = 'Internal';
    public static final String CONTACT_RECRUIT_RECORDTYPE = 'Recruit';
    public static final String OPPORTUNITY_FIXED_PRICE_RECORDTYPE = 'Fixed price';
    public static final String OPPORTUNITY_SUPPORT_RECORDTYPE = 'Support';
    public static final String OPPORTUNITY_TIME_MATERIAL_RECORDTYPE = 'Time & Material';
    public static final String CANDIDATE_INTERNAL_RECORDTYPE = 'Internal';
    public static final String CANDIDATE_EXTERNAL_RECORDTYPE = 'External';
    public static final String EVENT_INTERNAL_RECORDTYPE = 'Internal';
    public static final String EVENT_EXTERNAL_RECORDTYPE = 'External';
    public static final String CUSTOMEVENT_GENERAL_RECORDTYPE = 'General';
    public static final String CUSTOMEVENT_INTERVIEW_RECORDTYPE = 'Interview';
    public static final String CUSTOMEVENT_PERIODIC_RECORDTYPE = 'Periodic Assessment';
    public static final String EQUIPMENT_EQUIPMENT_RECORDTYPE = 'Equipment';
    public static final String EQUIPMENT_LICENSE_RECORDTYPE = 'License';
    public static final String EQUIPMENT_PHONE_CONTRACT_RECORDTYPE = 'Phone Contract';
    private static final String SEPARATOR = '_';

    // List of Supported sObjects
    private static final Set<String> OBJECT_NAMES = new Set<String> {
            SOBJECT_NAME_ACCOUNT,
            SOBJECT_NAME_CASE,
            SOBJECT_NAME_CONTACT,
            SOBJECT_NAME_BTN_CV,
            SOBJECT_NAME_BTN_RESOURCE_REQUEST,
            SOBJECT_NAME_OPPORTUNITY,
            SOBJECT_NAME_CUSTOMEVENT,
            SOBJECT_NAME_EVENT,
            SOBJECT_NAME_EQUIPMENT
    };

    public static Map<String,RecordType> MAP_RECORD_TYPE_NAME_2_RECORD_TYPE;
    public static Map<String,List<RecordType>> MAP_SOBJECT_NAME_2_RECORD_TYPES_LIST;

    static {
        MAP_RECORD_TYPE_NAME_2_RECORD_TYPE = createMapOfRecordTypeName2RecordTypes(
                new BTN_DAO_RecordType().findRecordTypesForSObjectSet(OBJECT_NAMES)
        );
        MAP_SOBJECT_NAME_2_RECORD_TYPES_LIST = createMapOfSObjectName2RecordTypesList(
                MAP_RECORD_TYPE_NAME_2_RECORD_TYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeCandidateInternal method - returns record type Internal for Candidate
     * @return RecordType
    */
    public static RecordType getRecordTypeCandidateInternal() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_BTN_CV + SEPARATOR + CANDIDATE_INTERNAL_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeCandidateExternal method - returns record type External for Candidate
     * @return RecordType
    */
    public static RecordType getRecordTypeCandidateExternal() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_BTN_CV + SEPARATOR + CANDIDATE_EXTERNAL_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeEventInternal method - returns record type Internal for Event
     * @return RecordType
    */
    public static RecordType getRecordTypeEventInternal() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_EVENT + SEPARATOR + EVENT_INTERNAL_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeCandidateExternal method - returns record type External for Event
     * @return RecordType
    */
    public static RecordType getRecordTypeEventExternal() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_EVENT + SEPARATOR + EVENT_EXTERNAL_RECORDTYPE
        );
    }
    
    /**
    * @author Dariusz Chmiela
    * @date 2016-09-20
    * @description getRecordTypeAccountBritenet method - returns record type BRITENET for Account
    * @return RecordType
    */
    public static RecordType getRecordTypeAccountBritenet() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_ACCOUNT + SEPARATOR + ACCOUNT_BRITENET_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeAccountPrivateSector method - returns record type PRIVATE SECTOR for Account
     * @return RecordType
    */
    public static RecordType getRecordTypeAccountPrivateSector() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_ACCOUNT + SEPARATOR + ACCOUNT_PRIVATE_SECTOR_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeAccountPublicSector method - returns record type PUBLIC SECTOR for Account
     * @return RecordType
    */
    public static RecordType getRecordTypeAccountPublicSector() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_ACCOUNT + SEPARATOR + ACCOUNT_PUBLIC_SECTOR_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeResourceRequestAuto method - returns record type AUTO for Resource Request
     * @return RecordType
    */
    public static RecordType getRecordTypeResourceRequestAuto() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_BTN_RESOURCE_REQUEST + SEPARATOR + RESOURCE_REQUEST_AUTO_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeResourceRequestAuto method - returns record type AUTO for Resource Request
     * @return RecordType
    */
    public static RecordType getRecordTypeResourceRequestManual() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_BTN_RESOURCE_REQUEST + SEPARATOR + RESOURCE_REQUEST_MANUAL_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeCaseExternalOffBoarding method - returns record type EXTERNAL OFFBOARDING for Case
     * @return RecordType
    */
    public static RecordType getRecordTypeCaseExternalOffBoarding() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_CASE + SEPARATOR + CASE_EXTERNAL_OFFBOARDING_RECORDTYPE
        );
    }

    /**
     * @author Mateusz Przywara
     * @date 2016-10-12
     * @description getRecordTypeCustomEventInterview method - returns record type Interview for BTN_Event__c
     * @return RecordType
    */
    public static RecordType getRecordTypeCustomEventInterview() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_CUSTOMEVENT + SEPARATOR + CUSTOMEVENT_INTERVIEW_RECORDTYPE
        );
    }

    /**
     * @author Mateusz Przywara
     * @date 2016-10-12
     * @description getRecordTypeCustomEventGeneral method - returns record type Genral for BTN_Event__c
     * @return RecordType
    */
    public static RecordType getRecordTypeCustomEventGeneral() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_CUSTOMEVENT + SEPARATOR + CUSTOMEVENT_GENERAL_RECORDTYPE
        );
    }
    
    /**
     * @author Wojciech Mazur
     * @date 2016-12-14
     * @description getRecordTypeCustomEventPeriodicAssessment method - returns record type Personal Asessment for Event
     * @return RecordType
    */
    public static RecordType getRecordTypeCustomEventPeriodicAssessment() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_CUSTOMEVENT + SEPARATOR + CUSTOMEVENT_PERIODIC_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeCaseExternalOnBoarding method - returns record type EXTERNAL ONBOARDING for Case
     * @return RecordType
    */
    public static RecordType getRecordTypeCaseExternalOnBoarding() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_CASE + SEPARATOR + CASE_EXTERNAL_ONBOARDING_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeCaseInternalOnBoarding method - returns record type INTERNAL ONBOARDING for Case
     * @return RecordType
    */
    public static RecordType getRecordTypeCaseInternalOnBoarding() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_CASE + SEPARATOR + CASE_INTERNAL_ONBOARDING_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeCaseInternalOffBoarding method - returns record type INTERNAL ONBOARDING for Case
     * @return RecordType
    */
    public static RecordType getRecordTypeCaseInternalOffBoarding() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_CASE + SEPARATOR + CASE_INTERNAL_OFFBOARDING_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeContactBusiness method - returns record type BUSINESS for Contact
     * @return RecordType
    */
    public static RecordType getRecordTypeContactBusiness() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_CONTACT + SEPARATOR + CONTACT_BUSINESS_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeContactInternal method - returns record type INTERNAL for Contact
     * @return RecordType
    */
    public static RecordType getRecordTypeContactInternal() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_CONTACT + SEPARATOR + CONTACT_INTERNAL_RECORDTYPE
        );
    }
    
    /**
     * @author Wojciech Mazur
     * @date 2016-09-20
     * @description getRecordTypeContactRecruit method - returns record type RECRUIT for Contact
     * @return RecordType
    */
    public static RecordType getRecordTypeContactRecruit() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_CONTACT + SEPARATOR + CONTACT_RECRUIT_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeOpportunityFixedPrice method - returns record type FIXED PRICE for Opportunity
     * @return RecordType
    */
    public static RecordType getRecordTypeOpportunityFixedPrice() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_OPPORTUNITY + SEPARATOR + OPPORTUNITY_FIXED_PRICE_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeOpportunityTimeMaterial method - returns record type TIME & MATERIAL for Opportunity
     * @return RecordType
    */
    public static RecordType getRecordTypeOpportunityTimeMaterial() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_OPPORTUNITY + SEPARATOR + OPPORTUNITY_TIME_MATERIAL_RECORDTYPE
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeOpportunitySupport method - returns record type SUPPORT for Opportunity
     * @return RecordType
    */
    public static RecordType getRecordTypeOpportunitySupport() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_OPPORTUNITY + SEPARATOR + OPPORTUNITY_SUPPORT_RECORDTYPE
        );
    }

    public static RecordType getRecordTypeEquipmentEquipment() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_EQUIPMENT + SEPARATOR + EQUIPMENT_EQUIPMENT_RECORDTYPE
        );
    }

    public static RecordType getRecordTypeEquipmentLicense() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_EQUIPMENT + SEPARATOR + EQUIPMENT_LICENSE_RECORDTYPE
        );
    }

    public static RecordType getRecordTypeEquipmentPhoneContract() {
        return MAP_RECORD_TYPE_NAME_2_RECORD_TYPE.get(
                SOBJECT_NAME_EQUIPMENT + SEPARATOR + EQUIPMENT_PHONE_CONTRACT_RECORDTYPE
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description isCaseInternalOnBoarding Test Record Type of SFDC Case
     * @param caseObject SFDC Case
     * @return Boolean Is Case InternalOnBoarding?
    */
    public static Boolean isCaseInternalOnBoarding(Case caseObject) {
        return caseObject.RecordTypeId == BTN_RecordTypeUtils.getRecordTypeCaseInternalOnBoarding().Id;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description isCaseInternalOffBoarding Test Record Type of SFDC Case
     * @param caseObject SFDC Case
     * @return Boolean Is Case InternalOffBoarding?
    */
    public static Boolean isCaseInternalOffBoarding(Case caseObject) {
        return caseObject.RecordTypeId == BTN_RecordTypeUtils.getRecordTypeCaseInternalOffBoarding().Id;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description isCaseExternalOnBoarding Test Record Type of SFDC Case
     * @param caseObject SFDC Case
     * @return Boolean Is Case ExternalOnBoarding?
    */
    public static Boolean isCaseExternalOnBoarding(Case caseObject) {
        return caseObject.RecordTypeId == BTN_RecordTypeUtils.getRecordTypeCaseExternalOnBoarding().Id;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description isCaseExternalOffBoarding Test Record Type of SFDC Case
     * @param caseObject SFDC Case
     * @return Boolean Is Case ExternalOffBoarding?
    */
    public static Boolean isCaseExternalOffBoarding(Case caseObject) {
        return caseObject.RecordTypeId == BTN_RecordTypeUtils.getRecordTypeCaseExternalOffBoarding().Id;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description isCaseExternal Test Record Type of SFDC Case
     * @param caseObject SFDC Case
     * @return Boolean Is Case ExternalOffBoarding or External Onboarding?
    */
    public static Boolean isCaseExternal(Case caseObject) {
        return isCaseExternalOffBoarding(caseObject) || isCaseExternalOnBoarding(caseObject);
    }

    public static Boolean isEquipmentEquipment(BTN_Equipment__c equipment) {
        return equipment.RecordTypeId == BTN_RecordTypeUtils.getRecordTypeEquipmentEquipment().Id;
    }

    public static Boolean isEquipmentLicense(BTN_Equipment__c equipment) {
        return equipment.RecordTypeId == BTN_RecordTypeUtils.getRecordTypeEquipmentLicense().Id;
    }

    public static Boolean isEquipmentPhoneContract(BTN_Equipment__c equipment) {
        return equipment.RecordTypeId == BTN_RecordTypeUtils.getRecordTypeEquipmentPhoneContract().Id;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description isInterview Test Record Type of BTN_Event__c
     * @param caseObject SFDC Case
     * @return Boolean Is Case ExternalOffBoarding?
    */
    public static Boolean isInterview(BTN_Event__c eventItem) {
        return eventItem.RecordTypeId == BTN_RecordTypeUtils.getRecordTypeCustomEventInterview().Id;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description isGeneral Test Record Type of BTN_Event__c
     * @param caseObject SFDC Case
     * @return Boolean Is Case ExternalOffBoarding?
    */
    public static Boolean isGeneral(BTN_Event__c eventItem) {
        return eventItem.RecordTypeId == BTN_RecordTypeUtils.getRecordTypeCustomEventGeneral().Id;
    }


    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description isRecruit Test Record Type of Contact
     * @param contactItem SFDC Contact
     * @return Boolean Is Contact Recruit?
    */
    public static Boolean isRecruit(Contact contactItem) {
        return contactItem.RecordTypeId == BTN_RecordTypeUtils.getRecordTypeContactRecruit().Id;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-28
     * @description createMapOfSObjectName2RecordTypesList create map SObject Name to List of related Record Types
     * @return Map of Record Types by Record Type Name
     * @return Boolean Is Case ExternalOffBoarding?
    */
    private static Map<String,List<RecordType>> createMapOfSObjectName2RecordTypesList(
            Map<String, RecordType> rtMap
    ) {
        Map<String, List<RecordType>> result = new Map<String, List<RecordType>>();
        for (RecordType rtItem : rtMap.values()) {
            if (result.containsKey(rtItem.SobjectType)) {
                result.get(rtItem.SobjectType).add(rtItem);
            } else {
                result.put(rtItem.SobjectType, new List<RecordType>{rtItem});
            }
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-28
     * @description createMapOfRecordTypeName2RecordTypes
     * @param rtMap
     * @return Map<String,List<RecordType>>
    */
    private static Map<String, RecordType> createMapOfRecordTypeName2RecordTypes(
            List<RecordType> recordTypeList
    ) {
        Map<String, RecordType> result = new Map<String, RecordType>();
        for (RecordType rtItem : recordTypeList) {
            result.put(rtItem.SObjectType + SEPARATOR + rtItem.Name, rtItem);
        }
        return result;
    }
}