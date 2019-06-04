public with sharing class BL_CreateTeamController {
    @AuraEnabled
    public static void saveTeam(BL_Team__c team, sObject player, Boolean isBattleRoyale) {
        Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
        if (isBattleRoyale == true) {
            team.Player1__c = currentPlayer;
            team.RecordTypeId = BL_Utils.getRecordTypeIdByDeveloperName('BL_Team__c', BL_Constants.TEAM_RT_BATTLE_ROYALE);
            team.IsActive__c = true;
            Database.insert(team);
        } else {
            Contact secondPlayer = (Contact) player;
            List<BL_Team__c> existingTeams = [
                    SELECT Id, Name
                    FROM BL_Team__c
                    WHERE (Player1__c = :currentPlayer AND Player2__c = :secondPlayer.Id)
                    OR (Player1__c = :secondPlayer.Id AND Player2__c = :currentPlayer)
            ];

            if (existingTeams.isEmpty()){
                team.Player1__c = currentPlayer;
                team.Player2__c = secondPlayer.Id;
                team.RecordTypeId = BL_Utils.getRecordTypeIdByDeveloperName('BL_Team__c', BL_Constants.TEAM_RT_CLASSIC);
                Database.insert(team);
            } else {
                throw new AuraHandledException('Team already existed.');
            }
        }
    }
}