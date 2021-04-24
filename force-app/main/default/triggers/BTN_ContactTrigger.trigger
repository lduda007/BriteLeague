/*
    @Author Wojciech Mazur, Mateusz Przywara
    @Date 2016-10-05
*/
trigger BTN_ContactTrigger on Contact (before insert, after insert, before update, after update) {
    private static final String NAME_FIELD_ON_CONTACT = 'Name_frm__c';
    Set<String> fieldsToTrack = new Set<String>();
    BTN_DAO_User userDao = new BTN_DAO_User();
    if(!BTN_TriggerUtils.skipTrigger('BTN_ContactTrigger')) {
        if(trigger.isBefore && trigger.isInsert){
            //if current user is Community user then we have to change owner to some Salesforce user
            if(userDao.isCommunityUser(BTN_Utils.getCurrentUser().Id)){
                BTN_BriteCRM_settings__c briteCS = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_DEF_CONTACT_OWNER);
                if (briteCS !=null){
                    String owneruserName = briteCS.Value__c;
                    User newOwner = userDao.findUserByUserName(owneruserName);
                    if (newOwner!=null){
                        for(Contact c:trigger.new){
                            c.OwnerId = newOwner.Id;
                        }
                    }
                }
            }
        }
        // Mateusz - BRITCRM-195 - post changes on Chatter, field in customizable list(Field Set).
        // Mateusz - BRITCRM-240 - create or replace old Search Fragments
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                Map<Id, Contact> recruitsMap = filterRecruitContactsMap(Trigger.newMap);
                if (!recruitsMap.isEmpty()) {
                    // Create and Insert Search Fragments based on Recruit Skills
                    BTN_ContactUtils.createSearchFragments(recruitsMap.keySet());
                    // Post inserts notification on Chatter Feed All HR Group
                    BTN_ChatterUtils.postInsertsOnHumanResourcesGroup(
                            recruitsMap,
                            NAME_FIELD_ON_CONTACT
                    );
                }
            }
            // Mateusz - BRITCRM-195 - post changes on Chatter, field in customizable list(Field Set).
            if (Trigger.isUpdate) {
                List<Contact> recruitsOld = filterRecruitContactsList(Trigger.old);
                Map<Id, Contact> recruitsNewMap = filterRecruitContactsMap(Trigger.newMap);
                if (!recruitsNewMap.isEmpty()) {
                    // Create and Insert Search Fragments based on Recruit Skills
                    List<Contact> contactsWithChangedSkills = filterRectruitsWithChangedSkills(recruitsOld, recruitsNewMap);
                    // delete and generate new Search Fragments for Contacts
                    if (!contactsWithChangedSkills.isEmpty()) {
                        BTN_ContactUtils.deleteSearchFragmentsForContacts(BTN_Utils.getSetOfIds(contactsWithChangedSkills));
                        BTN_ContactUtils.createSearchFragments(BTN_Utils.getSetOfIds(contactsWithChangedSkills));
                    }
                    // Post changes notification on Chatter Feed All HR Group
                    BTN_ChatterUtils.postChangesOnHumanResourcesGroup(
                            recruitsOld,
                            recruitsNewMap,
                            fieldsToTrack,
                            NAME_FIELD_ON_CONTACT
                    );
                }
            }
        }
    }


    /**
     * @author Mateusz Przywara
     * @date   2016-10-21
     * @description filterRecruitContactsList
     * @param contacts
     * @return List<Contact> List of Recruits
    */
    private List<Contact> filterRecruitContactsList(List<Contact> contacts) {
        List<Contact> result = new List<Contact>();
        for (Contact contactItem : contacts) {
            if (BTN_RecordTypeUtils.isRecruit(contactItem)) {
                result.add(contactItem);
            }
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-21
     * @description filterRecruitContactsList
     * @param contacts
     * @return Map<Id, Contact> Map of Recruits
    */
    private Map<Id, Contact> filterRecruitContactsMap(Map<Id, Contact> contacts) {
        List<Contact> result = new List<Contact>();
        for (Contact contactItem : contacts.values()) {
            if (BTN_RecordTypeUtils.isRecruit(contactItem)) {
                result.add(contactItem);
            }
        }
        return new Map<Id, Contact>(result);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-21
     * @description filterRecruitContactsList
     * @param contacts
     * @return Map<Id, Contact> Map of Recruits
    */
    private List<Contact> filterRectruitsWithChangedSkills(List<Contact> recruitsOld, Map<Id, Contact> recruitsNew) {
        List<Contact> result = new List<Contact>();
        for (Contact contactItem : recruitsOld) {
            if ((String.isNotBlank(recruitsNew.get(contactItem.Id).Skills__c))
                    &&((String.isBlank(contactItem.Skills__c) && String.isNotBlank(recruitsNew.get(contactItem.Id).Skills__c))
                    || (!contactItem.Skills__c.equals(recruitsNew.get(contactItem.Id).Skills__c))
            )) {
                result.add(contactItem);
            }
        }
        return result;
    }

}