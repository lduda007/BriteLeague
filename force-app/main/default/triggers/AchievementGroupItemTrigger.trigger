trigger AchievementGroupItemTrigger on Achievement_Group_Item__c (before insert, before update, after insert, after update, after delete, after undelete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Map<Id, Achievement__c> achievements = new Map<Id, Achievement__c>(AchievementService.getAllAchievements(true));
            for(Achievement_Group_Item__c item : Trigger.new) {
                item.ExternalId__c = achievements.get(item.Group__c).ExternalID__c+'#'+achievements.get(item.Achievement__c).ExternalID__c;
            }
        }
    }

    if (Trigger.isAfter) {
        List<Achievement_Group_Item__c> items = new List<Achievement_Group_Item__c>();
        if (Trigger.isInsert || Trigger.isUndelete) {
            items = Trigger.new;
        } else if (Trigger.isDelete) {
            items = Trigger.old;
        } else if (Trigger.isUpdate) {
            for (Achievement_Group_Item__c item : Trigger.new) {
                if (item.Achievement__c != Trigger.oldMap.get(item.Id).Achievement__c) {
                    items.add(item);
                }
            }
        }
        
        Set<ID> achievementIds = new Set<ID>();
        for (Achievement_Group_Item__c item : items) {
            achievementIds.add(item.Achievement__c);
        }
        if (!achievementIds.isEmpty()) {
            achievementIds = AchievementService.getGroupsByMemberIds(achievementIds);
            AchievementService.calculateContactAchievementGroupValues(null, achievementIds);
        }
        
        AchievementService.calculateContactProfileScores(null, null);
    }

}