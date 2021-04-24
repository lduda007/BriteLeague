/**
 * @author Mateusz Przywara
 * @date   2016-07-15
 * @description Class test utils for Email
*/
@isTest
private class BTN_Email_Utils_Test {
    private static final String EMAIL_ATTACHMENT_BLOB_VALUE = '"MASTERRECORDID","ACCOUNTID","LASTNAME","FIRSTNAME",' +
            '"SALUTATION","MIDDLENAME","SUFFIX","NAME","OTHERSTREET","OTHERCITY"';
    private static final String ATTACHMENT_NAME = 'Pudzian_Pudzianowski.csv';
    private static final String INVALID_EMAIL = 'invalidEmail@fakeOrg.com';
    private static BTN_UserBuilderUtils userBuilderUtils = new BTN_UserBuilderUtils();

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description Prepare data for tests
    */
    @testSetup static void createDataStructure() {
        //BTN_TestDataFactory.createDataStructureForBriteRM();
        Account acc = BTN_TestDataFactory.getBriteNetAccount();
        Contact contactInternal = BTN_TestDataFactory.getRequestorInternalContact(acc.Id);
        // TODO Donno why someone creating here Community User
        /*User currentUser;
        //User user = userBuilderUtils.buildRRCommunityUser();
        insert user;
        PermissionSetAssignment psa = new PermissionSetAssignment(
                PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :BTN_ConstantRepo.PERM_SET_NAME_RESOURCE_REQUESTOR].Id,
                AssigneeId = user.Id);
        insert psa;*/
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description Method generates coverage and test if method does not return exception
    */
    testmethod static void generateCoverageOnSendEmailMethod() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_DAO_Contact contactDAO = new BTN_DAO_Contact();
            Id contactId  = new BTN_DAO_Contact().findInternals().get(0).Id;
            List<String> recipients = new List<String>();
            recipients.add(contactId);
            String sender = 'BriteCRM testers';
            String subject = 'test subject';
            String emailBody = 'content';
            List<Attachment> attachments = new List<Attachment>();
            attachments.add(
                    new Attachment(
                        Name = ATTACHMENT_NAME,
                        Body = Blob.valueOf(EMAIL_ATTACHMENT_BLOB_VALUE),
                        ParentId = contactId
                    )
            );
            recipients.add(INVALID_EMAIL);
            insert attachments;
            Id orgWideEmailId;
            System.assertNotEquals(null, BTN_Email_Utils.sendEmailWithAttachments(sender, recipients, subject,
                    emailBody, BTN_Utils.getSetOfIds(attachments), orgWideEmailId));
        }
    }
}