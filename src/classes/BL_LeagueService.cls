public class BL_LeagueService {

    public static void startLeague(Id leagueId) {
        BL_DAO_League daoLeague = new BL_DAO_League();
        BL_League__c league = daoLeague.getLeagueById(leagueId);

        if(league == null || league.Status__c == BL_Constants.LEAGUE_STATUS_STARTED) {
            throw new AuraHandledException(Label.BL_League_already_started);
        }

        league.Start_Date__c = System.now();
        league.Status__c = BL_Constants.LEAGUE_STATUS_STARTED;
        update league;

        BL_LeagueMatchesService.generateMatchesAfterLeagueStarted(leagueId);
    }
}