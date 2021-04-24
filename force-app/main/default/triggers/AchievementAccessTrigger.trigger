trigger AchievementAccessTrigger on AchievementAccess__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Map<Id, Achievement__c> achievements = new Map<Id, Achievement__c>(AchievementService.getAllAchievements(true));
            Map<Id, Contact> contacts = AchievementService.getContacts();

            for (AchievementAccess__c item : Trigger.new) {
                String ExternalId = '';

                ExternalId = achievements.get(item.Achievement__c).ExternalId__c+'#';
                if (item.OnlyLeaders__c) {
                    ExternalId += item.OnlyLeaders__c;
                }
                if (contacts.get(item.Contact__c) != null) {
                    ExternalId += contacts.get(item.Contact__c).ExternalId__c;
                }

                item.ExternalId__c = ExternalId;
            }
        }
    }
}