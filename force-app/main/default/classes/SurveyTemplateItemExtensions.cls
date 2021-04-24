public with sharing class SurveyTemplateItemExtensions {

    public static final String TEMPLATE_ID_PARAM = 'templateId';
    public SurveyTemplateItem__c templateItem {get; set;}
    private ApexPages.StandardController stdCtrl;
    private AchievementSurveyUtils.AchievementQuestionProvider achievementQuestionProvider = new AchievementSurveyUtils.AchievementQuestionProvider();
    private Map<Id, String> categories;

    public SurveyTemplateItemExtensions(ApexPages.StandardController stdController) {
        if(!test.isRunningTest()) {
            stdController.addFields(new List<String>{
                'Config__c', 'Order__c', 'QuestionId__c', 'QuestionProvider__c', 'SurveyTemplate__c', 'UniqueOrder__c', 'Required__c', 'IsSystem__c'
            });
        }
        stdCtrl = stdController;
        templateItem = (SurveyTemplateItem__c)stdCtrl.getRecord();
        if (templateItem.Id == null) {
            templateItem.SurveyTemplate__c = ApexPages.currentPage().getParameters().get(TEMPLATE_ID_PARAM);
        }
    }

    public PageReference saveNew() {
        SavePoint sp = Database.setSavePoint();
        PageReference ref = null;

        setNameAndConfigItem();

        try {
            upsert templateItem;

            ref = new Pagereference(('/' + templateItem.Id).subString(0, 4) + '/e');
            ref.getParameters().put(TEMPLATE_ID_PARAM, templateItem.SurveyTemplate__c);

        } catch (System.DMLException e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }

        return ref;
    }

    public PageReference save() {
        SavePoint sp = Database.setSavePoint();

        setNameAndConfigItem();

        try {
            upsert templateItem;
        } catch (System.DMLException e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }

        return new Pagereference('/' + templateItem.SurveyTemplate__c);
    }

    public void setConfig() {
        templateItem.Config__c = getConfigSignature();
    }

    public PageReference checkedRequired() {
        if (templateItem.IsSystem__c) {
            templateItem.Required__c = true;
        }
        return null;
    }

    private String getConfigSignature() {
        if (!String.isBlank(templateItem.QuestionProvider__c)) {
            return SurveyUtils.getConfigSignature(templateItem.QuestionProvider__c);
        }
        return '';
    }

    private void setNameAndConfigItem() {
        String regExp = '[/\\s+/g]';

        if (templateItem.Config__c.replaceAll(regExp, '') == getConfigSignature().replaceAll(regExp, '')) {
            templateItem.Config__c = '';
        }

        if (!String.isBlank(templateItem.Config__c)) {
            Map<String, Object> cfg = new Map<String, Object>((Map<String, Object>)JSON.deserializeUntyped(templateItem.Config__c));
            //if (!String.isBlank((String)cfg.get(AchievementSurveyUtils.ACHIEVMENT_ID_CONF_KEY)) && cfg.get(AchievementSurveyUtils.ACHIEVMENT_ID_CONF_KEY) != null) {
            //    templateItem.Name = AchievementUtils.getAllAchievements().get((ID)cfg.get(AchievementSurveyUtils.ACHIEVMENT_ID_CONF_KEY)).Name;
            if (!String.isBlank((String)cfg.get(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY)) && cfg.get(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY) != '') {
                templateItem.Name = AchievementUtils.getExternalIdAllAchievements().get((String)cfg.get(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY)).Name;
            //} else if (!String.isBlank((String)cfg.get(AchievementSurveyUtils.CATEGORY_ID_CONF_KEY)) && cfg.get(AchievementSurveyUtils.CATEGORY_ID_CONF_KEY) != null) {
                //templateItem.Name = System.Label.Category + ': ' + AchievementService.getCategoriesMap().get((Id)cfg.get(AchievementSurveyUtils.CATEGORY_ID_CONF_KEY));
            } else if (!String.isBlank((String)cfg.get(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY)) && cfg.get(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY) != '') {
                templateItem.Name = System.Label.Category + ': ' + AchievementService.getExternalIdCategoriesMap().get((String)cfg.get(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY));
            } else if (cfg.get(AchievementSurveyUtils.ACHIEVMENT_GET_ALL_CONF) == 'true') {
                templateItem.Name = System.Label.All_Questions;
            } else if (cfg.get(AchievementSurveyUtils.ACHIEVMENT_EMAIL_CONF) == 'true') {
                templateItem.Name = System.Label.Question_Who;
            }
        }
    }
}