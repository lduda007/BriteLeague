
public with sharing class BL_TournamentStartEmailService {
    @InvocableMethod
    public static void sendEmailAfterCompetitionStarts(List<String> leagueId){
        List<EmailTemplate> template = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'League Start Email'];
//        notifyPlayersAfterLeagueStarted(leagueId[0], templete[0].Id);
    }
}