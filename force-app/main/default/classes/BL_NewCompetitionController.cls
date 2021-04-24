public without sharing class BL_NewCompetitionController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper() {
        InitDataWrapper initDataWrapper;
        try {
            initDataWrapper = new InitDataWrapper();
            initDataWrapper.populateLeagueRecordTypeDeveloperNameToIdMap();
            initDataWrapper.populateLeagueTeamSizeOptions();
            initDataWrapper.populateCompetitionWrapper();
        } catch (Exception e) {
            String uiMessage = 'An error occurred during initialization of "BL_NewCompetition" component: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }
        return initDataWrapper;
    }

    @AuraEnabled
    public static Id saveCompetition(String newCompetitionWrapperJson) {
        BL_Competition__c competition = new BL_Competition__c();
        try {
            CompetitionWrapper newCompetitionWrapper = (CompetitionWrapper) JSON.deserialize(newCompetitionWrapperJson, CompetitionWrapper.class);

            competition.RecordTypeId = BL_Competition__c.getSObjectType()
                    .getDescribe()
                    .getRecordTypeInfosByDeveloperName()
                    .get(newCompetitionWrapper.recordType)
                    .getRecordTypeId();

            competition.Name = newCompetitionWrapper.name;
            competition.TeamSize__c = newCompetitionWrapper.teamSize;
            competition.Start_Date__c = newCompetitionWrapper.startDate;
            competition.End_Date__c = newCompetitionWrapper.endDate;
            competition.Max_Teams__c = newCompetitionWrapper.teamsLimit;

            if (newCompetitionWrapper.recordType == BL_Constants.LEAGUE_RT_CUP) {
                competition.Match_No__c = 1;
            } else {
                competition.Match_No__c = newCompetitionWrapper.rounds;
            }

            insert competition;
        } catch (Exception e) {
            String uiMessage = 'An error occurred during creation of competition: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }
        return competition.Id;
    }

    public class InitDataWrapper {
        @AuraEnabled
        public List<OptionWrapper> competitionRecordTypeOptions;
        @AuraEnabled
        public List<OptionWrapper> competitionTeamSizeOptions;
        @AuraEnabled
        public CompetitionWrapper competitionWrapper;

        public void populateLeagueRecordTypeDeveloperNameToIdMap() {
            competitionRecordTypeOptions = new List<OptionWrapper>();
            BL_BriteLeagueSettings__c briteLeagueSettings = BL_BriteLeagueSettings__c.getInstance();
            Set<String> enabledLeagueRecordTypes = String.isNotBlank(briteLeagueSettings.Enabled_League_Record_Types__c)
                    ? new Set<String>(briteLeagueSettings.Enabled_League_Record_Types__c.split(','))
                    : new Set<String>();

            Map<String, RecordTypeInfo> recordTypeInfoMap = BL_Competition__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
            for (RecordTypeInfo recordTypeInfo : recordTypeInfoMap.values()) {
                if (enabledLeagueRecordTypes.contains(recordTypeInfo.getDeveloperName())) {
                    competitionRecordTypeOptions.add(new OptionWrapper(recordTypeInfo.getName(), recordTypeInfo.getDeveloperName()));
                }
            }
        }

        public void populateLeagueTeamSizeOptions() {
            competitionTeamSizeOptions = new List<OptionWrapper>{
                    new OptionWrapper('Single Player', 'Single Player'),
                    new OptionWrapper('Two Players', 'Two Players')
            };
        }

        public void populateCompetitionWrapper() {
            competitionWrapper = new CompetitionWrapper();
        }
    }

    public class CompetitionWrapper {
        @AuraEnabled
        public String recordType;
        @AuraEnabled
        public String teamSize;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Datetime startDate = Datetime.now();
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