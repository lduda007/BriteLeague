@isTest
public class SurveyTestUtils {

    public static final String DEFAULT_SURVEY_HANDLER_CONFIGURATION_CLASS = 'AchievementSurveyUtils.AchievementPositionProfileHandler';
    public static final String DEFAULT_QUESTION_PROVIDER_CLASS = 'AchievementSurveyUtils.AchievementQuestionProvider';
    public static final String DEFAULT_SURVEY_CONFIGURATION_SIGNATURE = '{"id": ""}';

    public static List<SurveyModel.TemplateInfo> templatesInfoRequest(String userId) {
        return SurveyFrontController.getInstance().getTemplatesInfo(new SurveyUtils.Request(userID));
    }

    public static SurveyModel.Template templateRequest(String userId, String templateApiName) {
        return SurveyFrontController.getInstance().getTemplate(new SurveyUtils.TemplateRequest(userID, templateApiName));
    }

    public static SurveyModel.Survey surveyRequest(String userId, String templateApiName, String surveyId) {
        return SurveyFrontController.getInstance().getSurvey(new SurveyUtils.SurveyRequest(userId, templateApiName, surveyId));
    }

    public static SurveyTemplateItem__c createDefaultTemplateItem(SurveyTemplate__c template) {
        return buildDefaultTemplateItem(template).buildAndSave();
    }

    public static TemplateItemBuilder buildDefaultTemplateItem(SurveyTemplate__c template) {
        SurveyTestUtils.SurveyConfigBuilder cfg = SurveyTestUtils.createDefaultQuestionProvider('questionProvider');
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('name').buildAndSave();
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('Apex', category).asSkill().buildAndSave();

        return new SurveyTestUtils.TemplateItemBuilder(template, cfg.getConfigs().get('questionProvider')).withConfig('{"id": "'+achievement.Id+'", "getAll":"true"}');
    }

    public static SurveyTemplate__c createDefaultTemplate(String templateName) {
        return buildDefaultTemplate(templateName).buildAndSave();
    }

    public static TemplateBuilder buildDefaultTemplate(String templateName) {
        return new SurveyTestUtils.TemplateBuilder(templateName);
    }

    public static SurveyConfigBuilder createDefaultSurveyHandler(String name) {
        SurveyConfigBuilder cfg = new SurveyConfigBuilder().setServiceConfig(name, DEFAULT_SURVEY_HANDLER_CONFIGURATION_CLASS, DEFAULT_SURVEY_CONFIGURATION_SIGNATURE, null, true).setSurveyHandlerRecordType(name);
        cfg.buildAndSave();
        return cfg;
    }

    public static SurveyConfigBuilder createDefaultQuestionProvider(String name) {
        SurveyConfigBuilder cfg = new SurveyConfigBuilder().setServiceConfig(name, DEFAULT_QUESTION_PROVIDER_CLASS, DEFAULT_SURVEY_CONFIGURATION_SIGNATURE, null, true).setQuestionProviderRecordType(name);
        cfg.buildAndSave();
        return cfg;
    }

    public virtual class SurveyConfigBuilder {
        private Map<String, SurveyConfiguration__c> config;

        public SurveyConfigBuilder() {
            config = new Map<String, SurveyConfiguration__c>();
        }

        public SurveyConfigBuilder setServiceConfig(String configName, String configClass, String configSignature, ID recordType, Boolean active) {
            SurveyConfiguration__c cfg = config.containsKey(configName) ? config.get(configName) : new SurveyConfiguration__c(Name=configName);

            if (configClass != null){
                cfg.Class__c = configClass;
            }
            if (active != null){
                cfg.Active__c = active;
            }
            if (configSignature != null){
                cfg.ConfigSignature__c = configSignature;
            }
            if (recordType != null){
                cfg.RecordTypeId = recordType;
            }
            config.put(cfg.Name, cfg);
            return this;
        }

        public SurveyConfiguration__c build(){
            return config.values();
        }

        public SurveyConfiguration__c buildAndSave(){
            upsert config.values();
            return config.values();
        }

        public SurveyConfigBuilder setConfigSignature(String configName, String configSignature) {
            return setServiceConfig(configName, null, configSignature, null, true);
        }

        public SurveyConfigBuilder setConfigClass(String configName, String configClass) {
            return setServiceConfig(configName, configClass, null, null, true);
        }

        public SurveyConfigBuilder setQuestionProviderRecordType(String configName) {
            return setServiceConfig(configName, null, null, SurveyUtils.getSurveyConfigRecordType(SurveyUtils.SURVEY_CONFIGURATION_SURVEY_QUESTION_PROVIDER_RECORD_TYPE).Id, true);
        }

        public SurveyConfigBuilder setSurveyHandlerRecordType(String configName) {
            return setServiceConfig(configName, null, null, SurveyUtils.getSurveyConfigRecordType(SurveyUtils.SURVEY_CONFIGURATION_SURVEY_HANDLER_RECORD_TYPE).Id, true);
        }

        public Map<String, SurveyConfiguration__c> getConfigs(){
            return config;
        }
    }

    public class TemplateAccessBuilder {
        private SurveyTemplateAccesses__c record;

        public TemplateAccessBuilder(SurveyTemplate__c tamplate) {
            record = new SurveyTemplateAccesses__c(
                OnlyLeaders__c = true,
                SurveyTemplate__c = tamplate.Id
            );
        }

        public TemplateAccessBuilder withContact(Contact contact) {
            record.OnlyLeaders__c = false;
            record.Contact__c = contact.Id;
            return this;
        }

        public SurveyTemplateAccesses__c build() {
            return record;
        }

        public SurveyTemplateAccesses__c buildAndSave() {
            upsert record;
            return record;
        }
    }

    public class TemplateBuilder {

        protected SurveyTemplate__c record;
        protected List<SurveyTemplateItem__c> items = new List<SurveyTemplateItem__c>();

        public TemplateBuilder(String name) {
            record = new SurveyTemplate__c(
                Name = name,
                ApiName__c = name,
                Active__c = true,
                Description__c = 'Lorem ipsum',
                StartDate__c = System.today() - 7,
                EndDate__c = System.today() + 7,
                Importance__c = 'Medium',
                MultiSurvey__c = false,
                Private__c = false,
                Submittable__c = false,
                Config__c = '{}',
                SurveyHandler__c = createDefaultSurveyHandler('defaultName').config.get('defaultName').Id
            );
        }

        public SurveyTemplate__c buildAndSave() {
            upsert record;

            if (!items.isEmpty()) {
                for (SurveyTemplateItem__c item : items){
                    if (item.SurveyTemplate__c == null) {
                        item.SurveyTemplate__c = record.Id;
                        item.Config__c = '';
                        item.QuestionProvider__c = createDefaultQuestionProvider('defaultQuestionProvider').config.get('defaultQuestionProvider').Id;
                    }
                }
                upsert items;
            }

            return record;
        }

        public SurveyTemplate__c build() {
            return record;
        }

        public List<SurveyTemplateItem__c> getItems() {
            return items;
        }

        public TemplateBuilder withHandler(Id recordTypeId) {
            record.SurveyHandler__c = recordTypeId;
            return this;
        }

        public TemplateBuilder withNameAndApiName(String name) {
            record.Name = name;
            record.ApiName__c = name;
            return this;
        }

        public TemplateBuilder withConfig(String config) {
            record.Config__c = config;
            return this;
        }

        public TemplateBuilder deactivate() {
            record.Active__c = false;
            return this;
        }

        public TemplateBuilder fromFuture() {
            record.StartDate__c = Date.today() + 1;
            record.EndDate__c = Date.today() + 2;
            return this;
        }

        public TemplateBuilder fromPast() {
            record.StartDate__c = Date.today() - 2;
            record.EndDate__c = Date.today() - 1;
            return this;
        }

        public TemplateBuilder withActualDate() {
            record.StartDate__c = Date.today() - 1;
            record.EndDate__c = Date.today() + 1;
            return this;
        }

        public TemplateBuilder withStartDate(Date startDate) {
            record.StartDate__c = startDate;
            return this;
        }

        public TemplateBuilder withEndDate(Date endDate) {
            record.EndDate__c = endDate;
            return this;
        }

        public TemplateBuilder asMultisurvey() {
            record.MultiSurvey__c = true;
            return this;
        }

        public TemplateBuilder privateSurvey() {
            record.Private__c = true;
            return this;
        }

        public TemplateBuilder submittable() {
            record.Submittable__c = true;
            return this;
        }

        public TemplateBuilder addItem(SurveyTemplateItem__c item) {
            item.Order__c = items.size();
            items.add(item);
            return this;
        }
    }

    public virtual class TemplateItemBuilder {

        protected SurveyTemplateItem__c record;

        public TemplateItemBuilder() {}

        public TemplateItemBuilder(SurveyTemplate__c surveyTemplate, SurveyConfiguration__c questionProvider) {
            record = new SurveyTemplateItem__c(
                SurveyTemplate__c = surveyTemplate == null ? null : surveyTemplate.Id,
                QuestionProvider__c = questionProvider == null ? null : questionProvider.Id,
                Config__c = '',
                Order__c = 1
            );
        }

        public SurveyTemplateItem__c buildAndSave() {
            upsert record;
            return record;
        }

        public SurveyTemplateItem__c build() {
            return record;
        }

        public TemplateItemBuilder withOrder(Integer order) {
            record.Order__c = order;
            return this;
        }

        public TemplateItemBuilder withConfig(String config){
            record.Config__c = config;
            return this;
        }

        public TemplateItemBuilder withQuestionProvider(SurveyConfiguration__c provider){
            record.QuestionProvider__c = provider.Id;
            return this;
        }
    }
}