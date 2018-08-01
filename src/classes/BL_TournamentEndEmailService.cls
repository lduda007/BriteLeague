
public with sharing class BL_TournamentEndEmailService {
    public static void notifyPlayersAfterLeagueEnd(String leagueId) {
        List<BL_Competitor__c> competitors = BL_Utils.getLeagueCompetitors(leagueId);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> template = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'League End Email'];
        Set<String> toAddresses = new Set<String>();

        for (BL_Competitor__c competitor : competitors) {
            if(competitor.Team__r.Player1__c != null){
                Messaging.SingleEmailMessage messagePlayer1 = new Messaging.SingleEmailMessage();
                messagePlayer1.setTargetObjectId(competitor.Team__r.Player1__c);
                emails.add(messagePlayer1);
            }
            if(competitor.Team__r.Player2__c != null){
                Messaging.SingleEmailMessage messagePlayer2 = new Messaging.SingleEmailMessage();
                messagePlayer2.setTargetObjectId(competitor.Team__r.Player2__c);
                emails.add(messagePlayer2);
            }
        }

        for(Messaging.SingleEmailMessage email : emails){
            email.setWhatId(leagueId);
            email.setTemplateId(template[0].Id);
        }

        try {
            Messaging.sendEmail(emails);
        } catch (EmailException e) {
            throw new EmailException('Error: ' + e.getMessage());
        }
    }

    @InvocableMethod
    public static void sendEmailAfterCompetitionEnds(List<String> leagueId){
//        notifyPlayersAfterLeagueEnd(leagueId[0]);
    }
}