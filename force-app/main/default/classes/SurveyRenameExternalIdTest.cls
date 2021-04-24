@isTest
private class SurveyRenameExternalIdTest
{
    @isTest
    static void itShouldRenameAchievementExternalIdTemplateItem()
    {
        Test.startTest();
        // Given
        String configClassProvider = 'AchievementSurveyUtils.AchievementPositionProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementPositionProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentExternalId":"' + achievements[0].ExternalId__c + '","getAll":"false"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig);

        // When
        achievements[0].Name = 'New name';
        update achievements;
        Test.stopTest();

        // Then
        List<SurveyTemplateItem__c> surveyTemplateItem = [SELECT Config__c FROM SurveyTemplateItem__c];
        Map<String, Object> config = (Map<String, Object>) JSON.deserializeUntyped(surveyTemplateItem[0].Config__c);
        System.assertEquals('New name', (String) config.get(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY));
    }

    @isTest
    static void itShouldRenameCategoryExternalIdTemplateItem()
    {
        Test.startTest();
        // Given
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        Achievement_Category__c category = [SELECT Id, Name, ExternalId__c FROM Achievement_Category__c LIMIT 1];
        String templateItemConfig = '{"achievmentExternalId":"", "categoryExternalId":"' + category.ExternalId__c + '","getAll":"false", "email": "false"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig);

        // When
        category.Name = 'New category';
        update category;
        Test.stopTest();

        // Then
        List<SurveyTemplateItem__c> surveyTemplateItem = [SELECT Config__c FROM SurveyTemplateItem__c];
        Map<String, Object> config = (Map<String, Object>) JSON.deserializeUntyped(surveyTemplateItem[0].Config__c);
        System.assertEquals('New category', (String) config.get(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY));
    }

    static private List<Achievement__c> createAchievmentWithCategory(String name) {
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder(name+'SurveyRenameExternalIdTest').buildAndSave();
        new AchievementUtils.AchievementBuilder('AchievementSkill', category).asSkill().buildAndSave();
        return [SELECT Id, Name, ExternalId__c FROM Achievement__c];
    }

    static private List<SurveyTestUtils.SurveyConfigBuilder> createConfig(String providerName, String handlerName, String configClassProvider, String configClassHandler) {
        String configSignature = '{}';
        Id providerRecordTypeId = SurveyUtils.getSurveyConfigRecordType(SurveyUtils.SURVEY_CONFIGURATION_SURVEY_QUESTION_PROVIDER_RECORD_TYPE).Id;
        Id handlerRecordTypeId = SurveyUtils.getSurveyConfigRecordType(SurveyUtils.SURVEY_CONFIGURATION_SURVEY_HANDLER_RECORD_TYPE).Id;

        return new List <SurveyTestUtils.SurveyConfigBuilder> {
            new SurveyTestUtils.SurveyConfigBuilder().setServiceConfig(providerName, configClassProvider, configSignature, providerRecordTypeId, true),
            new SurveyTestUtils.SurveyConfigBuilder().setServiceConfig(handlerName, configClassHandler, configSignature, handlerRecordTypeId, true)
        };
    }

    static private SurveyTemplate__c  prepateTemplate (String configClassProvider, String configClassHandler, String templateConfig, String templateItemConfig) {
        String providerName = 'questionProviderSurveyRenameExternalIdTest';
        String handlerName = 'surveyHandlerSurveyRenameExternalIdTest';
        String configSignature = '{}';
        List<SurveyTestUtils.SurveyConfigBuilder> cfgs = createConfig(providerName, handlerName, configClassProvider, configClassHandler);
        cfgs[0].buildAndSave();
        cfgs[1].buildAndSave();
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveytemplatetest').withHandler(cfgs[1].getConfigs().get(handlerName).Id).withConfig(templateConfig).buildAndSave();
        SurveyTemplateItem__c templateItem = new SurveyTestUtils.TemplateItemBuilder(template, cfgs[0].getConfigs().get(providerName)).withConfig(templateItemConfig).buildAndSave();
        return template;
    }
}