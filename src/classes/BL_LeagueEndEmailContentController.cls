
public with sharing class BL_LeagueEndEmailContentController {
    public Id recordId {get; set {initializeCompetitorDetails(value);}}
    public String competitionUrl {get; set;}
    public Integer positionInLeague {get; set;}
    public String winnerTeamName {get; set;}
    public BL_Competitor__c competitor {get; set;}
    public List<BL_Competitor__c> leagueCompetitors {get; set;}

    private void initializeCompetitorDetails(String competitorId){
        system.debug(competitorId);
        List<BL_Competitor__c> competitors = [
            SELECT Id, Team__r.Name, GoalsFor__c, GoalsAgainst__c, Points__c, League__r.Name, League__c
            FROM BL_Competitor__c
            WHERE Id =: competitorId
        ];
        if(!competitors.isEmpty()){
            competitor = competitors[0];
            competitionUrl = BL_Utils.getBLCommunityUrl('League Page');

            Map<Id, BL_Competitor__c> competitorsMap = new Map<Id, BL_Competitor__c>([
                SELECT Id, Team__r.Name, Team__r.Player1__r.Name, Team__r.Player2__r.Name, GamesWon__c, GamesLost__c, GamesDrawn__c, GoalsFor__c, GoalsAgainst__c, GoalsDraw__c, Points__c
                FROM BL_Competitor__c
                WHERE League__c =: competitor.League__c
                ORDER BY Points__c DESC, GoalsDraw__c DESC, GoalsFor__c DESC, GoalsAgainst__c ASC
            ]);

            leagueCompetitors = competitorsMap.values();
            Integer index = 0;
            for (BL_Competitor__c cmp : [
                    SELECT Id, Team__r.Name
                    FROM BL_Competitor__c
                    WHERE League__c =: competitor.League__c
                    ORDER BY Points__c DESC
            ]) {
                if (index == 0) {
                    winnerTeamName = cmp.Team__r.Name;
                }
                if (cmp.Id == competitorId) {
                    positionInLeague = index + 1;
                    break;
                }
                index++;
            }
        }
    }
}