/**
 * AchievementSetPageExtension Tests
 * @author Adam Siwek
 */
@isTest
private class AchievementSetPageExtensionTest {

    @isTest
    private static void shouldSaveachievementSet() {
        //GIVEN
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('PositionProfile').asPositionProfile(careerPath).build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);

        //WHEN
        ext.saveAchievementSet();

        //THEN
        List<Achievement_Set__c> achievementSets = new List<Achievement_Set__c>();
        achievementSets.addAll([SELECT Name FROM Achievement_Set__c]);
        System.assertEquals(1, achievementSets.size());
        System.assertEquals('PositionProfile', achievementSets[0].name);
    }

    @isTest
    private static void shouldDisplayErrorMessageWithCareerPathFieldForNonProfilePositions() {
        //GIVEN
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL, SkillAssessment__c = true);
        insert c;
        List<Achievement_Set__c> achievementSets = new List<Achievement_Set__c> {
            new AchievementUtils.AchievementSetBuilder('ContactProfile').asContactProfile(c).withCareerPath(careerPath).build(),
            new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(c, c).withCareerPath(careerPath).build()
        };

        //WHEN

        //THEN
        for (Achievement_Set__c achievementSet : achievementSets) {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
            AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);
            System.assertEquals(null, ext.saveAchievementSet());
        }
        System.assertEquals(1, [SELECT COUNT() FROM Achievement_Set__c]);
    }

    @isTest
    private static void shouldDisplayErrorMessageWithCareerPathFieldForPositionProfile() {
        //GIVEN
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        List<Achievement_Set__c> achievementSets = new List<Achievement_Set__c> {
            new AchievementUtils.AchievementSetBuilder('PrositionProfile').asPositionProfile(careerPath).withoutCareerPath().build(),
            new AchievementUtils.AchievementSetBuilder('Profile').asProfile(careerPath).withoutCareerPath().build()
        };

        //WHEN

        //THEN
        for (Achievement_Set__c achievementSet : achievementSets) {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
            AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);
            System.assertEquals(null, ext.saveAchievementSet());
        }
        System.assertEquals(0, [SELECT COUNT() FROM Achievement_Set__c]);
    }

    @isTest
    private static void shouldDisplayErrorMessageWithContactFieldForContactAchievementSets() {
        //GIVEN
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL, SkillAssessment__c = true);
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('PositionProfile').asContactProfile(c).build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);

        //WHEN

        //THEN
        System.assertEquals(null, ext.saveAchievementSet());
        System.assertEquals(0, [SELECT COUNT() FROM Achievement_Set__c]);
    }

    @isTest
    private static void shouldDisplayErrorMessageWithContactFieldForNonContactAchievementSets() {
        //GIVEN
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL, SkillAssessment__c = true);
        insert c;
        List<Achievement_Set__c> achievementSets = new List<Achievement_Set__c> {
            new AchievementUtils.AchievementSetBuilder('PrositionProfile').asPositionProfile(careerPath).withContact(c).build(),
            new AchievementUtils.AchievementSetBuilder('Profile').asProfile(careerPath).withContact(c).build(),
            new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(c, c).withContact(c).build()
        };

        //WHEN

        //THEN
        for (Achievement_Set__c achievementSet : achievementSets) {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
            AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);
            System.assertEquals(null, ext.saveAchievementSet());
        }
        System.assertEquals(1, [SELECT COUNT() FROM Achievement_Set__c]);
    }

    @isTest
    private static void shouldDisplayErrorMessageWithWhoAndAboutWhoFieldForNonSurveys() {
        //GIVEN
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL, SkillAssessment__c = true);
        insert c;
        List<Achievement_Set__c> achievementSets = new List<Achievement_Set__c> {
            new AchievementUtils.AchievementSetBuilder('ContactProfile').asContactProfile(c).withWho(c).build(),
            new AchievementUtils.AchievementSetBuilder('PrositionProfile').asPositionProfile(careerPath).withWhoAbout(c).build(),
            new AchievementUtils.AchievementSetBuilder('Profile').asProfile(careerPath).withWho(c).withWhoAbout(c).build()
        };

        //WHEN

        //THEN
        for (Achievement_Set__c achievementSet : achievementSets) {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
            AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);
            System.assertEquals(null, ext.saveAchievementSet());
        }
        System.assertEquals(1, [SELECT COUNT() FROM Achievement_Set__c]);
    }

    @isTest
    private static void shouldDisplayErrorMessageWhoAndAboutWhoFieldForSurveys() {
        //GIVEN
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL, SkillAssessment__c = true);
        insert c;
        List<Achievement_Set__c> achievementSets = new List<Achievement_Set__c> {
            new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(c, c).withoutWho().build(),
            new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(c, c).withoutWhoAbout().build()
        };

        //WHEN

        //THEN
        for (Achievement_Set__c achievementSet : achievementSets) {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
            AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);
            System.assertEquals(null, ext.saveAchievementSet());
        }
        System.assertEquals(1, [SELECT COUNT() FROM Achievement_Set__c]);
    }

    @isTest
    private static void shouldUpdateAchievementSet() {
        //GIVEN
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('PositionProfile').asPositionProfile(careerPath).buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);
        ext.achievementSet.Name = 'PositionProfile Updated';

        //WHEN
        ext.saveAchievementSet();

        //THEN
        Achievement_Set__c updateachievementSet = [SELECT Name FROM Achievement_Set__c WHERE Id = :achievementSet.Id];
        System.assertEquals('PositionProfile Updated', updateachievementSet.Name);
    }

    @isTest
    private static void shouldUnselectAllAchievementCategories() {
        //GIVEN
        String categoryName1 = 'testCategory';
        String categoryName2 = 'testCategory1';
        List<Achievement_Category__c> categories = new List<Achievement_Category__c>{
            new AchievementUtils.AchievementCategoryBuilder(categoryName1).build(),
            new AchievementUtils.AchievementCategoryBuilder(categoryName2).build()
        };
        insert categories;
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('PositionProfile').asPositionProfile(careerPath).buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);
        ext.getCategoryFilters();

        //WHEN
        ext.unselectAllCategories();

        //THEN
        List<AchievementSetPageExtension.CategoryWrapper> categoryFilters = ext.getCategoryFilters();
        Integer count = 0;
        for (AchievementSetPageExtension.CategoryWrapper item : categoryFilters) {
            if (!item.selected) {
                count++;
            }
        }
        System.assertEquals(2, count);
    }

    @isTest
    private static void shouldSelectAllAchievementCategories() {
        //GIVEN
        String categoryName1 = 'testCategory';
        String categoryName2 = 'testCategory1';
        List<Achievement_Category__c> categories = new List<Achievement_Category__c>{
            new AchievementUtils.AchievementCategoryBuilder(categoryName1).build(),
            new AchievementUtils.AchievementCategoryBuilder(categoryName2).build()
        };
        insert categories;
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('PositionProfile').asPositionProfile(careerPath).buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);
        ext.getCategoryFilters();

        //WHEN
        ext.selectAllCategories();

        //THEN
        List<AchievementSetPageExtension.CategoryWrapper> categoryFilters = ext.getCategoryFilters();
        Integer count = 0;
        for (AchievementSetPageExtension.CategoryWrapper item : categoryFilters) {
            if (item.selected) {
                count++;
            }
        }
        System.assertEquals(2, count);
    }

    @isTest
    private static void shouldGetAchievementLevels() {
        //GIVEN
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('PositionProfile').asPositionProfile(careerPath).buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);

        //WHEN
        List<SelectOption> achievementLevels = ext.getAchievementLevels();

        //THEN
        System.assertEquals(4, achievementLevels.size());
    }

    @isTest
    private static void shouldDisplayFieldsForPrositionProfile() {
        //GIVEN
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('PositionProfile').asPositionProfile(careerPath).buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);

        //WHEN
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);

        //THEN
        System.assertEquals(true, ext.getCanEditAchievementSetName());
        System.assertEquals(false, ext.getShowWhoField());
        System.assertEquals(false, ext.getShowAchievementSetContact());
        System.assertEquals(true, ext.getShowAchievementSetMinScoreValue());
        System.assertEquals(true, ext.getShowCareerPath());
        System.assertEquals(true, ext.getShowGroups());
        System.assertEquals(true, ext.getShowSpecializations());
        System.assertEquals(true, ext.getShowSpecializationGroups());
    }

    @isTest
    private static void shouldDisplayFieldsForContactProfile() {
        //GIVEN
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL, SkillAssessment__c = true);
        insert c;
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c =:c.Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c.Id)).asContactProfile(c).buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);

        //WHEN
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);

        //THEN
        System.assertEquals(false, ext.getCanEditAchievementSetName());
        System.assertEquals(false, ext.getShowWhoField());
        System.assertEquals(true, ext.getShowAchievementSetContact());
        System.assertEquals(false, ext.getShowAchievementSetMinScoreValue());
        System.assertEquals(false, ext.getShowCareerPath());
        System.assertEquals(false, ext.getShowGroups());
        System.assertEquals(false, ext.getShowSpecializations());
        System.assertEquals(false, ext.getShowSpecializationGroups());
    }

    @isTest
    private static void shouldDisplayFieldsForProfile() {
        //GIVEN
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('PositionProfile').asProfile(careerPath).buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);

        //WHEN
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);

        //THEN
        System.assertEquals(true, ext.getCanEditAchievementSetName());
        System.assertEquals(false, ext.getShowWhoField());
        System.assertEquals(false, ext.getShowAchievementSetContact());
        System.assertEquals(true, ext.getShowAchievementSetMinScoreValue());
        System.assertEquals(true, ext.getShowCareerPath());
        System.assertEquals(true, ext.getShowGroups());
        System.assertEquals(false, ext.getShowSpecializations());
        System.assertEquals(false, ext.getShowSpecializationGroups());
    }

    @isTest
    private static void shouldDisplayFieldsForSurvey() {
        //GIVEN
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL, SkillAssessment__c = true);
        insert c;
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('PositionProfile').asSurvey(c, c).buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);

        //WHEN
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);

        //THEN
        System.assertEquals(false, ext.getCanEditAchievementSetName());
        System.assertEquals(true, ext.getShowWhoField());
        System.assertEquals(false, ext.getShowAchievementSetContact());
        System.assertEquals(false, ext.getShowAchievementSetMinScoreValue());
        System.assertEquals(false, ext.getShowCareerPath());
        System.assertEquals(false, ext.getShowGroups());
        System.assertEquals(false, ext.getShowSpecializations());
        System.assertEquals(false, ext.getShowSpecializationGroups());
    }

    @isTest
    private static void shouldFilterAchievementCategories() {
        //GIVEN
        createAchievements(3);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('PositionProfile').asPositionProfile(careerPath).buildAndSave();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);
        AchievementSetPageExtension ext = new AchievementSetPageExtension(stdCtrl);
        ext.getCategoryFilters();

        //WHEN
        List<AchievementUtils.AchievementGroup> achievementGroup =  ext.getAchievementGroups();

        //THEN
        System.assertEquals(3, achievementGroup.size());
    }

    private static void createAchievements(Integer count) {
        List<Achievement__c> achievements = new  List<Achievement__c>();
        for (Integer i = 0; i < count; i++) {
            Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('testCategory'+i).buildAndSave();
            achievements.add(new AchievementUtils.AchievementBuilder('AchievementCertificate'+i, category).asCert().build());
        }
        insert achievements;
    }
}