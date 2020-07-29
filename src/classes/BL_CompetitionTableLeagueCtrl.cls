public with sharing class BL_CompetitionTableLeagueCtrl {

    @AuraEnabled
    public static BL_Competition__c loadCompetitionWithCompetitors(String competitionId) {
        BL_DAO_Competition daoCompetition = new BL_DAO_Competition();
        return daoCompetition.getCompetitionById(competitionId);
    }

    @AuraEnabled
    public static List<BL_Match__c> loadCompetitionMatches(String competitionId, String competitorId) {
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
    public static BL_Competition__c startLeagueNow(String competitionId) {
        BL_Competition__c competition = loadCompetitionWithCompetitors(competitionId);

        if(competition == null || competition.Status__c == BL_Constants.LEAGUE_STATUS_STARTED) {
            throw new AuraHandledException(Label.BL_League_already_started);
        }

        try {
            competition.Start_Date__c = System.now();
            competition.Status__c = BL_Constants.LEAGUE_STATUS_STARTED;
            update competition;
            BL_MatchService.generateMatches(competitionId);
            return competition;
        } catch(DmlException e) {
            for(Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
            throw new AuraHandledException(Label.BL_Cannot_start_league);
        }
    }

    @AuraEnabled
    public static User getCurrentUser() {
        return BL_Utils.getCurrentUser();
    }
}