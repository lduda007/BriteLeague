public class BL_CompetitionDetailsController {

    @AuraEnabled
    public static DataWrapper getDataWrapper(Id competitionId) {
        DataWrapper wrapper;
        try {
            wrapper = new DataWrapper();
            wrapper.competition = new BL_DAO_Competition().getCompetitionById(competitionId);
            wrapper.settings = new BL_Settings().populateSettingsForCompetition(competitionId);
            wrapper.matches = new BL_DAO_Match().getMatchesForCompetition(competitionId);
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization of "BL_CompetitionDetails" component';
            BL_Utils.throwAuraHandledException(uiMessage, e);
        }

        return wrapper;
    }

    @AuraEnabled
    public static void startLeague(Id competitionId) {
        try {
            BL_CompetitionService.startCompetition(competitionId);
        } catch(Exception e) {
            String uiMessage = 'An error occurred during starting of the league';
            BL_Utils.throwAuraHandledException(uiMessage, e);
        }
    }

    public class DataWrapper {
        @AuraEnabled
        public BL_Competition__c competition;
        @AuraEnabled
        public BL_Settings settings;
        @AuraEnabled
        public List<BL_Match__c> matches;
    }
}