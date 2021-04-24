@IsTest
private class AchievementAccessTriggerTest {

    @isTest
    private static void shouldSetAccessToLeaders() {
        //GIVEN
        Achievement_Category__c cat = new AchievementUtils.AchievementCategoryBuilder('AchievementAccessCategory').buildAndSave();
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('Achievement', cat).asSkill().buildAndSave();

        //WHEN
        new AchievementUtils.AchievementAccessBuilder(achievement).onlyLeader().buildAndSave();

        //THEN
        AchievementAccess__c achievementAccess = [SELECT ExternalId__c FROM AchievementAccess__c LIMIT 1];
        System.assertEquals('Achievement#true', achievementAccess.ExternalId__c);
    }

    @isTest
    private static void shouldSetAccessToContact() {
        //GIVEN
        Contact c = new Contact(FirstName='Bruce', LastName='Wayne', Email='b.w@xample.com', SkillAssessment__c=true);
        insert c;
        Achievement_Category__c cat = new AchievementUtils.AchievementCategoryBuilder('AchievementAccessCategory').buildAndSave();
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('Achievement', cat).asSkill().buildAndSave();

        //WHEN
        new AchievementUtils.AchievementAccessBuilder(achievement).withContact(c).buildAndSave();

        //THEN
        AchievementAccess__c achievementAccess = [SELECT ExternalId__c FROM AchievementAccess__c LIMIT 1];
        System.assertEquals('Achievement#b.w@xample.com', achievementAccess.ExternalId__c);
    }


}