public class BL_CompetitionDetailsController {

    @AuraEnabled
    public static DataWrapper getDataWrapper(Id leagueId) {
        DataWrapper wrapper;
        try {
            wrapper = new DataWrapper();

            BL_DAO_League daoLeague = new BL_DAO_League();
            wrapper.league = daoLeague.getLeagueById(leagueId);
            wrapper.settings = new BL_Settings().populateSettingsForLeague(leagueId);
            wrapper.matches = loadLeagueMatches(leagueId, null);
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization of "Battle Royale Details" component';
            BL_Utils.throwAuraHandledException(uiMessage, e);
        }

        return wrapper;
    }

    @AuraEnabled
    public static void startLeague(Id leagueId) {
        try {
            BL_LeagueService.startLeague(leagueId);
        } catch(Exception e) {
            String uiMessage = 'An error occurred during starting of the league';
            BL_Utils.throwAuraHandledException(uiMessage, e);
        }
    }

    private static List<BL_Match__c> loadLeagueMatches(String leagueId, String competitorId) {
        List<BL_Match__c> leagueMatches;
        BL_DAO_Match daoMatch = new BL_DAO_Match();
        if(competitorId == null) {
            leagueMatches = daoMatch.getMatchesForLeague(leagueId);
        } else {
            leagueMatches = daoMatch.getMatchesForLeagueAndCompetitor(leagueId, competitorId);
        }
        return leagueMatches;
    }

    public class DataWrapper {
        @AuraEnabled
        public BL_League__c league;
        @AuraEnabled
        public BL_Settings settings;
        @AuraEnabled
        public List<BL_Match__c> matches;
    }
}