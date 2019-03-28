public without sharing class BL_CreateLeagueController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper() {
        InitDataWrapper initDataWrapper;
        try {
            initDataWrapper = new InitDataWrapper();
            initDataWrapper.populateLeagueRecordTypeDeveloperNameToIdMap();
            initDataWrapper.populateLeagueTeamSizeOptions();
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }
        return initDataWrapper;
    }

    public class InitDataWrapper {
        @AuraEnabled
        public List<OptionWrapper> leagueRecordTypeOptions;
        @AuraEnabled
        public List<OptionWrapper> leagueTeamSizeOptions;

        public void populateLeagueRecordTypeDeveloperNameToIdMap() {
            leagueRecordTypeOptions = new List<OptionWrapper>();
            BL_BriteLeagueSettings__c briteLeagueSettings = BL_BriteLeagueSettings__c.getInstance();
            Set<String> enabledLeagueRecordTypes = String.isNotBlank(briteLeagueSettings.Enabled_League_Record_Types__c)
                    ? new Set<String>(briteLeagueSettings.Enabled_League_Record_Types__c.split(','))
                    : new Set<String>();

            Map<String, RecordTypeInfo> recordTypeInfoMap = BL_League__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
            for(RecordTypeInfo recordTypeInfo : recordTypeInfoMap.values()) {
                if(enabledLeagueRecordTypes.contains(recordTypeInfo.getDeveloperName())) {
                    leagueRecordTypeOptions.add(new OptionWrapper(recordTypeInfo.getName(), recordTypeInfo.getDeveloperName()));
                }
            }
        }

        public void populateLeagueTeamSizeOptions() {
            leagueTeamSizeOptions = new List<OptionWrapper>{
                    new OptionWrapper('Single Player', 'Single Player'),
                    new OptionWrapper('Two Players', 'Two Players')
            };
        }
    }

    public class OptionWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public OptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}