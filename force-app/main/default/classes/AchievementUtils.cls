/**
 * Achievement Utils methods
 * @author Adam Siwek
 */
public with sharing class AchievementUtils {

    private static final String ACHIEVEMENT_OBJECT_TYPE = 'Achievement__c';
    private static final String ACHIEVEMENT_SET_OBJECT_TYPE = 'Achievement_Set__c';

    public static final Integer EMPLOYEE_LIMIT = 10;
    public static final Integer POSITION_LIMIT = 10;

    public static final String ACHIEVEMENT_SET_CONTACT_PROFILE_RECORD_TYPE = 'Contact_Profile';
    public static final String ACHIEVEMENT_SET_POSITION_RECORD_TYPE = 'Position_Profile';
    public static final String ACHIEVEMENT_SET_PROFILE_RECORD_TYPE = 'Achievements_Profile';
    public static final String ACHIEVEMENT_SET_SURVEY_RECORD_TYPE = 'Survey';

    public static final String ACHIEVEMENT_SKILL_RECORD_TYPE = 'Skill';
    public static final String ACHIEVEMENT_BADGE_RECORD_TYPE = 'Badge';
    public static final String ACHIEVEMENT_CERTIFICATE_RECORD_TYPE = 'Certificate';
    public static final String ACHIEVEMENT_GROUP_RECORD_TYPE = 'Group';
    public static final String ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE = 'Specialization';
    public static final String ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE = 'Attribute';
    public static final String ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE = 'MonthsFromDate';

    public static final String ACHIEVEMENT_LEVEL_1 = 'Junior';
    public static final String ACHIEVEMENT_LEVEL_2 = 'Professional';
    public static final String ACHIEVEMENT_LEVEL_3 = 'Senior';

    public static final String ACHIEVEMENT_LEVEL_1_VALUE = '1';
    public static final String ACHIEVEMENT_LEVEL_2_VALUE = '2';
    public static final String ACHIEVEMENT_LEVEL_3_VALUE = '4';
    public static final Map<String, String> ACHIEVEMENT_LEVEL_VALUE = new Map<String, String>{
        '1' => 'Junior',
        '2' => 'Professional',
        '4' => 'Senior'
    };

    public static final String ACHIEVEMENT_GREATEST_VALUE_GROUP_TYPE = 'Greatest Value';
    public static final String ACHIEVEMENT_GREATEST_VALUE_SPECIALIZATION_GROUP_TYPE = 'Greatest Value (Specialization)';
    public static final String ACHIEVEMENT_MANUAL_GROUP_TYPE = 'Manual';

    private static final Map<String, Double> LEVEL_VALUE = new Map<String, Double> {
        AchievementUtils.ACHIEVEMENT_LEVEL_1.toLowerCase() => 1.0,
        AchievementUtils.ACHIEVEMENT_LEVEL_2.toLowerCase() => 2.0,
        AchievementUtils.ACHIEVEMENT_LEVEL_3.toLowerCase() => 3.0
    };

    private static Map<String, Achievement__c> allAchievements = new Map<String, Achievement__c>();
    private static Map<String, Achievement__c> externalIdAllAchievements = new Map<String, Achievement__c>();

    public static String getAchievementSetObjectType(){
        return ACHIEVEMENT_SET_OBJECT_TYPE;
    }

    public static Double getLevelValue(String level) {
        return level == null || !LEVEL_VALUE.containsKey(level.toLowerCase()) ? 0.0 : LEVEL_VALUE.get(level.toLowerCase());
    }
    public static Boolean compareLevel(String l1, String l2) {
        Double v1 = l1 == null ? 0 : LEVEL_VALUE.get(l1.toLowerCase());
        Double v2 = l2 == null ? 0 : LEVEL_VALUE.get(l2.toLowerCase());
        return v1 < v2;
    }

    public static Map<String, Achievement__c> getAllAchievements(){
        if (allAchievements.isEmpty()){
            allAchievements.putAll([SELECT Id, Name FROM Achievement__c]);
        }
        return allAchievements;
    }

    public static String prepareAchivementSetItemExternalId(Achievement_Set__c achievementSet, Achievement__c achievement) {
        return achievementSet.ExternalID__c+'#'+achievement.ExternalId__c;
    }

    public static Map<String, Achievement__c> getExternalIdAllAchievements(){
        if (externalIdAllAchievements.isEmpty()){
            for (Achievement__c item : [SELECT ExternalId__c, Name FROM Achievement__c]) {
                externalIdAllAchievements.put(item.ExternalId__c, item);
            }
            allAchievements.putAll([SELECT Id, Name FROM Achievement__c]);
        }
        return externalIdAllAchievements;
    }

    public static Set<ID> getContactProfileRecordTypeIds() {
        return new Set<ID> {getAchievementSetContactProfileRecordType().Id};
    }

    public static Set<ID> getContactTargetProfileRecordTypeIds() {
        return new Set<ID> {getAchievementSetPositionRecordType().Id, getAchievementSetProfileRecordType().Id};
    }

    public static Set<ID> getPositionProfileRecordTypeIds() {
        return new Set<ID> {getAchievementSetPositionRecordType().Id};
    }

    public static Set<ID> getSpecializationRecordTypeIds() {
        return new Set<ID> {getAchievementSetProfileRecordType().Id};
    }

    public static Set<ID> getSurveyRecordTypeIds() {
        return new Set<ID> {getAchievementSetSurveyRecordType().Id};
    }

    public static RecordType getAchievementSetContactProfileRecordType() {
        return getAchievementSetRecordType(ACHIEVEMENT_SET_CONTACT_PROFILE_RECORD_TYPE);
    }
    public static RecordType getAchievementSetPositionRecordType() {
        return getAchievementSetRecordType(ACHIEVEMENT_SET_POSITION_RECORD_TYPE);
    }
    public static RecordType getAchievementSetProfileRecordType() {
        return getAchievementSetRecordType(ACHIEVEMENT_SET_PROFILE_RECORD_TYPE);
    }
    public static RecordType getAchievementSetSurveyRecordType() {
        return getAchievementSetRecordType(ACHIEVEMENT_SET_SURVEY_RECORD_TYPE);
    }
    public static RecordType getAchievementSkillRecordType() {
        return getAchievementRecordType(ACHIEVEMENT_SKILL_RECORD_TYPE);
    }
    public static RecordType getAchievementBadgeRecordType() {
        return getAchievementRecordType(ACHIEVEMENT_BADGE_RECORD_TYPE);
    }
    public static RecordType getAchievementCertificateRecordType() {
        return getAchievementRecordType(ACHIEVEMENT_CERTIFICATE_RECORD_TYPE);
    }
    public static RecordType getAchievementGroupRecordType() {
        return getAchievementRecordType(ACHIEVEMENT_GROUP_RECORD_TYPE);
    }
    public static RecordType getAchievementSpecializationRecordType() {
        return getAchievementRecordType(ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE);
    }
    public static RecordType getAchievementAttributeRecordType() {
        return getAchievementRecordType(ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE);
    }
    public static RecordType getAchievementMonthsFromDateRecordType() {
        return getAchievementRecordType(ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE);
    }

    public static RecordType getAchievementSetRecordType(String rtDevName) {
        return SystemUtils.loadAndGetRecordType(ACHIEVEMENT_SET_OBJECT_TYPE, rtDevName);
    }
    public static RecordType getAchievementRecordType(String rtDevName) {
        return SystemUtils.loadAndGetRecordType(ACHIEVEMENT_OBJECT_TYPE, rtDevName);
    }

    public with sharing class CareerPathBuilder implements SystemUtils.Builder {
        private Career_Path__c record;

        public CareerPathBuilder(String name) {
            record = new Career_Path__c(Name = name);
        }

        public Career_Path__c build() {
            return record;
        }
        public Career_Path__c buildAndSave() {
            upsert build();
            return record;
        }
    }

    public with sharing class AchievementCategoryBuilder implements SystemUtils.Builder {
        private Achievement_Category__c record;

        public AchievementCategoryBuilder(String name) {
            record = new Achievement_Category__c(Name = name);
        }

        public AchievementCategoryBuilder addParent(Id parentId) {
            record.Parent_Category__c = parentId;
            return this;
        }

        public Achievement_Category__c build() {
            return record;
        }
        public Achievement_Category__c buildAndSave() {
            upsert build();
            return record;
        }
    }

    public with sharing class AchievementBuilder implements SystemUtils.Builder {
        private Achievement__c record;
        private List<Achievement_Group_Item__c> groupItems = new List<Achievement_Group_Item__c>();
        private List<Achievement_Value__c> achievementValues = new List<Achievement_Value__c>();

        public AchievementBuilder(String name, Achievement_Category__c category) {
            record = new Achievement__c(Name = name, Achievement_Category__c = category.Id);
        }

        public AchievementBuilder asSkill() {
            record.RecordTypeId = getAchievementSkillRecordType().Id;
            achievementValues.clear();
            groupItems.clear();
            return this;
        }

        public AchievementBuilder asCert() {
            record.RecordTypeId = getAchievementCertificateRecordType().Id;
            achievementValues.clear();
            groupItems.clear();
            return this;
        }

        public AchievementBuilder asBadge() {
            record.RecordTypeId = getAchievementBadgeRecordType().Id;
            achievementValues.clear();
            groupItems.clear();
            return this;
        }

        public AchievementBuilder asGroup() {
            record.RecordTypeId = getAchievementGroupRecordType().Id;
            achievementValues.clear();
            groupItems.clear();
            return this;
        }

        public AchievementBuilder asSpecialization(Achievement_Set__c achievementSet) {
            record.RecordTypeId = getAchievementSpecializationRecordType().Id;
            record.Speciality__c = achievementSet.Id;
            achievementValues.clear();
            groupItems.clear();
            return this;
        }

        public AchievementBuilder asDate() {
            record.RecordTypeId = getAchievementMonthsFromDateRecordType().Id;
            achievementValues.clear();
            groupItems.clear();
            return this;
        }

        public AchievementBuilder asAttribute() {
            record.RecordTypeId = getAchievementAttributeRecordType().Id;
            achievementValues.clear();
            groupItems.clear();
            return this;
        }

        public AchievementBuilder addGroupItem(Achievement__c achievement) {
            if (record.RecordTypeId == getAchievementGroupRecordType().Id) {
                groupItems.add(new Achievement_Group_Item__c(Achievement__c = achievement.Id));
            }
            return this;
        }

        public AchievementBuilder addAttributeValue(String name, Decimal value) {
            if (record.RecordTypeId == getAchievementAttributeRecordType().Id) {
                achievementValues.add(new Achievement_Value__c(Name = name, Value__c = value, Details__c = 'Description: ' + name));
            }
            return this;
        } 

        public Achievement__c build() {
            return record;
        }
        public Achievement__c buildAndSave() {
            upsert record;
            if (!groupItems.isEmpty()) {
                for (Achievement_Group_Item__c grp : groupItems) {
                    if (grp.Group__c == null ) {
                        grp.Group__c = record.Id;
                    }
                }
                upsert groupItems;
            }
            if (!achievementValues.isEmpty()) {
                for (Achievement_Value__c av : achievementValues) {
                    av.Achievement__c = record.Id;
                }
                upsert achievementValues;
            }
            return record;
        }
    }

    public with sharing class AchievementSetBuilder implements SystemUtils.Builder {
        private Achievement_Set__c record;
        private Map<Id, Achievement_Set_Item__c> itemMap;

        public AchievementSetBuilder(Achievement_Set__c r) {
            record = r;
            itemMap = new Map<Id, Achievement_Set_Item__c>();
        }

        public AchievementSetBuilder(String name) {
            this(new Achievement_Set__c(Name = name));
        }

        public AchievementSetBuilder asContactProfile(Contact c) {
            record.RecordTypeId = getAchievementSetContactProfileRecordType().Id;
            record.Contact__c = c.Id;
            String name = c.LastName + ' ' + c.FirstName + ' - ' + getAchievementSetContactProfileRecordType().Name;
            if (name.length() > 80) {
                name = c.LastName + '. ' + c.FirstName.substring(0, 1) + ' - ' + getAchievementSetContactProfileRecordType().Name;
                if (name.length() > 80) {
                    name = name.substring(0, 77)+'...';
                }
            }
            record.Name = name;
            return this;
        }

        public AchievementSetBuilder asPositionProfile(Career_Path__c careerPath) {
            record.RecordTypeId = getAchievementSetPositionRecordType().Id;
            record.Career_Path__c = careerPath.Id;
            return this;
        }

        public AchievementSetBuilder asProfile(Career_Path__c careerPath) {
            record.RecordTypeId = getAchievementSetProfileRecordType().Id;
            record.Career_Path__c = careerPath.Id;
            return this;
        }

        public AchievementSetBuilder asSurvey(Contact who, Contact whoAbout) {
            record.RecordTypeId = getAchievementSetSurveyRecordType().Id;
            record.Who__c = who.Id;
            record.AboutWho__c = whoAbout.Id;
            record.Name = who.FirstName + ' ' + who.LastName + ' -> ' + whoAbout.FirstName + ' ' + whoAbout.LastName;
            return this;
        }

        public AchievementSetBuilder withContact(Contact c) {
            record.Contact__c = c.Id;
            return this;
        }

        public AchievementSetBuilder withWho(Contact who) {
            record.Who__c = who.Id;
            return this;
        }

        public AchievementSetBuilder withWhoAbout(Contact whoAbout) {
            record.AboutWho__c = whoAbout.Id;
            return this;
        }
        public AchievementSetBuilder withoutCareerPath() {
            record.Career_Path__c = null;
            return this;
        }

        public AchievementSetBuilder withCareerPath(Career_Path__c careerPath) {
            record.Career_Path__c = careerPath.Id;
            return this;
        }

        public AchievementSetBuilder withoutWho() {
            record.Who__c = null;
            return this;
        }

        public AchievementSetBuilder withoutWhoAbout() {
            record.AboutWho__c = null;
            return this;
        }

        public AchievementSetBuilder addSkill(Achievement__c achievement, String level) {
            addAchievement(achievement, level, null, null, null);
            return this;
        }
        public AchievementSetBuilder addBadge(Achievement__c achievement, Integer amount) {
            addAchievement(achievement, null, amount, null, null);
            return this;
        }
        public AchievementSetBuilder addAttribute(Achievement__c achievement, Integer attributeValue) {
            addAchievement(achievement, null, attributeValue, null, null);
            return this;
        }
        public AchievementSetBuilder addCert(Achievement__c achievement) {
            addAchievement(achievement, null, null, null, null);
            return this;
        }
        public AchievementSetBuilder addGroup(Achievement__c achievement, Integer amount) {
            addAchievement(achievement, null, amount, null, null);
            return this;
        }
        public AchievementSetBuilder addSpecialization(Achievement__c achievement, Double minSpecialityMatch) {
            addAchievement(achievement, null, null, minSpecialityMatch, null);
            return this;
        }
        public AchievementSetBuilder addSpecializationGroup(Achievement__c achievement, Double minSpecialityMatch) {
            addAchievement(achievement, null, null, minSpecialityMatch, null);
            return this;
        }
        public AchievementSetBuilder addDate(Achievement__c achievement, Datetime date_c) {
            addAchievement(achievement, null, null, null, date_c);
            return this;
        }

        private Achievement_Set_Item__c addAchievement(Achievement__c achievement, String level, Integer amount, Double minSpecialityMatch, Datetime date_c) {
            Achievement_Set_Item__c item;
            if (itemMap.containsKey(achievement.Id)) {
                item = itemMap.get(achievement.Id);
            } else {
                item = new Achievement_Set_Item__c(Achievement__c = achievement.Id);
                itemMap.put(achievement.Id, item);
            }
            item.Level__c = level;
            item.Amount__c = amount;
            item.Min_Speciality_Match__c = minSpecialityMatch;
            item.Date__c = date_c;
            return item;
        }

        public Achievement_Set__c build() {
            return record;
        }
        public Achievement_Set__c buildAndSave() {
            upsert record;
            for (Achievement_Set_Item__c item : itemMap.values()) {
                if (item.Achievement_Set__c == null) {
                    item.Achievement_Set__c = record.Id;
                }
            }
            upsert itemMap.values();
            return record;
        }
    }

    public with sharing class AchievementGroup {
        public String name {get; set;}
        public List<Achievement> achievements {get; set;}

        public AchievementGroup(String name) {
            this.name = name;
            achievements = new List<Achievement>();
        }

        public Boolean getHasValue() {
            for (Achievement a : achievements) {
                if (a.getHasValue() || a.getHasDifferentValue()) {
                    return true;
                }
            }
            return false;
        }
        
        public Boolean getHasValueToCompare() {
            for (Achievement a : achievements) {
                if (a.getHasValueToCompare()) {
                    return true;
                }
            }
            return false;
        }
    }

    public with sharing class AchievementAccessBuilder implements SystemUtils.Builder {
        private AchievementAccess__c record;

        public AchievementAccessBuilder(Achievement__c achievement) {
            record = new AchievementAccess__c(Achievement__c = achievement.Id);
        }

        public AchievementAccessBuilder OnlyLeader() {
            record.OnlyLeaders__c = true;
            record.Contact__c = null;
            return this;
        }

        public AchievementAccessBuilder withContact(Contact contact) {
            record.OnlyLeaders__c = false;
            record.Contact__c = contact.Id;
            return this;
        }

        public AchievementAccess__c build() {
            return record;
        }
        public AchievementAccess__c buildAndSave() {
            upsert record;
            return record;
        }

    }
}