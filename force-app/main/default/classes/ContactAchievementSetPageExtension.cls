/**
 * Contact standard controller extension for the Achievements Set record manipulations.
 * @author Adam Siwek
 */
public with sharing class ContactAchievementSetPageExtension extends AchievementSetPageExtension {

    public ContactAchievementSetPageExtension(ApexPages.StandardController stdCtrl) {
        super(stdCtrl);
        getCategoryFilters();
    }

    protected override SObject getContextRecord(ApexPages.StandardController ctr, Map<String, String> pageParams) {
        Id recordId = System.currentPageReference().getParameters().get('id');
        SObject record = new Contact();
        record.put('Id', recordId);
        return record;
    }

    protected override void loadFirstAchievementSet(SObject scopeRecord, Map<String, String> pageParams) {
        achievementSet = [SELECT Id, Name, RecordTypeId, Contact__c, Career_Path__c, Score_Minimal_Value__c, Number_Of_Achievements__c, Parent_Profile__c, Who__c, AboutWho__c, SelfSurvey__c FROM Achievement_Set__c WHERE Contact__c = :scopeRecord.Id AND RecordTypeId = :AchievementUtils.getAchievementSetContactProfileRecordType().Id AND IsDeleted = false LIMIT 1 ALL ROWS];
    }
}