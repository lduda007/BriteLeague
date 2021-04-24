public with sharing class AchievementSurveyUtils {
    final static public String ACHIEVEMENT_CERTIFICATE_VALUE = 'Yes';
    final static public String ACHIEVMENT_ID_CONF_KEY = 'achievmentId';
    final static public String CATEGORY_ID_CONF_KEY = 'categoryId';
    final static public String ACHIEVMENT_EXTERNALID_CONF_KEY = 'achievmentExternalId';
    final static public String CATEGORY_EXTERNALID_CONF_KEY = 'categoryExternalId';
    final static public String ACHIEVMENTSET_ID_CONF_KEY = 'achievmentSetId';
    final static public String ACHIEVMENT_GET_ALL_CONF = 'getAll';
    final static public String ACHIEVMENT_EMAIL_CONF = 'email';
    final static public String ACHIEVMENT_DEFAULT_DESCRITPION = 'Default';

    public static Boolean checkItemsWithGetAll(List<SurveyTemplateItem__c> surveyTemplateItems) {
        Boolean getAll = false;
        for (SurveyTemplateItem__c item : surveyTemplateItems) {
            SurveyUtils.QuestionConfig cfg  = new SurveyUtils.QuestionConfig(item);
            if (cfg.getBoolean(ACHIEVMENT_GET_ALL_CONF)) {
                getAll = true;
                break;
            }
        }
        return getAll;
    }

    public static Boolean isGreatestValue(Achievement__c achievement) {
        if (achievement != null) {
            return achievement.RecordTypeId == AchievementUtils.getAchievementGroupRecordType().Id && (achievement.Group_Type__c == AchievementUtils.ACHIEVEMENT_GREATEST_VALUE_GROUP_TYPE || achievement.Group_Type__c == AchievementUtils.ACHIEVEMENT_GREATEST_VALUE_SPECIALIZATION_GROUP_TYPE);
        } else {
            return false;
        }
    }

    private static List<Contact> employees = null;
    public static List<Contact> getEmployees(String email) {
        if (employees == null) {
            employees = new List<Contact>();
            employees = [SELECT Id, Email, Name, FirstName, LastName FROM Contact WHERE SkillAssessment__c = true AND Id NOT IN :getAboutWhoIdFromAchievementSet(email) ORDER BY Name];
        }
        return employees;
    }

    private static List<Id> aboutWhoIDs = new List<Id>();
    public static List<Id> getAboutWhoIdFromAchievementSet(String email) {
        if (aboutWhoIDs.isEmpty()) {
            aboutWhoIDs = new List<Id>();
            for(Achievement_Set__c item : [SELECT AboutWho__c FROM Achievement_Set__c WHERE Who__r.Email = :email]) {
                aboutWhoIDs.add(item.AboutWho__c);
            }
        }
        return aboutWhoIDs;
    }

    public virtual with sharing class AchievementQuestionProvider extends SurveyUtils.SurveyQuestionProvider {

        protected List<SurveyModel.Option> questionOptions = null;

        public AchievementQuestionProvider() {
        }

        public virtual override List<SurveyModel.Question> getQuestions(List<SurveyTemplateItem__c> surveyTemplateItems, SurveyUtils.TemplateRequest request) {
            return getQuestionsFromTemplateItems(surveyTemplateItems, request);
        }

        protected virtual List<SurveyModel.Question> getQuestionsFromTemplateItems(List<SurveyTemplateItem__c> surveyTemplateItems, SurveyUtils.TemplateRequest request) {
            List<SurveyModel.Question> surveyQuestions = new List<SurveyModel.Question>();
            getContact(request.userId);
            if (AchievementSurveyUtils.checkItemsWithGetAll(surveyTemplateItems)) {
                Integer order = 0;
                for ( Achievement__c item : AchievementService.getAllAchievements()) {
                    if (checkAchievementAccess(item.AchievementsAccess__r)) {
                        SurveyModel.Question question = prepareQuestion(item, false, ++order);
                        if(question != null) {
                            surveyQuestions.add(question);
                        }
                    }
                }
            } else {
                for (SurveyTemplateItem__c item : surveyTemplateItems) {
                    List<SurveyModel.Question> questions = getQuestions(new SurveyUtils.QuestionConfig(item), item.IsSystem__c, surveyQuestions.size());
                    if (!questions.isEmpty()) {
                        surveyQuestions.addAll(questions);
                    }
                }
            }
            return removeDuplicate(surveyQuestions);
        }

        private Contact contact = null;
        private Contact getContact(String email) {
            if (contact == null) {
                List<Contact> contacts = [SELECT Id, IsLeader__c FROM Contact WHERE Email = :email LIMIT 1];
                contact = contacts[0];
            }
            return contact;
        }

        private Boolean checkAchievementAccess(List<AchievementAccess__c> achievementAccess) {
            Boolean accessAchievement = true;
            for (AchievementAccess__c item : achievementAccess) {
                accessAchievement = false;
                if ((contact.IsLeader__c == true && item.OnlyLeaders__c == true) || contact.Id == item.Contact__c) {
                    accessAchievement = true;
                    break;
                }
            }
            return accessAchievement;
        }

        private List<SurveyModel.Question> removeDuplicate(List<SurveyModel.Question> surveyQuestions) {
            Map<Id, SurveyModel.Question> questions = new Map<Id, SurveyModel.Question>();
            for (SurveyModel.Question item : surveyQuestions) {
                if (!questions.containsKey(item.Id)) {
                    questions.put(item.Id, item);
                }
            }
            return questions.values();
        }

        protected virtual List<SurveyModel.Question> getQuestions(QuestionConfig cfg, Boolean isSystem, Integer order) {
            List<SurveyModel.Question> questions = new List<SurveyModel.Question>();
            //Id achievementId = cfg.getId(AchievementSurveyUtils.ACHIEVMENT_ID_CONF_KEY);
            //Id categoryId = cfg.getID(AchievementSurveyUtils.CATEGORY_ID_CONF_KEY);
            String achievementId = cfg.getString(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY);
            String categoryId = cfg.getString(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY);
            if (achievementId != null && achievementId != '') {
                Achievement__c achievement = AchievementService.getAchievement(achievementId);
                if (achievement != null) {
                    if (checkAchievementAccess(achievement.AchievementsAccess__r)) {
                        if (isGreatestValue(achievement)) {
                            for (Achievement_Group_Item__c item : achievement.Achievement_Group_Items__r) {
                                Question question = prepareQuestion(AchievementService.getAchievement(item.Achievement__c), isSystem, ++order);
                                if (question != null) {
                                    questions.add(question);
                                }
                                //questions.add(prepareQuestion(AchievementService.getAchievement(item.Achievement__c), isSystem, ++order));
                            }
                        } else {
                            Question question = prepareQuestion(achievement, isSystem, ++order);
                            if (question != null) {
                                questions.add(question);
                            }
                        }
                    }
                } else {
                    throw new SurveyUtils.SurveyQuestionProviderException(String.format(System.Label.CannotFoundAchievementWithID, new List<String>{achievementId}));
                }
            } else if (categoryId != null && categoryId != '') {
                String categoryName = AchievementService.getCategoryName(categoryId);
                Set<Id> ids = AchievementService.getSubCategoriesIds(categoryName);
                for ( Achievement__c item : AchievementService.getAllAchievements()) {
                    if (ids.contains(item.Achievement_Category__c) && checkAchievementAccess(item.AchievementsAccess__r)) {
                        if (item.Group_Type__c == AchievementUtils.ACHIEVEMENT_GREATEST_VALUE_SPECIALIZATION_GROUP_TYPE) {
                            for (Achievement_Group_Item__c itemGroup : item.Achievement_Group_Items__r) {
                                Question question = prepareQuestion(AchievementService.getAchievement(itemGroup.Achievement__c), isSystem, ++order);
                                if (question != null) {
                                    questions.add(question);
                                }
                            }
                        } else{
                            SurveyModel.Question question = prepareQuestion(item, isSystem, ++order);
                            if(question != null) {
                                questions.add(question);
                            }
                        }
                    }
                }
            } else {
                throw new SurveyUtils.SurveyQuestionProviderException(System.Label.AchievementIdIsMandatory);
            }
            return questions;
        }

        protected virtual Question prepareQuestion(Achievement__c achievement, Boolean isSystem, Integer order) {
            Question question = new Question(achievement.Id, achievement.Name);
            question.order = order;
            question.descriptions.put(ACHIEVMENT_DEFAULT_DESCRITPION, achievement.Details__c);
            if (achievement.recordType.DeveloperName == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE || (achievement.recordType.DeveloperName == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE && achievement.Group_Type__c == AchievementUtils.ACHIEVEMENT_MANUAL_GROUP_TYPE)) {
                question.descriptions.put(AchievementUtils.ACHIEVEMENT_LEVEL_1_VALUE, achievement.Level_1_Details__c);
                question.descriptions.put(AchievementUtils.ACHIEVEMENT_LEVEL_2_VALUE, achievement.Level_2_Details__c);
                question.descriptions.put(AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE, achievement.Level_3_Details__c);
            } else if (achievement.recordType.DeveloperName == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE) {
                for (Achievement_Value__c item : achievement.AchievementValues__r) {
                    question.descriptions.put(String.valueOf(item.Value__c), item.Details__c);
                }
            }
            question.readOnly = false;
            question.isSystem = isSystem;
            question.category = achievement.Achievement_Category__r.Name;
            question.categoryId = achievement.Achievement_Category__r.Id;
            question.type = SurveyUtils.QUESTION_TYPE_SELECT;
            if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE) {
                question.options = questionLevelOptions();
            } else if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE) {
                question.type = SurveyUtils.QUESTION_TYPE_CHECKBOX;
                question.options = new List<SurveyModel.Option> {
                        //new SurveyModel.Option(null, Label.None),
                        new SurveyModel.Option(AchievementSurveyUtils.ACHIEVEMENT_CERTIFICATE_VALUE, Label.Yes)
                };
            } else if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE) {
                if (achievement.Group_Type__c == AchievementUtils.ACHIEVEMENT_MANUAL_GROUP_TYPE) {
                    question.options = questionLevelOptions();
                } else {
                    question.readOnly = true;
                }
            } else if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE) {
                question.type = SurveyUtils.QUESTION_TYPE_POSITIVE_INTEGER;
            } else if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE) {
                question.type = SurveyUtils.QUESTION_TYPE_INFO;
            } else if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE) {
                question.type = SurveyUtils.QUESTION_TYPE_ATTRIBUTE;
                question.options = new List<SurveyModel.Option>();
                List<Achievement_Value__c> achievementValues = AchievementService.getAchievementsValues().get(achievement.Id).values();
                for (Integer i = achievementValues.size() - 1; i >= 0; i --) {
                    question.options.add(new SurveyModel.Option(String.valueOf(achievementValues[i].Value__c), achievementValues[i].Name));
                }
            } else if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE) {
                question.type = SurveyUtils.QUESTION_TYPE_DATE;
            }

            return question;
        }

        protected List<SurveyModel.Option> questionLevelOptions() {
            questionOptions = new List<SurveyModel.Option> {
                    //new SurveyModel.Option(null, Label.None),
                    new SurveyModel.Option(AchievementUtils.ACHIEVEMENT_LEVEL_1_VALUE, Label.SkillLevelJunior),
                    new SurveyModel.Option(AchievementUtils.ACHIEVEMENT_LEVEL_2_VALUE, Label.SkillLevelProfessional),
                    new SurveyModel.Option(AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE, Label.SkillLevelSenior)
            };
            return questionOptions;
        }
    }

    public with sharing class AchievementPositionProfileQuestionProvider extends AchievementQuestionProvider {

        public AchievementPositionProfileQuestionProvider() {
        }

        public override Question prepareQuestion(Achievement__c achievement, Boolean isSystem, Integer order) {
            Question question = super.prepareQuestion(achievement, isSystem, order);
            if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE) {
                question.type = SurveyUtils.QUESTION_TYPE_POSITIVE_INTEGER;
            } else if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE) {
                question.type = SurveyUtils.QUESTION_TYPE_PERCENT;
            } else if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE) {
                question.options = questionLevelOptions();
                question.readOnly = false;
            }
            return question;
        }
    }

    public with sharing class AchievementSpecializationQuestionProvider extends AchievementQuestionProvider {

        public AchievementSpecializationQuestionProvider() {
        }

        public override Question prepareQuestion(Achievement__c achievement, Boolean isSystem, Integer order) {
            Question question = null;
            if (achievement.RecordType.DeveloperName != AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE) {
                question = super.prepareQuestion(achievement, isSystem, order);
                if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE) {
                    question.type = SurveyUtils.QUESTION_TYPE_POSITIVE_INTEGER;
                } else if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE) {
                    question.options = questionLevelOptions();
                    question.readOnly = false;
                }
            }
            return question;
        }
    }

    public with sharing class AchievementEmployeeProfileQuestionProvider extends AchievementQuestionProvider {

        public AchievementEmployeeProfileQuestionProvider() {
        }

        protected override Question prepareQuestion(Achievement__c achievement, Boolean isSystem, Integer order) {
            Question question = super.prepareQuestion(achievement, isSystem, order);
            if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE) {
                question.type = SurveyUtils.QUESTION_TYPE_POSITIVE_INTEGER;
            } else if (isGreatestValue(achievement)) {
                question.readOnly = true;
                question.type = SurveyUtils.QUESTION_TYPE_INFO;
            } else if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE) {
                question.readOnly = true;
                question.type = SurveyUtils.QUESTION_TYPE_PERCENT;
            }

            return question;
        }
    }

    public with sharing class AchievementSurveyQuestionProvider extends AchievementQuestionProvider {

        public AchievementSurveyQuestionProvider() {
        }

        protected List<SurveyModel.Option> questionOptions = null;

        protected override List<SurveyModel.Question> getQuestionsFromTemplateItems(List<SurveyTemplateItem__c> surveyTemplateItems, SurveyUtils.TemplateRequest request){
            List<SurveyModel.Question> questions = new List<SurveyModel.Question>();
            Integer index = getIndexEmailQuestion(surveyTemplateItems);
            Question question = new Question(AchievementSurveyUtils.ACHIEVMENT_EMAIL_CONF, System.Label.Employee);
            question.type = SurveyUtils.QUESTION_TYPE_EMAIL;
            question.isSystem = surveyTemplateItems.get(index).IsSystem__c;
            question.order = (Integer) surveyTemplateItems.get(index).Order__c;
            question.required = surveyTemplateItems.get(index).Required__c;
            question.readOnly = false;
            question.options = questionUsersOptions(request.userId);
            questions.add(question);
            surveyTemplateItems.remove(index);

            questions.addAll(super.getQuestionsFromTemplateItems(surveyTemplateItems, request));
            return questions;
        }

        private Integer getIndexEmailQuestion(List<SurveyTemplateItem__c> surveyTemplateItems) {
            Integer index = null;
            for (Integer i=0; i < surveyTemplateItems.size(); i++) {
                QuestionConfig cfg = new QuestionConfig(surveyTemplateItems.get(i));
                if (cfg.getBoolean(AchievementSurveyUtils.ACHIEVMENT_EMAIL_CONF)) {
                    index = i;
                    break;
                }
            }
            if (index == null) {
                throw new SurveyUtils.SurveyQuestionProviderException(System.Label.TamplateNotContainsQuestionOfEmail);
            }
            return index;
        }

        private List<SurveyModel.Option> questionUsersOptions(String email) {
            if (questionOptions == null) {
                questionOptions = new List<SurveyModel.Option>();

                for (Contact c: getEmployees(email)) {
                    questionOptions.add(new SurveyModel.Option(c.Email, c.LastName+' '+c.Firstname));
                }
            }
            return questionOptions;
        }

        protected override Question prepareQuestion(Achievement__c achievement, Boolean isSystem, Integer order) {
            Question question = null;
            if (((achievement.Group_Type__c == AchievementUtils.ACHIEVEMENT_MANUAL_GROUP_TYPE && achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE) || achievement.RecordType.DeveloperName != AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE) &&
                    achievement.RecordType.DeveloperName != AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE) {
                question = super.prepareQuestion(achievement, isSystem, order);
                if (achievement.RecordType.DeveloperName == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE) {
                    question.type = SurveyUtils.QUESTION_TYPE_POSITIVE_INTEGER;
                }
            }
            return question;
        }
    }

    public with sharing class AchievementQuestionGraphProvider extends AchievementQuestionProvider {

        private Map<String, Question> questions = new Map<String, Question>();
        private Integer order = 1;

        public AchievementQuestionGraphProvider() {
        }

        public override List<SurveyModel.Question> getQuestions(List<SurveyTemplateItem__c> surveyTemplateItems, SurveyUtils.TemplateRequest request) {
            Set<ID> recordTypeIds = new Set<ID> {
                    AchievementUtils.getAchievementSetRecordType(AchievementUtils.ACHIEVEMENT_SET_POSITION_RECORD_TYPE).Id,
                    AchievementUtils.getAchievementSetRecordType(AchievementUtils.ACHIEVEMENT_SET_PROFILE_RECORD_TYPE).Id
            };
            List<Achievement_Set__c> achievementSets = AchievementService.getAchievementSets(null, recordTypeIds, true);
            questions = new Map<String, Question>();
            questions.put('rootId', new QuestionInfo('rootId', 'Root', null, order, false));
            for (Career_Path__c item : AchievementService.getCareerPaths()) {
                questions.put(item.Id, new QuestionInfo(item.Id, item.Name, item.Description__c, ++order, false));
                questions.get(item.Id).addParentId('rootId');
            }
            for (Achievement_Set__c achievementSet : achievementSets) {
                String parentId = achievementSet.Parent_Profile__c == null ? achievementSet.Career_Path__c : achievementSet.Parent_Profile__c;
                if (!questions.containsKey(achievementSet.Id)) {
                    questions.put(achievementSet.Id, new QuestionInfo(achievementSet.Id, achievementSet.Name, achievementSet.Description__c, ++order, true));
                }
                questions.get(achievementSet.Id).addParentId(parentId);
                for (Achievement_Set_Item__c item : achievementSet.Achievements__r) {
                    Achievement__c achievement = AchievementService.getAchievement(item.Achievement__c);
                    if (!questions.containsKey(achievement.Id)) {
                        questions.put(achievement.Id, new Question(achievement, ++order, true));
                    }
                    questions.get(achievement.Id).addParentId(achievementSet.Id);
                    for (Achievement_Group_Item__c groupItem : achievement.Achievement_Group_Items__r) {
                        Achievement__c achievementFromGruop = AchievementService.getAchievement(groupItem.Achievement__c);
                        if (!questions.containsKey(item.Id)) {
                            questions.put(achievementFromGruop.Id, prepareQuestion(achievementFromGruop, false, ++order));
                        }
                        questions.get(achievementFromGruop.Id).addParentId(item.Id);
                    }
                }
            }
            for(Achievement__c achievement : AchievementService.getAllAchievements()){
                if (!questions.containsKey(achievement.Id)) {
                    questions.put(achievement.Id, prepareQuestion(achievement, false, ++order));
                }
            }
            return questions.values();
        }

    }

    public with sharing virtual class Question extends SurveyModel.Question {

        private Set<String> parentIds = new Set<String>();
        private Boolean canOpen;
        private String category;
        private Id categoryId;
        private Boolean required = false;
        private Map<String, String> descriptions = new Map<String, String>();

        public Question(String id, String name) {
            super(id, name);
            canOpen = true;
        }

        public Question(Achievement__c achievement, Integer order, Boolean canOpen) {
            super(achievement.Id, achievement.Name, order, 'text', null, false, false);
            this.canOpen = canOpen;
        }

        public void addParentId(String parentId) {
            parentIds.add(parentId);
        }
    }

    public with sharing class QuestionInfo extends Question {

        public QuestionInfo(String id, String name, String description, Integer order, Boolean canOpen) {
            super(id, name);
            this.type = SurveyUtils.QUESTION_TYPE_INFO;
            this.order = order;
            this.description = description;
            this.canOpen = canOpen;
            this.readOnly = true;
        }
    }

    public with sharing class Answer extends SurveyModel.Answer {

        public Decimal otherEmployeeAvgValue;
        public Map<String, Integer> otherEmployeesSkillOrGroupValue = new Map<String, Integer>();
        private Decimal sumAnswers = 0;
        private String selfAnswer;
        private String type;
        private Boolean readOnly = false;
        private String aboutWhoName;

        public Answer () {
        }

    }

    public abstract with sharing class AchievementBaseHandler extends SurveyUtils.SurveyHandler {

        public virtual override List<SurveyModel.SurveyInfo> getSurveyToTemplateInfo(SurveyConfig cfg, SurveyModel.TemplateInfo templateInfo, SurveyUtils.Request request){
            List<SurveyModel.SurveyInfo> surveys = new List<SurveyModel.SurveyInfo>();
            for (Achievement_Set__c achievementSet : getAchievementSets(cfg, request)) {
                SurveyModel.SurveyInfo survey = new SurveyModel.SurveyInfo();
                survey.surveyId = achievementSet.Id;
                survey.userId = request.UserId;
                survey.name = achievementSet.Name;
                survey.templateApiName = templateInfo.templateApiName;
                surveys.add(survey);
            }
            return surveys;
        }

        protected virtual List<Achievement_Set__c> getAchievementSets(SurveyConfig cfg, SurveyUtils.Request request) {
            List<Achievement_Set__c> achievementSets = new List<Achievement_Set__c>();
            Id achievementId = cfg.getId(AchievementSurveyUtils.ACHIEVMENTSET_ID_CONF_KEY);
            if (achievementId != null) {
                achievementSets.add(AchievementService.getAchievementSetInfo(achievementId));
            } else {
                achievementSets.addAll(AchievementService.getAchievementSets(null, getRecordType(), true));
            }
            return achievementSets;
        }

        public virtual override SurveyModel.Survey getSurvey(SurveyConfig cfg) {
            Set<Id> ids = getSurveyId(cfg);
            List<Achievement_Set__c> achievementSets = AchievementService.getAchievementSets(ids, null, true);
            if (achievementSets.isEmpty()) {
                List<String> arguments = new List<String>();
                for (Id id : ids) {
                    arguments.add((String) id);
                }
                throw new AchievementBaseHandlerException(String.format(System.Label.NotFoundAchievementSetWithId, arguments));
            }
            Achievement_Set__c achievementSet = achievementSets[0];
            return prepareSurvey(achievementSet, cfg.getTemplateApiName());
        }

        protected virtual Set<Id> getSurveyId(SurveyConfig cfg) {
            Set<Id> ids = new Set<Id>();
            Id achievementSetId = cfg.getId(AchievementSurveyUtils.ACHIEVMENTSET_ID_CONF_KEY);
            if (achievementSetId != null) {
                ids.add(achievementSetId);
            } else {
                SurveyUtils.SurveyContext context = (SurveyUtils.SurveyContext)this.getContext();
                SurveyUtils.SurveyRequest request = (SurveyUtils.SurveyRequest)context.getRequest();
                if (request.surveyId != '' && request.surveyId != null) {
                    ids.add(request.surveyId);
                }
            }
            if (ids.isEmpty()) {
                throw new AchievementSurveyUtils.AchievementBaseHandlerException(System.Label.AchievementSetWasNotSetOnTheSurveyTemplate);
            }
            return ids;
        }

        protected virtual SurveyModel.Survey prepareSurvey(Achievement_Set__c achievementSet, String templateApiName) {
            SurveyUtils.SurveyContext context = (SurveyUtils.SurveyContext)this.getContext();
            SurveyUtils.SurveyRequest request = (SurveyUtils.SurveyRequest)context.getRequest();
            SurveyTemplate__c template = context.surveyTemplate();
            SurveyModel.Survey survey = new SurveyModel.Survey();
            List<Answer> answers = new List<Answer>();
            List<Achievement_Set_Item__c> achievementSetItems = new List<Achievement_Set_Item__c>();
            survey.surveyId = achievementSet.Id;
            survey.userId = request.userId;
            survey.name = achievementSet.Name;
            survey.templateApiName = templateApiName;
            if (checkItemsWithGetAll(template.SurveyTemplateItems__r)) {
                achievementSetItems.addAll(achievementSet.Achievements__r);
            } else {
                //Map<Id, Achievement_Set_Item__c> achievementItems = prepareAchievementSetItemMap(achievementSet.Achievements__r);
                Map<String, Achievement_Set_Item__c> achievementItems = prepareAchievementSetItemMap(achievementSet.Achievements__r, true);
                Map<Id, List<Achievement__c>> categories = AchievementService.getCategoriesWithAchievments();
                for (SurveyTemplateItem__c item : template.SurveyTemplateItems__r) {
                    SurveyUtils.QuestionConfig cfg = new SurveyUtils.QuestionConfig(item);
                    //Id achievementId = cfg.getId(AchievementSurveyUtils.ACHIEVMENT_ID_CONF_KEY);
                    //Id categoryId = cfg.getId(AchievementSurveyUtils.CATEGORY_ID_CONF_KEY);
                    String achievementId = cfg.getString(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY);
                    String categoryId = cfg.getString(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY);
                    if (achievementId != '') {
                        Achievement__c achievement = AchievementService.getAchievement(achievementId);
                        if (isGreatestValue(achievement)) {
                            for (Achievement_Group_Item__c groupItem : achievement.Achievement_Group_Items__r) {
                                //achievementSetItems.add(achievementItems.get(groupItem.Achievement__c));
                                achievementSetItems.add(achievementItems.get(groupItem.Achievement__r.ExternalId__c));
                            }
                        } else {
                            achievementSetItems.add(achievementItems.get(achievementId));
                        }
                    }
                    if (categoryId != '') {
                        String categoryName = AchievementService.getCategoryName(categoryId);
                        for (Id id : AchievementService.getSubCategoriesIds(categoryName)){
                            List<Achievement__c> achievements = categories.get(id);
                            if (achievements != null) {
                                for (Achievement__c achievementItem : achievements) {
                                    if (achievementItem.Group_Type__c == AchievementUtils.ACHIEVEMENT_GREATEST_VALUE_SPECIALIZATION_GROUP_TYPE) {
                                        for (Achievement_Group_Item__c itemGroup : achievementItem.Achievement_Group_Items__r) {
                                            achievementSetItems.add(achievementItems.get(itemGroup.Achievement__r.ExternalId__c));
                                        }
                                    } else{
                                        achievementSetItems.add(achievementItems.get(achievementItem.ExternalId__c));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            for(Achievement_Set_Item__c item : achievementSetItems) {
                if (item != null) {
                    answers.add(prepareAnswer(item));
                }
            }
            survey.answers = answers;
            return survey;
        }

        private Map<Id, Achievement_Set_Item__c> prepareAchievementSetItemMap(List<Achievement_Set_Item__c> items) {
            Map<Id, Achievement_Set_Item__c> achievementSetItems = new Map<Id, Achievement_Set_Item__c>();
            for (Achievement_Set_Item__c item : items) {
                achievementSetItems.put(item.Achievement__c, item);
            }
            return achievementSetItems;
        }

        private Map<String, Achievement_Set_Item__c> prepareAchievementSetItemMap(List<Achievement_Set_Item__c> items, Boolean externalId) {
            Map<String, Achievement_Set_Item__c> achievementSetItems = new Map<String, Achievement_Set_Item__c>();
            for (Achievement_Set_Item__c item : items) {
                achievementSetItems.put(item.Achievement__r.ExternalId__c, item);
            }
            return achievementSetItems;
        }

        private Answer prepareAnswer(Achievement_Set_Item__c item) {
            Answer answer = new Answer();
            answer.id = item.Id;
            answer.questionId = item.Achievement__c;
            answer.type = item.Type__c;
            if (item.Type__c == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE || item.Type__c == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE || item.Type__c == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE) {
                answer.value = item.LevelValue__c;
            } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE) {
                answer.value = AchievementSurveyUtils.ACHIEVEMENT_CERTIFICATE_VALUE;
            } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE) {
                answer.value = String.valueOf(item.Min_Speciality_Match__c);
            } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE) {
                answer.value = String.valueOf(item.Date__c);
            } else {
                answer.value = String.valueOf(item.Amount__c);
            }
            return answer;
        }

        public override void save(SurveyConfig cfg) {
            Achievement_Set__c achievementSet = getAchievementSetWithItems(cfg);
            SurveyUtils.SurveyContext context = (SurveyUtils.SurveyContext)this.getContext();
            List<SurveyModel.Answer> answers = prepareAnswerToSave(context.getSurveyModel().answers);
            List<Id> achievementIds = prepareAchievmentIds(answers);
            SurveyTemplate__c template = context.surveyTemplate();
            Map<Id, Achievement__c> achievementsItems = prepareAchievementsFromTemplateItem(template.SurveyTemplateItems__r);
            Map<Id, String> answersValue = prepareAnswersValueMap(answers);
            List<Achievement_Set_Item__c> achievementSetItems = prepareAchievementSetItemsFromSurveyAnswers(achievementSet, achievementsItems, answers);
            List<Achievement> achievements = AchievementService.convert(cfg.getId(AchievementSurveyUtils.ACHIEVMENTSET_ID_CONF_KEY), achievementIds, achievementSetItems);
            for (Achievement achievement : achievements) {
                if (achievement.getIsCert()) {
                    achievement.selected = (answersValue.get(achievement.oldRecord.Achievement__c) == AchievementSurveyUtils.ACHIEVEMENT_CERTIFICATE_VALUE) ? true : false;
                }
            }
            AchievementService.save(achievements);
        }

        protected virtual List<SurveyModel.Answer> prepareAnswerToSave(List<SurveyModel.Answer> answers) {
            return answers;
        }

        protected virtual Achievement_Set__c getAchievementSetWithItems(SurveyConfig cfg) {
            Set<ID> achievementIds = new Set<ID>();
            achievementIds.addAll(getSurveyId(cfg));
            List<Achievement_Set__c> achievementSets = getAchievementSets(achievementIds);
            if (achievementSets.isEmpty()) {
                throw new AchievementSurveyUtils.AchievementBaseHandlerException(System.Label.CannotFindProperSurvey);
            }
            return achievementSets[0];
        }

        public abstract List<Achievement_Set__c> getAchievementSets(Set<ID> achievementIds);
        public abstract Set<ID> getRecordType();

        protected virtual List<Id> prepareAchievmentIds(List<SurveyModel.Answer> answers) {
            List<Id> ids = new List<Id>();
            for (SurveyModel.Answer item : answers) {
                ids.add(item.questionId);
            }
            return ids;
        }

        protected Map<Id, String> prepareAnswersValueMap(List<SurveyModel.Answer> answers) {
            Map<Id, String> values = new Map<Id, String>();
            for (SurveyModel.Answer item : answers) {
                values.put(item.questionId, item.value);
            }
            return values;
        }

        protected Map<Id, Achievement__c> prepareAchievementsFromTemplateItem(List<SurveyTemplateItem__c> templateItems){
            Map<Id, Achievement__c> achievements = new Map<Id, Achievement__c>();
            if (AchievementSurveyUtils.checkItemsWithGetAll(templateItems)) {
                for ( Achievement__c item : AchievementService.getAllAchievements()) {
                    achievements.put(item.Id, item);
                }
            } else {
                for (SurveyTemplateItem__c item : templateItems) {
                    SurveyUtils.QuestionConfig cfg = new SurveyUtils.QuestionConfig(item);
                    //Id achievementId = cfg.getId(ACHIEVMENT_ID_CONF_KEY);
                    //Id categoryId = cfg.getId(AchievementSurveyUtils.CATEGORY_ID_CONF_KEY);
                    String achievementId = cfg.getString(ACHIEVMENT_EXTERNALID_CONF_KEY);
                    String categoryId = cfg.getString(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY);
                    Map<Id, List<Achievement__c>> categories = AchievementService.getCategoriesWithAchievments();
                    Achievement__c achievement = AchievementService.getAchievement(achievementId);
                    if (isGreatestValue(achievement)) {
                        for (Achievement_Group_Item__c groupItem : achievement.Achievement_Group_Items__r) {
                            if (!achievements.containsKey(groupItem.Achievement__c)) {
                                achievements.put(groupItem.Achievement__c, AchievementService.getAchievement(groupItem.Achievement__r.ExternalId__c));
                            }
                        }
                    } else if (categoryId != '') {
                        String categoryName = AchievementService.getCategoryName(categoryId);
                        for (Id id : AchievementService.getSubCategoriesIds(categoryName)) {
                            List<Achievement__c> achievementsList = categories.get(id);
                            if (achievementsList != null) {
                                for (Achievement__c achievementItem : achievementsList) {
                                    if (achievementItem.Group_Type__c == AchievementUtils.ACHIEVEMENT_GREATEST_VALUE_SPECIALIZATION_GROUP_TYPE) {
                                        for (Achievement_Group_Item__c itemGroup : AchievementService.getAchievement(achievementItem.Id).Achievement_Group_Items__r) {
                                            achievements.put(itemGroup.Achievement__c, AchievementService.getAchievement(itemGroup.Achievement__c));
                                        }
                                    } else{
                                        if (!achievements.containsKey(achievementItem.Id)) {
                                            achievements.put(achievementItem.Id, achievementItem);
                                        }
                                    }
                                }
                            }
                        }
                    } else if (achievement != null) {
                        if (!achievements.containsKey(AchievementService.getAchievement(achievementId).Id)) {
                            if (AchievementService.getAchievement(achievementId).Group_Type__c == AchievementUtils.ACHIEVEMENT_GREATEST_VALUE_SPECIALIZATION_GROUP_TYPE) {
                                for (Achievement_Group_Item__c itemGroup : AchievementService.getAchievement(achievementId).Achievement_Group_Items__r) {
                                    achievements.put(itemGroup.Achievement__c, AchievementService.getAchievement(itemGroup.Achievement__c));
                                }
                            } else {
                                achievements.put(AchievementService.getAchievement(achievementId).Id, achievement);
                            }
                        }
                    }
                }
            }
            return achievements;
        }

        protected virtual List<Achievement_Set_Item__c> prepareAchievementSetItemsFromSurveyAnswers(Achievement_Set__c achievementSet, Map<Id, Achievement__c> achievements, List<SurveyModel.Answer> answers) {
            List<Achievement_Set_Item__c> achievementSetItems = new List<Achievement_Set_Item__c>();
            Map<ID, Achievement_Set_Item__c> achievementIdToItemMap = mapAchievementIdToItems(achievementSet.Achievements__r);
            for (SurveyModel.Answer answer : answers) {
                ID achievementId = answer.questionId;
                if (achievements.containsKey(achievementId)) {
                    Achievement_Set_Item__c item;
                    if (achievementIdToItemMap.containsKey(achievementId)) {
                        item = achievementIdToItemMap.get(achievementId);
                    } else {
                        item = new Achievement_Set_Item__c(
                                Achievement__c = achievementId,
                                Achievement_Set__c = achievementSet.Id
                        );
                    }
                    String recortTypeName = achievements.get(achievementId).RecordType.DeveloperName;
                    if (recortTypeName == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE || recortTypeName == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE) {
                        item.Level__c = AchievementUtils.ACHIEVEMENT_LEVEL_VALUE.get(answer.value);
                    } else if (recortTypeName == AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE) {
                        if (answer.value != '' && answer.value.isNumeric()) {
                            item.Min_Speciality_Match__c = Decimal.valueOf(answer.value);
                        }
                    } else if(recortTypeName == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE || recortTypeName == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE) {
                        if (answer.value != '' && answer.value.isNumeric()) {
                            item.Amount__c = Decimal.valueOf(answer.value);
                        }
                    } else if(recortTypeName == AchievementUtils.ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE) {
                        if (answer.value != '' && answer.value != null) {
                            list<String> d2 = answer.value.split('-');
                            list<integer> timeComponent = new list<integer>();

                            timeComponent.add(Integer.valueOf(d2[0]));
                            timeComponent.add(Integer.valueOf(d2[1]));
                            timeComponent.add(Integer.valueOf(d2[2].left(2)));

                            String t = d2[2].substringBetween('T','.');

                            list<String> time1 = t.split(':');
                            timeComponent.add(Integer.valueOf(time1[0]));
                            timeComponent.add(Integer.valueOf(time1[1]));
                            timeComponent.add(Integer.valueOf(time1[2]));

                            Datetime dt = Datetime.newInstance(timeComponent[0], timeComponent[1], timeComponent[2], timeComponent[3], timeComponent[4], timeComponent[5]);
                            if (dt <= DateTime.newInstance(Datetime.now().year(), Datetime.now().month(), Datetime.now().day(), 23, 59, 59)) {
                                item.Date__c = dt;
                            }
                        } else {
                            item.Date__c = null;
                        }

                    }
                    achievementSetItems.add(item);
                } 
                /*
                else {
                    throw new AchievementSurveyUtils.AchievementBaseHandlerException(String.format(System.Label.ThisAnswerCannotBeSaveThisSurvey, new List<String>{answer.value}));
                }
                */

            }
            return achievementSetItems;
        }

        protected virtual Map<ID, Achievement_Set_Item__c> mapAchievementIdToItems(List<Achievement_Set_Item__c> items) {
            Map<ID, Achievement_Set_Item__c> achievementIdToItemMap = new Map<ID, Achievement_Set_Item__c>();
            for (Achievement_Set_Item__c oldItem : items) {
                achievementIdToItemMap.put(oldItem.Achievement__c, oldItem);
            }
            return achievementIdToItemMap;
        }
    }

    public with sharing class AchievementPositionProfileHandler extends AchievementBaseHandler {
        public override List<Achievement_Set__c> getAchievementSets(Set<ID> achievementIds) {
            return AchievementService.getAchievementSets(achievementIds, getRecordType(), true);
        }

        public override Set<ID> getRecordType() {
            return AchievementUtils.getPositionProfileRecordTypeIds();
        }
    }

    public with sharing class AchievementSpecializationHandler extends AchievementBaseHandler {
        public override List<Achievement_Set__c> getAchievementSets(Set<ID> achievementIds) {
            return AchievementService.getAchievementSets(achievementIds, getRecordType(), true);
        }

        public override Set<ID> getRecordType() {
            return AchievementUtils.getSpecializationRecordTypeIds();
        }
    }

    public with sharing class AchievementEmployeeProfileHandler extends AchievementBaseHandler {
        public override List<Achievement_Set__c> getAchievementSets(Set<ID> achievementIds) {
            return AchievementService.getAchievementSets(achievementIds, getRecordType(), true);
        }

        public override Set<ID> getRecordType() {
            return AchievementUtils.getContactProfileRecordTypeIds();
        }

        protected override SurveyModel.Survey prepareSurvey(Achievement_Set__c achievementSet, String templateApiName) {
            SurveyModel.Survey survey = super.prepareSurvey(achievementSet, templateApiName);
            Map<Id, Achievement_Set_Item__c> selfAnswers = getSelfSurvey(achievementSet.Contact__c);
            Map<Id, SurveyModel.Answer> answers = new Map<Id, SurveyModel.Answer>();
            String answerValue;

            for (SurveyModel.Answer item : survey.answers) {
                answers.put(item.questionId, item);
            }

            for (Achievement__c item : AchievementService.getAllAchievements()) {
                Answer answer;
                if (answers.containsKey(item.Id)) {
                    answer = (Answer)answers.get(item.Id);
                } else {
                    answer = new Answer();
                    answer.questionId = item.Id;
                    answer.value = '';
                    survey.answers.add(answer);
                    answers.put(item.Id, answer);
                }
                if (selfAnswers.containsKey(item.Id)) {
                    if (item.RecordTypeId == AchievementUtils.getAchievementRecordType(AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE).Id) {
                        answer.sumAnswers ++;
                        answerValue = selfAnswers.get(item.Id).LevelValue__c;
                    } else if (item.RecordTypeId == AchievementUtils.getAchievementRecordType(AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE).Id) {
                        answer.sumAnswers ++;
                        answerValue = AchievementSurveyUtils.ACHIEVEMENT_CERTIFICATE_VALUE;
                    } else if (item.RecordTypeId == AchievementUtils.getAchievementRecordType(AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE).Id) {
                        answer.sumAnswers ++;
                        answerValue = String.valueOf(selfAnswers.get(item.Id).Amount__c);
                    } else if (item.RecordTypeId == AchievementUtils.getAchievementRecordType(AchievementUtils.ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE).Id) {
                        answer.sumAnswers ++;
                        answerValue = selfAnswers.get(item.Id).Date__c.format('yyyy-MM-dd');
                    } else if (item.RecordTypeId == AchievementUtils.getAchievementRecordType(AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE).Id) {
                        answer.sumAnswers ++;
                        answerValue = String.valueOf(selfAnswers.get(item.Id).Amount__c);
                    }

                    answer.selfAnswer = answerValue;
                }
            }
            getOthersSurvesValues(achievementSet.Contact__c, answers);

            return survey;
        }


        private Map<Id, Achievement_Set_Item__c> selfSurveyValue = null;
        private Map<Id, Achievement_Set_Item__c> getSelfSurvey(Id contactId) {
            if (selfSurveyValue == null) {
                selfSurveyValue = new Map<Id, Achievement_Set_Item__c>();
                for (Achievement_Set_Item__c item : [SELECT Achievement__c, Amount__c, Date__c, Level__c, LevelValue__c, Weight__c, Min_Speciality_Match__c, NumberOfMonths__c FROM Achievement_Set_Item__c WHERE Achievement_Set__r.RecordTypeId =: AchievementUtils.getAchievementSetSurveyRecordType().Id AND Achievement_Set__r.AboutWho__c =: contactId AND Achievement_Set__r.Who__c =: contactId AND HistoryRecord__c=false]) {
                    selfSurveyValue.put(item.Achievement__c, item);
                }
            }
            return selfSurveyValue;
        }

        private Map<Id, SurveyModel.Answer> getOthersSurvesValues(Id contactId, Map<Id, SurveyModel.Answer> surveyAnswers) {
            for(AggregateResult item: [SELECT Achievement__c, Achievement__r.RecordType.DeveloperName RecordTypeDevName, Achievement__r.Group_Type__c GroupType, LevelValue__c, COUNT(Id) CountValue, AVG(Amount__c) AmountValue, AVG(NumberOfMonths__c) NumberOfMonths FROM Achievement_Set_Item__c WHERE Achievement_Set__r.RecordTypeId =: AchievementUtils.getAchievementSetSurveyRecordType().Id AND Achievement_Set__r.AboutWho__c =: contactId  AND Achievement_Set__r.Who__c !=: contactId AND HistoryRecord__c=false GROUP BY Achievement__c, LevelValue__c, Achievement__r.RecordType.DeveloperName, Achievement__r.Group_Type__c ORDER BY Achievement__c]) {
                if (surveyAnswers.containsKey((Id)item.get('Achievement__c'))) {
                    Answer answer = (Answer) surveyAnswers.get((Id)item.get('Achievement__c'));
                    String type = (String) item.get('RecordTypeDevName');
                    String gruopType = (String) item.get('GroupType');
                    if ((type == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE || type == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE || (type == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE && gruopType == AchievementUtils.ACHIEVEMENT_MANUAL_GROUP_TYPE)) && item.get('LevelValue__c') != null) {
                        answer.sumAnswers += (Integer) item.get('CountValue');
                        answer.otherEmployeesSkillOrGroupValue.put((String) item.get('LevelValue__c'), (Integer) item.get('CountValue'));
                    } else if (type == AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE && item.get('CountValue') != null) {
                        answer.sumAnswers += (Decimal) item.get('CountValue');
                        answer.otherEmployeeAvgValue = (Decimal) item.get('CountValue');
                    } else if (type == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE && item.get('AmountValue') != null) {
                        answer.sumAnswers += (Decimal) item.get('AmountValue');
                        answer.otherEmployeeAvgValue = (Decimal) item.get('AmountValue');
                    } else if (type == AchievementUtils.ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE && item.get('NumberOfMonths') != null) {
                        answer.sumAnswers += (Decimal) item.get('NumberOfMonths');
                        answer.otherEmployeeAvgValue = (Decimal) item.get('NumberOfMonths');
                    }
                }
            }
            return surveyAnswers;
        }
    }

    public with sharing class AchievementSurveyHandler extends AchievementBaseHandler {
        public override List<Achievement_Set__c> getAchievementSets(Set<ID> achievementIds) {
            return null;
        }

        public List<Achievement_Set__c> getAchievementSets(Contact who, Contact aboutWho) {
            return AchievementService.getAchievementSets(null, getRecordType(), true, 'Who__c = \'' + who.Id + '\' AND AboutWho__c = \'' + aboutWho.Id + '\'');
        }

        public override Set<ID> getRecordType() {
            return AchievementUtils.getSurveyRecordTypeIds();
        }

        public override List<SurveyModel.SurveyInfo> getSurveyToTemplateInfo(SurveyConfig cfg, SurveyModel.TemplateInfo templateInfo, SurveyUtils.Request request) {
            List<SurveyModel.SurveyInfo> surveys = super.getSurveyToTemplateInfo(cfg, templateInfo, request);
            for (SurveyModel.SurveyInfo item : surveys) {
                List<String> names = item.name.split(' -> ');
                item.name = names[1];
            }
            return surveys;
        }

        public override SurveyModel.Survey getSurvey(SurveyConfig cfg) {
            SurveyModel.Survey survey = super.getSurvey(cfg);
            List<String> names = survey.name.split(' -> ');
            survey.name = names[1];
            return survey;
        }

        protected override List<Achievement_Set__c> getAchievementSets(SurveyConfig cfg, SurveyUtils.Request request) {
            List<Achievement_Set__c> achievementSets = new List<Achievement_Set__c>();
            Map<String, Contact> contacts = getContactMap(new List<String>{request.userId});
            Contact who = contacts.get(request.userId);
            if (who == null) {
                throw new AchievementSurveyServiceException(String.format(System.Label.NotFoundUser, new List<String>{request.userId}));
            }
            achievementSets.addAll(AchievementService.getAchievementSets(null, getRecordType(), true, 'Who__c = \'' + who.Id + '\''));

            return achievementSets;
        }

        protected override SurveyModel.Survey prepareSurvey(Achievement_Set__c achievementSet, String templateApiName) {
            SurveyModel.Survey survey = super.prepareSurvey(achievementSet, templateApiName);
            Answer answer = new Answer();
            answer.id = null;
            answer.questionId = ACHIEVMENT_EMAIL_CONF;
            answer.readOnly = true;
            answer.aboutWhoName = achievementSet.AboutWho__r.FirstName+' '+achievementSet.AboutWho__r.LastName;
            answer.value = achievementSet.AboutWho__r.Email;
            survey.answers.add(answer);
            return survey;
        }

        protected override Achievement_Set__c getAchievementSetWithItems(SurveyConfig cfg) {
            SurveyUtils.SurveyContext context = (SurveyUtils.SurveyContext)this.getContext();
            String targetId = getTargetId(context.getSurveyModel().answers);
            SurveyUtils.SurveyRequest request = (SurveyUtils.SurveyRequest)context.getRequest();
            String userId = request.userId;
            if (String.isBlank(targetId)) {
                throw new AchievementSurveyServiceException(System.Label.PleaseProvideTargetIdThisFieldIsMandatory);
            }
            Map<String, Contact> contacts = getContactMap(new List<String>{userId, targetId});
            Contact who = contacts.get(userId);
            Contact aboutWho = contacts.get(targetId);
            if (who == null) {
                throw new AchievementSurveyServiceException(String.format(System.Label.CannotFindContactWithEmail, new List<String>{userId}));
            }
            if (aboutWho == null) {
                throw new AchievementSurveyServiceException(String.format(System.Label.CannotFindContactWithEmail, new List<String>{targetId}));
            }
            List<Achievement_Set__c> achievementSets = getAchievementSets(who, aboutWho);
            if (achievementSets.isEmpty()) {
                Achievement_Set__c newSurvey = new Achievement_Set__c(Name = who.LastName + ' ' + who.FirstName + ' -> ' + aboutWho.LastName + ' ' + aboutWho.FirstName, Who__c=who.Id, AboutWho__c=aboutWho.Id, RecordTypeId=AchievementUtils.getAchievementSetSurveyRecordType().Id);
                insert newSurvey;
                achievementSets = getAchievementSets(who, aboutWho);
            }
            request.surveyId = achievementSets[0].Id;
            return achievementSets[0];
        }

        private Map<String, Contact> getContactMap(List<String> emails){
            Map<String, Contact> users = new Map<String, Contact>();
            for(Contact item : [SELECT Id, Email, Name, Firstname, Lastname FROM Contact WHERE Email IN :emails LIMIT 2]){
                users.put(item.Email, item);
            }
            return users;
        }

        protected override List<SurveyModel.Answer> prepareAnswerToSave(List<SurveyModel.Answer> answers) {
            List<Integer> indexes = new List<Integer>();
            for (Integer i = 0; i < answers.size(); i ++) {
                if (answers.get(i).questionId == SurveyUtils.QUESTION_TYPE_EMAIL) {
                    answers.remove(i);
                }
            }
            return answers;
        }

        private String getTargetId(List<SurveyModel.Answer> answers) {
            String getTargetId = '';
            for (SurveyModel.Answer item : answers) {
                if (item.questionId == SurveyUtils.QUESTION_TYPE_EMAIL) {
                    getTargetId = item.value;
                    break;
                }
            }
            return getTargetId;
        }
    }


    public virtual class AchievementBaseHandlerException extends SurveyUtils.SurveyException {}
    public virtual class AchievementSurveyServiceException extends SurveyUtils.SurveyException {}
}