public without sharing class BL_DAO_Match {
    public List<BL_Match__c> getMatchesForLeague(Id leagueId) {
        return [
                SELECT Id, Name, League__r.RecordType.DeveloperName, League__r.TeamSize__c, Round__c, DrawRound__c,
                        Team1__r.Team__c, Team2__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__r.Name, Team1_Score__c, Team2_Score__c,
                        Team1__r.Team__r.Player1__r.ImageUrl__c, Team1__r.Team__r.Player2__r.ImageUrl__c, Team2__r.Team__r.Player1__r.ImageUrl__c,
                        Team2__r.Team__r.Player2__r.ImageUrl__c, Team1__r.Team__r.Player1__c, Team1__r.Team__r.Player2__c, Team2__r.Team__r.Player1__c,
                        Team2__r.Team__r.Player2__c, Team1__r.Team__r.Player1__r.Name, Team1__r.Team__r.Player2__r.Name, Team2__r.Team__r.Player1__r.Name,
                        Team2__r.Team__r.Player2__r.Name, Team1Round1Goals__c, Team1Round2Goals__c, Team1Round3Goals__c, Team2Round1Goals__c,Team2Round2Goals__c,
                        Team2Round3Goals__c
                FROM BL_Match__c
                WHERE League__c =: leagueId
                ORDER BY DrawRound__c, Round__c
        ];
    }
    public List<BL_Match__c> getMatchesForLeagueAndCompetitor(Id leagueId, Id competitorId) {
        return [
                SELECT Id, Name, League__r.RecordType.DeveloperName, League__r.TeamSize__c, Round__c, DrawRound__c,
                        Team1__r.Team__c, Team2__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__r.Name, Team1_Score__c, Team2_Score__c,
                        Team1__r.Team__r.Player1__r.ImageUrl__c, Team1__r.Team__r.Player2__r.ImageUrl__c, Team2__r.Team__r.Player1__r.ImageUrl__c,
                        Team2__r.Team__r.Player2__r.ImageUrl__c, Team1__r.Team__r.Player1__c, Team1__r.Team__r.Player2__c, Team2__r.Team__r.Player1__c,
                        Team2__r.Team__r.Player2__c, Team1__r.Team__r.Player1__r.Name, Team1__r.Team__r.Player2__r.Name, Team2__r.Team__r.Player1__r.Name,
                        Team2__r.Team__r.Player2__r.Name, Team1Round1Goals__c, Team1Round2Goals__c, Team1Round3Goals__c, Team2Round1Goals__c,Team2Round2Goals__c,
                        Team2Round3Goals__c
                FROM BL_Match__c
                WHERE League__c =: leagueId AND (Team1__c =: competitorId OR Team2__c =: competitorId)
                ORDER BY DrawRound__c, Round__c
        ];
    }
}