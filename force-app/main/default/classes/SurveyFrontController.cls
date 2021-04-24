global with sharing class SurveyFrontController {

    private static SurveyFrontController instance = null;
    private Map<String, SurveyTemplate__c> templates = new Map<String, SurveyTemplate__c>();

    global static SurveyFrontController getInstance() {
        if (instance == null) {
            instance = new SurveyFrontController();
        }
        return instance;
    }

    private SurveyFrontController() {
        getAllVaiableTemplates();
    }

    global List<SurveyModel.TemplateInfo> getTemplatesInfo(SurveyUtils.Request request) {
        validateRequest(request);
        List<SurveyModel.TemplateInfo> templatesInfo = new List<SurveyModel.TemplateInfo>();
        for (SurveyTemplate__c template : templates.values()) {
            if (!template.Private__c || (template.Private__c && checkTemplateAccess(request.userId, template.SurveyTemplateAccesses__r))) {
                SurveyModel.TemplateInfo templateInfo = new SurveyModel.TemplateInfo(template);
                SurveyUtils.SurveyConfig cfg = new SurveyUtils.SurveyConfig(template);
                templateInfo.surveys.addAll(SurveyUtils.getSurveyHandler(template.SurveyHandler__r.Name).getSurveyToTemplateInfo(cfg, templateInfo, request));
                templatesInfo.add(templateInfo);
            }
        }
        return templatesInfo;
    }


    global SurveyModel.Template getTemplate(SurveyUtils.TemplateRequest request) {
        validateTemplateRequest(request);
        SurveyUtils.TemplateContext templateContext = new SurveyUtils.TemplateContext(request);
        SurveyModel.Template template = templateContext.getTemplate();
        validateTamplateQuestions(template);
        return template;
    }


    global SurveyModel.Survey getSurvey(SurveyUtils.SurveyRequest request) {
        validateSurveyRequest(request);
        SurveyUtils.SurveyContext templateContext = new SurveyUtils.SurveyContext(request);
        SurveyModel.Survey survey = templateContext.getSurvey();
        return survey;
    }

    global SurveyModel.Survey saveSurvey(String rawSurvey) {
        SurveyModel.Survey survey = parseSurvey(rawSurvey);
        SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(survey);
        validateSurveyRequest(request);
        SurveyUtils.SurveyContext surveyContext = new SurveyUtils.SurveyContext(request, survey);
        surveyContext.saveSurvey();
        return getSurvey(request);
    }

    private Map<String, SurveyTemplate__c> getAllVaiableTemplates() {
        if (templates.values().isEmpty()) {
            for (SurveyTemplate__c item : [SELECT Id, Name, ApiName__c, StartDate__c, EndDate__c, Importance__c, Description__c, Private__c, Submittable__c, MultiSurvey__c, Active__c, SurveyHandler__r.Name, Config__c,
                                               (SELECT  OnlyLeaders__c, Contact__r.Email FROM SurveyTemplateAccesses__r)
                                               FROM SurveyTemplate__c
                                               WHERE Active__c = true
                                                    AND (StartDate__c = null OR StartDate__c <= TODAY)
                                                    AND (EndDate__c = null OR EndDate__c >= TODAY)
                                                ORDER BY Name]) {
                templates.put(item.ApiName__c, item);
            }
        }
        return templates;
    }

    public List<SurveyModel.Survey> getSurveysToCompare(SurveyUtils.SurveyRequest request) {
        return null;
    }

    private void validateRequest(SurveyUtils.Request request) {
        if (String.isBlank(request.userId)) {
            throw new SurveyFrontControllerException(System.Label.UserIdFieldValueIsMandatory);
        }

    }

    private void validateTemplateRequest(SurveyUtils.TemplateRequest request) {
        validateRequest(request);
        validateTemplateApiNameAndAccessLevel(request);
        if (String.isBlank(request.templateApiName)) {
            throw new SurveyFrontControllerException(System.Label.TemplateApiNameFieldValueIsMandatory);
        }
    }

    private void validateSurveyRequest(SurveyUtils.SurveyRequest request) {
        validateTemplateRequest(request);
        /*
        if (String.isBlank(request.surveyId)) {
            throw new SurveyFrontControllerException('surveyId field value is mandatory!');
        }
        */
    }

    private void validateTemplateApiNameAndAccessLevel(SurveyUtils.TemplateRequest request) {
        if (templates.get(request.templateApiName) == null) {
            throw new SurveyFrontControllerException(String.format(System.Label.NotFoundTemplate, new List<String>{request.templateApiName}));
        }

        if (!checkTemplateAccess(request.userId, templates.get(request.templateApiName).SurveyTemplateAccesses__r) && templates.get(request.templateApiName).Private__c) {
            throw new SurveyFrontControllerException(System.Label.YouNotHavePermission);
        }
    }

    private void validateTamplateQuestions(SurveyModel.Template template) {
        validateTamplateDates(template);
        if (template.questions.isEmpty()) {
            throw new SurveyFrontControllerException(String.format(System.Label.DosentContainAnyQuestions, new List<String>{template.Name}));
        }
    }

    private void validateTamplateDates(SurveyModel.Template template) {
        if (!(template.startDate <= System.today() && template.endDate >= System.today()) && (template.startDate != null && template.endDate != null)) {
            throw new SurveyFrontControllerException(String.format(System.Label.TemplateNameIsNotUnavailable, new List<String>{template.Name}));
        }
    }

    private SurveyModel.Survey parseSurvey(String rawSurvey) {
        if (String.isBlank(rawSurvey)) {
            throw new SurveyFrontControllerException(System.Label.SurveyResponseCannotBeBlank);
        }
        return (SurveyModel.Survey)JSON.deserialize(rawSurvey, SurveyModel.Survey.class);
    }

    private Boolean checkTemplateAccess(String userId, List<SurveyTemplateAccesses__c> templateAccesses) {
        if (isUserHasAccess(templateAccesses, userId) || isLeader(userId)) {
            return true;
        } else {
            return false;
        }
    }

    private Boolean isUserHasAccess(List<SurveyTemplateAccesses__c> templateAccesses, String userId) {
        Boolean access = false;
        for (SurveyTemplateAccesses__c item : templateAccesses) {
            if (!item.OnlyLeaders__c && item.Contact__r.Email == userId) {
                access = true;
                break;
            }
        }
        return access;
    }

    private Boolean isLeader(String userId) {
        List<Contact> contacts = new List<Contact>();
        contacts.addAll([SELECT IsLeader__c FROM Contact WHERE Email= :userId LIMIT 1]);
        if (!contacts.isEmpty()) {
            return contacts[0].IsLeader__c;
        } else {
            return false;
        }
    }

    public class SurveyFrontControllerException extends SurveyUtils.SurveyException {}
}