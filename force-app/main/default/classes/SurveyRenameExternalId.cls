global class SurveyRenameExternalId implements Database.Batchable<sObject> {
    
    String query;
    String externalIdType;
    Map<String, String> externalIds;

    global SurveyRenameExternalId(String externalIdType, Map<String, String> externalIds) {
        this.externalIdType = externalIdType;
        this.externalIds = externalIds;
        query = 'SELECT Config__c FROM SurveyTemplateItem__c';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<SurveyTemplateItem__c> surveyTemplateItems = (List<SurveyTemplateItem__c>)scope;
        List<SurveyTemplateItem__c> newSurveyTemplateItems = new List<SurveyTemplateItem__c>();
        for (SurveyTemplateItem__c item : surveyTemplateItems) {
            Map<String, Object> config = (Map<String, Object>)JSON.deserializeUntyped(item.Config__c);
            if (externalIds.containsKey((String) config.get(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY)) || externalIds.containsKey((String) config.get(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY))) {
                if (this.externalIdType == AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY) {
                    config.put(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY, (Object) externalIds.get((String) config.get(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY)));
                    item.Config__c = JSON.serialize(config);
                } else if (this.externalIdType == AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY) {
                    config.put(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY, (Object) externalIds.get((String) config.get(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY)));
                    item.Config__c = JSON.serialize(config);
                }
                newSurveyTemplateItems.add(item);
            }
        }
        update newSurveyTemplateItems;
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
}