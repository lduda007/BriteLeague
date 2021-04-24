public class BTN_Email_Utils {
    public static final String SYSTEM_SENDER = 'BriteCRM_System' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX;
    
    /**
     * @author Wojciech Mazur
     * @date   2016-10-04
     * Send Email utility method 
     * @param  ID recipient user receiver
     * @param  ID relatedRecord related record
     * @param  String templateName template name
     * @return             Status message 'Success' for Success
    */
    public static List<Messaging.SendEmailResult> sendTemplatedEmail(ID recipient, ID relatedRecord, String templateName){
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	mail.setTargetObjectId(recipient);
    	Id templateId; 
    	try {templateId = [select id, name from EmailTemplate where developername = : templateName].id;}
    	catch (Exception e) {
    		throw new BTN_Exception ('[U-03] Unable to locate EmailTemplate using name: ' + templateName +
    				' refer to Setup | Communications Templates ' + templateName);
    	}
    	mail.setTemplateId(templateId);
    	mail.setWhatId(relatedRecord);   
    	mail.setBccSender(false);
    	mail.setUseSignature(false);
    	//mail.setSenderDisplayName('HR Recruiting');
    	mail.setSaveAsActivity(false); 
    	return	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-05-10
     * Send Email utility method generaly for CV and Resource Request sObject
     * @param  emailAdress String email address
     * @param  subject  Email Subject,
     * @param  emailBody Email content
     * @param  attachments List od attachments for email
     * @param  relatedObjectId Id of email source sObject.
     * @return             Status message 'Success' for Success
    */
    public static List<Messaging.SendEmailResult> sendEmailWithAttachments(
            String sender,
            List<String> recipients,
            String subject,
            String emailBody,
            Set<Id> attachmentsIdList,
            Id orgWideEmailAddressId,
            Id relatedObjectId
    ) {
        Messaging.EmailFileAttachment emailAttachment;
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();

        for (Attachment attaItem : [
                                    SELECT
                                        Name, Body
                                    FROM
                                        Attachment
                                    WHERE
                                        Id IN :attachmentsIdList
                                    ]) {
            emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setFileName(attaItem.Name);
            emailAttachment.setBody(attaItem.Body);
            emailAttachments.add(emailAttachment);
        }

        mailList = new Messaging.SingleEmailMessage[]{};
        Messaging.SingleEmailMessage mail  = new Messaging.SingleEmailMessage();
        mail.toAddresses = recipients;
        mail.setSubject(subject);
        mail.sethtmlBody(emailBody);
        if (!emailAttachments.isEmpty()) {
            mail.setFileAttachments(emailAttachments);
        }
        if (orgWideEmailAddressId != null) {
            mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        } else {
            mail.setSenderDisplayName(sender);
        }
        if (!BTN_ValidationHandler.isNull(relatedObjectId)) {
            mail.setWhatId(relatedObjectId);
            mail.setSaveAsActivity(!Test.isRunningTest()); //TODO TO FIX |System.EmailException: SendEmail failed. First exception on row 0; first error: INVALID_FIELD_FOR_INSERT_UPDATE, Task: bad field names on insert/update call: ActivityOriginType: [ActivityOriginType]
            // https://success.salesforce.com/issues_view?id=a1p300000008aRlAAI
            // it works on CS83 but not on CS82 which is actual Dev Server.
            // mail.setSaveAsActivity(true);
        }
        mailList.add(mail);

        return Messaging.sendEmail(mailList);
    }

	public static List<Messaging.SendEmailResult> sendEmailWithAttachments(
			String sender,
			List<String> recipients,
			String subject,
			String emailBody,
			Set<Id> attachmentsIdList,
			Id orgWideEmailAddressId,
			Id relatedObjectId,
			List<String> ccRecipients
	) {
		Messaging.EmailFileAttachment emailAttachment;
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
		List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();

		for (Attachment attaItem : [
				SELECT
						Name, Body
				FROM
						Attachment
				WHERE
						Id IN :attachmentsIdList
		]) {
			emailAttachment = new Messaging.EmailFileAttachment();
			emailAttachment.setFileName(attaItem.Name);
			emailAttachment.setBody(attaItem.Body);
			emailAttachments.add(emailAttachment);
		}

		mailList = new Messaging.SingleEmailMessage[]{};
		Messaging.SingleEmailMessage mail  = new Messaging.SingleEmailMessage();
		mail.toAddresses = recipients;
		mail.setSubject(subject);
		mail.sethtmlBody(emailBody);

		if(ccRecipients != null && !ccRecipients.isEmpty())
			mail.ccAddresses = ccRecipients;

		if (!emailAttachments.isEmpty()) {
			mail.setFileAttachments(emailAttachments);
		}
		if (orgWideEmailAddressId != null) {
			mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
		} else {
			mail.setSenderDisplayName(sender);
		}
		if (!BTN_ValidationHandler.isNull(relatedObjectId)) {
			mail.setWhatId(relatedObjectId);
			mail.setSaveAsActivity(!Test.isRunningTest()); //TODO TO FIX |System.EmailException: SendEmail failed. First exception on row 0; first error: INVALID_FIELD_FOR_INSERT_UPDATE, Task: bad field names on insert/update call: ActivityOriginType: [ActivityOriginType]
			// https://success.salesforce.com/issues_view?id=a1p300000008aRlAAI
			// it works on CS83 but not on CS82 which is actual Dev Server.
			// mail.setSaveAsActivity(true);
		}
		mailList.add(mail);

		return Messaging.sendEmail(mailList);
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-05-10
     * Send Email utility method generaly for CV and Resource Request sObject
     * @param  emailAdress String email address
     * @param  subject  Email Subject,
     * @param  emailBody Email content
     * @param  attachments List od attachments for email
     * @return             Status message 'Success' for Success
    */
    public static List<Messaging.SendEmailResult> sendEmailWithAttachments(
            String sender,
            List<String> recipients,
            String subject, String
            emailBody,
            Set<Id> attachmentsIdList,
            Id orgWideEmailAddressId
    ) {
        return sendEmailWithAttachments(
                sender,
                recipients,
                subject,
                emailBody,
                attachmentsIdList,
                orgWideEmailAddressId,
                null
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-10
     * Send Email utility method generaly for CV and Resource Request sObject
     * @param  emailAdress String email address
     * @param  subject  Email Subject,
     * @param  emailBody Email content
     * @param  attachments List od attachments for email
     * @return             Status message 'Success' for Success
    */
    public static List<Messaging.SendEmailResult> sendWarningEmailToAdmin(
            String subject,
            String emailBody
    ) {
	    Group sysAdminsGroup = new BTN_DAO_Group().getSysAdmins();
	    List<GroupMember> sysAdminsGroupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :sysAdminsGroup.Id];
		Set<Id> sysAdminIds = new Set<Id>();

	    for(GroupMember member : sysAdminsGroupMembers){
		    sysAdminIds.add(member.UserOrGroupId);
	    }

	    List<User> sysAdmins = new BTN_DAO_User().findUsersByIds(sysAdminIds);
	    List<String> recipients = new List<String>();

	    for(User sysAdmin : sysAdmins){
		    recipients.add(sysAdmin.Email);
	    }

        return sendEmailWithAttachments(
                SYSTEM_SENDER,
                recipients,
                subject,
                emailBody,
                null,
                null,
                null
        );
    }
}