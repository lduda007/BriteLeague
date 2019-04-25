public with sharing class BL_LeaguesListViewController {
    @AuraEnabled
    public static void insertCompetitor(BL_Competitor__c competitor) {
        List<BL_Competitor__c> competitorsToInsert = new List<BL_Competitor__c>();

        if(checkLeagueCompetitors(competitor.League__c, competitor.Team__c)) {
            competitorsToInsert.add(competitor);

            BL_DAO_Team daoTeam = new BL_DAO_Team();
            BL_Team__c team = daoTeam.getTeamById(competitor.Team__c);

            if(team.RecordType.DeveloperName == BL_Constants.TEAM_RT_BATTLE_ROYALE) {
                for(BL_Team__c subTeam : daoTeam.getTeamsByParentTeamId(competitor.Team__c)) {
                    BL_Competitor__c subCompetitor = new BL_Competitor__c(
                            Team__c = subTeam.Id,
                            League__c = competitor.League__c
                    );

                    competitorsToInsert.add(subCompetitor);
                }
            }

            insert competitorsToInsert;
        } else {
            throw new AuraHandledException(Label.BL_League_Full);
        }
    }

    private static List<String> getPlayerLeaguesIds() {
        String playerId = BL_Utils.getCurrentUser().ContactId;
        List<BL_Competitor__c> comps = [
                SELECT Id, League__c
                FROM BL_Competitor__c
                WHERE Team__r.Player1__c = :playerId
                OR Team__r.Player2__c = :playerId
        ];
        List<Id> excLeagues = new List<Id>();
        List<BL_Competitor__c> parentTeamsCompetitors = [
                SELECT League__c
                FROM BL_Competitor__c
                WHERE Team__c IN (
                        SELECT Team__c
                        FROM BL_TeamMember__c
                        WHERE Member__r.Player1__c = :playerId
                        OR Member__r.Player2__c = :playerId
                )
        ];
        for(BL_Competitor__c bl_competitor : comps) {
            excLeagues.add(bl_competitor.League__c);
        }
        for(BL_Competitor__c bl_competitor : parentTeamsCompetitors) {
            excLeagues.add(bl_competitor.League__c);
        }
        return excLeagues;
    }

    @AuraEnabled
    public static List<BL_League__c> getAllLeagues() {
        return [
                SELECT Id, Name, Max_Teams__c, Teams_Joined__c, Start_Date__c, End_Date__c, TeamSize__c,
                        RecordType.DeveloperName, Status__c
                FROM BL_League__c
                ORDER BY Name ASC
        ];
    }

    @AuraEnabled
    public static List<BL_League__c> getOpenLeagues() {
        List<BL_League__c> leagues = new List<BL_League__c>();
        for(BL_League__c league : [
                SELECT Id, Name, Max_Teams__c, Teams_Joined__c, Start_Date__c, End_Date__c, TeamSize__c,
                        RecordType.DeveloperName
                FROM BL_League__c
                WHERE (Status__c = 'Assembling teams' AND Start_Date__c >= :System.now())
                AND Id NOT IN :getPlayerLeaguesIds()
                AND RecordType.DeveloperName != :BL_Constants.LEAGUE_RT_BATTLE_ROYALE
        ]) {
            if(league.Max_Teams__c > league.Teams_Joined__c) {
                leagues.add(league);
            }
        }
        return leagues;
    }

    @AuraEnabled
    public static List<BL_League__c> getMyLeagues() {
        List<BL_League__c> leagues = new List<BL_League__c>();
        for(BL_League__c league : [
                SELECT Name, Max_Teams__c, Teams_Joined__c, Start_Date__c, End_Date__c, RecordType.DeveloperName,
                        Status__c, TeamSize__c
                FROM BL_League__c
                WHERE Id IN :getPlayerLeaguesIds()
                ORDER BY Name
        ]) {
            leagues.add(league);
        }
        return leagues;
    }

    @AuraEnabled
    public static List<DTO_Team> getPlayerTeams(String leagueId) {
        Id playerId = BL_Utils.getCurrentUser().ContactId;

        BL_DAO_Team daoTeam = new BL_DAO_Team();
        List<BL_Team__c> teams = daoTeam.getTeamsByPlayerId(playerId);

        BL_DAO_League daoLeague = new BL_DAO_League();
        BL_League__c league = daoLeague.getLeagueById(leagueId);

        List<DTO_Team> dtoList = new List<DTO_Team>();

        for(BL_Team__c team : teams) {
            if(league.RecordType.DeveloperName != BL_Constants.LEAGUE_RT_BATTLE_ROYALE || (league.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE && team.RecordType.DeveloperName == BL_Constants.TEAM_RT_BATTLE_ROYALE)) {
                DTO_Team t = new DTO_Team();
                t.recordId = team.Id;
                t.name = team.Name;
                t.isActive = team.IsActive__c;
                if(team.Player1__c != playerId) {
                    t.secondPlayerName = team.Player1__r.Name;
                    t.secondPlayerId = team.Player1__c;
                } else if(team.Player2__c != playerId) {
                    t.secondPlayerName = team.Player2__r.Name;
                    t.secondPlayerId = team.Player2__c;
                }
                dtoList.add(t);
            }
        }

        return dtoList;
    }

    @AuraEnabled
    public static User getCurrentUser() {
        return BL_Utils.getCurrentUser();
    }

    private static Boolean checkLeagueCompetitors(String leagueId, String teamId) {
        BL_Team__c team = [
                SELECT Id, Player1__c, Player2__c
                FROM BL_Team__c
                WHERE Id = :teamId
                LIMIT 1
        ];

        List<BL_League__c> league = [
                SELECT Max_Teams__c, (SELECT Id, Team__r.Player1__c, Team__r.Player2__c FROM Competitors__r)
                FROM BL_League__c
                WHERE Id = :leagueId
        ];

        if(!league.isEmpty()) {
            for(BL_Competitor__c comp : league[0].Competitors__r) {
                if(team.Player1__c != null && (team.Player1__c == comp.Team__r.Player1__c || team.Player1__c == comp.Team__r.Player2__c)) {
                    return true;
                }
                if(team.Player2__c != null && (team.Player2__c == comp.Team__r.Player1__c || team.Player2__c == comp.Team__r.Player2__c)) {
                    return true;
                }
            }
            if(league[0].Max_Teams__c <= league[0].Competitors__r.size()) {
                return false;
            }
        }

        return true;
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