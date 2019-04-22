public class BL_BattleRoyaleDetailsController {

    @AuraEnabled
    public static DataWrapper getDataWrapper(Id leagueId) {
        DataWrapper wrapper;
        try {
            wrapper = new DataWrapper();

            BL_DAO_League daoLeague = new BL_DAO_League();
            wrapper.league = daoLeague.getLeagueById(leagueId);

            wrapper.userSettings = new BL_UserSettings()
                    .populateSettingsForLeague(leagueId);
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

    public class DataWrapper {
        @AuraEnabled
        public BL_League__c league;
        @AuraEnabled
        public BL_UserSettings userSettings;
    }
}