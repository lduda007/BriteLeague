public with sharing class BL_Create1PlayerCompetitorController {
    @AuraEnabled
    public static String insertCompetitor(BL_Competitor__c competitor) {
        User currentUser = BL_Utils.getCurrentUser();
        competitor.Team__c = getPlayerSinglePlayerTeamId(currentUser.ContactId);

        if(competitor.Team__c == null){
            competitor.Team__c = createTeamForSinglePlayerAndGetId();
        }
        if (String.isNotBlank(competitor.Competition__c)) {
            insert competitor;
            return 'SUCCESS';
        } else {
            throw new AuraHandledException(Label.BL_League_Full);
        }

    }

    private static String createTeamForSinglePlayerAndGetId(){
        User currentUser = [SELECT Id, Name, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        BL_Team__c team = new BL_Team__c();
        team.Name = currentUser.Name;
        team.Player1__c = currentUser.ContactId;
        team.IsSinglePlayer__c = true;
        team.IsActive__c = true;
        insert team;
        return team.Id;
    }

    private static String getPlayerSinglePlayerTeamId(String playerId){
        List<BL_Team__c> team = [
                SELECT Id
                FROM BL_Team__c
                WHERE Player1__c =: playerId AND IsSinglePlayer__c = true
        ];
        return team.isEmpty() ? null : team[0].Id;
    }
}