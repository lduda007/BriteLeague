public with sharing class BL_Utils {
    private static User CURRENT_USER = getCurrentUser();

    public static User getCurrentUser() {
        if(CURRENT_USER == null || CURRENT_USER.Id != UserInfo.getUserId()){
            CURRENT_USER = [SELECT Id, ContactId, CreatedDate FROM User WHERE Id = :UserInfo.getUserId()];
        }
        return CURRENT_USER;
    }

    public static String getBLCommunitySettings(String field){
        BL_CommunitySettings__c communitySettings = BL_CommunitySettings__c.getInstance('BriteLeagueSettings');
        return (String)communitySettings.get(field);
    }

    public static String getBLCommunityUrl(String instance){
        BL_BriteLeagueUrls__c communityUrl = BL_BriteLeagueUrls__c.getInstance(instance);
        return (String)communityUrl.get('Url__c');
    }

    public static List<BL_Competitor__c> getLeagueCompetitors(String leagueId){
        List<BL_Competitor__c> competitors = [
            SELECT Id, Team__c, Team__r.Player1__c, Team__r.Player2__c, Points__c
            FROM BL_Competitor__c
            WHERE League__c =: leagueId
            ORDER BY Points__c DESC
        ];
        return competitors;
    }

    public static void throwAuraHandledException(String message) {
        throwAuraHandledException(message, message);
    }

    public static void throwAuraHandledException(String uiMessage, String apexMessage) {
        AuraHandledException auraException = new AuraHandledException(uiMessage);
        auraException.setMessage(apexMessage);
        throw auraException;
    }

    public static Id getRecordTypeIdByDeveloperName(String objectAPIName, String recordTypeDeveloperName) {
        SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
        if(objectType != null) {
            Schema.RecordTypeInfo recordTypeInfo = objectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName);
            return recordTypeInfo != null ? recordTypeInfo.getRecordTypeId() : null;
        }
        return null;
    }

    public without sharing class UnsecureClass{
        public void deleteNotOwnedRecord(SObject record){
            try{
                delete record;
            }catch (DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug(e.getDmlMessage(i));
                }
            }
        }
    }
}