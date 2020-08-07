public without sharing class BL_TournamentEndEmailService {

    @InvocableMethod
    public static void sendEmailAfterCompetitionEnds(List<String> competitionIds) {
        Id competitionId = competitionIds[0];
        BL_Competition__c competition = new BL_DAO_Competition().getCompetitionById(competitionId);

        String templateName;
        if (competition.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_CUP) {
            templateName = 'CupEndEmailNotification';
        } else if (competition.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_LEAGUE) {
            templateName = 'LeagueEndEmailNotification';
        } else if (competition.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE) {
            templateName = 'LeagueEndEmailNotification';
        }

        List<EmailTemplate> template = [SELECT Id, Name FROM EmailTemplate WHERE Name = :templateName];
        if (!template.isEmpty()) {
            BL_TournamentEmailService.notifyPlayersAfterCompetitionStartOrEnd(competitionId, template[0].Id);
        }
    }
}