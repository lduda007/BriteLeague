
public with sharing class BL_TournamentEndEmailService {
    @InvocableMethod
    public static void sendEmailAfterCompetitionEnds(List<String> leagueId){
        List<EmailTemplate> template = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'League End Email'];
//        notifyPlayersAfterLeagueEnd(leagueId[0], templete[0].Id);
    }
}