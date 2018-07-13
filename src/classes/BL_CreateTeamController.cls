public with sharing class BL_CreateTeamController {
    @AuraEnabled
    public static void saveTeam(BL_Team__c team, sObject player) {
        //if (true){
        //    throw new AuraHandledException('Duplicate record');
        //} else {
        Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
        Contact secondPlayer = (Contact) player;
        
        team.Player1__c = currentPlayer;
        team.Player2__c = secondPlayer.Id;
        
        Database.insert(team);
        //}
        
        
    }
}