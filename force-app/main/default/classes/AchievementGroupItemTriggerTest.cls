@isTest
private class AchievementGroupItemTriggerTest {

    @isTest
    private static void shouldSetAchievemntGroupLevelToSenior(){
        Contact c = new Contact(FirstName='Zdzisiek', LastName='Burak', Email='z@burak.com', SkillAssessment__c=true);
        insert c;
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c =: c.Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('category Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();
        Achievement__c apexSkill = new AchievementUtils.AchievementBuilder('apexSkill', category).asSkill().buildAndSave();
        Achievement__c visualforceSkill = new AchievementUtils.AchievementBuilder('visualforceSkill', category).asSkill().buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c.Id)).asContactProfile(c).
                addSkill(apexSkill, AchievementUtils.ACHIEVEMENT_LEVEL_3).addSkill(visualforceSkill, AchievementUtils.ACHIEVEMENT_LEVEL_3).buildAndSave();

        Test.startTest();
        Achievement__c salesforceGroup = new AchievementUtils.AchievementBuilder('salesforceGroup', category).asGroup().addGroupItem(apexSkill).addGroupItem(visualforceSkill).buildAndSave();
        Test.stopTest();

        System.assertEquals('Senior', [SELECT Level__c FROM Achievement_Set_Item__c WHERE Achievement__c =: salesforceGroup.Id].Level__c);
    }

    @isTest
    private static void shouldSetAchievemntGroupLevelToProfessional(){
        Contact c = new Contact(FirstName='Zdzisiek', LastName='Burak', Email='z@burak.com', SkillAssessment__c=true);
        insert c;
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c = :c.Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('category Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();
        Achievement__c apexSkill = new AchievementUtils.AchievementBuilder('apexSkill', category).asSkill().buildAndSave();
        Achievement__c visualforceSkill = new AchievementUtils.AchievementBuilder('visualforceSkill', category).asSkill().buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c.Id)).asContactProfile(c).
                addSkill(apexSkill, AchievementUtils.ACHIEVEMENT_LEVEL_1).addSkill(visualforceSkill, AchievementUtils.ACHIEVEMENT_LEVEL_2).buildAndSave();

        Test.startTest();
        Achievement__c salesforceGroup = new AchievementUtils.AchievementBuilder('salesforceGroup', category).asGroup().addGroupItem(apexSkill).addGroupItem(visualforceSkill).buildAndSave();
        Test.stopTest();

        System.assertEquals('Professional', [SELECT Level__c FROM Achievement_Set_Item__c WHERE Achievement__c =: salesforceGroup.Id].Level__c);
    }

    @isTest
    private static void shouldSetAchievemntGroupLevelToJunior(){
        Contact c = new Contact(FirstName='Zdzisiek', LastName='Burak', Email='z@burak.com', SkillAssessment__c=true);
        insert c;
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c = :c.Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('category Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();
        Achievement__c apexSkill = new AchievementUtils.AchievementBuilder('apexSkill', category).asSkill().buildAndSave();
        Achievement__c visualforceSkill = new AchievementUtils.AchievementBuilder('visualforceSkill', category).asSkill().buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c.Id)).asContactProfile(c).
                addSkill(apexSkill, AchievementUtils.ACHIEVEMENT_LEVEL_1).addSkill(visualforceSkill, AchievementUtils.ACHIEVEMENT_LEVEL_1).buildAndSave();

        Test.startTest();
        Achievement__c salesforceGroup = new AchievementUtils.AchievementBuilder('salesforceGroup', category).asGroup().addGroupItem(apexSkill).addGroupItem(visualforceSkill).buildAndSave();
        Test.stopTest();

        System.assertEquals('Junior', [SELECT Level__c FROM Achievement_Set_Item__c WHERE Achievement__c =: salesforceGroup.Id].Level__c);
    }

}