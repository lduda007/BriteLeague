public class BL_BattleRoyaleTableController {

    @AuraEnabled
    public static DataWrapper getDataWrapper(Id leagueId) {
        DataWrapper wrapper;
        try {
            wrapper = new DataWrapper();

            BL_DAO_Team daoTeam = new BL_DAO_Team();
            wrapper.battleRoyaleTeams = daoTeam.getTeamsByLeagueId(leagueId);
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization of "Battle Royale Table" component';
            BL_Utils.throwAuraHandledException(uiMessage, e);
        }

        return wrapper;
    }

    public class DataWrapper {
        @AuraEnabled
        public List<BL_Team__c> battleRoyaleTeams;
    }
}