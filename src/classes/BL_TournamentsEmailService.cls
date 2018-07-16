
public with sharing class BL_TournamentsEmailService {
    //  templateId   must be ID of an Email template
    //  targetObjId must be a Contact, User, Lead Id -- also used in merge fields of template recipient.xxxx
    //  whatId    must be an SObject that is used in the merge fields of the template relatedTo.xxxx
    //  fromId    if non null, use current user, otherwise, use this ID (most likely an org wide no reply id)
    //  bcc      not permitted when using templates

    public static void notifyPlayersAfterLeagueStarted(String leagueId) {
        List<BL_Competitor__c> competitors = BL_Utils.getLeagueCompetitors(leagueId);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String templateId = [select id, name from EmailTemplate where developername = :'League Start Email'].id;
        List<String> toAddresses = new List<String>();

        for (BL_Competitor__c competitor : competitors) {
            toAddresses.add(competitor.Team__r.Player1__r.Email);
            toAddresses.add(competitor.Team__r.Player2__r.Email);
        }
        email.setToAddresses(toAddresses);
//        email.setCcAddresses(ccRecipients);
//        email.setTargetObjectId(targetObjId);
        email.setWhatId(leagueId);
//        email.setorgWideEmailAddressId(orgWideEmailId);
        email.setTemplateId(templateId);
//        email.setSaveAsActivity(saveAsActivity);
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        } catch (EmailException e) {
            throw new EmailException('[U-02] sendTemplatedEmail error. ' + e.getMessage());
        }
    }
}