global class AchievementGroupCalculationJob implements Database.Batchable<sObject> {

    private final Set<ID> groups;

    global AchievementGroupCalculationJob(Set<ID> groups) {
        this.groups = groups;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(AchievementService.getAchievementSetsQuery(null, AchievementUtils.getContactProfileRecordTypeIds(), true));
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        AchievementService.calculateContactAchievementGroupValuesWithoutBatch((List<Achievement_Set__c>)scope, groups);
    }

    global void finish(Database.BatchableContext BC){
    }
}