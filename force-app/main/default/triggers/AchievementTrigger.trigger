trigger AchievementTrigger on Achievement__c (before insert, before update, after insert, after update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        ID skillTypeId = AchievementUtils.getAchievementSkillRecordType().Id;
        ID groupTypeId = AchievementUtils.getAchievementGroupRecordType().Id;
        ID specializationTypeId = AchievementUtils.getAchievementSpecializationRecordType().Id;
        for (Achievement__c a : Trigger.new) {
            a.ExternalId__c = a.Name;
            if (a.RecordTypeId != skillTypeId && a.RecordTypeId != groupTypeId) {
                a.Level_1_Details__c = null;
                a.Level_2_Details__c = null;
                a.Level_3_Details__c = null;
            }
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            Map <String, String> externalIDs = new Map<String, String>();
            for (Achievement__c item : Trigger.old) {
                if (item.ExternalId__c != Trigger.newMap.get(item.Id).ExternalId__c) {
                    externalIDs.put(item.ExternalId__c, Trigger.newMap.get(item.Id).ExternalId__c);
                }
            }
            if (!externalIDs.isEmpty()) {
                Database.executeBatch(new SurveyRenameExternalId(AchievementSurveyUtils.ACHIEVMENT_EXTERNALID_CONF_KEY, externalIDs));
            }
        }
    }
}