trigger UpdateContactAchievementProfiles on Contact (before insert, before update, after insert, after update, after delete) {

    List<Achievement_Set__c> profiles = new List<Achievement_Set__c>();

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for (Contact c : Trigger.new) {
            c.ExternalId__c = c.Email;
        }
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        profiles = new List<Achievement_Set__c>();
        for (Contact c : Trigger.new) {
            if (c.SkillAssessment__c) {
                profiles.add(new AchievementUtils.AchievementSetBuilder('').asContactProfile(c).build());
            }
        }
        if (!profiles.isEmpty()) {
            insert profiles;
        }

    } else if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> contactIds = new Set<Id>();
        profiles.clear();
        Map<Id, Achievement_Set__c> achievementSet = new Map<Id, Achievement_Set__c>();
        for (Contact c : Trigger.new) {
            if (c.FirstName != Trigger.oldMap.get(c.Id).FirstName || c.LastName != Trigger.oldMap.get(c.Id).LastName) {
                contactIds.add(c.Id);
            }
            if (c.SkillAssessment__c && c.Achievement_Profile__c == null) {
                profiles.add(new AchievementUtils.AchievementSetBuilder('').asContactProfile(c).build());
            }
        }
        if (!profiles.isEmpty()) {
            insert profiles;
        }

        if (!contactIds.isEmpty()) {
            profiles = [SELECT Name, Contact__r.FirstName, Contact__r.LastName FROM Achievement_Set__c WHERE Contact__c IN :contactIds];
            for (Achievement_Set__c p : profiles) {
                new AchievementUtils.AchievementSetBuilder(p).asContactProfile(p.Contact__r);
            }
            update profiles;
        }

    } else if (Trigger.isAfter && Trigger.isDelete) {
        delete [SELECT Id FROM Achievement_Set__c WHERE Contact__c = null AND RecordTypeId=:AchievementUtils.getAchievementSetContactProfileRecordType().Id];
    }

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        Set<Id> contactIds = new Set<Id>();
        if (Trigger.old != null) {
            for (Contact contact : Trigger.old) {
                contactIds.add(contact.Leader__c);
                contactIds.add(contact.Guardian__c);
            }
        }

        if (Trigger.new != null) {
            for (Contact contact : Trigger.new) {
                contactIds.add(contact.Leader__c);
                contactIds.add(contact.Guardian__c);
            }
        }
        List<Contact> contacts = [SELECT Id, IsLeader__c, (SELECT Id FROM ManagedEmployees__r), (SELECT Id FROM GuardedEmployees__r) FROM Contact WHERE Id IN :contactIds LIMIT :contactIds.size()];
        for(Contact c : contacts) {
            c.IsLeader__c = !(c.ManagedEmployees__r.isEmpty() && c.GuardedEmployees__r.isEmpty());
        }
        update contacts;
    }
}