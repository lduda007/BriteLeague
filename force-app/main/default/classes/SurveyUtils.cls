global with sharing class SurveyUtils {

    public static final String QUESTION_TYPE_TEXT = 'text';
    public static final String QUESTION_TYPE_SELECT = 'select';
    public static final String QUESTION_TYPE_INFO = 'info';
    public static final String QUESTION_TYPE_ERROR = 'error';
    public static final String QUESTION_TYPE_POSITIVE_INTEGER = 'positiveInteger';
    public static final String QUESTION_TYPE_PERCENT = 'percent';
    public static final String QUESTION_TYPE_EMAIL = 'email';
    public static final String QUESTION_TYPE_CHECKBOX = 'checkbox';
    public static final String QUESTION_TYPE_DATE = 'date';
    public static final String QUESTION_TYPE_ATTRIBUTE = 'attribute';

    public static final String QUESTION_STATUS_OPEN = 'Open';
    public static final String QUESTION_STATUS_IN_PROGRESS = 'In Progress';
    public static final String QUESTION_STATUS_SUBMITED = 'Submited';

    public static final String QUESTION_SEARCH_OPTION = 'searchinall';

    public static final String SURVEY_CONFIGURATION_SURVEY_HANDLER_RECORD_TYPE = 'Survey_Handler';
    public static final String SURVEY_CONFIGURATION_SURVEY_QUESTION_PROVIDER_RECORD_TYPE = 'Survey_Question_Provider';

    public static String createApiName(String name) {
        String regExp = '[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|/|\\[-`|\\(|\\)|\\{|\\}|\\;|\\\'"-]';
        return (name == null ? '' : name).toLowerCase().replaceAll(regExp, '').trim().replace(' ', '_')
            .replace('ą', 'a')
            .replace('ś', 's')
            .replace('ż', 'z')
            .replace('ź', 'z')
            .replace('ć', 'c')
            .replace('ń', 'n')
            .replace('ł', 'l')
            .replace('ó', 'o')
            .replace('ę', 'e');
    }


    private static Map<String, Map<String, RecordType>> recordTypeMap = new Map<String, Map<String, RecordType>>();

    public static RecordType getSurveyQuestionRecordType(String rtDevName) {
        return loadAndGetRecordType('SurveyQuestion__c', rtDevName);
    }

    public static RecordType getSurveyConfigRecordType(String rtDevName) {
        return loadAndGetRecordType('SurveyConfiguration__c', rtDevName);
    }

    public static RecordType loadAndGetRecordType(String objectType, String rtDevName) {
        if (!recordTypeMap.containsKey(objectType)) {
            recordTypeMap.put(objectType, new Map<String, RecordType>());
            for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = :objectType]) {
                recordTypeMap.get(objectType).put(rt.DeveloperName, rt);
            }
        }
        return recordTypeMap.get(objectType).get(rtDevName);
    }


    private static Map<String, SurveyQuestionProvider> questionProviders;
    private static Map<String, SurveyHandler> surveyHandlers;
    private static Map<String, SurveyConfiguration__c> surveyConfig;

    private static void loadSurveyConfiguration() {
        if (surveyConfig == null) {
            questionProviders = new Map<String, SurveyQuestionProvider>();
            surveyHandlers = new Map<String, SurveyHandler>();
            surveyConfig = new Map<String, SurveyConfiguration__c>(
                [SELECT Name, Active__c, Class__c, ConfigSignature__c, RecordTypeId, RecordType.DeveloperName
                 FROM SurveyConfiguration__c WHERE Active__c = true]);
        }
    }

    public static Map<String, SurveyQuestionProvider> getQuestionProviders() {
        if (questionProviders == null || questionProviders.isEmpty()) {
            loadSurveyConfiguration();
            for (SurveyConfiguration__c cfg : surveyConfig.values()) {
                if (SurveyUtils.getSurveyConfigRecordType(SURVEY_CONFIGURATION_SURVEY_QUESTION_PROVIDER_RECORD_TYPE).id == cfg.RecordTypeId) {
                   questionProviders.put(cfg.Name, (SurveyQuestionProvider)Type.forName(cfg.Class__c).newInstance());
                }
            }
        }
        return questionProviders;
    }

    public static SurveyQuestionProvider getQuestionProvider(String name) {
        if (!getQuestionProviders().containsKey(name)) {
            throw new SurveyQuestionProviderException(String.format(System.Label.SurveyProviderDoesNotExist, new List<String>{name}));
        }
        return getQuestionProviders().get(name);
    }

    public static Map<String, SurveyHandler> getSurveyHandlers() {
        if (surveyHandlers == null || surveyHandlers.isEmpty()) {
            loadSurveyConfiguration();
            for (SurveyConfiguration__c cfg : surveyConfig.values()) {
                if (SurveyUtils.getSurveyConfigRecordType(SURVEY_CONFIGURATION_SURVEY_HANDLER_RECORD_TYPE).id == cfg.RecordTypeId) {
                    surveyHandlers.put(cfg.Name, (SurveyHandler)Type.forName(cfg.Class__c).newInstance());
                }
            }
        }
        return surveyHandlers;
    }

    public static SurveyHandler getSurveyHandler(String name) {
        if (!getSurveyHandlers().containsKey(name)) {
            throw new SurveyQuestionProviderException(String.format(System.Label.SurveyHandlerDoesNotExist, new List<String>{name}));

        }
        return getSurveyHandlers().get(name);
    }

    public static String getConfigSignature(ID configId) {
        loadSurveyConfiguration();
        return surveyConfig.get(configId).ConfigSignature__c;
    }


    public abstract with sharing class SurveyQuestionProvider {

        private TemplateContext context;
        private String providerName;

        public SurveyQuestionProvider init(TemplateContext context, String providerName) {
            this.context = context;
            this.providerName = providerName;

            return this;
        }

        protected TemplateContext getContext() {
            return context;
        }

        protected String getProviderName() {
            return providerName;
        }

        public abstract List<SurveyModel.Question> getQuestions(List<SurveyTemplateItem__c> surveyTemplateItems, SurveyUtils.TemplateRequest request);

    }

    public with sharing class QuestionConfig extends BaseConfig {

        public QuestionConfig(SurveyTemplateItem__c item) {
            super(String.isBlank(item.Config__c) ? new Map<String, Object>() : (Map<String, Object>)JSON.deserializeUntyped(item.Config__c));
            cfg.put('order', item.Order__c);
        }

        public Integer getOrder() {
            return ((Decimal)cfg.get('order')).intValue();
        }
    }

    public with sharing class SurveyConfig extends BaseConfig {

        public SurveyConfig(SurveyTemplate__c template) {
            super(String.isBlank(template.Config__c) ? new Map<String, Object>() : (Map<String, Object>)JSON.deserializeUntyped(template.Config__c));
            cfg.put('templateApiName', template.ApiName__c);
        }

        public String getTemplateApiName() {
            return (String)cfg.get('templateApiName');
        }
    }

    public virtual with sharing class BaseConfig {
        private Map<String, Object> cfg;

        public BaseConfig(Map<String, Object> cfg) {
            this.cfg = cfg;
        }

        public Boolean hasValue(String key) {
            return cfg.containsKey(key);
        }

        public Object getValue(String key) {
            return cfg.get(key);
        }

        public Boolean getBoolean(String key) {
            if (cfg.get(key) != '' ) {
                return Boolean.valueOf(cfg.get(key));
            } else {
                return null;
            }
        }

        public String getString(String key) {
            return (String)cfg.get(key);
        }

        public ID getId(String key) {
            if (cfg.get(key) != '' ) {
                return (ID)cfg.get(key);
            } else {
                return null;
            }
        }

        public Integer getInteger(String key) {
            return (Integer)cfg.get(key);
        }

    }

    public abstract with sharing class SurveyHandler {

        private SurveyContext context;
        private String handlerName;

        public SurveyHandler init(SurveyContext context, String handlerName) {
            this.context = context;
            this.handlerName = handlerName;

            return this;
        }

        protected SurveyContext getContext() {
            return context;
        }

        protected String getHandlerName() {
            return handlerName;
        }

        public virtual List<SurveyModel.SurveyInfo> getSurveyToTemplateInfo(SurveyConfig cfg, SurveyModel.TemplateInfo templateInfo, SurveyUtils.Request request){
            return new List<SurveyModel.SurveyInfo>();
        }

        public abstract SurveyModel.Survey getSurvey(SurveyConfig cfg);

        public abstract void save(SurveyConfig cfg);
    }


    public virtual with sharing class TemplateContext {

        protected TemplateRequest request;
        protected SurveyTemplate__c surveyTemplate;
        protected Map<String, List<SurveyTemplateItem__c>> providerNameToItems = new Map<String, List<SurveyTemplateItem__c>>();
        protected Map<String, SurveyTemplateItem__c> questionIdToItem = new Map<String, SurveyTemplateItem__c>();

        public TemplateContext(TemplateRequest request) {
            this.request = request;
            loadTemplateWithItemsAndConfig();

            for (SurveyTemplateItem__c item : surveyTemplate.SurveyTemplateItems__r) {
                if (!providerNameToItems.containsKey(item.QuestionProvider__r.Name)) {
                    providerNameToItems.put(item.QuestionProvider__r.Name, new List<SurveyTemplateItem__c>());
                }
                providerNameToItems.get(item.QuestionProvider__r.Name).add(item);

                questionIdToItem.put(item.Id, item);
            }
        }

        public SurveyModel.Template getTemplate() {
            SurveyModel.Template template = new SurveyModel.Template(surveyTemplate);
            template.questionSearchOption.add(QUESTION_SEARCH_OPTION);
            if (surveyTemplate.QuestionSearchOptions__c != null) {
                for (String item : surveyTemplate.QuestionSearchOptions__c.split(';')){
                    template.questionSearchOption.add(item.toLowerCase().replaceAll( '\\s+', '').replaceAll( '-', ''));
                }
            }
            for (String provider: providerNameToItems.keySet()) {
                template.addAllQuestions(getQuestionProvider(provider).init(this, provider).getQuestions(providerNameToItems.get(provider), request));
            }
            return template;
        }

        public SurveyTemplate__c surveyTemplate() {
            return surveyTemplate;
        }

        public List<SurveyTemplateItem__c> providerNameToItems(String key) {
            return providerNameToItems.get(key);
        }

        public TemplateRequest getRequest() {
            return request;
        }

        private void loadTemplateWithItemsAndConfig() {
            List<SurveyTemplate__c> templates =
                [SELECT Id, Name, ApiName__c, StartDate__c, EndDate__c, Importance__c, Description__c, Private__c, Submittable__c, MultiSurvey__c, Active__c, ServiceName__c, Config__c, QuestionSearchOptions__c,
                    SurveyHandler__r.Name, SurveyHandler__r.Class__c, SurveyHandler__r.ConfigSignature__c, SurveyHandler__c,
                    (SELECT Id, Config__c, Name, Order__c, Required__c, IsSystem__c, QuestionProvider__r.Class__c, QuestionProvider__r.ConfigSignature__c, QuestionProvider__r.Name FROM SurveyTemplateItems__r WHERE QuestionProvider__r.Active__c = true ORDER BY Order__c)
                FROM SurveyTemplate__c
                WHERE Active__c = true
                    AND (StartDate__c = null OR StartDate__c <= TODAY)
                    AND (EndDate__c = null OR EndDate__c >= TODAY)
                    AND SurveyHandler__r.Active__c = true 
                    AND ApiName__c=:request.templateApiName LIMIT 1];

            if (templates.isEmpty()) {
                throw new SurveyException('Cannot find template with api name : ' + request.templateApiName);
            }

            surveyTemplate = templates[0];
        }
    }

    public virtual with sharing class SurveyContext extends TemplateContext {

        private SurveyModel.Survey survey;

        public SurveyContext(SurveyRequest request, SurveyModel.Survey survey) {
            super(request);
            this.survey = survey;
        }

        public SurveyContext(SurveyRequest request) {
            super(request);
        }

        public SurveyModel.Survey getSurveyModel() {
            return survey;
        }

        public SurveyModel.Survey getSurvey() {
            SurveyModel.Survey survey = getSurveyHandler(surveyTemplate.SurveyHandler__r.Name).init(this, surveyTemplate.SurveyHandler__r.Name).getSurvey(new SurveyConfig(surveyTemplate));
            return survey;
        }

        public void saveSurvey() {
            getSurveyHandler(surveyTemplate.SurveyHandler__r.Name).init(this, surveyTemplate.SurveyHandler__r.Name).save(new SurveyConfig(surveyTemplate));
        }
    }

    global virtual with sharing class Request {
        global String userId;

        global Request(String userId) {
            this.userId = userId;
        }

        global Request(){
        }
    }

    global virtual with sharing class TemplateRequest extends Request {
        global String templateApiName;

        global TemplateRequest(String userId, String templateApiName) {
            super(userId);
            this.templateApiName = templateApiName;
        }

        global TemplateRequest(){
        }
    }

    global virtual with sharing class SurveyRequest extends TemplateRequest {
        global String surveyId;

        global SurveyRequest() {
        }

        global SurveyRequest(String userId, String templateApiName, String surveyId) {
            super(userId, templateApiName);
            this.surveyId = surveyId;
        }

        global SurveyRequest(SurveyModel.Survey survey) {
            this(survey.userId, survey.templateApiName, survey.surveyId);
        }
    }

    public virtual class SurveyException extends Exception {

        public virtual Map<String, Object> toMap() {
           return new Map<String, Object> {
               'type' => getTypeName(),
               'message' => getMessage(),
               'lineNumber' => getLineNumber(),
               'stack' => getStackTraceString()
           };
       }

       public virtual String toJSON() {
           return JSON.serialize(toMap());
       }
    }

    public virtual class SurveyQuestionProviderException extends SurveyException {
    }

}