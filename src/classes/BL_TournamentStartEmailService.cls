public with sharing class BL_TournamentStartEmailService {
    @InvocableMethod
    public static void sendEmailAfterCompetitionStarts(List<String> leagueId){

        List<EmailTemplate> template = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'CompetitionStartedEmailNotification'];
        if(!template.isEmpty()){
            BL_TournamentEmailService.notifyPlayersAfterCompetitionStartOrEnd(leagueId[0], template[0].Id);
        }
    }
}