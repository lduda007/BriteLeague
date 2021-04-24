public with sharing class BL_TournamentStartEmailService {

    @InvocableMethod
    public static void sendEmailAfterCompetitionStarts(List<String> competitionIds){
        List<EmailTemplate> template = [
                SELECT Id, Name
                FROM EmailTemplate
                WHERE Name = 'CompetitionStartedEmailNotification'
        ];
        if(!template.isEmpty()){
            BL_TournamentEmailService.notifyPlayersAfterCompetitionStartOrEnd(competitionIds[0], template[0].Id);
        }
    }
}