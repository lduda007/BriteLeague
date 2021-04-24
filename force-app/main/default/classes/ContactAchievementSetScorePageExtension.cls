/**
 * Contact Profile Score standard controller extension for the Achievements Set record manipulations.
 * @author Adam Siwek
 */
public with sharing virtual class ContactAchievementSetScorePageExtension extends AchievementSetPageExtension {

    public ContactAchievementSetScorePageExtension(ApexPages.StandardController stdCtrl) {
        super(stdCtrl);
    }

    protected override void loadFirstAchievementSet(SObject scopeRecord, Map<String, String> pageParams) {
        achievementSet = [SELECT Id, Name, RecordTypeId, Contact__c, Score_Minimal_Value__c, Career_Path__c, Number_Of_Achievements__c, Parent_Profile__c, Who__c, AboutWho__c, SelfSurvey__c FROM Achievement_Set__c WHERE Id = :((Contact_Profile_Score__c)scopeRecord).Contact_Profile__c AND IsDeleted = false LIMIT 1 ALL ROWS];
    }

    protected override void loadSecondAchievementSet(SObject scopeRecord, Map<String, String> pageParams) {
        achievementSetToCmpId = ((Contact_Profile_Score__c)scopeRecord).Achievement_Profile__c;
    }
}