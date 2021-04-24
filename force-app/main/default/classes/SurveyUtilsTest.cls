@isTest
private class SurveyUtilsTest {

    @isTest
    static void shouldGetTemplateProvider() {
        //GIVEN
        String classProvider = 'AchievementSurveyUtils.AchievementQuestionProvider';
        String confName = 'SurveyDefaultConfiguration';

        SurveyTestUtils.SurveyConfigBuilder conf = new SurveyTestUtils.SurveyConfigBuilder();
        SurveyConfiguration__c providerconf = conf.setServiceConfig(confName, classProvider, null, SurveyUtils.getSurveyConfigRecordType(SurveyUtils.SURVEY_CONFIGURATION_SURVEY_QUESTION_PROVIDER_RECORD_TYPE).Id, true).buildAndSave();

        //WHEN
        Map<String, SurveyUtils.SurveyQuestionProvider> providers = SurveyUtils.getQuestionProviders();

        //THEN
        System.assertEquals(1, providers.size());
    }

    @isTest
    static void shouldGetSurveyHandler(){
        //GIVEN
        String classProvider = 'AchievementSurveyUtils.AchievementBaseHandler';
        String confName = 'HandlerDefaultConfiguration';

        SurveyTestUtils.SurveyConfigBuilder conf = new SurveyTestUtils.SurveyConfigBuilder();
        SurveyConfiguration__c providerconf = conf.setServiceConfig(confName, classProvider, null, SurveyUtils.getSurveyConfigRecordType(SurveyUtils.SURVEY_CONFIGURATION_SURVEY_HANDLER_RECORD_TYPE).Id, true).buildAndSave();

        //WHEN
        Map<String,SurveyUtils.SurveyHandler> handlers = SurveyUtils.getSurveyHandlers();

        //THEN
        System.assertEquals(1, handlers.size());
    }

    @isTest
    static void shouldChangeApiNameToLowercase() {
        //GIVEN
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('test Template').buildAndSave();

        //WHEN

        //THEN
        SurveyTemplate__c newTemplate = [SELECT ApiName__c FROM SurveyTemplate__c];
        System.assertEquals('test_template', newTemplate.ApiName__c);
    }

    @isTest
    static void shouldChangeApiNameToLowercaseWhenUpdateSurveyTemplate() {
        //GIVEN
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('test Template').buildAndSave();
        template.Name = 'Test template 2';
        update template;

        //WHEN

        //THEN
        SurveyTemplate__c newTemplate = [SELECT ApiName__c FROM SurveyTemplate__c];
        System.assertEquals('test_template_2', newTemplate.ApiName__c);
    }

    @isTest
    static void shouldChangeApiNameToLowercaseAndTrim() {
        //GIVEN
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('test Template ').buildAndSave();

        //WHEN

        //THEN
        SurveyTemplate__c newTemplate = [SELECT ApiName__c FROM SurveyTemplate__c];
        System.assertEquals('test_template', newTemplate.ApiName__c);
    }

    @isTest
    static void shouldChangeApiNameToLowercaseAndTrimAndReplaceSpecialChars() {
        //GIVEN
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('test Template !@#$%^&*()-+=').buildAndSave();

        //WHEN

        //THEN
        SurveyTemplate__c newTemplate = [SELECT ApiName__c FROM SurveyTemplate__c];
        System.assertEquals('test_template', newTemplate.ApiName__c);
    }
}