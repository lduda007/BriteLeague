public class BL_MatchesTableController {

    @AuraEnabled
    public static List<BL_Match__c> getCompetitionMatches(String competitionId, String competitorId) {
        List<BL_Match__c> matches;
        BL_DAO_Match daoMatch = new BL_DAO_Match();

        if(competitorId == null) {
            matches = daoMatch.getMatchesForCompetition(competitionId);
        } else {
            matches = daoMatch.getMatchesForCompetitionAndCompetitor(competitionId, competitorId);
        }

        return matches;
    }

    @AuraEnabled
    public static User getCurrentUser() {
        return BL_Utils.getCurrentUser();
    }
}