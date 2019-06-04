public without sharing class BL_TournamentEndEmailService {

    @InvocableMethod
    public static void sendEmailAfterCompetitionEnds(List<String> leagueId){
        List<BL_League__c> league = [
                SELECT RecordType.DeveloperName
                FROM BL_League__c
                WHERE Id = :leagueId
        ];
        if(!league.isEmpty()) {
            String templateName;
            if(league.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_CUP) {
                templateName = 'CupEndEmailNotification';
            } else if(league.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_CLASSIC) {
                templateName = 'LeagueEndEmailNotification';
            } else if(league.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE) {
                templateName = 'LeagueEndEmailNotification';
            }

            List<EmailTemplate> template = [SELECT Id, Name FROM EmailTemplate WHERE Name =: templateName];
            if(!template.isEmpty()){
                BL_TournamentEmailService.notifyPlayersAfterCompetitionStartOrEnd(leagueId[0], template[0].Id);
            }
        }
    }
}