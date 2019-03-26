
public with sharing class BL_SinglePlayerScoreProviderController {
    @AuraEnabled
    public static BL_Match__c getMatchDetails(String matchId) {
        system.debug(matchId);
        List<BL_Match__c> matchDetails = [
                SELECT  Id,isResolved__c,MatchDate__c, Team1__c, Team2__c, Team1__r.Team__r.Player1__r.Name, Team2__r.Team__r.Player1__r.Name, Team1_Score__c,Team2_Score__c, Team1TotalGoalsScored__c, Team2TotalGoalsScored__c,
                        Team1__r.GoalsFor__c,Team1__r.GoalsAgainst__c,Team1__r.GamesWon__c,Team1__r.GamesLost__c,Team1__r.GamesDrawn__c,
                        Team2__r.GoalsFor__c,Team2__r.GoalsAgainst__c,Team2__r.GamesWon__c,Team2__r.GamesLost__c,Team2__r.GamesDrawn__c, Team1Round1Goals__c,
                        Team1Round2Goals__c, Team1Round3Goals__c, Team2Round1Goals__c,Team2Round2Goals__c,Team2Round3Goals__c, Team1__r.Team__r.Player1__r.ImageUrl__c, Team2__r.Team__r.Player1__r.ImageUrl__c
                FROM BL_Match__c
                WHERE Id =: matchId
        ];
        return !matchDetails.isEmpty() ? matchDetails[0] : new BL_Match__c();
    }

    @AuraEnabled
    public static String saveMatchScoreAndUpdateCompetitorsStatistics(BL_Match__c match) {
        match.isResolved__c = true;
        try{
            update match;
            updateCompetitorsStatistics(match);
            return 'SUCCESS';
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
            throw new AuraHandledException('Cannot save match score!');
        }
    }

    private static void updateCompetitorsStatistics(BL_Match__c match){
        Map<Id, BL_Competitor__c> matchCompetitorsMap = new Map<Id, BL_Competitor__c>([
                SELECT Id, GamesLost__c,GamesDrawn__c,GamesWon__c,GoalsAgainst__c,GoalsFor__c, RoundsWon__c, RoundsLost__c
                FROM BL_Competitor__c
                WHERE League__c =: match.League__c AND (Id =: match.Team1__c OR Id =: match.Team2__c)
        ]);
        matchCompetitorsMap.get(match.Team1__c).GamesLost__c += match.Team1_Score__c < match.Team2_Score__c ? 1 : 0;
        matchCompetitorsMap.get(match.Team1__c).GamesDrawn__c += match.Team1_Score__c == match.Team2_Score__c ? 1 : 0;
        matchCompetitorsMap.get(match.Team1__c).GamesWon__c += match.Team1_Score__c > match.Team2_Score__c ? 1 : 0;
        matchCompetitorsMap.get(match.Team1__c).RoundsWon__c += match.Team1_Score__c > match.Team2_Score__c ? 1 : 0;
        matchCompetitorsMap.get(match.Team1__c).RoundsLost__c += match.Team1_Score__c < match.Team2_Score__c ? 1 : 0;
        matchCompetitorsMap.get(match.Team1__c).GoalsFor__c += match.Team1_Score__c;
        matchCompetitorsMap.get(match.Team1__c).GoalsAgainst__c += match.Team2_Score__c;

        matchCompetitorsMap.get(match.Team2__c).GamesLost__c += match.Team2_Score__c < match.Team1_Score__c ? 1 : 0;
        matchCompetitorsMap.get(match.Team2__c).GamesDrawn__c += match.Team1_Score__c == match.Team2_Score__c ? 1 : 0;
        matchCompetitorsMap.get(match.Team2__c).GamesWon__c += match.Team2_Score__c > match.Team1_Score__c ? 1 : 0;
        matchCompetitorsMap.get(match.Team2__c).RoundsWon__c += match.Team2_Score__c > match.Team1_Score__c ? 1 : 0;
        matchCompetitorsMap.get(match.Team2__c).RoundsLost__c += match.Team2_Score__c < match.Team1_Score__c ? 1 : 0;
        matchCompetitorsMap.get(match.Team2__c).GoalsFor__c += match.Team2_Score__c;
        matchCompetitorsMap.get(match.Team2__c).GoalsAgainst__c += match.Team1_Score__c;

        update matchCompetitorsMap.values();
    }
}