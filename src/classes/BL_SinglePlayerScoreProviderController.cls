public with sharing class BL_SinglePlayerScoreProviderController {
    @AuraEnabled
    public static BL_Match__c getMatchDetails(String matchId) {
        BL_Match__c match;
        try {
            List<BL_Match__c> matchDetails = [
                    SELECT Id, League__c, isResolved__c,MatchDate__c, Team1__c, Team2__c, Team1__r.Team__r.Player1__r.Name, Team2__r.Team__r.Player1__r.Name, Team1_Score__c,Team2_Score__c, Team1TotalGoalsScored__c, Team2TotalGoalsScored__c,
                            Team1__r.GoalsFor__c,Team1__r.GoalsAgainst__c,Team1__r.GamesWon__c,Team1__r.GamesLost__c,Team1__r.GamesDrawn__c,
                            Team2__r.GoalsFor__c,Team2__r.GoalsAgainst__c,Team2__r.GamesWon__c,Team2__r.GamesLost__c,Team2__r.GamesDrawn__c, Team1Round1Goals__c,
                            Team1Round2Goals__c, Team1Round3Goals__c, Team2Round1Goals__c,Team2Round2Goals__c,Team2Round3Goals__c, Team1__r.Team__r.Player1__r.ImageUrl__c, Team2__r.Team__r.Player1__r.ImageUrl__c
                    FROM BL_Match__c
                    WHERE Id = :matchId
            ];
            match = !matchDetails.isEmpty() ? matchDetails[0] : new BL_Match__c();
        } catch(Exception e) {
            BL_Utils.throwAuraHandledException('', e);
        }

        return match;
    }

    @AuraEnabled
    public static void saveMatchScoreAndUpdateCompetitorsStatistics(BL_Match__c match) {
        try {
            match.isResolved__c = true;
            match.MatchDate__c = System.now();
            update match;
            updateCompetitorsStatistics(match);
        } catch(Exception e) {
            BL_Utils.throwAuraHandledException('saveMatchScoreAndUpdateCompetitorsStatistics()', e);
        }
    }

    private static void updateCompetitorsStatistics(BL_Match__c match){
        Map<Id, BL_Competitor__c> matchCompetitorsMap = new Map<Id, BL_Competitor__c>([
                SELECT Id, GamesLost__c,GamesDrawn__c,GamesWon__c,GoalsAgainst__c,GoalsFor__c, RoundsWon__c, RoundsLost__c
                FROM BL_Competitor__c
                WHERE League__c =: match.League__c
                AND (
                        Id =: match.Team1__c
                        OR Id =: match.Team2__c
                )
        ]);
        BL_Competitor__c competitor1 = matchCompetitorsMap.get(match.Team1__c);
        BL_Competitor__c competitor2 = matchCompetitorsMap.get(match.Team2__c);

        competitor1.GamesLost__c += match.Team1_Score__c < match.Team2_Score__c ? 1 : 0;
        competitor1.GamesDrawn__c += match.Team1_Score__c == match.Team2_Score__c ? 1 : 0;
        competitor1.GamesWon__c += match.Team1_Score__c > match.Team2_Score__c ? 1 : 0;
        competitor1.RoundsWon__c += match.Team1_Score__c > match.Team2_Score__c ? 1 : 0;
        competitor1.RoundsLost__c += match.Team1_Score__c < match.Team2_Score__c ? 1 : 0;
        competitor1.GoalsFor__c += match.Team1_Score__c;
        competitor1.GoalsAgainst__c += match.Team2_Score__c;

        competitor2.GamesLost__c += match.Team2_Score__c < match.Team1_Score__c ? 1 : 0;
        competitor2.GamesDrawn__c += match.Team1_Score__c == match.Team2_Score__c ? 1 : 0;
        competitor2.GamesWon__c += match.Team2_Score__c > match.Team1_Score__c ? 1 : 0;
        competitor2.RoundsWon__c += match.Team2_Score__c > match.Team1_Score__c ? 1 : 0;
        competitor2.RoundsLost__c += match.Team2_Score__c < match.Team1_Score__c ? 1 : 0;
        competitor2.GoalsFor__c += match.Team2_Score__c;
        competitor2.GoalsAgainst__c += match.Team1_Score__c;

        update new List<BL_Competitor__c> {
                competitor1, competitor2
        };
    }
}