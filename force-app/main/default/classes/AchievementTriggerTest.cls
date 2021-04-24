/**
 * Achievement Trigger Test
 * @author Michał Banasik
 */
@isTest
private class AchievementTriggerTest {

    @isTest
    private static void shouldNotCreateLevelDescriptionForBadgeRecordType() {
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('achievement', new AchievementUtils.AchievementCategoryBuilder('category').buildAndSave()).asBadge().build();

        insert achievement;

        Achievement__c insertedAchievement = [SELECT Level_1_Details__c, Level_2_Details__c, Level_3_Details__c FROM Achievement__c WHERE Id=:achievement.Id];
        System.assertEquals(null, insertedAchievement.Level_1_Details__c);
        System.assertEquals(null, insertedAchievement.Level_2_Details__c);
        System.assertEquals(null, insertedAchievement.Level_3_Details__c);
    }

    @isTest
    private static void shouldNotCreateLevelDescriptionForCertificateRecordType() {
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('achievement', new AchievementUtils.AchievementCategoryBuilder('category').buildAndSave()).asCert().build();

        insert achievement;

        Achievement__c insertedAchievement = [SELECT Level_1_Details__c, Level_2_Details__c, Level_3_Details__c FROM Achievement__c WHERE Id=:achievement.Id];
        System.assertEquals(null, insertedAchievement.Level_1_Details__c);
        System.assertEquals(null, insertedAchievement.Level_2_Details__c);
        System.assertEquals(null, insertedAchievement.Level_3_Details__c);
    }

    @isTest
    private static void shouldNotCreateLevelDescriptionForSpecializationRecordType() {
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('Specjalization').asProfile(careerPath).buildAndSave();
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('achievement', new AchievementUtils.AchievementCategoryBuilder('category').buildAndSave()).asSpecialization(achievementSet).build();

        insert achievement;

        Achievement__c insertedAchievement = [SELECT Level_1_Details__c, Level_2_Details__c, Level_3_Details__c FROM Achievement__c WHERE Id=:achievement.Id];
        System.assertEquals(null, insertedAchievement.Level_1_Details__c);
        System.assertEquals(null, insertedAchievement.Level_2_Details__c);
        System.assertEquals(null, insertedAchievement.Level_3_Details__c);
    }

    @isTest
    private static void shouldCreateLevelDescriptionForGroupRecordType() {
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('achievement', new AchievementUtils.AchievementCategoryBuilder('category').buildAndSave()).asGroup().build();

        insert achievement;

        Achievement__c insertedAchievement = [SELECT Level_1_Details__c, Level_2_Details__c, Level_3_Details__c FROM Achievement__c WHERE Id=:achievement.Id];
        System.assertNotEquals(null, insertedAchievement.Level_1_Details__c);
        System.assertNotEquals(null, insertedAchievement.Level_2_Details__c);
        System.assertNotEquals(null, insertedAchievement.Level_3_Details__c);
    }

    @isTest
    private static void shouldCreateLevelDescriptionForSkillRecordType() {
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('achievement', new AchievementUtils.AchievementCategoryBuilder('category').buildAndSave()).asSkill().build();

        insert achievement;

        Achievement__c insertedAchievement = [SELECT Level_1_Details__c, Level_2_Details__c, Level_3_Details__c FROM Achievement__c WHERE Id=:achievement.Id];
        System.assertNotEquals(null, insertedAchievement.Level_1_Details__c);
        System.assertNotEquals(null, insertedAchievement.Level_2_Details__c);
        System.assertNotEquals(null, insertedAchievement.Level_3_Details__c);
    }
}