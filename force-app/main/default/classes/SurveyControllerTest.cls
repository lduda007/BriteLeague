@isTest
private class SurveyControllerTest {
    static final private String SFCD_URL = 'https://eu6.force.com';

    @isTest
    static private void shouldGetTemplatesInfo() {
        //GIVEN
        SurveyTemplate__c template = prepateTemplate();
        Contact contact = prepareUser(template);
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String url = SFCD_URL+'/services/apexrest/survey/gettemplatesinfo/'+contact.Email;

        //WHEN
        List<SurveyModel.TemplateInfo> templates = (List<SurveyModel.TemplateInfo>) JSON.deserialize(getResponse(url), List<SurveyModel.TemplateInfo>.class) ;

        //THEN
        System.assertEquals('surveytemplatetest', templates[0].name);
    }

    @isTest
    static private void shouldGetTemplate() {
        //GIVEN
        SurveyTemplate__c surveyTemplate = prepateTemplate();
        Contact contact = prepareUser(surveyTemplate);
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String url = SFCD_URL+'/services/apexrest/survey/gettemplate/'+contact.Email+'/surveytemplatetest';

        //WHEN
        SurveyModel.Template template = (SurveyModel.Template) JSON.deserialize(getResponse(url), SurveyModel.Template.class) ;

        //THEN
        System.assertEquals('surveytemplatetest', template.name);
        System.assertEquals(5, template.questions.size());
    }

    @isTest
    static private void shouldGetSurvey() {
        //GIVEN
        SurveyTemplate__c template = prepateTemplate();
        Contact contact = prepareUser(template);
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        Double minSpecialityMatch = 0.30;
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c =: contact.Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(contact.Id))
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        String url = SFCD_URL+'/services/apexrest/survey/getsurvey/'+contact.Email+'/surveytemplatetest/'+achievementSet.Id;

        //WHEN
        SurveyModel.Survey survey = (SurveyModel.Survey) JSON.deserialize(getResponse(url), SurveyModel.Survey.class) ;

        //THEN
        System.assertEquals('test test - Employee Profile', survey.name);
        System.assertEquals('test@test.pl', survey.userId);
        System.assertEquals(5, survey.answers.size());
    }

    @isTest
    static private void shouldSaveSurvey() {
        //GIVEN
        SurveyTemplate__c template = prepateTemplate();
        Contact contact = prepareUser(template);
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        Double minSpecialityMatch = 0.30;
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c =: contact.Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(contact.Id))
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        String url = SFCD_URL+'/services/apexrest/survey';
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contact.Email, template.ApiName__c, achievementSet.Id);
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);

        //WHEN
        SurveyModel.Survey surveyResponse = (SurveyModel.Survey) JSON.deserialize(getResponse(url, JSON.serialize(survey)), SurveyModel.Survey.class) ;

        //THEN
        System.assertEquals('test test - Employee Profile', surveyResponse.name);
        System.assertEquals('test@test.pl', surveyResponse.userId);
        System.assertEquals(5, surveyResponse.answers.size());
    }

    static private String getResponse(String url) {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = url;
        return SurveyController.getData();
    }

    static private String getResponse(String url, String post) {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = url;
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueof(post);
        return SurveyController.saveSurvey();
    }

    static private List<Achievement__c> createAchievmentWithCategory(String name) {
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder(name+'SurveyControllerTest').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPathAchievementSurveyControllerTest').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('Specjalization SurveyControllerTest').asProfile(careerPath).buildAndSave();
        List<Achievement__c> achievements = new List<Achievement__c>{
            new AchievementUtils.AchievementBuilder('AchievementSkill SurveyControllerTest', category).asSkill().build(),
            new AchievementUtils.AchievementBuilder('AchievementCertificate SurveyControllerTest', category).asCert().build(),
            new AchievementUtils.AchievementBuilder('AchievementBadge SurveyControllerTest', category).asBadge().build(),
            new AchievementUtils.AchievementBuilder('AchievementGroup SurveyControllerTest', category).asGroup().build(),
            new AchievementUtils.AchievementBuilder('AchievementSpecialization SurveyControllerTest', category).asSpecialization(achievementSet).build()
        };
        insert achievements;
        return achievements;
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

    static private SurveyTemplate__c  prepateTemplate () {
        String configClassProvider = 'AchievementSurveyUtils.AchievementEmployeeProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementEmployeeProfileHandler';
        String providerName = 'questionProviderSurveyControllerTest';
        String handlerName = 'surveyHandlerSurveyControllerTest';
        String configSignature = '{}';
        String templateConfig = '{}';
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        List<SurveyTestUtils.SurveyConfigBuilder> cfgs = createConfig(providerName, handlerName, configClassProvider, configClassHandler);
        cfgs[0].buildAndSave();
        cfgs[1].buildAndSave();
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveytemplatetest').withHandler(cfgs[1].getConfigs().get(handlerName).Id).withConfig(templateConfig).buildAndSave();
        SurveyTemplateItem__c templateItem = new SurveyTestUtils.TemplateItemBuilder(template, cfgs[0].getConfigs().get(providerName)).withConfig(templateItemConfig).buildAndSave();
        return template;
    }

    static private Contact prepareUser(SurveyTemplate__c template) {
        Contact contact = new Contact(FirstName = 'test', LastName = 'test', Email='test@test.pl', SkillAssessment__c = true);
        insert contact;

        SurveyTemplateAccesses__c access = new SurveyTemplateAccesses__c(Contact__c=contact.Id, SurveyTemplate__c=template.Id);
        insert access;

        return contact;
    }
}