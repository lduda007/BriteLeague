public with sharing class BL_LeaguesListViewController {
    @AuraEnabled
    public static void insertCompetitor(BL_Competitor__c competitor) {
        if (checkLeagueCompetitors(competitor.League__c)) {
            insert competitor;
        } else {
            throw new AuraHandledException(Label.BL_League_Full);
        }
    }

    private static List<String> getPlayerLeaguesIds() {
        String playerId = BL_Utils.getCurrentUser().ContactId;
        List<BL_Competitor__c> comps = [
                SELECT Id, League__c
                FROM BL_Competitor__c
                WHERE Team__r.Player1__c = :playerId OR Team__r.Player2__c = :playerId
        ];
        List<Id> excLeagues = new List<Id>();
        for (BL_Competitor__c bl_competitor : comps) {
            excLeagues.add(bl_competitor.League__c);
        }
        return excLeagues;
    }

    @AuraEnabled
    public static List<BL_League__c> getLeagues() {
        List<BL_League__c> leagues = new List<BL_League__c>();
        for (BL_League__c league : [
                SELECT Name, Max_Teams__c, Teams_Joined__c, Start_Date__c, End_Date__c, isCup__c
                FROM BL_League__c
                WHERE (Status__c = 'Assembling Teams' AND Start_Date__c >= :System.today())
                AND Id NOT IN :getPlayerLeaguesIds()
        ]) {
            if (league.Max_Teams__c > league.Teams_Joined__c) {
                leagues.add(league);
            }
        }
        return leagues;
    }

    @AuraEnabled
    public static List<BL_League__c> getMyLeagues() {
        List<BL_League__c> leagues = new List<BL_League__c>();
        for (BL_League__c league : [
                SELECT Name, Max_Teams__c, Teams_Joined__c, Start_Date__c, End_Date__c, isCup__c
                FROM BL_League__c
                WHERE Id IN :getPlayerLeaguesIds()
        ]) {
            leagues.add(league);
        }
        return leagues;
    }


    @AuraEnabled
    public static List<DTO_Team> getPlayerTeams(String leagueId) {
        Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
        List<BL_Team__c> teams = [
                SELECT Id, Name, Player1__r.Name, Player2__r.Name, IsActive__c
                FROM BL_Team__c
                WHERE IsActive__c = true AND
                (Player1__c = :currentPlayer OR
                Player2__c = :currentPlayer)
        ];
        List<DTO_Team> dtoList = new List<DTO_Team>();
        for (BL_Team__c team : teams) {
            DTO_Team t = new DTO_Team();
            t.recordId = team.Id;
            t.name = team.Name;
            t.isActive = team.IsActive__c;
            if (team.Player1__c != currentPlayer) {
                t.secondPlayerName = team.Player1__r.Name;
                t.secondPlayerId = team.Player1__c;
            } else if (team.Player2__c != currentPlayer) {
                t.secondPlayerName = team.Player2__r.Name;
                t.secondPlayerId = team.Player2__c;
            }
            dtoList.add(t);
        }
        return dtoList;
    }

    private static Boolean checkLeagueCompetitors(String leagueId) {
        String playerId = BL_Utils.getCurrentUser().ContactId;
        BL_League__c league = [
                SELECT Max_Teams__c, (SELECT Id, Team__r.Player1__c, Team__r.Player2__c FROM Competitors__r)
                FROM BL_League__c
                WHERE Id = :leagueId
        ];
        for (BL_Competitor__c comp : league.Competitors__r) {
            if (comp.Team__r.Player1__c == playerId || comp.Team__r.Player2__c == playerId) {
                return false;
            } else return true;
        }
        if (league.Max_Teams__c <= league.Competitors__r.size()) {
            return false;
        } else {
            return true;
        }
    }


    public class DTO_Team {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public Integer won { get; set; }
        @AuraEnabled public Integer lost { get; set; }
        @AuraEnabled public String secondPlayerName { get; set; }
        @AuraEnabled public String secondPlayerId { get; set; }
        @AuraEnabled public Integer teamsNumber { get; set; }
        @AuraEnabled public Boolean isActive { get; set; }
        @AuraEnabled public Boolean canDelete { get; set; }
    }
}