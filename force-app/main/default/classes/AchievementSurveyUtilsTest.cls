@isTest
private class AchievementSurveyUtilsTest {
    
    @isTest 
    static void shouldGetTemplatePositionProfileWithAllQuestion() {
        // GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementPositionProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementPositionProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);
        //WHEN
        SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);

        //THEN
        System.assertEquals('surveytemplatetest', surveyModelTemplate.name);
        System.assertEquals(5, surveyModelTemplate.questions.size());
    }

    @isTest 
    static void shouldGetTemplateSurveyWithCategoryID() {
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        Achievement_Category__c category = [SELECT Id, ExternalId__c FROM Achievement_Category__c LIMIT 1];
        String templateItemConfig = '{"achievmentExternalId":"", "categoryExternalId":"' + category.ExternalId__c + '","getAll":"false", "email": "false"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, true);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);
        //WHEN
        SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);

        //THEN
        System.assertEquals('surveytemplatetest', surveyModelTemplate.name);
        System.assertEquals(4, surveyModelTemplate.questions.size());
    }

    @isTest 
    static void shouldGetTemplatePositionProfile() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementPositionProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementPositionProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentExternalId":"' + achievements[0].ExternalId__c + '","getAll":"false"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);

        //WHEN
        SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);

        //THEN
        System.assertEquals('surveytemplatetest', surveyModelTemplate.name);
        System.assertEquals(1, surveyModelTemplate.questions.size());
    }

    @isTest 
    static void shouldGetTemplateEmployeeProfileWithAllQuestion() {
        // GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementEmployeeProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementEmployeeProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);

        //WHEN
        SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);

        //THEN
        System.assertEquals('surveytemplatetest', surveyModelTemplate.name);
        System.assertEquals(5, surveyModelTemplate.questions.size());
    }

    @isTest 
    static void shouldGetTemplateEmployeeProfile() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementEmployeeProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementEmployeeProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentExternalId":"' + achievements[0].ExternalId__c + '","getAll":"false"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);

        //WHEN
        SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);

        //THEN
        System.assertEquals('surveytemplatetest', surveyModelTemplate.name);
        System.assertEquals(1, surveyModelTemplate.questions.size());
    }

    @isTest 
    static void shouldGetTemplateSurveyWithAllQuestion() {
        // GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true","email": "false" }';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, true);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);

        //WHEN
        SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);

        //THEN
        System.assertEquals('surveytemplatetest', surveyModelTemplate.name);
        System.assertEquals(4, surveyModelTemplate.questions.size());
    }

    @isTest 
    static void shouldGetTemplateSurvey() {
        // GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentExternalId":"' + achievements[0].ExternalId__c + '","getAll":"false","email": "false" }';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, true);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);

        //WHEN
        SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);

        //THEN
        System.assertEquals('surveytemplatetest', surveyModelTemplate.name);
        System.assertEquals(2, surveyModelTemplate.questions.size());
    }

    @isTest 
    static void shouldNotGetTemplateSurveyWithoutEmailItem() {
        // GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"' + achievements[0].Id + '","getAll":"false","email": "false" }';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);

        //WHEN
        try {
            SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);
            System.assert(false, 'Tamplate not contains question of email');
        } catch (Exception e){}
    }

    @isTest 
    static void shouldNotGetTemplatePositionProfileWithNoFoundAchievment() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementPositionProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementPositionProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"false"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);

        //WHEN
        try {
        SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);
            System.assert(false, 'AchievementId is mandatory!');
        } catch (Exception e){}
    }

    @isTest 
    static void shouldGetTemplateToGraph() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementQuestionGraphProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementBaseHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder('PositionProfile').asPositionProfile(careerPath)
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .buildAndSave();
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);

        //WHEN
        SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);

        //THEN
        System.assertEquals('surveytemplatetest', surveyModelTemplate.name);
        System.assertEquals(10, surveyModelTemplate.questions.size());
    }

    @isTest 
    static void shouldNotGetTemplateWithWrongAchievmentId() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementPositionProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementPositionProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"5003000000D8cuIAEA","getAll":"false"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);

        //WHEN
        try {
            SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);
            System.assert(false, 'Wrong achievmentId');
        } catch (Exception e){}
    }

    @isTest 
    static void shouldNotGetTemplateWithoutAchievmentId() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementPositionProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementPositionProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"false"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(contacts[0].Email, template.ApiName__c);

        //WHEN
        try {
            SurveyModel.Template surveyModelTemplate = SurveyFrontController.getInstance().getTemplate(request);
            System.assert(false, 'Wrong achievmentId');
        } catch (Exception e){}
        
    }

    @isTest 
    static void shouldGetAchievementPositionProfile() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementPositionProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementPositionProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder('PositionProfile').asPositionProfile(careerPath)
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);

        //WHEN
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);

        //THEN
        System.assertEquals('PositionProfile', survey.name);
        System.assertEquals('test1@test.pl', survey.userId);
        System.assertEquals(3, survey.answers.size());
    }

    @isTest 
    static void shouldGetAchievementEmployeeProfile() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementEmployeeProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementEmployeeProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c =: contacts[0].Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }

        Double minSpecialityMatch = 0.30;
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(contacts[0].Id))
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);

        //WHEN
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);

        //THEN
        System.assertEquals('test1 test1 - Employee Profile', survey.name);
        System.assertEquals('test1@test.pl', survey.userId);
        System.assertEquals(5, survey.answers.size());
    }

    @isTest 
    static void shouldGetAchievementSpecialization() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSpecializationQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSpecializationHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        Achievement_Set__c aSet = [SELECT Name, Career_Path__c FROM Achievement_Set__c WHERE RecordTypeId =: AchievementUtils.getAchievementSetProfileRecordType().Id];
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(aSet)
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);

        //WHEN
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
        //THEN
        System.assertEquals('Specialization', survey.name);
        System.assertEquals('test1@test.pl', survey.userId);
        System.assertEquals(3, survey.answers.size());
    }

    @isTest 
    static void shouldGetAchievementSurvey() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(2, template);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(contacts[0], contacts[1])
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);

        //WHEN
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);

        //THEN
        System.assertEquals('test2 test2', survey.name);
        System.assertEquals('test1@test.pl', survey.userId);
        System.assertEquals(4, survey.answers.size());
    }

    @isTest 
    static void shouldGetTemplateInfoEmployeeProfile() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementEmployeeProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementEmployeeProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        List<Contact> contacts = prepareUsers(1, template);
        Double minSpecialityMatch = 0.30;
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c =: contacts[0].Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(contacts[0].Id))
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        SurveyUtils.Request request = new SurveyUtils.Request(contacts[0].Email);

        //WHEN
        List<SurveyModel.TemplateInfo> templates = SurveyFrontController.getInstance().getTemplatesInfo(request);

        //THEN
        System.assertEquals('surveytemplatetest', templates[0].name);
        System.assertEquals(1, templates[0].surveys.size());
    }

    @isTest 
    static void shouldGetTemplateInfoSurvey() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        List<Contact> contacts = prepareUsers(1, template);
        Double minSpecialityMatch = 0.30;
       Achievement_Set__c achievementSet1  = new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(contacts[0], contacts[0])
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        SurveyUtils.Request request = new SurveyUtils.Request(contacts[0].Email);

        //WHEN
        List<SurveyModel.TemplateInfo> templates = SurveyFrontController.getInstance().getTemplatesInfo(request);

        //THEN
        System.assertEquals('surveytemplatetest', templates[0].name);
        System.assertEquals(1, templates[0].surveys.size());
    }

    @isTest 
    static void shouldNotGetTemplateInfoSurveyWithWrongWhoEmial() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        List<Contact> contacts = prepareUsers(1, template);
        Double minSpecialityMatch = 0.30;
       Achievement_Set__c achievementSet1  = new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(contacts[0], contacts[0])
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        SurveyUtils.Request request = new SurveyUtils.Request('t@test.com');

        //WHEN
        try {
            List<SurveyModel.TemplateInfo> templates = SurveyFrontController.getInstance().getTemplatesInfo(request);
            System.assert(false, 'You not have permission!');
        } catch (Exception e){}
    }

    @isTest 
    static void shouldGetTemplateInfoWithTemplateConfig() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementEmployeeProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementEmployeeProfileHandler';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test@test.com', SkillAssessment__c = true);
        insert c;
        Double minSpecialityMatch = 0.30;
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c =: c.Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c.Id))
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        String templateConfig = '{"achievmentSetId": "'+achievementSet.Id+'"}';
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        insert new SurveyTemplateAccesses__c(Contact__c=c.Id, SurveyTemplate__c=template.Id);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        SurveyUtils.Request request = new SurveyUtils.Request(c.Email);

        //WHEN
        List<SurveyModel.TemplateInfo> templates = SurveyFrontController.getInstance().getTemplatesInfo(request);

        //THEN
        System.assertEquals('surveytemplatetest', templates[0].name);
        System.assertEquals(1, templates[0].surveys.size());
    }

    @isTest 
    static void shouldUpdateEmployeeProfile() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementEmployeeProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementEmployeeProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        Double minSpecialityMatch = 0.30;
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c =: contacts[0].Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(contacts[0].Id))
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
        survey.answers[0].value = AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE;
        survey.answers[2].value = '55';

        //WHEN
        SurveyModel.Survey newSurvey = SurveyFrontController.getInstance().saveSurvey(JSON.serialize(survey));

        //THEN
        System.assertEquals('test1 test1 - Employee Profile', newSurvey.name);
        System.assertEquals('test1@test.pl', newSurvey.userId);
        System.assertEquals(5, newSurvey.answers.size());
        System.assertEquals(AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE, newSurvey.answers[0].value);
        System.assertEquals('55', newSurvey.answers[2].value);
    }

    @isTest 
    static void shouldUpdatePositionProfile() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementPositionProfileQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementPositionProfileHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        Double minSpecialityMatch = 0.30;
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder('PrositionProfile').asPositionProfile(careerPath)
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
        survey.answers[0].value = AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE;
        survey.answers[2].value = '55';

        //WHEN
        SurveyModel.Survey newSurvey = SurveyFrontController.getInstance().saveSurvey(JSON.serialize(survey));

        //THEN
        System.assertEquals('PrositionProfile', newSurvey.name);
        System.assertEquals('test1@test.pl', newSurvey.userId);
        System.assertEquals(4, newSurvey.answers.size());
        System.assertEquals(AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE, newSurvey.answers[0].value);
        System.assertEquals('55', newSurvey.answers[2].value);
    }

    @isTest 
    static void shouldUpdateSpecialization() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSpecializationQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSpecializationHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        Double minSpecialityMatch = 0.30;
        Achievement_Set__c aSet = [SELECT Name, Career_Path__c FROM Achievement_Set__c WHERE RecordTypeId =: AchievementUtils.getAchievementSetProfileRecordType().Id];
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(aSet)
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
        survey.answers[0].value = AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE;
        survey.answers[2].value = '55';

        //WHEN
        SurveyModel.Survey newSurvey = SurveyFrontController.getInstance().saveSurvey(JSON.serialize(survey));

        //THEN
        System.assertEquals('Specialization', newSurvey.name);
        System.assertEquals('test1@test.pl', newSurvey.userId);
        System.assertEquals(4, newSurvey.answers.size());
        System.assertEquals(AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE, newSurvey.answers[0].value);
        System.assertEquals('55', newSurvey.answers[2].value);
    }

    @isTest 
    static void shouldUpdateAchievementSurvey() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        List<Contact> contacts = prepareUsers(2, template);
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(contacts[0], contacts[1])
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
        survey.answers[0].value = AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE;
        survey.answers[2].value = '55';
        survey.answers[3].value = 'test2@test.pl';

        //WHEN
        SurveyModel.Survey newSurvey = SurveyFrontController.getInstance().saveSurvey(JSON.serialize(survey));

        //THEN
        System.assertEquals('test2 test2', newSurvey.name);
        System.assertEquals('test1@test.pl', newSurvey.userId);
        System.assertEquals(4, newSurvey.answers.size());
        System.assertEquals(AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE, newSurvey.answers[0].value);
        System.assertEquals('55', newSurvey.answers[2].value);
        System.assertEquals('test2@test.pl', newSurvey.answers[3].value);
    }

    @isTest 
    static void shouldSaveNewAchievementSurvey() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        List<Contact> contacts = prepareUsers(2, template);
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(contacts[0], contacts[1])
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
        delete achievementSet;
        survey.answers[0].value = AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE;
        survey.answers[2].value = '55';
        survey.answers[3].value = 'test2@test.pl';

        //WHEN
        SurveyModel.Survey newSurvey = SurveyFrontController.getInstance().saveSurvey(JSON.serialize(survey));

        //THEN
        System.assertEquals('test2 test2', newSurvey.name);
        System.assertEquals('test1@test.pl', newSurvey.userId);
        System.assertEquals(4, newSurvey.answers.size());
        System.assertEquals(1, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Type__c = :AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE AND LevelValue__c = :AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE]);
        System.assertEquals(1, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Type__c = :AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE AND Amount__c = 55]);
    }

    @isTest 
    static void shouldNotSaveNewAchievementSurveyWithoutTargetId() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        List<Contact> contacts = prepareUsers(2, template);
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(contacts[0], contacts[1])
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
        survey.answers[0].value = 'Senior';
        survey.answers[2].value = '55';
        survey.answers[3].value = '';

        //WHEN
        try {
            SurveyModel.Survey newSurvey = SurveyFrontController.getInstance().saveSurvey(JSON.serialize(survey));
            System.assert(false, 'Please provide Target Id, this field is mandatory!');
        } catch (Exception e){}
    }

    @isTest 
    static void shouldNotSaveNewAchievementSurveyWithNotFoundAboutWho() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSurveyQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSurveyHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        List<Contact> contacts = prepareUsers(2, template);
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder('Survey').asSurvey(contacts[0], contacts[1])
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
        survey.answers[0].value = 'Senior';
        survey.answers[2].value = '55';
        survey.answers[3].value = 't@test.pl';

        //WHEN
        try {
            SurveyModel.Survey newSurvey = SurveyFrontController.getInstance().saveSurvey(JSON.serialize(survey));
            System.assert(false, 'Cannot find contact with email');
        } catch (Exception e){}
    }

    @isTest
    static void shouldNotGetAchievementSetWithNotFoundAvhievementId() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSpecializationQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSpecializationHandler';
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        Double minSpecialityMatch = 0.30;
        Achievement_Set__c aSet = [SELECT Name, Career_Path__c FROM Achievement_Set__c WHERE RecordTypeId =: AchievementUtils.getAchievementSetProfileRecordType().Id];
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(aSet)
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        String templateConfig = '{"achievmentSetId": "'+achievementSet.Id+'"}';
        String templateItemConfig = '{"achievmentId":"'+achievements[0].Id+'","getAll":"false"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);
        delete achievementSet;

        //WHEN
        try {
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
            System.assert(false, 'Not found Achievement Set with Id');
        } catch (Exception e){}
    }

    @isTest
    static void shouldNotGetAchievementSetWithNoSurveyId() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSpecializationQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSpecializationHandler';
        String templateConfig = '{}';
        Double minSpecialityMatch = 0.30;
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"'+achievements[0].Id+'","getAll":"false"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        Achievement_Set__c aSet = [SELECT Name, Career_Path__c FROM Achievement_Set__c WHERE RecordTypeId =: AchievementUtils.getAchievementSetProfileRecordType().Id];
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(aSet)
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, null);

        //WHEN
        try {
            SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
            System.assert(false, 'Achievement Set was not set on the Survey Template!');
        } catch (Exception e){}
    }

    @isTest
    static void shouldNotUpdateSpecializationWithNoSurveyId() {
        //GIVEN
        String configClassProvider = 'AchievementSurveyUtils.AchievementSpecializationQuestionProvider';
        String configClassHandler = 'AchievementSurveyUtils.AchievementSpecializationHandler';
        String templateConfig = '{}';
        List<Achievement__c> achievements = createAchievmentWithCategory('categoryName');
        String templateItemConfig = '{"achievmentId":"","getAll":"true"}';
        SurveyTemplate__c template = prepateTemplate(configClassProvider, configClassHandler, templateConfig, templateItemConfig, false);
        List<Contact> contacts = prepareUsers(1, template);
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPath_1').buildAndSave();
        Double minSpecialityMatch = 0.30;
        Achievement_Set__c aSet = [SELECT Name, Career_Path__c FROM Achievement_Set__c WHERE RecordTypeId =: AchievementUtils.getAchievementSetProfileRecordType().Id];
        Achievement_Set__c achievementSet  = new AchievementUtils.AchievementSetBuilder(aSet)
            .addSkill(achievements[0], 'Junior')
            .addCert(achievements[1])
            .addBadge(achievements[2], 10)
            .addSpecialization(achievements[4], minSpecialityMatch)
            .buildAndSave();
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(contacts[0].Email, template.ApiName__c, achievementSet.Id);
        SurveyModel.Survey survey = SurveyFrontController.getInstance().getSurvey(request);
        delete achievementSet;

        //WHEN
        try {
            SurveyModel.Survey newSurvey = SurveyFrontController.getInstance().saveSurvey(JSON.serialize(survey));
            System.assert(false, 'Cannot find proper survey!');
        } catch (Exception e){}
    }

    static private List<Achievement__c> createAchievmentWithCategory(String name) {
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder(name+'AchievementSurveyUtilsTest').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('careerPathAchievementSurveyUtilsTest').buildAndSave();
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder('Specialization').asProfile(careerPath).buildAndSave();
        List<Achievement__c> achievements = new List<Achievement__c>{
            new AchievementUtils.AchievementBuilder('AchievementSkill', category).asSkill().build(),
            new AchievementUtils.AchievementBuilder('AchievementCertificate', category).asCert().build(),
            new AchievementUtils.AchievementBuilder('AchievementBadge', category).asBadge().build(),
            new AchievementUtils.AchievementBuilder('AchievementGroup', category).asGroup().build(),
            new AchievementUtils.AchievementBuilder('AchievementSpecialization', category).asSpecialization(achievementSet).build()
        };
        insert achievements;
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

    static private SurveyTemplate__c  prepateTemplate (String configClassProvider, String configClassHandler, String templateConfig, String templateItemConfig, Boolean addItemEmail) {
        String providerName = 'questionProviderAchievementSurveyUtilsTest';
        String handlerName = 'surveyHandlerAchievementSurveyUtilsTest';
        String configSignature = '{}';
        List<SurveyTestUtils.SurveyConfigBuilder> cfgs = createConfig(providerName, handlerName, configClassProvider, configClassHandler);
        cfgs[0].buildAndSave();
        cfgs[1].buildAndSave();
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveytemplatetest').withHandler(cfgs[1].getConfigs().get(handlerName).Id).withConfig(templateConfig).buildAndSave();
        SurveyTemplateItem__c templateItem = new SurveyTestUtils.TemplateItemBuilder(template, cfgs[0].getConfigs().get(providerName)).withConfig(templateItemConfig).buildAndSave();
        if (addItemEmail) {
            String templateItemEmailConfig = '{"achievmentId":"","getAll":"false","email": "true" }';
            SurveyTemplateItem__c templateItem1 = new SurveyTestUtils.TemplateItemBuilder(template, cfgs[0].getConfigs().get(providerName)).withConfig(templateItemEmailConfig).withOrder(2).buildAndSave();
        }
        return template;
    }

    static private List<Contact> prepareUsers(Integer count, SurveyTemplate__c template) {
        List<Contact> contacts = new List<Contact>();
        List<SurveyTemplateAccesses__c> accesses = new List<SurveyTemplateAccesses__c>();
        for (Integer i = 1; i <= count; i++) {
            contacts.add( new Contact(FirstName = 'test'+i, LastName = 'test'+i, Email='test'+i+'@test.pl', SkillAssessment__c = true) );
        }
        insert contacts;

        for (Contact item : contacts) {
            accesses.add( new SurveyTemplateAccesses__c(Contact__c=item.Id, SurveyTemplate__c=template.Id) );
        }
        insert accesses;
        return contacts;
    }
}