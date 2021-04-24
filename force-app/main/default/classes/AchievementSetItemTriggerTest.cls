@isTest
private class AchievementSetItemTriggerTest {

    @isTest
    private static void shouldStartAchievementGroupPartialCalculationJob(){
        Contact c = new Contact(FirstName='Zdzisiek', LastName='Burak', Email='Zdzisiek@Burak.pl', SkillAssessment__c=true);
        insert c;
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('category Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();
        Achievement__c apexSkill = new AchievementUtils.AchievementBuilder('apexSkill', category).asSkill().buildAndSave();
        Achievement__c visualforceSkill = new AchievementUtils.AchievementBuilder('visualforceSkill', category).asSkill().buildAndSave();
        Achievement__c soqlSkill = new AchievementUtils.AchievementBuilder('soqlSkill', category).asSkill().buildAndSave();
        Achievement_Set__c achievementSet2 = new AchievementUtils.AchievementSetBuilder('positionProfile').asPositionProfile(careerPath).buildAndSave();
        Achievement_Set__c achievementSet = [SELECT Id, Contact__c, Number_Of_Achievements__c,Active_Contact__c,Career_Path__c,Description__c,Parent_Profile__c,Score_Minimal_Value__c, SelfSurvey__c FROM Achievement_Set__c WHERE Contact__c =: c.Id LIMIT 1];
        Achievement_Set_Item__c achievementSetItem1 = new Achievement_Set_Item__c(
                                                            Achievement_Set__c = achievementSet.id,
                                                            Achievement__c = apexSkill.Id,
                                                            Level__c = AchievementUtils.ACHIEVEMENT_LEVEL_1,
                                                            Amount__c = 1,
                                                            Min_Speciality_Match__c = 0.3);
        Achievement_Set_Item__c achievementSetItem2 = new Achievement_Set_Item__c(
                                                            Achievement_Set__c = achievementSet.id,
                                                            Achievement__c = visualforceSkill.Id,
                                                            Level__c = AchievementUtils.ACHIEVEMENT_LEVEL_1,
                                                            Amount__c = 2,
                                                            Min_Speciality_Match__c = 0.6);
        Achievement_Set_Item__c achievementSetItem3 = new Achievement_Set_Item__c(
                                                            Achievement_Set__c = achievementSet2.id,
                                                            Achievement__c = apexSkill.Id,
                                                            Level__c = AchievementUtils.ACHIEVEMENT_LEVEL_1,
                                                            Amount__c = 1,
                                                            Min_Speciality_Match__c = 0.3);
        Achievement_Set_Item__c achievementSetItem4 = new Achievement_Set_Item__c(
                                                            Achievement_Set__c = achievementSet2.id,
                                                            Achievement__c = visualforceSkill.Id,
                                                            Level__c = AchievementUtils.ACHIEVEMENT_LEVEL_1,
                                                            Amount__c = 2,
                                                            Min_Speciality_Match__c = 0.6);
        List<Achievement_Set_Item__c> achievementSetItems = new List<Achievement_Set_Item__c>{achievementSetItem1, achievementSetItem2, achievementSetItem3, achievementSetItem4};
        insert achievementSetItems;
        Achievement__c salesforceGroup = new AchievementUtils.AchievementBuilder('salesforceGroup', category).asGroup().addGroupItem(visualforceSkill).addGroupItem(apexSkill).buildAndSave();

        achievementSetItem1.Level__c = AchievementUtils.ACHIEVEMENT_LEVEL_3;
        achievementSetItem1.Min_Speciality_Match__c = 0.45;
    }

}