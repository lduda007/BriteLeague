@isTest
private class SurveyFrontControllerTest {

    @isTest
    private static void shouldThrowExceptionWhenUserIdIsNotInTheRequestForAllTemplates() {
        try {
            SurveyTestUtils.templatesInfoRequest(null);
            System.assert(false, 'Should throw exception when request data are invalid!');
        } catch (SurveyFrontController.SurveyFrontControllerException e) {
        }
    }

    @isTest
    private static void shouldNotRetrieveDeactivatedTemplatesInfo() {
        SurveyTestUtils.buildDefaultTemplate('template').deactivate().buildAndSave();

        List<SurveyModel.TemplateInfo> templatesInfo = SurveyTestUtils.templatesInfoRequest('a.a@test.com');

        System.assertEquals(0, templatesInfo.size());
    }

    @isTest
    private static void shouldNotRetrieveOldTemplatesInfo() {
        SurveyTestUtils.buildDefaultTemplate('template').fromPast().buildAndSave();

        List<SurveyModel.TemplateInfo> templatesInfo = SurveyTestUtils.templatesInfoRequest('a.a@test.com');

        System.assertEquals(0, templatesInfo.size());
    }

    @isTest
    private static void shouldNotRetrieveFutureTemplatesInfo() {
        SurveyTestUtils.buildDefaultTemplate('template').fromFuture().buildAndSave();

        List<SurveyModel.TemplateInfo> templatesInfo = new List<SurveyModel.TemplateInfo>();
        templatesInfo.addAll(SurveyTestUtils.templatesInfoRequest('a.a@test.com'));

        System.assertEquals(0, templatesInfo.size());
    }

    @isTest
    private static void shouldNotRetrievePrivateTemplatesInfo() {
        SurveyTestUtils.buildDefaultTemplate('templatePrivate').privateSurvey().buildAndSave();
        List<SurveyModel.TemplateInfo> templatesInfo = new List<SurveyModel.TemplateInfo>();
        templatesInfo.addAll(SurveyTestUtils.templatesInfoRequest('a.a@test.com'));

        System.assertEquals(0, templatesInfo.size());
    }

    @isTest
    private static void templateRequestShouldThrowExceptionWhenSurveyCfgIsNotSet() {
        try {
            SurveyTestUtils.templateRequest('a.a@test.com', 'testTemplate');
            System.assert(false, 'Should throw exception when request data are invalid!');
        } catch (SurveyUtils.SurveyException e) {
        }
    }

    @isTest
    private static void shouldThrowExceptionWhenUserIdIsNotInTheTemplateRequest() {

        try {
            SurveyTestUtils.templateRequest(null, 'testTemplate');
            System.assert(false, 'Should throw exception when request data are invalid!');
        } catch (SurveyFrontController.SurveyFrontControllerException e) {
        }
    }


    @isTest
    private static void shouldThrowExceptionWhenTemplateApiNameIsNotInTheTemplateRequest() {

        try {
            SurveyTestUtils.templateRequest('a.a@test.com', null);
            System.assert(false, 'Should throw exception when request data are invalid!');
        } catch (SurveyFrontController.SurveyFrontControllerException e) {
        }
    }

    @isTest
    private static void shouldThrowExceptionWhenThereAreNoTemplatesToRetrieve() {

        try {
            SurveyTestUtils.templateRequest('a.a@test.com', 'testTemplate');
            System.assert(false, 'Should thow exception when no data ara available');
        } catch (SurveyUtils.SurveyException e) {
        }
    }

    @isTest
    private static void shouldThrowExceptionWhenTemplateNotExists() {
        SurveyTestUtils.createDefaultTemplate('template');

        try {
            SurveyModel.Template response = SurveyTestUtils.templateRequest('testuser@test.com', 'template2');
            System.assert(false, 'Should thow exception when template not exists');
        } catch (SurveyUtils.SurveyException e) {
        }
    }

    @isTest
    private static void shouldThrowExceptionWhenTemplateDoesNotHaveQuestions() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('template').buildAndSave();

        try {
            SurveyModel.Template response = SurveyTestUtils.templateRequest('testuser@test.com', 'template');
            System.assert(false, 'Should thow exception when template does not have questions');
        } catch (SurveyFrontController.SurveyFrontControllerException e) {
        }
    }

    @isTest
    private static void surveyRequestShouldThrowExceptionWhenSurveyConfigIsNotSet() {
        try {
            SurveyTestUtils.surveyRequest(null, 'testTemplate', 'surveyId');
            System.assert(false, 'Should throw exception when request data are invalid!');
        } catch (SurveyUtils.SurveyException e) {
        }
    }

    @isTest
    private static void shouldThrowExceptionWhenUserIdIsNotInTheSurveyRequest() {

        try {
            SurveyTestUtils.surveyRequest(null, 'testTemplate', 'surveyId');
            System.assert(false, 'Should throw exception when request data are invalid!');
        } catch (SurveyUtils.SurveyException e) {
        }
    }

    @isTest
    private static void shouldThrowExceptionWhenTemplateApiNameIsNotInTheSurveysRequest() {

        try {
            SurveyTestUtils.surveyRequest('a.a@test.com', null, 'surveyId');
            System.assert(false, 'Should throw exception when request data are invalid!');
        } catch (SurveyUtils.SurveyException e) {
        }
    }

    @isTest
    private static void shouldThrowExceptionWhenSurveyIdIsNotInTheSurveysRequest() {

        try {
            SurveyTestUtils.surveyRequest('a.a@test.com', 'testTemplate', null);
            System.assert(false, 'Should throw exception when request data are invalid!');
        } catch (SurveyUtils.SurveyException e) {
        }
    }

    @isTest
    private static void shouldThrowExceptionWhenRequestForSaveSurveyIsInvalid() {

        try {
            SurveyFrontController.getInstance().saveSurvey(null);
            System.assert(false, 'Should throw exception when request data are invalid!');
        } catch (SurveyUtils.SurveyException e) {
        }
    }

    @isTest
    private static void shouldShoutGetPrivateTemplateForAccessUser() {
        //GIVEN
        SurveyTemplate__c template = SurveyTestUtils.buildDefaultTemplate('template').privateSurvey().buildAndSave();
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test@test.com');
        insert c;
        new SurveyTestUtils.TemplateAccessBuilder(template).withContact(c).buildAndSave();

        //WHEN
        //List<SurveyModel.TemplateInfo> templatesInfo = SurveyTestUtils.templatesInfoRequest('test@test.com');
        List<SurveyModel.TemplateInfo> templatesInfo = SurveyFrontController.getInstance().getTemplatesInfo(new SurveyUtils.Request('test@test.com'));

        //THEN
        System.assertEquals(1, templatesInfo.size());
    }

    @isTest
    private static void shouldShoutGetPrivateTemplateForLeader() {
        //GIVEN
        SurveyTemplate__c template = SurveyTestUtils.buildDefaultTemplate('template').privateSurvey().buildAndSave();
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test@test.com', IsLeader__c = true);
        insert c;
        new SurveyTestUtils.TemplateAccessBuilder(template).buildAndSave();

        //WHEN
        List<SurveyModel.TemplateInfo> templatesInfo = SurveyTestUtils.templatesInfoRequest('test@test.com');

        //THEN
        System.assertEquals(1, templatesInfo.size());
    }

    @isTest
    private static void shouldShoutNotGetPrivate() {
        //GIVEN
        SurveyTemplate__c template = SurveyTestUtils.buildDefaultTemplate('template').privateSurvey().buildAndSave();
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test@test.com', IsLeader__c = false);
        insert c;

        //WHEN
        List<SurveyModel.TemplateInfo> templatesInfo = SurveyTestUtils.templatesInfoRequest('test@test.com');

        //THEN
        System.assertEquals(0, templatesInfo.size());
    }
}