global class AchievementProfileCalcuationJob implements Database.Batchable<sObject> {

    global AchievementProfileCalcuationJob() {
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(AchievementService.getAchievementSetsQuery(null, AchievementUtils.getContactProfileRecordTypeIds(), true));
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Achievement_Set__c> positionProfiles = AchievementService.getAchievementSets(null, AchievementUtils.getContactTargetProfileRecordTypeIds(), true);

        AchievementService.calculateContactProfileScoresWithoutBatch((List<Achievement_Set__c>)scope, positionProfiles);
    }

    global void finish(Database.BatchableContext BC){
    }
}