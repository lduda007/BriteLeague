public with sharing class BL_PlayerTeamsListController {
    @AuraEnabled
    public static List<DTO_Team> getPlayerTeams(){
        Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
        List<BL_Team__c> teams = [SELECT Id, Name, Player1__c, Player2__c, Player1__r.Name, Player2__r.Name FROM BL_Team__c WHERE Player1__c = :currentPlayer OR Player2__c = :currentPlayer];
        List<DTO_Team> dtoList = new List<DTO_Team>();
        for (BL_Team__c team : teams){
            DTO_Team t = new DTO_Team();
            t.recordId = team.Id;
            t.name = team.Name;
            if (team.Player1__c != currentPlayer){
                t.secondPlayerName = team.Player1__r.Name;
                t.secondPlayerId = team.Player1__c;
            } else if (team.Player2__c != currentPlayer){
                t.secondPlayerName = team.Player2__r.Name;
                t.secondPlayerId = team.Player2__c;
            }
            dtoList.add(t);
        }
        
        return dtoList;
    }
    
    @AuraEnabled
    public static void saveTeam(BL_Team__c team, sObject player){
        BL_CreateTeamController.saveTeam(team, player);
    }
    
    public class DTO_Team{
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String recordId {get;set;}
        @AuraEnabled public Integer won {get;set;}
        @AuraEnabled public Integer lost {get;set;}
        @AuraEnabled public String secondPlayerName {get;set;}
        @AuraEnabled public String secondPlayerId {get;set;}
        @AuraEnabled public Boolean canDelete {get;set;}
    }
}