public without sharing class BL_CreateLeagueController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper() {
        InitDataWrapper initDataWrapper;
        try {
            initDataWrapper = new InitDataWrapper();
            initDataWrapper.populateLeagueRecordTypeDeveloperNameToIdMap();
            initDataWrapper.populateLeagueTeamSizeOptions();
            initDataWrapper.populateLeagueWrapper();
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }
        return initDataWrapper;
    }

    @AuraEnabled
    public static Id saveCompetition(String newLeagueWrapperJson) {
        BL_League__c league = new BL_League__c();
        try {
            LeagueWrapper newLeagueWrapper = (LeagueWrapper) JSON.deserialize(newLeagueWrapperJson, LeagueWrapper.class);

            league.RecordTypeId = BL_League__c.getSObjectType()
                    .getDescribe()
                    .getRecordTypeInfosByDeveloperName()
                    .get(newLeagueWrapper.recordType)
                    .getRecordTypeId();

            league.Name = newLeagueWrapper.name;
            league.TeamSize__c = newLeagueWrapper.teamSize;
            league.Start_Date__c = newLeagueWrapper.startDate;
            league.End_Date__c = newLeagueWrapper.endDate;
            league.Max_Teams__c = newLeagueWrapper.teamsLimit;

            if(newLeagueWrapper.recordType == BL_Constants.LEAGUE_RT_CUP) {
                league.Match_No__c = 1;
            } else {
                league.Match_No__c = newLeagueWrapper.rounds;
            }

            insert league;
        } catch(Exception e) {
            String uiMessage = 'An error occurred during creation of competition: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }
        return league.Id;
    }

    public class InitDataWrapper {
        @AuraEnabled
        public List<OptionWrapper> leagueRecordTypeOptions;
        @AuraEnabled
        public List<OptionWrapper> leagueTeamSizeOptions;
        @AuraEnabled
        public LeagueWrapper leagueWrapper;

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

        public void populateLeagueWrapper() {
            leagueWrapper = new LeagueWrapper();
        }
    }

    public class LeagueWrapper {
        @AuraEnabled
        public String recordType;//
        @AuraEnabled
        public String teamSize;//
        @AuraEnabled
        public String name;//
        @AuraEnabled
        public Datetime startDate;
        @AuraEnabled
        public Datetime endDate;
        @AuraEnabled
        public Integer teamsLimit;
        @AuraEnabled
        public Integer rounds;
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