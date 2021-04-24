trigger SurveyTemplateTrigger on SurveyTemplate__c (before insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (SurveyTemplate__c item: trigger.new) {
                item.ApiName__c = SurveyUtils.createApiName(item.Name);
                item.ExternalId__c = item.Name;
            }
        }
    }
}