public with sharing class BL_TournamentEmailService {

    public static void notifyPlayersAfterCompetitionStartOrEnd(String competitionId, String templateId) {
        BL_DAO_Competitor daoCompetitor = new BL_DAO_Competitor();
        List<BL_Competitor__c> competitors = daoCompetitor.getCompetitorsByCompetitionId(competitionId);
        List<Messaging.SingleEmailMessage> emails = createSingleMessagesListForPlayers(competitors, templateId, competitionId);

        try {
            Messaging.sendEmail(emails);
        } catch(EmailException e) {
            throw new EmailException('Error ' + e.getMessage());
        }
    }

    private static List<Messaging.SingleEmailMessage> createSingleMessagesListForPlayers(List<BL_Competitor__c> competitors, String templateId, String leagueId) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Set<String> playersIds = new Set<String>();
        for(BL_Competitor__c competitor : competitors) {
            if(competitor.Team__r.Player1__c != null && !playersIds.contains(competitor.Team__r.Player1__c)) {
                emails.add(createSingleMessageForPlayer(competitor.Team__r.Player1__c, templateId, leagueId, competitor.Id));
                playersIds.add(competitor.Team__r.Player1__c);
            }
            if(competitor.Team__r.Player2__c != null && !playersIds.contains(competitor.Team__r.Player2__c)) {
                emails.add(createSingleMessageForPlayer(competitor.Team__r.Player2__c, templateId, leagueId, competitor.Id));
                playersIds.add(competitor.Team__r.Player2__c);
            }
        }
        return emails;
    }

    private static Messaging.SingleEmailMessage createSingleMessageForPlayer(String playerId, String templateId, String leagueId, String competitorId) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(playerId);
        message.setWhatId(competitorId);
        message.setTemplateId(templateId);
        return message;
    }

}