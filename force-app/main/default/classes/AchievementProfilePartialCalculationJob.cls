global class AchievementProfilePartialCalculationJob implements Database.Batchable<sObject> {

    private final String query;
    
    global AchievementProfilePartialCalculationJob(Set<ID> contactProfileIds) {
        query = AchievementService.getAchievementSetsQuery(contactProfileIds, AchievementUtils.getContactProfileRecordTypeIds(), true);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Achievement_Set__c> positionProfiles = AchievementService.getAchievementSets(null, AchievementUtils.getContactTargetProfileRecordTypeIds(), true);
            
        AchievementService.calculateContactProfileScoresWithoutBatch((List<Achievement_Set__c>)scope, positionProfiles);
    }

    global void finish(Database.BatchableContext BC){
    }
}