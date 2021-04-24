public with sharing class AchievementContactsSearchController {

    public String options {get; set;}

    public static List<Achievement_Set__c> search(SearchCriteria criteria) {
        List<Achievement_Set__c> employeesProfiles = new List<Achievement_Set__c>();
        Set<Id> employeesProfilesIds = new Set<Id>();
        if (!criteria.achievementsSetsIds.isEmpty() || !criteria.achievementsSearchCriterias.isEmpty()) {
            employeesProfilesIds.addall(prepareEmployeesProfilesIds(criteria));
            if (!employeesProfilesIds.isEmpty()) {
                //employeesProfiles.addAll(AchievementService.getAchievementSets(employeesProfilesIds,null, true));
               List<Achievement_Set__c> contacts = getContacts(employeesProfilesIds);
               for (Achievement_Set__c item : contacts) {
                   for (Achievement_Set_Item__c achievmentItem : item.Achievements__r) {
                       achievmentItem.Min_Speciality_Match__c = achievmentItem.Min_Speciality_Match__c == null ? 0 : achievmentItem.Min_Speciality_Match__c * 100;
                       if (achievmentItem.Type__c == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE) {
                            achievmentItem.LevelValue__c = AchievementService.getAchievementsValues().get(achievmentItem.Achievement__c).get(Integer.valueOf(achievmentItem.LevelValue__c)).Name;
                       }
                   }

                   for (Contact_Profile_Score__c probe : item.Contact_Profile_Scores__r) {
                       probe.Match__c = probe.Match__c == null ? 0 : probe.Match__c * 100;
                   }
               }

               employeesProfiles.addAll(contacts);
            }
        }
        return employeesProfiles;
    }

    public static Map<String, List<Option>> getOptions() {
        Map<String, List<Option>> options = new Map<String, List<Option>>();
        List<Option> achievments = new List<Option>();
        List<Option> achievmentsSets = new List<Option>();

        for (Achievement__c item : getAcheivments()) {
            achievments.add( new Option(item));
        }
        options.put('achievments', achievments);

        for (Achievement_Set__c item : getAcheivmentsSets()) {
            achievmentsSets.add( new Option(item));
        }
        options.put('achievmentsSets', achievmentsSets);

        return options;
    }

    private static List<Achievement_Set__c> getContacts(Set<Id> employeesProfilesIds) {
        return [
            SELECT Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, Contact__r.Current_Position__r.Name, Career_Path__c, Parent_Profile__c,
                   (SELECT Achievement__r.Name, Achievement__c, Amount__c, Level__c, LevelValue__c, Weight__c, Min_Speciality_Match__c, Type__c, NumberOfMonths__c FROM Achievements__r WHERE HistoryRecord__c=false ORDER BY Achievement__r.Name),
                   (SELECT Achievement_Profile__r.Name, Match__c FROM Contact_Profile_Scores__r ORDER BY Match__c DESC, Achievement_Profile__r.Name DESC)
           FROM Achievement_Set__c WHERE Id IN :employeesProfilesIds LIMIT :employeesProfilesIds.size()];
    }

    private static Boolean isSkill(AchievementSearchCriteria itemCriteria) {
        return itemCriteria.recordType == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE && itemCriteria.level != null && itemCriteria.minAmount == null && itemCriteria.selected == null;
    }

    private static Boolean isAttribute(AchievementSearchCriteria itemCriteria) {
        return itemCriteria.recordType == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE && itemCriteria.level != null && itemCriteria.minAmount == null && itemCriteria.selected == null;
    }

    private static Boolean isGroup(AchievementSearchCriteria itemCriteria) {
        return itemCriteria.recordType == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE && itemCriteria.level != null && itemCriteria.minAmount == null && itemCriteria.selected == null;
    }

    private static Boolean isBadge(AchievementSearchCriteria itemCriteria) {
        return itemCriteria.recordType == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE && itemCriteria.level == null && itemCriteria.minAmount != null && itemCriteria.selected == null;
    }

    private static Boolean isDate(AchievementSearchCriteria itemCriteria) {
        return itemCriteria.recordType == AchievementUtils.ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE && itemCriteria.level == null && itemCriteria.minAmount != null && itemCriteria.selected == null;
    }

    private static Boolean isSpecialization(AchievementSearchCriteria itemCriteria) {
        return itemCriteria.recordType == AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE && itemCriteria.level == null && itemCriteria.minAmount != null && itemCriteria.selected == null;
    }

    private static Boolean isCartificate(AchievementSearchCriteria itemCriteria) {
        return itemCriteria.level == null && itemCriteria.minAmount == null && itemCriteria.selected == true;
    }

    private static String prepareQueryToEmployeesProfilesIds(SearchCriteria searchCriteria) {
        List<Id> achievementsIds = new List<Id>();
        Map<String, List<String>> levels = new Map<String, List<String>>();
        levels.put(AchievementUtils.ACHIEVEMENT_LEVEL_1, new List<String>{AchievementUtils.ACHIEVEMENT_LEVEL_1, AchievementUtils.ACHIEVEMENT_LEVEL_2, AchievementUtils.ACHIEVEMENT_LEVEL_3});
        levels.put(AchievementUtils.ACHIEVEMENT_LEVEL_2, new List<String>{AchievementUtils.ACHIEVEMENT_LEVEL_2, AchievementUtils.ACHIEVEMENT_LEVEL_3});
        levels.put(AchievementUtils.ACHIEVEMENT_LEVEL_3, new List<String>{AchievementUtils.ACHIEVEMENT_LEVEL_3});
        if (!searchCriteria.achievementsSetsIds.isEmpty()) {
            for (Contact_Profile_Score__c item : [SELECT Contact_Profile__c FROM Contact_Profile_Score__c WHERE Achievement_Profile__c IN :searchCriteria.achievementsSetsIds]) {
                achievementsIds.add(item.Contact_Profile__c);
            }
        }
        String query = 'SELECT Achievement_Set__c FROM Achievement_Set_Item__c WHERE Achievement_Set__r.RecordType.DeveloperName =\'' + AchievementUtils.ACHIEVEMENT_SET_CONTACT_PROFILE_RECORD_TYPE + '\'';
        if (!achievementsIds.isEmpty()) {
            query += ' AND Achievement_Set__c IN (\'' + String.join(achievementsIds, '\',\'') + '\')';
        }

        if (!searchCriteria.achievementsSearchCriterias.isEmpty()) {
            query += ' AND (';
            for (AchievementSearchCriteria itemCriteria : searchCriteria.achievementsSearchCriterias) {
                query += ' (Achievement__r.Id = \''+itemCriteria.Id+'\'';
                if (isSkill(itemCriteria)) {
                    query += ' AND Type__c = \''+AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE+'\' AND Level__c IN (\'' + String.join(levels.get(AchievementUtils.ACHIEVEMENT_LEVEL_VALUE.get(itemCriteria.level)), '\',\'') + '\')';
                }
                if (isGroup(itemCriteria)) {
                    query += ' AND Type__c = \''+AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE+'\' AND Level__c IN (\'' + String.join(levels.get(AchievementUtils.ACHIEVEMENT_LEVEL_VALUE.get(itemCriteria.level)), '\',\'') + '\')';
                }
                if (isAttribute(itemCriteria)) {
                    query += ' AND Type__c = \''+AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE+'\' AND LevelValue__c = \''+itemCriteria.level+'\'';
                }
                if (isBadge(itemCriteria)) {
                    query += ' AND Type__c = \''+AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE + '\' AND Amount__c >= '+ Double.valueOf(itemCriteria.minAmount);
                }
                if (isSpecialization(itemCriteria)) {
                    query += ' AND Type__c = \''+AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE + '\' AND Min_Speciality_Match__c >= '+ Double.valueOf(itemCriteria.minAmount)/100;
                }
                if (isCartificate(itemCriteria)) {
                    query += ' AND Type__c = \''+AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE +'\'';
                }
                 if (isDate(itemCriteria)) {
                    query += ' AND Type__c = \''+AchievementUtils.ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE + '\' AND  NumberOfMonths__c >= '+ Double.valueOf(itemCriteria.minAmount);
                }
                query += ' ) OR';
            }
            query = query.substring(0, query.length()-2);
            query += ')';
        }
        query += ' GROUP BY Achievement_Set__c';

        if (!searchCriteria.achievementsSearchCriterias.isEmpty()) {
             query += ' HAVING Count(Id) = '+searchCriteria.achievementsSearchCriterias.size();
        }

        if (achievementsIds.isEmpty() && searchCriteria.achievementsSearchCriterias.isEmpty()) {
            return null;
        }
        return query;
    }

    private static Set<Id> prepareEmployeesProfilesIds(SearchCriteria searchCriteria) {
        Set<Id> ids = new Set<Id>();
        String query = prepareQueryToEmployeesProfilesIds(searchCriteria);
        if (query != null) {
            for (AggregateResult item : Database.query(query)) {
                ids.add((Id)item.get('Achievement_Set__c'));
            }
        }
        return ids;
    }

    private static List<Achievement__c> getAcheivments() {
        return AchievementService.getAllAchievements();
    }

    private static List<Achievement_Set__c> getAcheivmentsSets() {
        return  AchievementService.getAchievementSets(null, AchievementUtils.getPositionProfileRecordTypeIds(), false);
    }

    public with sharing class Option {
        public Id id;
        public String text; // name
        public String recordType;
        public Map<String, String> options;

        public Option(Achievement__c achievment) {
            this.id = achievment.Id;
            this.text = achievment.Name;
            this.recordType = achievment.RecordType.DeveloperName;
            if (achievment.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE) {
                this.options = new Map<String, String>();
                for (Achievement_Value__c item : achievment.AchievementValues__r) {
                    options.put(String.valueOf(item.Value__c), item.Name);
                }
            } else if (achievment.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE || 
                   (achievment.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE && achievment.Group_Type__c == AchievementUtils.ACHIEVEMENT_MANUAL_GROUP_TYPE)) {
                this.options = new Map<String, String>();
                options.put(AchievementUtils.ACHIEVEMENT_LEVEL_1_VALUE, AchievementUtils.ACHIEVEMENT_LEVEL_1);
                options.put(AchievementUtils.ACHIEVEMENT_LEVEL_2_VALUE, AchievementUtils.ACHIEVEMENT_LEVEL_2);
                options.put(AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE, AchievementUtils.ACHIEVEMENT_LEVEL_3);
            }
        }

        public Option(Achievement_Set__c achievmentSet) {
            this.id = achievmentSet.Id;
            this.text = achievmentSet.Name;
            this.recordType = achievmentSet.RecordType.DeveloperName;
        }
    }

    public with sharing class SearchCriteria {
        List<Id> achievementsSetsIds = new List<Id>();
        List<AchievementSearchCriteria> achievementsSearchCriterias = new List<AchievementSearchCriteria>();

        public SearchCriteria(List<Id>achievementsSetsIds, List<AchievementSearchCriteria> achievementsSearchCriterias) {
            if (achievementsSetsIds != null) {
                this.achievementsSetsIds.addAll(achievementsSetsIds);
            }
            if (achievementsSearchCriterias != null) {
                this.achievementsSearchCriterias.addAll(achievementsSearchCriterias);
            }
        }
    }

    public with sharing class AchievementSearchCriteria {
        public Id id;
        public String name;
        public String level;
        public Decimal minAmount;
        public Boolean selected;
        public String recordType;

        public AchievementSearchCriteria (Id id, String name, String level, Decimal minAmount, Boolean selected, String recordType) {
            this.id = id;
            this.name = name;
            this.level = level;
            this.minAmount = minAmount;
            this.selected = selected;
            this.recordType = recordType;
        }
    }
}