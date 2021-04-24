public without sharing class BL_LeagueDetailsController {

    @AuraEnabled
    public static BL_Competition__c loadCompetitionWithCompetitors(String competitionId) {
        List<BL_Competition__c> competitions = [
                SELECT
                    Id,
                    Name,
                    Start_Date__c,
                    End_Date__c,
                    Match_No__c,
                    Max_Teams__c,
                    Teams_Joined__c,
                    isPrivate__c,
                    CreatedBy.Name,
                    OwnerId,
                    Status__c,
                    TeamSize__c, (
                        SELECT
                            Id,
                            Team__c,
                            Team__r.Player1__c, Team__r.Player2__c, Team__r.Name,
                            Team__r.Player1__r.LastName, Team__r.Player1__r.Name, Team__r.Player2__r.LastName,
                            Team__r.Player2__r.Name,
                                GamesWon__c, GamesLost__c, GamesDrawn__c, GoalsFor__c, GoalsAgainst__c, GoalsDraw__c, Points__c,
                                Team__r.Player1__r.ImageUrl__c, Team__r.Player2__r.ImageUrl__c
                        FROM Competitors__r
                        ORDER BY Points__c DESC, GoalsDraw__c DESC, GoalsFor__c DESC, GoalsAgainst__c ASC, Team__r.Name ASC
                )
                FROM BL_Competition__c
                WHERE Id = :competitionId
        ];
        return competitions.size() > 0 ? competitions[0] : new BL_Competition__c();
    }

    @AuraEnabled
    public static List<BL_Match__c> loadCompetitionMatches(String competitionId, String competitorId) {
        List<BL_Match__c> matches;
        BL_DAO_Match daoMatch = new BL_DAO_Match();
        if (competitorId == null) {
            matches = daoMatch.getMatchesForCompetition(competitionId);
        } else {
            matches = daoMatch.getMatchesForCompetitionAndCompetitor(competitionId, competitorId);
        }
        return matches;
    }

    @AuraEnabled
    public static BL_Competition__c startLeagueNow(String competitionId) {
        BL_Competition__c competition = loadCompetitionWithCompetitors(competitionId);

        if (competition == null || competition.Status__c == BL_Constants.LEAGUE_STATUS_STARTED) {
            throw new AuraHandledException(Label.BL_League_already_started);
        }

        try {
            competition.Start_Date__c = System.now();
            competition.Status__c = BL_Constants.LEAGUE_STATUS_STARTED;
            update competition;
            BL_MatchService.generateMatches(competitionId);
            return competition;
        } catch (DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
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