trigger AchievementSetItemTrigger on Achievement_Set_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Map<Id, Achievement__c> achievements = new Map<Id, Achievement__c>(AchievementService.getAllAchievements(true));
            Map<Id, Achievement_Set__c> achievementsSets = new Map<Id, Achievement_Set__c>();
            for (Achievement_Set_Item__c item : Trigger.new) {
                achievementsSets.put(item.Achievement_Set__c, null);
            }

            achievementsSets = new Map<Id, Achievement_Set__c>(AchievementService.getAchievementSets(achievementsSets.keySet(), null, false));
            for (Achievement_Set_Item__c item : Trigger.new) {
                if (!item.HistoryRecord__c) {
                    if (Trigger.isInsert || Trigger.isUpdate) {
                        item.ExternalID__c = AchievementUtils.prepareAchivementSetItemExternalId(achievementsSets.get(item.Achievement_Set__c), achievements.get(item.Achievement__c));
                    }
                }
            }
            achievementsSets.clear();
        }
    }

    if (Trigger.isBefore && !System.isBatch()) {
        if (Trigger.isInsert || Trigger.isUpdate) {

            for (Achievement_Set_Item__c item : Trigger.new) {
                if (!item.HistoryRecord__c) {
                    if (item.Type__c == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE) {
                        item.LevelValue__c = String.valueOf(item.Amount__c);
                    } 
                    if (item.Type__c == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE || (item.Type__c == AchievementUtils.ACHIEVEMENT_GROUP_RECORD_TYPE && item.Level__c != null)) {
                        if (item.Level__c == AchievementUtils.ACHIEVEMENT_LEVEL_1) {
                            item.LevelValue__c = '1';
                        }
                        if (item.Level__c == AchievementUtils.ACHIEVEMENT_LEVEL_2) {
                            item.LevelValue__c = '2';
                        }
                        if (item.Level__c == AchievementUtils.ACHIEVEMENT_LEVEL_3) {
                            item.LevelValue__c = '4';
                        }
                    }
                }
            }
        }

        AchievementsConfig__c cs = AchievementsConfig__c.getOrgDefaults();
        if ((Trigger.isUpdate || Trigger.isDelete) && (cs.TrackAchievementItemHistory__c || Test.isRunningTest())) {
            AchievementService.blockHistoryRecordModifications(Trigger.new);
            AchievementService.trackHistory(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter && !System.isBatch()) {
        List<Achievement_Set_Item__c> items = new List<Achievement_Set_Item__c>();
        List<Achievement_Set_Item__c> tmpItems = new List<Achievement_Set_Item__c>();
        if (Trigger.isInsert || Trigger.isUndelete) {
            tmpItems = Trigger.new;
        } else if (Trigger.isDelete) {
            tmpItems = Trigger.old;
        } else if (Trigger.isUpdate) {
            for (Achievement_Set_Item__c item : Trigger.new) {
                if (item.Level__c != Trigger.oldMap.get(item.Id).Level__c || item.Amount__c != Trigger.oldMap.get(item.Id).Amount__c ||
                    item.Min_Speciality_Match__c != Trigger.oldMap.get(item.Id).Min_Speciality_Match__c) {
                    tmpItems.add(item);
                }
            }
        }

        for (Achievement_Set_Item__c item : tmpItems) {
            if (!item.HistoryRecord__c) {
                items.add(item);
            }
        }

        Set<ID> profileIds = new Set<ID>();
        for (Achievement_Set_Item__c item : items) {
            profileIds.add(item.Achievement_Set__c);
        }

        Set<ID> contactPRT = AchievementUtils.getContactProfileRecordTypeIds();
        Set<ID> contactTargetPRT = AchievementUtils.getContactTargetProfileRecordTypeIds();
        Set<ID> profilesRT = new Set<ID>(contactPRT);
        profilesRT.addAll(contactTargetPRT);

        Set<ID> contactProfileIds = new Set<ID>();
        Set<ID> contactTargetProfilesIds = new Set<ID>();
        for (Achievement_Set__c profile : AchievementService.getAchievementSets(profileIds, profilesRT, false)) {
            if (contactPRT.contains(profile.RecordTypeId)) {
                contactProfileIds.add(profile.Id);
            } else if (contactTargetPRT.contains(profile.RecordTypeId)) {
                contactTargetProfilesIds.add(profile.Id);
            }
        }

        if (contactProfileIds.isEmpty()) {
            contactProfileIds = null;
        }
        if (contactTargetProfilesIds.isEmpty()) {
            contactTargetProfilesIds = null;
        }

        if (contactProfileIds != null) {
            Set<ID> achievementIds = new Set<ID>();
            for (Achievement_Set_Item__c item : items) {
                if (contactProfileIds.contains(item.Achievement_Set__c)) {
                    achievementIds.add(item.Achievement__c);
                }
            }
            if (!achievementIds.isEmpty()) {
                achievementIds = AchievementService.getGroupsByMemberIds(achievementIds);
                AchievementService.calculateContactAchievementGroupValues(contactProfileIds, achievementIds);
            }
        }

        AchievementService.calculateContactProfileScores(contactProfileIds, contactTargetProfilesIds);
    }
}