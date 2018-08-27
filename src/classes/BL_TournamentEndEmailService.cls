public with sharing class BL_TournamentEndEmailService {
    @InvocableMethod
    public static void sendEmailAfterCompetitionEnds(List<String> leagueId){
        List<BL_League__c> competition = [
                SELECT isCup__c
                FROM BL_League__c
                WHERE Id =: leagueId
        ];
        if(!competition.isEmpty()){
            String templateName;
            templateName = competition[0].isCup__c ? 'CupEndEmailNotification' : 'LeagueEndEmailNotification';
            List<EmailTemplate> template = [SELECT Id, Name FROM EmailTemplate WHERE Name =: templateName];
            if(!template.isEmpty()){
                BL_TournamentEmailService.notifyPlayersAfterCompetitionStartOrEnd(leagueId[0], template[0].Id);
            }
        }
    }
}