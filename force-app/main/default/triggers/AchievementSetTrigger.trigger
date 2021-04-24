trigger AchievementSetTrigger on Achievement_Set__c (before insert, before update, after insert, after update) {

    if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
        Map<Id, Contact> contacts = AchievementService.getContacts();
        for (Achievement_Set__c a : Trigger.new) {
            if ((a.RecordTypeId == AchievementUtils.getAchievementSetProfileRecordType().Id ||
                a.RecordTypeId == AchievementUtils.getAchievementSetPositionRecordType().Id) &&
                a.Score_Minimal_Value__c == null) {

                a.Score_Minimal_Value__c = 0.5;
            }
            String externalID = SystemUtils.loadAndGetRecordTypes(AchievementUtils.getAchievementSetObjectType()).get(a.RecordTypeId).DeveloperName + '#' + a.Name;
            if (contacts.get(a.Contact__c) != null) {
                externalID += '#'+contacts.get(a.Contact__c).externalID__c;
            }
            if (contacts.get(a.Who__c) != null) {
                externalID += '#'+contacts.get(a.Who__c).externalID__c;
            }
            if (contacts.get(a.AboutWho__c) != null) {
                externalID += '#'+contacts.get(a.AboutWho__c).externalID__c;
            }
            a.ExternalId__c = externalID;
        }
    }

    if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
        Map<Id, Id> contactIdToAchievementSetId = new Map<Id, Id>();
    
        for (Achievement_Set__c a : Trigger.new) {
            if (a.RecordTypeId == AchievementUtils.getAchievementSetContactProfileRecordType().Id) {
                contactIdToAchievementSetId.put(a.Contact__c, a.Id);
            }
        }

        if (!contactIdToAchievementSetId.isEmpty()) {
            List<Contact> contacts = [SELECT Achievement_Profile__c FROM Contact WHERE Achievement_Profile__c = null AND Id IN :contactIdToAchievementSetId.keySet() LIMIT :contactIdToAchievementSetId.size()];
            
            for (Contact c : contacts) {
                c.Achievement_Profile__c  = contactIdToAchievementSetId.get(c.Id);
            }
            
            if (!contacts.isEmpty()) {
                update contacts;
            }
            
        }
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<ID> achievementSetIds = new Set<ID>();
        for (Achievement_Set__c a : Trigger.new) {
            if ((a.RecordTypeId == AchievementUtils.getAchievementSetProfileRecordType().Id ||
                 a.RecordTypeId == AchievementUtils.getAchievementSetPositionRecordType().Id) && 
                a.Score_Minimal_Value__c != Trigger.oldMap.get(a.Id).Score_Minimal_Value__c) {

                achievementSetIds.add(a.Id);
            }
        }

        if (!achievementSetIds.isEmpty()) {
            AchievementService.calculateContactProfileScores(achievementSetIds, null);
        }
    }
}