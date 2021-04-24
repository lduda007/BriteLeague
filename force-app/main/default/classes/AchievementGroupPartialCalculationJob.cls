global class AchievementGroupPartialCalculationJob implements Database.Batchable<sObject> {

    private final Set<ID> groups;
    private final String query;

    global AchievementGroupPartialCalculationJob(Set<ID> contactProfileIds, Set<ID> groups) {
        this.groups = groups;
        query = AchievementService.getAchievementSetsQuery(contactProfileIds, AchievementUtils.getContactProfileRecordTypeIds(), true);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        AchievementService.calculateContactAchievementGroupValuesWithoutBatch((List<Achievement_Set__c>)scope, groups);
    }

    global void finish(Database.BatchableContext BC){
    }
}