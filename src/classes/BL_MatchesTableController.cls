public class BL_MatchesTableController {

    @AuraEnabled
    public static List<BL_Match__c> loadLeagueMatches(String leagueId, String competitorId) {
        List<BL_Match__c> leagueMatches;
        BL_DAO_Match daoMatch = new BL_DAO_Match();

        if(competitorId == null) {
            leagueMatches = daoMatch.getMatchesForLeague(leagueId);
        } else {
            leagueMatches = daoMatch.getMatchesForLeagueAndCompetitor(leagueId, competitorId);
        }

        return leagueMatches;
    }

    @AuraEnabled
    public static User getCurrentUser() {
        return BL_Utils.getCurrentUser();
    }
}