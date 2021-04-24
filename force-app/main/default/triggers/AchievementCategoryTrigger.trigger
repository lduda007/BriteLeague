trigger AchievementCategoryTrigger on Achievement_Category__c (before insert, before update, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (Achievement_Category__c item : Trigger.new) {
                item.ExternalId__c = item.name;
            }
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            Map <String, String> externalIDs = new Map<String, String>();
            for (Achievement_Category__c item : Trigger.old) {
                if (item.ExternalId__c != Trigger.newMap.get(item.Id).ExternalId__c) {
                    externalIDs.put(item.ExternalId__c, Trigger.newMap.get(item.Id).ExternalId__c);
                }
            }
            if (!externalIDs.isEmpty()) {
                Database.executeBatch(new SurveyRenameExternalId(AchievementSurveyUtils.CATEGORY_EXTERNALID_CONF_KEY, externalIDs));
            }
        }
    }
}