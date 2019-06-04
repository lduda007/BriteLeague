public with sharing class BL_PlayerTeamsListController {
    @AuraEnabled
    public static List<BL_Team__c> getPlayerTeams(){
        User currentUser = BL_Utils.getCurrentUser();
        List<BL_Team__c> directTeams = [
                SELECT Id, Name, RecordType.Name, IsActive__c, Player1__c, Player2__c, Player1__r.LastName, Player2__r.LastName, Total_Games_Won__c,
                        Total_Games_Lost__c, Total_Games_Drawn__c, Total_Goals_Scored__c, Total_Goals_Lost__c
                FROM BL_Team__c
                WHERE (Player1__c = :currentUser.ContactId OR Player2__c = :currentUser.ContactId)
                AND IsActive__c = true
                AND IsSinglePlayer__c = false
                ORDER BY LastModifiedDate
        ];
        List<BL_Team__c> parentTeams = [
                SELECT Id, Name, RecordType.Name, IsActive__c, Player1__c, Player2__c, Player1__r.LastName, Player2__r.LastName, Total_Games_Won__c,
                        Total_Games_Lost__c, Total_Games_Drawn__c, Total_Goals_Scored__c, Total_Goals_Lost__c
                FROM BL_Team__c
                WHERE Id IN (SELECT Team__c FROM BL_TeamMember__c WHERE Member__c IN :directTeams)
                ORDER BY LastModifiedDate
        ];
        Set<BL_Team__c> playerTeams = new Set<BL_Team__c>();
        playerTeams.addAll(directTeams);
        playerTeams.addAll(parentTeams);
        return new List<BL_Team__c>(playerTeams);
    }

    @AuraEnabled
    public static List<BL_Team__c> getReceivedTeamInvitations(){
        Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
        List<BL_Team__c> invitations = [
                SELECT Id, Name, Player1__c, Player1__r.Name
                FROM BL_Team__c
                WHERE IsActive__c = false AND Player2__c = :currentPlayer
        ];
        system.debug(invitations);
        return invitations;
    }

    @AuraEnabled
    public static List<BL_Team__c> getSentTeamInvitations(){
        Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
        List<BL_Team__c> invitations = [
                SELECT Id, Name, Player2__c, Player2__r.Name
                FROM BL_Team__c
                WHERE IsActive__c = false AND Player1__c = :currentPlayer
        ];
        system.debug(invitations);
        return invitations;
    }

    @AuraEnabled
    public static void saveTeam(BL_Team__c team, sObject player){
        BL_CreateTeamController.saveTeam(team, player, false);
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

    @AuraEnabled
    public static User getCurrentUser() {
        return BL_Utils.getCurrentUser();
    }
}