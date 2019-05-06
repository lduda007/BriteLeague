public without sharing class BL_DAO_Match {

    public BL_Match__c getMatchById(Id matchId) {
        List<BL_Match__c> matchList = [
                SELECT id, isResolved__c,MatchDate__c, League__c, League__r.RecordType.DeveloperName, Team1__c, Team1__r.Team__c, Team2__c, Team2__r.Team__c, Team1_Score__c,Team2_Score__c, Team1TotalGoalsScored__c, Team2TotalGoalsScored__c,
                        Team1__r.GoalsFor__c,Team1__r.GoalsAgainst__c,Team1__r.GamesWon__c,Team1__r.GamesLost__c,Team1__r.GamesDrawn__c,
                        Team2__r.GoalsFor__c,Team2__r.GoalsAgainst__c,Team2__r.GamesWon__c,Team2__r.GamesLost__c,Team2__r.GamesDrawn__c, Team1Round1Goals__c,
                        Team1Round2Goals__c, Team1Round3Goals__c, Team2Round1Goals__c,Team2Round2Goals__c,Team2Round3Goals__c
                FROM BL_Match__c
                WHERE id = :matchId
                LIMIT 1
        ];
        return matchList.isEmpty() ? null : matchList[0];
    }
    public List<BL_Match__c> getMatchesForLeague(Id leagueId) {
        return [
                SELECT Id, Name, League__r.RecordType.DeveloperName, League__r.TeamSize__c, Round__c,
                        Team1__r.Team__c, Team2__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__r.Name, Team1_Score__c, Team2_Score__c,
                        Team1__r.Team__r.Player1__r.ImageUrl__c, Team1__r.Team__r.Player2__r.ImageUrl__c, Team2__r.Team__r.Player1__r.ImageUrl__c,
                        Team2__r.Team__r.Player2__r.ImageUrl__c, Team1__r.Team__r.Player1__c, Team1__r.Team__r.Player2__c, Team2__r.Team__r.Player1__c,
                        Team2__r.Team__r.Player2__c, Team1__r.Team__r.Player1__r.Name, Team1__r.Team__r.Player2__r.Name, Team2__r.Team__r.Player1__r.Name,
                        Team2__r.Team__r.Player2__r.Name, Team1Round1Goals__c, Team1Round2Goals__c, Team1Round3Goals__c, Team2Round1Goals__c,Team2Round2Goals__c,
                        Team2Round3Goals__c
                FROM BL_Match__c
                WHERE League__c = :leagueId
                ORDER BY Round__c ASC, Team1__r.Team__r.Name ASC, Team2__r.Team__r.Name ASC
        ];
    }
    public List<BL_Match__c> getMatchesForLeagueAndCompetitor(Id leagueId, Id competitorId) {
        return [
                SELECT Id, Name, League__r.RecordType.DeveloperName, League__r.TeamSize__c, Round__c,
                        Team1__r.Team__c, Team2__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__r.Name, Team1_Score__c, Team2_Score__c,
                        Team1__r.Team__r.Player1__r.ImageUrl__c, Team1__r.Team__r.Player2__r.ImageUrl__c, Team2__r.Team__r.Player1__r.ImageUrl__c,
                        Team2__r.Team__r.Player2__r.ImageUrl__c, Team1__r.Team__r.Player1__c, Team1__r.Team__r.Player2__c, Team2__r.Team__r.Player1__c,
                        Team2__r.Team__r.Player2__c, Team1__r.Team__r.Player1__r.Name, Team1__r.Team__r.Player2__r.Name, Team2__r.Team__r.Player1__r.Name,
                        Team2__r.Team__r.Player2__r.Name, Team1Round1Goals__c, Team1Round2Goals__c, Team1Round3Goals__c, Team2Round1Goals__c,Team2Round2Goals__c,
                        Team2Round3Goals__c
                FROM BL_Match__c
                WHERE League__c = :leagueId AND (Team1__c = :competitorId OR Team2__c = :competitorId)
                ORDER BY Round__c
        ];
    }
}