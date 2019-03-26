public without sharing class BL_CreateLeagueController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper() {
        InitDataWrapper initDataWrapper;
        try {
            initDataWrapper = new InitDataWrapper();
            initDataWrapper.populateLeagueRecordTypeDeveloperNameToIdMap();
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }
        return initDataWrapper;
    }

    public class InitDataWrapper {
        @AuraEnabled
        public Map<String, Id> leagueRecordTypeDeveloperNameToId = new Map<String, Id>();

        public void populateLeagueRecordTypeDeveloperNameToIdMap() {
            Map<String, RecordTypeInfo> recordTypeInfoMap = BL_League__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
            for(RecordTypeInfo recordTypeInfo : recordTypeInfoMap.values()) {
                leagueRecordTypeDeveloperNameToId.put(recordTypeInfo.getDeveloperName(), recordTypeInfo.getRecordTypeId());
            }
        }
    }
}