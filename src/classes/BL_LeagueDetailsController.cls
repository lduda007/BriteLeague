public with sharing class BL_LeagueDetailsController {
    @AuraEnabled
    public static BL_League__c loadLeagueWithCompetitors(String leagueId) {
        List<BL_League__c> leagueToReturn = [
            SELECT Id, Name, Start_Date__c, End_Date__c, Match_No__c, Max_Teams__c,Teams_Joined__c, isPrivate__c, CreatedBy.Name, OwnerId, Status__c,
                (SELECT Id, Team__c, Team__r.Player1__c, Team__r.Player2__c, Team__r.Name, Team__r.Player1__r.LastName, Team__r.Player2__r.LastName, GamesWon__c, GamesLost__c, GamesDrawn__c, GoalsFor__c, GoalsAgainst__c, GoalsDraw__c, Points__c
                    FROM Competitors__r
                    ORDER BY Points__c DESC, GoalsDraw__c DESC, GoalsFor__c DESC, GoalsAgainst__c ASC)
            FROM BL_League__c
            WHERE Id =: leagueId
        ];
        return leagueToReturn.size() > 0 ? leagueToReturn[0] : new BL_League__c();
    }

    @AuraEnabled
    public static List<BL_Match__c> loadLeagueMatches(String leagueId, String competitorId) {
        List<BL_Match__c> leagueMatches;
        if(competitorId == null){
            leagueMatches = [
                    SELECT Id, Name, Team1__r.Team__c, Team2__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__r.Name, Team1_Score__c, Team2_Score__c,
                           Team1__r.Team__r.Player1__c, Team1__r.Team__r.Player2__c, Team2__r.Team__r.Player1__c, Team2__r.Team__r.Player2__c, Round__c, DrawRound__c,
                           Team1__r.Team__r.Player1__r.Name, Team1__r.Team__r.Player2__r.Name, Team2__r.Team__r.Player1__r.Name, Team2__r.Team__r.Player2__r.Name, Team1Round1Goals__c, Team1Round2Goals__c, Team1Round3Goals__c, Team2Round1Goals__c,Team2Round2Goals__c,Team2Round3Goals__c, League__r.isCup__c
                    FROM BL_Match__c
                    WHERE League__c =: leagueId
                    ORDER BY Round__c, DrawRound__c
            ];
        }else{
            leagueMatches = [
                    SELECT Id, Name, Team1__r.Team__c, Team2__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__r.Name, Team1_Score__c, Team2_Score__c,
                           Team1__r.Team__r.Player1__c, Team1__r.Team__r.Player2__c, Team2__r.Team__r.Player1__c, Team2__r.Team__r.Player2__c, Round__c, DrawRound__c
                    FROM BL_Match__c
                    WHERE League__c =: leagueId AND (Team1__c =: competitorId OR Team2__c =: competitorId)
                    ORDER BY Round__c, DrawRound__c
            ];
        }
        return leagueMatches;
    }

    @AuraEnabled
    public static BL_League__c startLeagueNow(String leagueId) {
        BL_League__c league = loadLeagueWithCompetitors(leagueId);

        if(league == null || league.Status__c == 'Started'){
            throw new AuraHandledException(Label.BL_League_already_started);
        }
        try{
            league.Start_Date__c = Date.today();
            league.Status__c = 'Started';
            update league;
            BL_LeagueMatchesService.generateMatchesAfterLeagueStarted(leagueId);
            return league;
        }catch (DmlException e){
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