
public with sharing class BL_LeagueDetailsController {
    @AuraEnabled
    public static BL_League__c loadLeagueWithCompetitors(String leagueId) {
        system.debug(leagueId);
        List<BL_League__c> leagueToReturn = [
            SELECT Id, Name, Start_Date__c, End_Date__c, Match_No__c, Max_Teams__c,Teams_Joined__c, isPrivate__c, CreatedBy.Name,
                (SELECT Id, Team__c, Team__r.Name, Team__r.Player1__r.LastName, Team__r.Player2__r.LastName, GamesWon__c, GamesLost__c, GamesDrawn__c, GoalsFor__c, GoalsAgainst__c, Points__c FROM Competitors__r)
            FROM BL_League__c
            WHERE Id =: leagueId
        ];
        return leagueToReturn.size() > 0 ? leagueToReturn[0] : new BL_League__c();
    }

    @AuraEnabled
    public static List<BL_Match__c> loadLeagueMatches(String leagueId, String competitorId) {
        system.debug('m '+leagueId);
        List<BL_Match__c> leagueMatches;
        if(competitorId == null){
            leagueMatches = [
                    SELECT Id, Name, Team1__r.Team__c, Team2__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__r.Name
                    FROM BL_Match__c
                    WHERE League__c =: leagueId
            ];
        }else{
            leagueMatches = [
                    SELECT Id, Name, Team1__r.Team__c, Team2__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__r.Name
                    FROM BL_Match__c
                    WHERE League__c =: leagueId AND (Team1__c =: competitorId OR Team2__c =: competitorId)
            ];
        }

        return leagueMatches;
    }

    @AuraEnabled
    public static BL_League__c startLeagueNow(String leagueId) {
        BL_League__c league = loadLeagueWithCompetitors(leagueId);
        if(league != null || league.Start_Date__c <= Date.today()){
            throw new AuraHandledException('League already started');
        }
        try{
            league.Start_Date__c = Date.today();
            update league;
            BL_LeagueMatchesService.generateMatchesAfterLeagueStarted(leagueId);
            return league;
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
            throw new AuraHandledException('Cannot start league');
        }
    }
}