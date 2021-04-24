@isTest
private class ContactAchievementSetScorePageExtTest {

    @isTest
    private static void shouldGetAchievementSet() {
        //GIVEN
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test@test.com.pl', SkillAssessment__c=true);
        insert c;
        Achievement_Set__c delAchievment = [SELECT Id FROM Achievement_Set__c LIMIT 1];
        delete delAchievment;

        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPaths').buildAndSave();

        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('Category').buildAndSave();
        List<Achievement__c> skills = new List<Achievement__c>{
            new AchievementUtils.AchievementBuilder('Skill1', category).asSkill().build(),
            new AchievementUtils.AchievementBuilder('Skill2', category).asSkill().build()
        };
        insert skills;
        Achievement_Set__c positionProfile = new AchievementUtils.AchievementSetBuilder('Junior SFDC').
                asPositionProfile(careerPath).
                addSkill(skills[0], AchievementUtils.ACHIEVEMENT_LEVEL_1).
                addSkill(skills[1], AchievementUtils.ACHIEVEMENT_LEVEL_1).
                buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('ContactProfile').
                asContactProfile(c).
                addSkill(skills[0], AchievementUtils.ACHIEVEMENT_LEVEL_1).
                addSkill(skills[1], AchievementUtils.ACHIEVEMENT_LEVEL_1).
                buildAndSave();


        //WHEN
        Test.startTest();
        Database.executeBatch(new AchievementProfileCalcuationJob());
        Test.stopTest();
        List<Contact_Profile_Score__c> contactProfileScores = [SELECT Contact_Profile__c, Achievement_Profile__c FROM Contact_Profile_Score__c WHERE Contact__c=:c.Id LIMIT 1];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(contactProfileScores[0]);
        ContactAchievementSetScorePageExtension ext = new ContactAchievementSetScorePageExtension(stdCtrl);

        //THEN
        System.assertEquals('test' + ' ' + 'test'+ ' - Employee Profile', ext.achievementSet.Name);
    }
}