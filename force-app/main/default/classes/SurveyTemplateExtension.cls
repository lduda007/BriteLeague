/**
*@author Michał Banasik
*/
public with sharing class SurveyTemplateExtension {

    public SurveyTemplate__c template {get; set;}
    public SurveyTemplateItem__c templateItem {get; set;}
    public SurveyTemplateAccesses__c templateAccess {get; set;}
    public List<TemplateQuestion> questionList {get; set;}
    public List<SeciurityContact> contactList {get; set;}
    public Boolean isClonning {get; set;}
    private Map<ID, Contact> contacts;
    private SurveyUtils.SurveyQuestionProvider achievementQuestionProvider;

    public SurveyTemplateExtension(ApexPages.StandardController stdCtrl) {
        SurveyTemplate__c oldTemplate = (SurveyTemplate__c)stdCtrl.getRecord();
        templateItem = new SurveyTemplateItem__c();
        templateAccess = new SurveyTemplateAccesses__c();
        isClonning = ApexPages.currentPage().getParameters().get('clone') == '1';
        oldTemplate = loadSurveyTemplate(oldTemplate);
        contacts = new Map<ID, Contact>([SELECT Id, Name, FirstName, LastName FROM Contact]);

        if (isClonning) {
            template = oldTemplate.clone();
            template.Name = null;
            template.ApiName__c = null;
        } else {
            template = oldTemplate;
        }

        prepareTemplateItems(oldTemplate);
        prepareAccessContacts(oldTemplate);
    }

    public class TemplateQuestion {
        public Integer index {get;set;}
        public SurveyTemplateItem__c data {get; set;}
        private SurveyTemplateExtension ext;

        public TemplateQuestion(Integer index, SurveyTemplateItem__c item, SurveyTemplateExtension ext) {
            this.ext = ext;
            this.index =  index;
            
            if (item.Id != null && ext.isClonning) {
                this.data = item.clone();
                this.data.SurveyTemplate__c = null;
            } else {
                this.data = item;
            }
            this.data.Order__c = index;
            this.data.UniqueOrder__c = ext.template.ExternalId__c + '#' + String.valueOf(index);
        }

        public void remove() {
            ext.questionList.remove(index);
            Integer i = 0;
            for (TemplateQuestion question : ext.questionList) {
                question.index = i++;
                question.data.Order__c = question.index;
                question.data.UniqueOrder__c = ext.template.ExternalId__c + '#' + String.valueOf(question.index);
            }
        }
    }

    public class SeciurityContact {
        public Integer index {get;set;}
        public SurveyTemplateAccesses__c data {get; set;}
        public String contactName {get; set;}
        private SurveyTemplateExtension ext;

        public SeciurityContact(Integer index, SurveyTemplateAccesses__c accessContact, SurveyTemplateExtension ext, Map<ID, Contact> contacts) {
            this.ext = ext;
            this.index =  index;
            this.contactName = contacts.containsKey(accessContact.Contact__c) ? contacts.get(accessContact.Contact__c).Name : System.Label.OnlyLeaders;
            if (SurveyTemplateAccesses__c.Id != null && ext.isClonning) {
                this.data = accessContact.clone();
            } else {
                this.data = accessContact;
            }
        }

        public void remove() {
            ext.contactList.remove(index);
            Integer i = 0;
            for (SeciurityContact accessContact : ext.contactList) {
                accessContact.index = i++;
            }
        }
    }

    public void addQuestion() {
        String regExp = '[/\\s+/g]';
        String configSignature = !String.isBlank(getQuestionProviderConfigSignature()) ? getQuestionProviderConfigSignature() : ' ';
        if (validateQuestion()){
            if (templateItem.Config__c.replaceAll(regExp, '') == configSignature.replaceAll(regExp, '')){
                templateItem.Config__c = '';
            }
            questionList.add(new TemplateQuestion(questionList.size(), templateItem, this));
            if (!String.isBlank(templateItem.Config__c)){
                Map<String, Object> cfg = new Map<String, Object>((Map<String, Object>)JSON.deserializeUntyped(templateItem.Config__c));
                //if (!String.isBlank((String)cfg.get(AchievementSurveyUtils.ACHIEVMENT_ID_CONF_KEY)) && cfg.get(AchievementSurveyUtils.ACHIEVMENT_ID_CONF_KEY) != null){
                //    questionList.get(questionList.size() - 1).data.Name = AchievementUtils.getAllAchievements().get((ID)cfg.get(AchievementSurveyUtils.ACHIEVMENT_ID_CONF_KEY)).Name;
                if (!String.isBlank((String)cfg.get(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY)) && cfg.get(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY) != null){
                    questionList.get(questionList.size() - 1).data.Name = AchievementUtils.getExternalIdAllAchievements().get((String)cfg.get(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY)).Name;
                //} else if (!String.isBlank((String)cfg.get(AchievementSurveyUtils.CATEGORY_ID_CONF_KEY)) && cfg.get(AchievementSurveyUtils.CATEGORY_ID_CONF_KEY) != null) {
                    //questionList.get(questionList.size() - 1).data.Name = System.Label.Category + ': ' + AchievementService.getCategoriesMap().get((Id)cfg.get(AchievementSurveyUtils.CATEGORY_ID_CONF_KEY));
                } else if (!String.isBlank((String)cfg.get(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY)) && cfg.get(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY) != null) {
                    questionList.get(questionList.size() - 1).data.Name = System.Label.Category + ': ' + AchievementService.getExternalIdCategoriesMap().get((String)cfg.get(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY));
                } else if (cfg.get(AchievementSurveyUtils.ACHIEVMENT_GET_ALL_CONF) == 'true') {
                    questionList.get(questionList.size() - 1).data.Name = System.Label.All_Questions;
                } else if (cfg.get(AchievementSurveyUtils.ACHIEVMENT_EMAIL_CONF) == 'true'){
                    questionList.get(questionList.size() - 1).data.Name = System.Label.Question_Who;
                }
            }
            
            templateItem = new SurveyTemplateItem__c();
        }
        else {
            addError(System.Label.QuestionProviderError);
        }
    }

    public void addContact() {
        if (validateAccessContact()) {
            contactList.add(new SeciurityContact(contactList.size(), templateAccess, this, contacts));
            templateAccess = new SurveyTemplateAccesses__c();
        } else {
            addError(System.Label.SurveyTemplateAccesses_AddContactAccess_Error);
        }
    }

    public void setTemplateItemConfig(){
        templateItem.Config__c = getQuestionProviderConfigSignature();
    }

    public void setTemplateConfig(){
        template.Config__c = getSurveyHandlerConfigSignature();
    }

    public PageReference save() {
        String regExp = '[/\\s+/g]';
        SavePoint sp = Database.setSavePoint();
        Boolean isNew = template.Id == null;
        String configSignature = !String.isBlank(getSurveyHandlerConfigSignature()) ? getSurveyHandlerConfigSignature() : ' ';

        if (template.Config__c.replaceAll(regExp, '') == configSignature.replaceAll(regExp, '')){
            template.Config__c = '';
        }
        try {
            upsert template;

            Map<ID, SurveyTemplateItem__c> oldItems = new Map<ID, SurveyTemplateItem__c>([SELECT Id FROM SurveyTemplateItem__c WHERE SurveyTemplate__c = :template.Id]);
            Map<ID, SurveyTemplateAccesses__c> oldAccess = new Map<ID, SurveyTemplateAccesses__c>([SELECT Id FROM SurveyTemplateAccesses__c WHERE SurveyTemplate__c = :template.Id]);

            List<SurveyTemplateItem__c> itemsToUpdate = new List<SurveyTemplateItem__c>();
            List<SurveyTemplateItem__c> itemsToInsert = new List<SurveyTemplateItem__c>();
            List<SurveyTemplateItem__c> itemsToDelete = new List<SurveyTemplateItem__c>();

            List<SurveyTemplateAccesses__c> accessToUpdate = new List<SurveyTemplateAccesses__c>();
            List<SurveyTemplateAccesses__c> accessToInsert = new List<SurveyTemplateAccesses__c>();
            List<SurveyTemplateAccesses__c> accessToDelete = new List<SurveyTemplateAccesses__c>();

            for (TemplateQuestion question : questionList) {
                if (question.data.Id == null) {
                    question.data.SurveyTemplate__c = template.Id;
                    itemsToInsert.add(question.data);
                } else if (oldItems.containsKey(question.data.Id)) {
                    itemsToUpdate.add(question.data);
                    oldItems.remove(question.data.Id);
                }
            }

            for (SurveyTemplateItem__c question : oldItems.values()) {
                itemsToDelete.add(question);
            }

            for (SeciurityContact contact : contactList) {
                if (contact.data.Id == null) {
                    contact.data.SurveyTemplate__c = template.Id;
                    accessToInsert.add(contact.data);
                } else if (oldAccess.containsKey(contact.data.Id)) {
                    accessToUpdate.add(contact.data);
                    oldAccess.remove(contact.data.Id);
                }
            }

            for (SurveyTemplateAccesses__c contact : oldAccess.values()) {
                accessToDelete.add(contact);
            }

            delete accessToDelete;
            insert accessToInsert;
            update accessToUpdate;

            delete itemsToDelete;
            insert itemsToInsert;
            update itemsToUpdate;

        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
            if (isNew){
                template = template.clone();
            }
            return null;
        }

        return cancel();
    }

    public PageReference cancel() {
        return new ApexPages.StandardController(template).view();
    }

    public List<SelectOption> getContacts() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('', Label.None));
        for (Contact c : contacts.values()) {
            options.add(new SelectOption(c.Id, c.LastName+' '+c.FirstName));
        }
        
        return options;
    }

    public void clearContactList() {
        contactList.clear();
    }

    public PageReference checkedRequired() {
        if (templateItem.IsSystem__c) {
            templateItem.Required__c = true;
        }
        return null;
    }

    private SurveyTemplate__c loadSurveyTemplate(SurveyTemplate__c temp) {
        if (temp.Id != null) {
        return [SELECT Id, Name, Description__c, ApiName__c, Active__c, Private__c, Submittable__c, MultiSurvey__c, Importance__c, StartDate__c, EndDate__c, ServiceName__c, SurveyHandler__c, Config__c, QuestionSearchOptions__c, ExternalId__c,
                    (SELECT Id, Name, Order__c, QuestionId__c, SurveyTemplate__c, QuestionProvider__c, Required__c, IsSystem__c, Config__c FROM SurveyTemplateItems__r),
                    (SELECT Id, Name, SurveyTemplate__c, Contact__c, OnlyLeaders__c FROM SurveyTemplateAccesses__r)
                FROM SurveyTemplate__c 
                WHERE Id =:temp.Id
                LIMIT 1];
        }
        return temp;
    }

    private void prepareTemplateItems(SurveyTemplate__c temp) {
        questionList = new List<TemplateQuestion>();
        Integer i = 0;
        for (SurveyTemplateItem__c item : temp.SurveyTemplateItems__r) {
            questionList.add(new TemplateQuestion(i++, item, this));
        }
    }

    private void prepareAccessContacts(SurveyTemplate__c temp) {
        contactList = new List<SeciurityContact>();
        Integer i = 0;
        for (SurveyTemplateAccesses__c item : temp.SurveyTemplateAccesses__r) {
            contactList.add(new SeciurityContact(i++, item, this, contacts));
        }
    }

    private Boolean validateQuestion(){
        if (String.isBlank(templateItem.QuestionProvider__c)) {
            return false;
        }
        return true;
    }

    private Boolean validateAccessContact(){
        if ((templateAccess.Contact__c == null && !templateAccess.OnlyLeaders__c) ||
            (templateAccess.Contact__c != null && templateAccess.OnlyLeaders__c)) {
            return false;
        }
        return true;
    }


    private static void addError(String message){
        ApexPages.addMessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, message)
        );
    }

    private String getSurveyHandlerConfigSignature(){
        if (!String.isBlank(template.SurveyHandler__c)){
            return SurveyUtils.getConfigSignature(template.SurveyHandler__c);
        }
        return '';
    }

    private String getQuestionProviderConfigSignature(){
        if (!String.isBlank(templateItem.QuestionProvider__c)){
            return SurveyUtils.getConfigSignature(templateItem.QuestionProvider__c);
        }
        return '';
    }
}