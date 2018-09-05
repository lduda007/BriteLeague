
public with sharing class BL_CupEndEmailContentController {
    public Id recordId {get; set {initializeCompetitorDetails(value);}}
    public String competitionUrl {get; set;}
    public Boolean isWinner {get; set;}
    public String winnerTeamName {get; set;}
    public BL_Competitor__c competitor {get; set;}
    public List<BL_Competitor__c> leagueCompetitors {get; set;}

    private void initializeCompetitorDetails(String competitorId){
        system.debug(competitorId);
        List<BL_Competitor__c> competitors = [
                SELECT Id, Team__r.Name, GoalsFor__c, GoalsAgainst__c, Points__c, League__r.Name, League__c, Team__r.Player1__c, Team__r.Player2__c, League__r.TeamSize__c
                FROM BL_Competitor__c
                WHERE Id =: competitorId
        ];
        if(!competitors.isEmpty()){
            competitor = competitors[0];
            competitionUrl = BL_Utils.getBLCommunityUrl('League Page');

            List<BL_Match__c> finalMatch = [
                    SELECT Id, Winner__c
                    FROM BL_Match__c
                    WHERE CupStage__c = 1 AND League__c =: competitor.League__c
            ];
            if(!finalMatch.isEmpty()){
                List<BL_Competitor__c> winnerTeam = [
                        SELECT Id, Team__r.Player1__c, Team__r.Player2__c, Team__r.Name
                        FROM BL_Competitor__c
                        WHERE Id =: finalMatch[0].Winner__c
                ];

                if(!winnerTeam.isEmpty()){
                    winnerTeamName = winnerTeam[0].Team__r.Name;
                    if(winnerTeam[0].Team__r.Player2__c == null && competitor.Team__r.Player2__c == null){
                        isWinner =  winnerTeam[0].Team__r.Player1__c == competitor.Team__r.Player1__c ? true : false;
                    }else{
                        isWinner =  winnerTeam[0].Team__r.Player1__c == competitor.Team__r.Player1__c ||
                                winnerTeam[0].Team__r.Player1__c == competitor.Team__r.Player2__c ||
                                winnerTeam[0].Team__r.Player2__c == competitor.Team__r.Player1__c ||
                                winnerTeam[0].Team__r.Player2__c == competitor.Team__r.Player2__c
                                ? true : false;
                    }
                }
            }
        }
    }
}