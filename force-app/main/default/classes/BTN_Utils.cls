public with sharing class BTN_Utils {
    private static final String NO_CUSTOMSETTING_PROPERTY = 'No custom setting property ';
    private static final String NONE_SELECTED_PICKLIST_TEXT = '--None--';

    public static User currentUser{set; get;}
    private static BTN_DAO_User userDAOLayer{set;
        get {
            if (BTN_ValidationHandler.isNull(userDAOLayer)) {
                userDAOLayer = new BTN_DAO_User().addGoogleFields().addProfileName();
            }
            return userDAOLayer;
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method returns Integer value of provided setting name.
     * @param settingName String Name of Custom Setting property.
     * @return Integer value of provided setting name
    */
    public static Integer getIntegerValueFromCS(String settingName) {
        BTN_UtilitiesSettings__c setting;
        Integer result;
        if ((setting = BTN_UtilitiesSettings__c.getInstance(settingName)) != null) {
            result = Integer.valueOf(setting.IntegerValue__c);
        }
        return result;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method check if Custom Setting property contains String value or not
     * @param settingName String Name of Custom Setting property.
     * @param value String value to check.
     * @return Boolean
    */
    public static Boolean isCSContains(String settingName, String value) {
        BTN_UtilitiesSettings__c setting;
        Boolean result = false;
        try {
            if((setting = BTN_UtilitiesSettings__c.getInstance(settingName)) != null) {
                result = setting.value__c.contains(value);
            }
        } catch (Exception ex) {
            //result = false;
            System.debug(NO_CUSTOMSETTING_PROPERTY + settingName);
        }

        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Caching Current User data. If exist return existing object. If not Query new one.
     * @return User Current User sObject
    */
    public static User getCurrentUser() {
        if (BTN_Utils.currentUser == null) {
            BTN_Utils.currentUser = userDAOLayer.findUserById(UserInfo.getUserId());
        }
        return BTN_Utils.currentUser;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method check if Custom Setting property contains String value or not
     * @param oppoId Id of Opportunity
     * @return Boolean Opportunity has products?
    */
    public static Boolean getOppoHasProducts(String oppoId) {
        return ([SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :oppoId].size() > 0);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method returns Set of available (enabled) Organization Currencies
     * @param all Boolean if true get All Currencies whenever they are active or not.
     * @return Set<String> Set of String consist Currency ISO Codes
    */
    public static Set<String> getAvailableCurrencyIsoCodeList(Boolean all) {
        Set<String> currencyIsoSet = new Set<String>();
        if (all) {
            for(CurrencyType item : [SELECT IsoCode FROM CurrencyType WHERE IsActive = true]) {
                currencyIsoSet.add(item.IsoCode);
            }
        } else {
            for(CurrencyType item : [SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = true]) {
                currencyIsoSet.add(item.IsoCode);
            }
        }
        return currencyIsoSet;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method XOR two sets of String values. XOR means it will return alements not existing in setB.
     * @param setA Set of Strings.
     * @param setB Set of Strings.
     * @return Set<String> Set of Strings not existing in SetA but exist in SetB.
    */
    public static Set<String> setXor(Set<String> setA, Set<String> setB) {
        Set<String> xorResult = new Set<String>();
        Boolean exist = false;
        for (String itemSetA : SetA) {
            for (String itemSetB : SetB) {
                if (itemSetA.equals(itemSetB)) {
                    exist = true;
                }
            }
            if (!exist) {
                xorResult.add(itemSetA);
            }
            exist = false;
        }
        return xorResult;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method returns List of Strings - collected Ids of sObjects.
     * @param sobjectList List of sObjects
     * @return List<String> Ids retrieved from List of sObjects.
    */
    public static List<String> getSObjectIds(List<sObject> sobjectList) {
        List<String> listIds = new List<String>();
        for(sObject item : sobjectList) {
            listIds.add(item.Id);
        }
        return listIds;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Method returns List of Strings - collected Ids of sObjects.
     * @param sobjectList List of sObjects
     * @return Set<Id> Ids retrieved from List of sObjects.
    */
    public static Set<Id> getSetOfIds(List<sObject> sobjectList) {
        return (new Map<Id, sObject>(sobjectList)).keySet();
    }

    /**
     * @author Wojciech Mazur
     * @date   2016-10-04
     * @description Method returns set of Ids - collected Ids of given field.
     * @param sobjectList List of sObjects
     * @param fieldname field name to extract
     * @return Set<Id> Ids retrieved from List of sObjects.
    */
    public static Set<Id> getSetOfIds(List<sObject> sobjectList, String fieldName) {
        Set<Id> listIds = new Set<Id>();
        for(sObject item : sobjectList) {
            if(item.get(fieldName)!=null){
                listIds.add((Id)item.get(fieldName));
            }
        }
        return listIds;
    }

    public static Set<String> getSetOfStrings(List<sObject> sobjectList, String fieldName){
        Set<String> returnSet = new Set<String>();
        for(sObject item : sobjectList) {
            if(item.get(fieldName)!=null){
                returnSet.add((Id)item.get(fieldName));
            }
        }
        return returnSet;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description findAccountByName search for Account
     * @param name Search filter
     * @param accounts List of SFDC Account
     * @return Id Found Account Id
    */
    public static Id findAccountByName(String name, List<Account> accounts) {
        Id result;
        for (Account accountItem : accounts) {
            if (accountItem.Name == name) {
                result = accountItem.Id;
                break;
            }
        }
        return result;
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description buldAssignmentGroupString Build Assignment group for Batch
     * @param contactId Id of Assignment Contact
     * @param accountId Id of Assignment Project Account Id
     * @return  BTN_Assignment__c
    */
    public static String buldAssignmentGroupString(Id contactId, Id accountId) {
        return contactId + ';' + accountId;
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-10-19
     * @description getNullSelectOption Return Default empty SelectOption
     * @return  SelectOption
    */
    public static SelectOption getNullSelectOption() {
        return new SelectOption('', NONE_SELECTED_PICKLIST_TEXT);
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-11-04
     * @description getNullSelectOption Return Default empty SelectOption
     * @return  SelectOption
    */
    public static Boolean isOpenCandidate(BTN_CV__c candidate) {
        return candidate.Status__c.equals(BTN_ConstantRepo.CANDIDATE_STATUS_OPEN);
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-11-04
     * @description getNullSelectOption Return Default empty SelectOption
     * @return  SelectOption
    */
    public static Boolean isInProgressCandidate(BTN_CV__c candidate) {
        return candidate.Status__c.equals(BTN_ConstantRepo.CANDIDATE_STATUS_INTERVIEW_IN_PROGRESS);
    }

    /**
     * @author Pawel Iwanowicz
     * @date   2016-11-30
     * @description postInsertCandidatesStatuses - changes statuses for other Candidates (BRITCRM-353)
    */
    public static void postInsertCandidatesStatuses(Map<Id, BTN_CV__c> newCandidateMap) {
        Map<Id, BTN_CV__c> signedCandidates = new Map<Id, BTN_CV__c>();
        List<Id> signedCandidatesContactsIds = new List<Id>();
        List<String> statuses = new List<String>{
                BTN_ConstantRepo.CANDIDATE_STATUS_OPEN,
                BTN_ConstantRepo.CANDIDATE_STATUS_INTERVIEW_IN_PROGRESS,
                BTN_ConstantRepo.CANDIDATE_STATUS_SUBMITTED_TO_EXTERNAL};

        // We are checking which candidates have status Contract Signed
        for (BTN_CV__c candidate : newCandidateMap.values()) {
            if (candidate.Status__c == BTN_ConstantRepo.CANDIDATE_STATUS_CONTRACT_SIGNED) {
                signedCandidates.put(candidate.Id, candidate);
                signedCandidatesContactsIds.add(candidate.Contact__c);
            }
        }

        // If there are any candidates with status Contract Signed
        if (signedCandidates.size() != 0) {
            List<BTN_CV__c> candidatesToChange = new List<BTN_CV__c>();
            candidatesToChange = [SELECT
                                    Id, Status__c, Contact__c, ResourceRequest__r.Status__c
                                FROM
                                    BTN_CV__c
                                WHERE
                                    Status__c IN :statuses
                                    AND Id NOT IN :signedCandidates.keySet()
                                    AND Contact__c IN :signedCandidatesContactsIds
                                    AND ResourceRequest__r.Status__c != 'Closed%'];

            if (candidatesToChange.size() != 0) {
                for (BTN_CV__c candidate :candidatesToChange) {
                    candidate.Status__c = BTN_ConstantRepo.CANDIDATE_STATUS_CONTRACT_SIGNED_WITH_DIFFERENT_EXTERNAL;
                }

                update candidatesToChange;
            }
        }
    }

    /**
     * @author Pawel Iwanowicz
     * @date   2016-11-30
     * @description postUpdateCandidatesStatuses - changes statuses for other Candidates (BRITCRM-353)
    */
    public static void postUpdateCandidatesStatuses(Map<Id, BTN_CV__c> newCandidateMap, Map<Id, BTN_CV__c> oldCandidateMap) {
        Map<Id, BTN_CV__c> signedCandidates = new Map<Id, BTN_CV__c>();
        List<Id> signedCandidatesContactsIds = new List<Id>();
        List<String> statuses = new List<String>{
                BTN_ConstantRepo.CANDIDATE_STATUS_OPEN,
                BTN_ConstantRepo.CANDIDATE_STATUS_INTERVIEW_IN_PROGRESS,
                BTN_ConstantRepo.CANDIDATE_STATUS_SUBMITTED_TO_EXTERNAL};

        // We are checking which candidates have status Contract Signed
        for (BTN_CV__c candidate : newCandidateMap.values()) {
            if (candidate.Status__c == BTN_ConstantRepo.CANDIDATE_STATUS_CONTRACT_SIGNED &&
                oldCandidateMap.get(candidate.Id).Status__c != BTN_ConstantRepo.CANDIDATE_STATUS_CONTRACT_SIGNED) {
                    signedCandidates.put(candidate.Id, candidate);
                    signedCandidatesContactsIds.add(candidate.Contact__c);
            }
        }
        // If there are any candidates with status Contract Signed
        if (signedCandidates.size() != 0) {
            List<BTN_CV__c> candidatesToChange = new List<BTN_CV__c>();
            candidatesToChange = [SELECT
                                    Id, Status__c, Contact__c, ResourceRequest__r.Status__c
                                FROM
                                    BTN_CV__c
                                WHERE
                                    Status__c IN :statuses
                                    AND Id NOT IN :signedCandidates.keySet()
                                    AND Contact__c IN :signedCandidatesContactsIds
                                    AND ResourceRequest__r.Status__c != 'Closed%'];

            if (candidatesToChange.size() != 0) {
                for (BTN_CV__c candidate :candidatesToChange) {
                    candidate.Status__c = BTN_ConstantRepo.CANDIDATE_STATUS_CONTRACT_SIGNED_WITH_DIFFERENT_EXTERNAL;
                }

                update candidatesToChange;
            }
        }
    }

    public static String getBTNPropertyValue(String nameOfTheProperty){
        BTN_BriteCRM_settings__c prop = BTN_BriteCRM_settings__c.getInstance(nameOfTheProperty);
        return prop != null ? prop.Value__c : '';
    }

    public static Set<String> getSetValuesByName(String listname) {
        BTN_BriteCRM_settings__c prop = BTN_BriteCRM_settings__c.getInstance(listname);
        String val = prop!= null ? prop.Value__c : '';
        return new Set<String>(val.split(','));
    }

    public static Map<Id,Id> getContactToUserMap(Set<Id> contactIds){
        Map<Id,Id> contactToUserMap = new Map<Id,Id>();
        for(User user : [select Id, ContactId from User where ContactId =: contactIds
                            and IsActive = true
                            and IsPortalEnabled = true]){
            contactToUserMap.put(user.ContactId, user.Id);
        }
        return contactToUserMap;
    }
}