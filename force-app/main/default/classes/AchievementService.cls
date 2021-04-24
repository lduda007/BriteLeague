/**
 * Achievement Service contains all logic related with Achievements process.
 * @author Adam Siwek
 */
public with sharing class AchievementService {

    public static List<Achievement_Set_Item__c> getAchievementSetItems(Id achievementSetId) {
        return achievementSetId != null ?
                [SELECT Level__c, Date__c, NumberOfMonths__c, Achievement__c, Amount__c, Min_Speciality_Match__c FROM Achievement_Set_Item__c WHERE Achievement_Set__c = :achievementSetId AND HistoryRecord__c=false] :
                new List<Achievement_Set_Item__c>();
    }

    public static List<Achievement__c> getAchievementGroups(Set<ID> groupIds) {
        return groupIds != null ?
                [SELECT Id, Group_Type__c, (SELECT Id, Achievement__c FROM Achievement_Group_Items__r) FROM Achievement__c WHERE Id = :groupIds AND Active__c = true] :
                [SELECT Id, Group_Type__c, (SELECT Id, Achievement__c FROM Achievement_Group_Items__r) FROM Achievement__c WHERE Active__c = true];
    }

    public static List<Career_Path__c> careerPaths = null;

    public static List<Career_Path__c> getCareerPaths() {
        if (careerPaths == null) {
            careerPaths = [SELECT Name, Description__c FROM Career_Path__c ORDER BY Name];
        }
        return careerPaths;
    }

    public static Map<Id, Achievement__c> activeAchievements = null;
    public static Map<String, Achievement__c> externalIDAllAchievements = null;
    public static Map<Id, Achievement__c> inactiveAchievements = null;

    public static Achievement__c getAchievement(ID achievementId) {
        getAllAchievements();
        return activeAchievements.get(achievementId);
    }

    public static Achievement__c getAchievement(String externalId) {
        getAllAchievements();
        return externalIDAllAchievements.get(externalId);
    }

    public static List<Achievement__c> getAllAchievements() {
        retrieveAchievements();
        return activeAchievements.values();
    }

    public static List<Achievement__c> getAllAchievements(Boolean all) {
       retrieveAchievements();
       List<Achievement__c> achievements = new List<Achievement__c>();
       achievements.addAll(activeAchievements.values());
       achievements.addAll(inactiveAchievements.values());
       return achievements;
    }

    private static void retrieveAchievements() {
        if (Test.isRunningTest()){
            activeAchievements = null;
            inactiveAchievements = null;
        }

        if (activeAchievements == null && inactiveAchievements == null) {
            activeAchievements = new Map<ID, Achievement__c>();
            inactiveAchievements = new Map<ID, Achievement__c>();
            externalIDAllAchievements = new Map<String, Achievement__c>();

            for (Achievement__c item : [SELECT Name, Details__c, Level_1_Details__c, Level_2_Details__c, Level_3_Details__c,
                                           Active__c, Group_Type__c, My_Achievement__c, 
                                           RecordType.Name, RecordType.DeveloperName, Speciality__c,
                                           Achievement_Category__c, Achievement_Category__r.Name, ExternalId__c,
                                           (SELECT Id, Name, Details__c, Value__c, IndexOfValue__c FROM AchievementValues__r ORDER BY Value__c),
                                           (SELECT Achievement__c, Achievement__r.ExternalId__c FROM Achievement_Group_Items__r WHERE Achievement__c != null),
                                           (SELECT Contact__c, OnlyLeaders__c FROM AchievementsAccess__r)
                                        FROM Achievement__c
                                        ORDER BY Achievement_Category__r.Name, RecordType.DeveloperName, Name]) {
                if (item.Active__c) {
                    activeAchievements.put(item.Id, item);
                    externalIDAllAchievements.put(item.ExternalId__c, item);
                } else{
                    inactiveAchievements.put(item.Id, item);
                }
            }
       }
    }

    public static List<Achievement_Category__c> getAllAchievementCategories() {
        return [SELECT Id, Name, Number_of_Achievements__c, ExternalId__c FROM Achievement_Category__c ORDER BY Name];
    }

    private static Map<Id, String> achievementCategories = null;
    private static Map<String, String> externalIdAchievementCategories = null;
    public static  void retrieveCategories() {
        if (achievementCategories == null && externalIdAchievementCategories == null) {
            achievementCategories = new Map<Id, String>();
            externalIdAchievementCategories = new Map<String, String>();
            for (Achievement_Category__c item : getAllAchievementCategories()) {
                achievementCategories.put(item.Id, item.Name);
                externalIdAchievementCategories.put(item.ExternalId__c, item.Name);
            }
        }
    }

    public static  Map<Id, String> getCategoriesMap() {
        retrieveCategories();
        return achievementCategories;
    }

        public static  Map<String, String> getExternalIdCategoriesMap() {
        retrieveCategories();
        return externalIdAchievementCategories;
    }

    public static String getCategoryName (String externalId) {
        if (externalIdAchievementCategories == null) {
            getCategoriesMap();
        }
        return externalIdAchievementCategories.get(externalId);
    }

    public static String getCategoryName (Id id) {
        if (achievementCategories == null) {
            getCategoriesMap();
        }
        return achievementCategories.get(id);
    }

    public static Set<Id> getSubCategoriesIds (String categoryName) {
        Set<Id> ids = new Set<Id>();
        String query = 'SELECT Id FROM Achievement_Category__c WHERE Hierarchy__c = \''+categoryName+'\' OR Hierarchy__c LIKE \'%>'+categoryName+'>%\' OR Hierarchy__c LIKE \'%>'+categoryName+'\' OR Hierarchy__c LIKE \''+categoryName+'>%\' ORDER BY Hierarchy__c';
        for (Achievement_Category__c item : Database.query(query)) {
            ids.add(item.Id);
        }
        return ids;
    }

    private static Map<Id, Map<Integer, Achievement_Value__c>> achievementValues = null;
    public static Map<Id,Map<Integer, Achievement_Value__c>> getAchievementsValues() {
        if(achievementValues == null){
            achievementValues = new Map<Id, Map<Integer, Achievement_Value__c>>();
            for(Achievement__c a : getAllAchievements()) {
                Map<Integer, Achievement_Value__c> values = new Map<Integer, Achievement_Value__c>();
                for(Integer i = a.AchievementValues__r.size()-1; i>=0;i--) {
                    values.put(Integer.valueOf(a.AchievementValues__r.get(i).Value__c), a.AchievementValues__r.get(i));
                }
                achievementValues.put(a.Id, values);
            }
        }
        return achievementValues;
    }

    private static Map<Id, List<Achievement__c>> achievementCategoriesWithAchievments = null;
    public static  Map<Id, List<Achievement__c>> getCategoriesWithAchievments() {
        if (achievementCategoriesWithAchievments == null) {
            achievementCategoriesWithAchievments = new Map<Id, List<Achievement__c>>();
            for (Achievement__c item : getAllAchievements()) {
                if (!achievementCategoriesWithAchievments.containsKey(item.Achievement_Category__c)) {
                    achievementCategoriesWithAchievments.put(item.Achievement_Category__c, new List<Achievement__c>{item});
                } else {
                    achievementCategoriesWithAchievments.get(item.Achievement_Category__c).add(item);
                }
            }
        }
        return achievementCategoriesWithAchievments;
    }

    public static List<AchievementUtils.AchievementGroup> getAchievementGroups(Id achievementSetId, Id achievementSetIdToCompare) {
        List<AchievementUtils.AchievementGroup> groups = new List<AchievementUtils.AchievementGroup>();
        Map<Id, Achievement_Set_Item__c> selectedAchivements = new Map<Id, Achievement_Set_Item__c>();
        Map<Id, Achievement_Set_Item__c> achievemetToCmp = new Map<Id, Achievement_Set_Item__c>();

        for (Achievement_Set_Item__c record : getAchievementSetItems(achievementSetId)) {
            selectedAchivements.put(record.Achievement__c, record);
        }

        if (achievementSetIdToCompare != null) {
            for (Achievement_Set_Item__c record : getAchievementSetItems(achievementSetIdToCompare)) {
                achievemetToCmp.put(record.Achievement__c, record);
            }
        }

        Set<String> uniqueGroupNames = new Set<String>();
        AchievementUtils.AchievementGroup actualGroup;

        for (Achievement__c a : getAllAchievements()) {

            if (!uniqueGroupNames.contains(a.Achievement_Category__c)) {
                actualGroup = new AchievementUtils.AchievementGroup(a.Achievement_Category__r.Name);
                uniqueGroupNames.add(a.Achievement_Category__c);
                groups.add(actualGroup);
            }
            Achievement_Set_Item__c oldRecord = selectedAchivements.get(a.Id);
            if (oldRecord == null) {
                oldRecord = new Achievement_Set_Item__c(Achievement_Set__c = achievementSetId, Achievement__c = a.Id);
            }
            Achievement ah = new Achievement(a, oldRecord);
            if (achievemetToCmp.containsKey(a.Id)) {
                ah.setDataToCmp(achievemetToCmp.get(a.Id));
            }
            actualGroup.achievements.add(ah);
        }

        return groups;
    }

    public static List<Achievement> convert(ID achievementSetId, List<ID> achievementIds, List<Achievement_Set_Item__c> oldItems) {
        List<Achievement> achievements = new List<Achievement>();
        Map<Id, Achievement_Set_Item__c> selectedAchivements = new Map<Id, Achievement_Set_Item__c>();

        for (Achievement_Set_Item__c record : oldItems) {
            selectedAchivements.put(record.Achievement__c, record);
        }

        for (ID achievementId : achievementIds) {
            Achievement_Set_Item__c oldRecord = selectedAchivements.get(achievementId);
            if (oldRecord == null) {
                oldRecord = new Achievement_Set_Item__c(Achievement_Set__c = achievementSetId, Achievement__c = achievementId);
            }
            achievements.add(new Achievement(getAchievement(achievementId), oldRecord));
        }
        return achievements;
    }

    public static void applyAchievementsToSet(Id achievementSetId, List<AchievementUtils.AchievementGroup> groups) {
        for (AchievementUtils.AchievementGroup grp : groups) {
            for (Achievement a : grp.achievements) {
                a.oldRecord.Achievement_Set__c = achievementSetId;
            }
        }
    }

    public static void save(List<AchievementUtils.AchievementGroup> groups) {
        List<Achievement_Set_Item__c> recordsToInsert = new List<Achievement_Set_Item__c>();
        List<Achievement_Set_Item__c> recordsToUpdate = new List<Achievement_Set_Item__c>();
        List<Achievement_Set_Item__c> recordsToDelete = new List<Achievement_Set_Item__c>();

        for (AchievementUtils.AchievementGroup g : groups) {
            prepareAchievementToSave(g.achievements, recordsToInsert, recordsToUpdate, recordsToDelete);
        }

        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
        if (!recordsToDelete.isEmpty()) {
            delete recordsToDelete;
        }
    }

    public static void save(List<Achievement> achievements) {
        List<Achievement_Set_Item__c> recordsToInsert = new List<Achievement_Set_Item__c>();
        List<Achievement_Set_Item__c> recordsToUpdate = new List<Achievement_Set_Item__c>();
        List<Achievement_Set_Item__c> recordsToDelete = new List<Achievement_Set_Item__c>();
        prepareAchievementToSave(achievements, recordsToInsert, recordsToUpdate, recordsToDelete);

        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
        if (!recordsToDelete.isEmpty()) {
            delete recordsToDelete;
        }
    }

    private static void prepareAchievementToSave(List<Achievement> achievements, List<Achievement_Set_Item__c> recordsToInsert, List<Achievement_Set_Item__c> recordsToUpdate,List<Achievement_Set_Item__c> recordsToDelete) {
        for (Achievement a : achievements) {
            if (a.getIsCert()) {
                if (!a.selected && !a.getIsNew()) {
                    recordsToDelete.add(a.oldRecord);
                } else if (a.selected && a.getIsNew()) {
                    recordsToInsert.add(a.oldRecord);
                }
            } else if (a.getIsBadge() || a.getIsAttribute()) {
                if (!a.getIsNew() && (a.oldRecord.Amount__c == 0 || a.oldRecord.Amount__c == null)) {
                    recordsToDelete.add(a.oldRecord);
                } else if (a.oldRecord.Amount__c != 0 && a.oldRecord.Amount__c != null) {
                    if (!a.getIsNew()) {
                        recordsToUpdate.add(a.oldRecord);
                    } else {
                        recordsToInsert.add(a.oldRecord);
                    }
                }
            } else if (a.getIsSkill() || a.getIsGroup()) {
                if (!a.getIsNew() && (a.oldRecord.Level__c == '' || a.oldRecord.Level__c == null)) {
                    recordsToDelete.add(a.oldRecord);
                } else if (a.oldRecord.Level__c != '' && a.oldRecord.Level__c != null) {
                    if (!a.getIsNew()) {
                        recordsToUpdate.add(a.oldRecord);
                    } else {
                        recordsToInsert.add(a.oldRecord);
                    }
                }
            } else if (a.getIsSpecialization()) {
                if (!a.getIsNew() && (a.oldRecord.Min_Speciality_Match__c == 0 || a.oldRecord.Min_Speciality_Match__c == null)) {
                    recordsToDelete.add(a.oldRecord);
                } else if (a.oldRecord.Min_Speciality_Match__c != 0 && a.oldRecord.Min_Speciality_Match__c != null) {
                    if (!a.getIsNew()) {
                        recordsToUpdate.add(a.oldRecord);
                    } else {
                        recordsToInsert.add(a.oldRecord);
                    }
                }
            } else if (a.getIsMonthsFromDate()) {
                if (!a.getIsNew() && (a.oldRecord.Date__c == null)) {
                    recordsToDelete.add(a.oldRecord);
                } else if(a.oldRecord.Date__c != null) {
                    if (!a.getIsNew()) {
                        recordsToUpdate.add(a.oldRecord);
                    } else {
                        recordsToInsert.add(a.oldRecord);
                    }
                }
            } 
        }
    }

    public static Map<Id, Achievement_Set__c> achievementSetsInfo = null;
    public static Map<Id, Achievement_Set__c> getAllAchievementSetsInfo() {
        if (achievementSetsInfo == null) {
            achievementSetsInfo = new Map<Id, Achievement_Set__c>();
            for (Achievement_Set__c item : [SELECT Id, Name FROM Achievement_Set__c]) {
                achievementSetsInfo.put(item.Id, item);
            }
        }
        return achievementSetsInfo;
    }

    public static Achievement_Set__c getAchievementSetInfo(Id key) {
        getAllAchievementSetsInfo();
        return achievementSetsInfo.get(key);
    }

    public static List<Achievement_Set__c> getAchievementSets(final Set<ID> ids, final Set<ID> recordTypeIds, Boolean withItems) {
        return getAchievementSets(ids, recordTypeIds, withItems, null);
    }

    public static List<Achievement_Set__c> getAchievementSets(final Set<ID> ids, final Set<ID> recordTypeIds, Boolean withItems, String customCondition) {
        return Database.query(getAchievementSetsQuery(ids, recordTypeIds, withItems, customCondition));
    }

    public static String getAchievementSetsQuery(final Set<ID> ids, final Set<ID> recordTypeIds, Boolean withItems) {
        return getAchievementSetsQuery(ids, recordTypeIds, withItems, null);
    }

    public static String getAchievementSetsQuery(final Set<ID> ids, final Set<ID> recordTypeIds, Boolean withItems, String customCondition) {
        String query = 'SELECT Id, Name, Contact__c, Contact__r.Email, Contact__r.FirstName, Contact__r.SkillAssessment__c, Contact__r.LastName, Contact__r.Current_Position__r.Name, Career_Path__c, Score_Minimal_Value__c, AboutWho__c, AboutWho__r.Email, AboutWho__r.FirstName, AboutWho__r.LastName, Who__c, RecordTypeId, SelfSurvey__c, Parent_Profile__c, RecordType.DeveloperName, Description__c, ExternalId__c, Skip_Score_Calculation__c';
        if (withItems) {
            query += ', (SELECT Achievement__r.Name, Achievement__r.ExternalId__c, Achievement__c, Amount__c, Level__c, LevelValue__c, NumberOfMonths__c, Date__c, Weight__c, Min_Speciality_Match__c, Type__c, Achievement__r.RecordType.DeveloperName, Achievement__r.Group_Type__c, ExternalId__c FROM Achievements__r WHERE HistoryRecord__c = false)';
        }
        query += ' FROM Achievement_Set__c WHERE';

        if ((recordTypeIds != null && recordTypeIds.isEmpty()) || (ids != null && ids.isEmpty())) {
            if (customCondition == null) {
                query += ' Id = null';
            }
        } else {
            query += ' Id != null';
            if (recordTypeIds != null && !recordTypeIds.isEmpty()) {
                Id rtContactProfile = null;
                query += ' AND (';
                if (recordTypeIds.contains(AchievementUtils.getAchievementSetContactProfileRecordType().Id)) {
                    rtContactProfile = AchievementUtils.getAchievementSetContactProfileRecordType().Id;
                    recordTypeIds.remove(rtContactProfile);
                }
                if (!recordTypeIds.isEmpty()) {
                    query += ' RecordTypeId IN (\'' + String.join(new List<ID>(recordTypeIds), '\',\'') + '\')';
                }

                if (rtContactProfile != null) {
                    if (!recordTypeIds.isEmpty()) {
                        query += ' OR';
                    }
                    query += ' (RecordTypeId = \''+rtContactProfile+'\' AND Contact__r.SkillAssessment__c = True)';
                }

                query += ' )';
            }
            if (ids != null && !ids.isEmpty()) {
                query += ' AND Id IN (\'' + String.join(new List<ID>(ids), '\',\'') + '\')';
            }
        }
        if (customCondition != null) {
            query += ' AND ' + customCondition;
        }
        query += ' ORDER BY Name';
        return query;
    }

    public static void calculateContactProfileScores(Set<ID> contactProfileIds, Set<ID> positionProfileIds) {
        if ((contactProfileIds != null && positionProfileIds != null &&
             contactProfileIds.size() <= AchievementUtils.EMPLOYEE_LIMIT &&
             positionProfileIds.size() <= AchievementUtils.POSITION_LIMIT) &&
            [SELECT Count() FROM AsyncApexJob WHERE JobType='BatchApex' AND ApexClass.Name = 'AchievementProfilePartialCalcuationJob' AND Status IN ('Queued', 'Holding') LIMIT 5] < 5) {
                
            Database.executeBatch(new AchievementProfilePartialCalculationJob(contactProfileIds));

        } else if ([SELECT Count() FROM AsyncApexJob WHERE JobType='BatchApex' AND ApexClass.Name = 'AchievementProfileCalcuationJob' AND Status IN ('Queued', 'Holding') LIMIT 1] == 0) {

            Database.executeBatch(new AchievementProfileCalcuationJob());
        }
    }

    public static void calculateContactProfileScoresWithoutBatch(List<Achievement_Set__c> contactProfiles, List<Achievement_Set__c> positionProfiles) {
        List<Contact_Profile_Score__c> profileScores = new List<Contact_Profile_Score__c>();
        List<Contact_Profile_Score__c> allProfileScores = new List<Contact_Profile_Score__c>();
        Set<String> profileScoresToDelete = new Set<String>();
        for (Achievement_Set__c c : contactProfiles) {
            for (Achievement_Set__c p : positionProfiles) {
                if (p.Skip_Score_Calculation__c != null && p.Skip_Score_Calculation__c) {
                    continue;
                }
                Contact_Profile_Score__c cp = calculateContactProfileScore(c, p);
                if (cp.Match__c >= p.Score_Minimal_Value__c) {
                    profileScores.add(cp);
                } else {
                    profileScoresToDelete.add(cp.unique_name__c);
                    cp.Match__c = 0.0;
                }
                allProfileScores.add(cp);
            }
        }

        rewriteContactProfileScoresToSpecializationItems(allProfileScores);

        if (!profileScores.isEmpty()) {
            upsert profileScores unique_name__c;
        }
        if (!profileScoresToDelete.isEmpty()) {
            delete [SELECT Id FROM Contact_Profile_Score__c WHERE unique_name__c IN : profileScoresToDelete LIMIT :profileScoresToDelete.size()];
        }
    }

    public static Contact_Profile_Score__c calculateContactProfileScore(Achievement_Set__c c, Achievement_Set__c p) {
        Map<Id, Achievement_Set_Item__c> caMap = new Map<Id, Achievement_Set_Item__c>();
        for (Achievement_Set_Item__c ca : c.Achievements__r) {
            caMap.put(ca.Achievement__c, ca);
        }

        Double counter = 0;
        Double sum = 0;
        Double weight = 1;

        for (Achievement_Set_Item__c ppa : p.Achievements__r) {
            weight = ppa.Weight__c == null ? 1.0 : ppa.Weight__c;
            sum += weight;
            if (caMap.containsKey(ppa.Achievement__c)) {
                Achievement_Set_Item__c ca = caMap.get(ppa.Achievement__c);
                if (ppa.Achievement__r.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE) {
                    counter += weight;
                } else if (ppa.Achievement__r.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE && ca.Amount__c != null && ppa.Amount__c != null) {
                    Double cAmount = ca.Amount__c;
                    Double pAmount = ppa.Amount__c;
                    if (cAmount >= pAmount) {
                        counter += weight;
                    } else {
                        counter += ((cAmount) / pAmount) * weight;
                    }
                } else if ((ppa.Achievement__r.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE ||
                            (ppa.Achievement__r.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE && ppa.Achievement__r.Group_Type__c == AchievementUtils.ACHIEVEMENT_MANUAL_GROUP_TYPE))
                            && ca.Level__c != null && ppa.Level__c != null) {
                    Double cAmount = AchievementUtils.getLevelValue(ca.Level__c);
                    Double pAmount = AchievementUtils.getLevelValue(ppa.Level__c);
                    if (cAmount >= pAmount) {
                        counter += weight;
                    } else {
                        counter += ((cAmount) / pAmount) * weight;
                    }
                } else if (ppa.Achievement__r.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE) {
                    if (ca.Min_Speciality_Match__c >= ppa.Min_Speciality_Match__c) {
                        counter += weight;
                    } else {
                        counter += ((ca.Min_Speciality_Match__c) / ppa.Min_Speciality_Match__c);
                    }
                } else if (ppa.Achievement__r.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE && ca.NumberOfmonths__c != null && ppa.NumberOfmonths__c != null) {
                    Double cNumberOfmonths = ca.NumberOfmonths__c;
                    Double pNumberOfmonths = ppa.NumberOfmonths__c;
                    if (cNumberOfmonths >= pNumberOfmonths) {
                        counter += weight;
                    } else {
                        counter += ((cNumberOfmonths) / pNumberOfmonths) * weight;
                    }
                } else if (ppa.Achievement__r.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE && ca.Amount__c != null && ppa.Amount__c != null) {
                    if (ca.Amount__c >= ppa.Amount__c) {
                        counter += weight;
                    } else {
                        Double pValue = getAchievementsValues().get(ca.Achievement__c).get(Integer.valueOf(ca.Amount__c)).IndexOfValue__c + 1;
                        Double cValue = getAchievementsValues().get(ppa.Achievement__c).get(Integer.valueOf(ppa.Amount__c)).IndexOfValue__c + 1;
                        counter += (pValue / cValue ) * weight;
                    }
                }
            }
        }
        return new Contact_Profile_Score__c(
                Contact__c = c.Contact__c,
                Contact_Profile__c = c.Id,
                Achievement_Profile__c = p.Id,
                unique_name__c = String.valueOf(c.Contact__c)+String.valueOf(p.Id),
                Match__c = sum == 0 ? 0 : counter/sum);
    }

    public static void rewriteContactProfileScoresToSpecializationItems(List<Contact_Profile_Score__c> profileScores) {
        List<Achievement_Set_Item__c> achievementSetItems = new List<Achievement_Set_Item__c>();
        List<Contact_Profile_Score__c> specializationProfileScores = new List<Contact_Profile_Score__c>();
        Map<Id, Achievement_Set__c> achievementSets = new Map<Id, Achievement_Set__c>();
        Set<String> achievementSetItemsToDelete = new Set<String>();
        Map<Id, Id> specializationAchievementIds = new Map<Id, Id>();
        Id specializationRecordTypeId = AchievementUtils.getAchievementSpecializationRecordType().Id;
        Id specializationSetRecordTypeId = AchievementUtils.getAchievementSetProfileRecordType().Id;

        for (Achievement_Set__c item : getAchievementSets(null, new Set<Id>{specializationSetRecordTypeId}, false)) {
            achievementSets.put(item.Id, item);
        }
        for (Achievement__c item : getAllAchievements(true)) {
            if (item.RecordTypeId == specializationRecordTypeId) {
                specializationAchievementIds.put(item.Speciality__c, item.Id);
            }
        }
        for (Contact_Profile_Score__c item : profileScores) {
            Achievement_Set__c achievementSet = achievementSets.get(item.Achievement_Profile__c);
            if (achievementSet != null && achievementSet.RecordTypeId == specializationSetRecordTypeId) {
                Achievement_Set_Item__c achievementSetItem = prepareAchievementSetItem(item, specializationAchievementIds);
                if (achievementSetItem.Min_Speciality_Match__c > 0) {
                    achievementSetItems.add(achievementSetItem);
                } else {
                    achievementSetItemsToDelete.add(achievementSetItem.ExternalId__c);
                }
            }
        }
        if(!achievementSetItems.isEmpty()) {
            upsert achievementSetItems ExternalId__c;
        }

        if(!achievementSetItemsToDelete.isEmpty()) {
            delete [SELECT Id FROM Achievement_Set_Item__c WHERE ExternalId__c IN : achievementSetItemsToDelete LIMIT :achievementSetItemsToDelete.size()];
        }
    }

    private static Achievement_Set_Item__c prepareAchievementSetItem(Contact_Profile_Score__c profileScore, Map<Id, Id> achievements) {
        Id id = achievements.get(profileScore.Achievement_Profile__c);
        Map<Id, Achievement_Set__c> achievementsSets = new Map<Id, Achievement_Set__c>();
        achievementsSets = new Map<Id, Achievement_Set__c>(getAchievementSets(new Set<Id>{profileScore.Contact_Profile__c}, null, false));
        Double minSpecialityMatch = profileScore.Match__c.setScale(2);
        return new Achievement_Set_Item__c(
                Achievement__c = id,
                ExternalId__c = achievementsSets.get(profileScore.Contact_Profile__c).ExternalID__c+'#'+getAchievement(id).ExternalId__c,
                Achievement_Set__c = profileScore.Contact_Profile__c,
                Min_Speciality_Match__c = minSpecialityMatch);
    }

    public static Set<ID> getGroupsByMemberIds(Set<ID> achievementIds) {
        Set<ID> groupIds = new Set<ID>();
        for (Achievement_Group_Item__c g : [SELECT Group__c FROM Achievement_Group_Item__c WHERE Achievement__c IN :achievementIds AND Group__r.Group_Type__c != :AchievementUtils.ACHIEVEMENT_MANUAL_GROUP_TYPE]) {
            groupIds.add(g.Group__c);
        }
        return groupIds;
    }

    public static void calculateContactAchievementGroupValues(Set<ID> contactProfileIds, Set<ID> groupIds) {
        if (!groupIds.isEmpty()) {
            if ((contactProfileIds != null && contactProfileIds.size() <= AchievementUtils.EMPLOYEE_LIMIT) &&
                [SELECT Count() FROM AsyncApexJob WHERE JobType='BatchApex' AND ApexClass.Name = 'AchievementGroupPartialCalculationJob' AND Status IN ('Queued', 'Holding') LIMIT 5] < 5) {
                Database.executeBatch(new AchievementGroupPartialCalculationJob(contactProfileIds, groupIds));
            } else if ([SELECT Count() FROM AsyncApexJob WHERE JobType='BatchApex' AND ApexClass.Name = 'AchievementGroupCalculationJob' AND Status IN ('Queued', 'Holding') LIMIT 1] == 0) {
                Database.executeBatch(new AchievementGroupCalculationJob(groupIds));
            }
        }
    }

    public static void calculateContactAchievementGroupValuesWithoutBatch(List<Achievement_Set__c> profiles, Set<Id> groups) {
        Map<ID, Set<ID>> skillIdToGroupIds = new Map<ID, Set<ID>>();
        Map<ID, Achievement__c> groupMap = new Map<ID, Achievement__c>();
        for (Achievement__c grp : AchievementService.getAchievementGroups(groups)) {
            for (Achievement_Group_Item__c item : grp.Achievement_Group_Items__r) {
                if (!skillIdToGroupIds.containsKey(item.Achievement__c)) {
                    skillIdToGroupIds.put(item.Achievement__c, new Set<ID>());
                }
                skillIdToGroupIds.get(item.Achievement__c).add(grp.Id);
            }
            groupMap.put(grp.Id, grp);
        }

        List<Achievement_Set_Item__c> items = new List<Achievement_Set_Item__c>();
        Map<ID, Map<ID, Achievement_Set_Item__c>> groupToItemMap = new Map<ID, Map<ID, Achievement_Set_Item__c>>();
        
        for (Achievement_Set__c profile : profiles) {
            for (Achievement_Set_Item__c item : profile.Achievements__r) {
                if (skillIdToGroupIds.containsKey(item.Achievement__c)) {
                    for (ID groupId : skillIdToGroupIds.get(item.Achievement__c)) {
                        Achievement__c grp = groupMap.get(groupId);
                        Achievement_Set_Item__c grpItem = addGroupAchievement(items, groupToItemMap, profile, grp);
                        if (grp.Group_Type__c == AchievementUtils.ACHIEVEMENT_GREATEST_VALUE_GROUP_TYPE || grp.Group_Type__c == AchievementUtils.ACHIEVEMENT_GREATEST_VALUE_SPECIALIZATION_GROUP_TYPE) {
                            if (AchievementUtils.compareLevel(grpItem.Level__c, item.Level__c)) {
                                grpItem.Level__c = item.Level__c;
                            }
                        }
                    }
                }
                if (groupMap.containsKey(item.Achievement__c)) {
                    Achievement_Set_Item__c grpItem = addGroupAchievement(items, groupToItemMap, profile, groupMap.get(item.Achievement__c));
                    grpItem.Id = item.Id;
                }
            }
        }


        List<Achievement_Set_Item__c> itemsToUpsert = new List<Achievement_Set_Item__c>();
        List<Achievement_Set_Item__c> itemsToDelete = new List<Achievement_Set_Item__c>();
        for (Achievement_Set_Item__c item : items) {
            Achievement__c grp = groupMap.get(item.Achievement__c);
            if (grp != null) {
                if(grp.Group_Type__c == AchievementUtils.ACHIEVEMENT_GREATEST_VALUE_GROUP_TYPE || grp.Group_Type__c == AchievementUtils.ACHIEVEMENT_GREATEST_VALUE_SPECIALIZATION_GROUP_TYPE) {
                    if (item.Level__c != null && item.Level__c != '') {
                        itemsToUpsert.add(item);
                    } else if (item.Id != null) {
                        itemsToDelete.add(item);
                    }
                }
            }
        }

        if (!itemsToUpsert.isEmpty()) {
            upsert itemsToUpsert;
        }
        if (!itemsToDelete.isEmpty()) {
            delete itemsToDelete;
        }
    }
    
    private static Achievement_Set_Item__c addGroupAchievement(List<Achievement_Set_Item__c> items, Map<ID, Map<ID, Achievement_Set_Item__c>> groupToItemMap, Achievement_Set__c profile, Achievement__c grp) {
        Achievement_Set_Item__c item;
        if (!groupToItemMap.containsKey(grp.Id)) {
            groupToItemMap.put(grp.Id, new Map<ID, Achievement_Set_Item__c>());
        }
        if (!groupToItemMap.get(grp.Id).containsKey(profile.Id)) {
            item = new Achievement_Set_Item__c(Achievement_Set__c=profile.Id, Achievement__c=grp.Id);
            items.add(item);
            groupToItemMap.get(grp.Id).put(profile.Id, item);
        }
        item = groupToItemMap.get(grp.Id).get(profile.Id);
        return item;
    }

    public static List<Contact_Profile_Score__c> findContactsByAchievmentsSet(Set<String> achievementsSets) {
        List<Contact_Profile_Score__c> contactScore = [SELECT Contact__r.FirstName, Contact__r.LastName, Match__c, Achievement_Profile__r.Name FROM Contact_Profile_Score__c WHERE Achievement_Profile__r.Name IN : achievementsSets];
        return contactScore;
    }

    public static List<Achievement_Set_Item__c> findContactsByAchievments(Set<String> achievements) {
        List<Achievement_Set_Item__c> contactScore = [SELECT Achievement_Set__r.Contact__r.FirstName, Achievement_Set__r.Contact__r.LastName, Min_Speciality_Match__c FROM Achievement_Set_Item__c WHERE Achievement__r.Name IN : achievements AND HistoryRecord__c=false];
        return contactScore;
    }

    public static Map<String, CategoryHierarchy> getCategoriesTree() {
        Map<String, CategoryHierarchy> categoriesHierarchy = new Map<String, CategoryHierarchy>();
        for (Achievement_Category__c item : getCategoriesToTree()) {
            CategoryHierarchy category = new CategoryHierarchy(item.Id, item.Parent_Category__c, item.Name);
            categoriesHierarchy.put(item.Id, category);
        }
        return categoriesHierarchy;
    }

    private static List<Achievement_Category__c> categoriesTree = null;
    private static List<Achievement_Category__c> getCategoriesToTree() {
        if (categoriesTree == null) {
            categoriesTree = [SELECT Id, Name, Parent_Category__c, Hierarchy__c FROM Achievement_Category__c ORDER BY Hierarchy__c DESC];
        }
        return categoriesTree;
    }

    private static Map<Id, Contact> contacts = null;
    public static Map<Id, Contact> getContacts () {
        if(contacts == null || Test.isRunningTest()) {
            contacts = new Map<Id, Contact>([SELECT Id, ExternalId__c FROM Contact WHERE SkillAssessment__c = True]);
        }
        return contacts;
    }

    public static void blockHistoryRecordModifications(Achievement_Set_Item__c[] newItems) {
        if (newItems != null && !newItems.isEmpty()) {
            for (Achievement_Set_Item__c item : newItems) {
                if (item.HistoryRecord__c) {
                    item.addError('Cannot modify history records!');
                }
            }
        }
    }

    public static void trackHistory(Achievement_Set_Item__c[] newItems, Map<ID, Achievement_Set_Item__c> oldItems) {
        Achievement_Set_Item__c[] historyItems = new List<Achievement_Set_Item__c>();
        DateTime currentDate = DateTime.now();

        if (newItems != null && !newItems.isEmpty()) {
            for (Achievement_Set_Item__c newItem : newItems) {
                if (oldItems.containsKey(newItem.Id)) {
                    newItem.EndDate__c = null;
                    Achievement_Set_Item__c oldItem = oldItems.get(newItem.Id);
                    if (!matchAttributes(newItem, oldItem).equalValue) {
                        Achievement_Set_Item__c historyItem = oldItem.clone();
                        historyItem.EndDate__c = currentDate;
                        historyItem.ExternalId__c = oldItem.ExternalId__c+'#' + math.random()*100000000;
                        newItem.StartDate__c = currentDate;
                        historyItems.add(historyItem);
                    }
                }
            }
        } else if (oldItems != null && !oldItems.values().isEmpty()){
             for (Achievement_Set_Item__c item : oldItems.values()) {
                Achievement_Set_Item__c historyItem = item.clone();
                historyItem.EndDate__c = currentDate;
                historyItem.ExternalId__c = item.ExternalId__c+'#' + math.random()*100000000;
                historyItems.add(historyItem);
            }
        }
        if (!historyItems.isEmpty()) {
            insert historyItems;
        }
    }

    public static ProfilerMatchingDetailsItem matchAttributes(Achievement_Set_Item__c src, Achievement_Set_Item__c target) {
        return new ProfilerMatchingDetails(src).addItem(target).comparedValues[0];
    }

    public virtual class ProfilerMatchingDetails {
        public Achievement_Set_Item__c baseValue {get; private set;}
        public Double scoreValue {get; private set;}
        public ProfilerMatchingDetailsItem[] comparedValues {get; private set;}

        public ProfilerMatchingDetails(Achievement_Set_Item__c item) {
            baseValue = item;
            scoreValue = getAttributeScoreValue(item);
            comparedValues =  new List<ProfilerMatchingDetailsItem>();
        }

        public ProfilerMatchingDetails addItem(Achievement_Set_Item__c srcItem) {
            comparedValues.add(new ProfilerMatchingDetailsItem(this, srcItem));
            return this;
        }
    }

    public static Double getAttributeScoreValue(Achievement_Set_Item__c item) {
        if (item.Type__c == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE || (item.Type__c == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE || item.LevelValue__c != null) || item.Type__c == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE) {
            return item.LevelValue__c == null ? 0.0 : Double.valueOf(item.LevelValue__c);
        } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE) {
            return item.Amount__c == null ? 0.0 : Double.valueOf(item.Amount__c);
        } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE) {
            return item.Id != null ? 1.0 : 0.0;
        } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE) {
            return item.NumberOfMonths__c == null ? 0.0 : Double.valueOf(item.NumberOfMonths__c);
        } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE) {
            return item.Min_Speciality_Match__c == null ? 0.0 : Double.valueOf(item.Min_Speciality_Match__c);
        }
        return 0.0;
    }

    public virtual class ProfilerMatchingDetailsItem {

        public ProfilerMatchingDetailsItem(ProfilerMatchingDetails detail, Achievement_Set_Item__c srcItem) {
            value = srcItem;
            scoreValue = getAttributeScoreValue(srcItem);
            percent = scoreValue >= detail.scoreValue || detail.scoreValue <= 0 ? 1.0 : scoreValue / detail.scoreValue;
            greaterValue = scoreValue > detail.scoreValue;
            lowerValue = scoreValue < detail.scoreValue;
            equalValue = scoreValue == detail.scoreValue;
        }

        public Achievement_Set_Item__c value {get; private set;}
        public Double scoreValue {get; private set;}
        public Double percent {get; private set;}
        public Boolean equalValue {get; private set;}
        public Boolean greaterValue {get; private set;}
        public Boolean lowerValue {get; private set;}
    }

    public  with sharing class CategoryHierarchy {
        public Id id;
        public Id parentId;
        public String name;

        public CategoryHierarchy(Id id, Id parentId, String name) {
            this.id = id;
            this.parentId = parentId;
            this.name = name;
        }
    }
}