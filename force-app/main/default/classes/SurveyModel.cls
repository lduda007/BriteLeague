global with sharing class SurveyModel {

    global with sharing virtual class BaseTemplate {

        global String id {get; set;}
        global String name {get; set;}
        global Date startDate {get; set;}
        global Date endDate {get; set;}
        global String importance {get; set;}
        global Boolean isPrivate {get; set;}
        global Boolean submittable {get; set;}
        global Boolean multiSurvey {get; set;}
        global String templateApiName {get; set;}
        global String description {get; set;}

        global BaseTemplate(String id, String name, Date startDate, Date endDate, String importance, Boolean isPrivate, Boolean submittable, Boolean multiSurvey, String apiName, String description) {
            this.id = id;
            this.name = name;
            this.startDate = startDate;
            this.endDate = endDate;
            this.importance = importance;
            this.isPrivate = isPrivate;
            this.submittable = submittable;
            this.multiSurvey = multiSurvey;
            this.templateApiName = apiName;
            this.description = description;
        }

        global BaseTemplate(SurveyTemplate__c template) {
            this(template.Id,
                template.Name,
                template.StartDate__c,
                template.EndDate__c,
                template.Importance__c,
                template.Private__c,
                template.Submittable__c,
                template.MultiSurvey__c,
                template.ApiName__c,
                template.Description__c);
        }
    }

    global with sharing virtual class TemplateInfo extends BaseTemplate {
        global List<SurveyInfo> surveys {get; set;}

        global TemplateInfo(SurveyTemplate__c template) {
            super(template);
            surveys = new List<SurveyInfo>();
        }
    }

    global with sharing virtual class Template extends BaseTemplate {
        global List<Question> questions {get; set;}
        global List<String> questionSearchOption = new List<String>();

        global Template(SurveyTemplate__c template) {
            super(template);
            questions = new List<Question>();
        }
        
        public void addQuestion(Question question) {
            questions.add(question);
        }

        public void addAllQuestions(List<Question> questions) {
            this.questions.addAll(questions);
        }
    }

    global with sharing virtual class Question {

        global String id {get; set;}
        global String name {get; set;}
        global Integer order {get; set;}
        global List<Option> options {get; set;}
        global Boolean readOnly {get; set;}
        global String description {get; set;}
        global String type {get; set;}
        global String question {get; set;}
        global Boolean isSystem {get; set;}

        global Question(String id, String name, Integer order, String type, List<Option> options, Boolean readOnly, Boolean isSystem) {
            this.id = id;
            this.name = name;
            this.order = order;
            this.type = type;
            this.options = options;
            this.readOnly = readOnly;
            this.isSystem = isSystem;
        }

        global Question(String id, String name) {
            this.id = id;
            this.name = name;
        }

        global Question(SurveyTemplateItem__c templateItem, List<Option> options) {
            this(
                templateItem.Id,
                templateItem.Name,
                (Integer) templateItem.Order__c,
                'text',
                options,
                false,
                false);
        }
    }

    global with sharing virtual class QuestionInfo extends Question {

        global QuestionInfo(SurveyTemplateItem__c templateItem, String description) {
            super(templateItem, null);
            this.description = description;
            this.readOnly = true;
            this.type = SurveyUtils.QUESTION_TYPE_INFO;
        }
    }

    global with sharing virtual class QuestionError extends QuestionInfo {

        global QuestionError(SurveyTemplateItem__c templateItem, String description) {
            super(templateItem, description);
            this.question = this.type = SurveyUtils.QUESTION_TYPE_ERROR;
        }
    }
    
    global with sharing virtual class Option {

        global String id {get; set;}
        global String name {get; set;}

        global Option(String id, String name) {
            this.id = id;
            this.name = name;
        }
    }

    global virtual with sharing class SurveyInfo {

        global String surveyId {get; set;}
        global String name {get; set;}
        global String templateApiName {get; set;}
        global String userId {get; set;}
        global Date dueDate {get; set;}

        global SurveyInfo() {
        }

        global SurveyInfo(String surveyId, String name, String templateApiName, String userId, Date dueDate) {
            this.surveyId = surveyId;
            this.name = name;
            this.templateApiName = templateApiName;
            this.userId = userId;
            this.dueDate = dueDate;
        }
    }

    global virtual with sharing class Survey extends SurveyInfo {

        global List<Answer> answers {get; set;}

        global Survey() {
            answers = new List<Answer>();
        }
    }

    global virtual with sharing class Answer {

        global String id {get; set;}
        global String questionId {get; set;}
        global String value {get; set;}
        global String comment {get; set;}
        global String serviceName {get; set;}

        global Answer(){
        }

        global Answer(String id, String questionId, String value, String comment, String serviceName) {
            this.id = id;
            this.questionId = questionId;
            this.value = value;
            this.comment = comment;
            this.serviceName = serviceName;
        }
    }
}