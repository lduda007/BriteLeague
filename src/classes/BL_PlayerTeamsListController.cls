public with sharing class BL_PlayerTeamsListController {
    @AuraEnabled
    public static List<DTO_Team> getPlayerTeams(){
        Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
        List<BL_Team__c> teams = [SELECT Id, Name, Player1__c, Player2__c, Player1__r.Name, Player2__r.Name, IsActive__c, (SELECT Won__c, Lost__c, Draw__c FROM Statistics__r) FROM BL_Team__c WHERE Player1__c = :currentPlayer OR (Player2__c = :currentPlayer AND IsActive__c = true)];
        List<DTO_Team> dtoList = new List<DTO_Team>();
        for (BL_Team__c team : teams){
            DTO_Team t = new DTO_Team();
            t.recordId = team.Id;
            t.name = team.Name;
            t.isActive = team.IsActive__c;
            if (team.Player1__c != currentPlayer){
                t.secondPlayerName = team.Player1__r.Name;
                t.secondPlayerId = team.Player1__c;
            } else if (team.Player2__c != currentPlayer){
                t.secondPlayerName = team.Player2__r.Name;
                t.secondPlayerId = team.Player2__c;
            }

            t.won = 0;
            t.lost = 0;
            t.draw = 0;
            for (BL_Statistic__c stat : team.Statistics__r){
                t.won += Integer.valueOf(stat.Won__c);
                t.lost += Integer.valueOf(stat.Lost__c);
                t.draw += Integer.valueOf(stat.Draw__c);
            }
            t.canDelete = canDeleteTeam(currentPlayer, team);
            dtoList.add(t);
        }
        
        return dtoList;
    }

    @AuraEnabled
    public static List<BL_Team__c> getTeamInvitations(){
        Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
        List<BL_Team__c> invitations = [SELECT Id, Name, Player1__c, Player1__r.Name FROM BL_Team__c WHERE IsActive__c = false AND Player2__c = :currentPlayer];

        return invitations;
    }

    @AuraEnabled
    public static void saveTeam(BL_Team__c team, sObject player){
        BL_CreateTeamController.saveTeam(team, player);
    }

    @AuraEnabled
    public static void deleteTeams(String recordId){
        List<BL_Team__c> teams = [SELECT Id FROM BL_Team__c WHERE Id = :recordId];
        if (!teams.isEmpty()){
            BL_Team__c team = teams.get(0);
            delete team;
        } else {
            throw new AuraHandledException('Record doesn\'t exist!');
        }
    }

    @AuraEnabled
    public static void confirmInvitation(String recordId, Boolean isConfirmed){
        List<BL_Team__c> teams = [SELECT Id, IsActive__c FROM BL_Team__c WHERE Id = :recordId];
        try {
            if (!teams.isEmpty()){
                BL_Team__c team = teams.get(0);
                if (isConfirmed == true){
                    team.IsActive__c = true;
                    update team;

                    BL_Statistic__c stats = new BL_Statistic__c(Team__c = team.Id);
                    insert stats;
                } else {
                    BL_Utils.UnsecureClass unsecureClass = new BL_Utils.UnsecureClass();
                    unsecureClass.deleteNotOwnedRecord(team);
                }
            } else {
                throw new AuraHandledException('Record doesn\'t exist!');
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' --> ' + ex.getStackTraceString());
        }
    }

    private static Boolean canDeleteTeam(Id currentUser, BL_Team__c team){
        if (team.IsActive__c == false && team.Player1__c == currentUser)
            return true;
        return false;
    }

    public class DTO_Team{
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String recordId {get;set;}
        @AuraEnabled public Integer won {get;set;}
        @AuraEnabled public Integer lost {get;set;}
        @AuraEnabled public Integer draw {get;set;}
        @AuraEnabled public String secondPlayerName {get;set;}
        @AuraEnabled public String secondPlayerId {get;set;}
        @AuraEnabled public Boolean isActive {get;set;}
        @AuraEnabled public Boolean canDelete {get;set;}
    }
}