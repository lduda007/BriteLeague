/**
 * @author Mateusz Przywara
 * @date   2016-07-18
 * @description BTN_SendEmailController_Test test Page with 3 email paths.
 * Request CV's from HR
 * Send Candidate
 * Send Candidates from Resource Request
 */
@isTest
private class BTN_SendEmailController_Test {
    private static final String TEST_BLOB_CONTENT = '"MASTERRECORDID","ACCOUNTID","LASTNAME","FIRSTNAME",' +
            '"SALUTATION","MIDDLENAME","SUFFIX","NAME","OTHERSTREET","OTHERCITY"';
    private static final String TEST_CANDIDATE_NAME = 'Pudzian_Pudzianowski.csv';
    private static final String TEST_EMAIL_CONTENT = 'body content TEST';
    private static final String EMAIL_ACTIVITY_SUBJECT_PREFIX = 'Email: ';
    private static String productMainSkills = 'Opportunity Product Main Skills';
    private static String salesRepEmail = 'test_sales_britenet@com.pl';
    
    /**
     * @author Mateusz Przywara
     * @date   2016-07-18
     * @description Prepare data for tests
    */
    @testSetup static void createDataStructure() {
        Test.startTest();
        BTN_TestDataFactory.getTriggerSkipperCustomSetting();
        BTN_TestDataFactory.getHRCollaborationGroup();
        Account acc = BTN_TestDataFactory.getBriteNetAccount();
        Account accBusiness = new Account(
            Name = BTN_ConstantRepo.ACCOUNT_PRIVATE_NAME,
            CurrencyIsoCode = BTN_TestDataFactory.TESTCURRENCY,
            RecordTypeId = BTN_RecordTypeUtils.getRecordTypeAccountPrivateSector().Id
        );
        insert accBusiness;
        BTN_TestDataFactory.getBusinessContact(accBusiness.Id);
        Test.stopTest();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-30
     * @description Test if page is creating properly. For the case when button on Resource Request page
     *              has been clicked.
     */
    @isTest static void testConstructionSendEmailControllerPageFromResourceRequestSide() {
        BTN_DAO_ResourceRequest resourceRequestDAO = new BTN_DAO_ResourceRequest();
        BTN_ResourceRequest__c resreq;
        User rmUser;
        System.runAs(rmUser = new BTN_DAO_User().findUserByProfileName(BTN_ConstantRepo.RESOURCE_MANAGER_PROFILE_NAME)){
            Opportunity oppo = BTN_TestDataFactory.getOpportunity(Test.getStandardPricebookId());
            resreq = BTN_TestDataFactory.getAutoResourceRequest(oppo);
            Account acc = BTN_TestDataFactory.getBriteNetAccount();
            Contact requestor = BTN_TestDataFactory.getRequestorInternalContact(acc.Id);

            resreq.Resource_Manager__c = requestor.Id;
            update resreq;
            Contact newRecruit = BTN_TestDataFactory.getRecruitContact(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id);
            BTN_CV__c cv = BTN_TestDataFactory.getCV(resreq.Id, newRecruit.Id);
            insert new Attachment(ParentId = cv.Id, Name = TEST_CANDIDATE_NAME, Body = Blob.valueOf(TEST_BLOB_CONTENT));

            PageReference pageTest = Page.BTN_SendMailFormPage;
            pageTest.getParameters().put(BTN_SendEmailController.ID_PARAMETER_NAME, resreq.Id);
            pageTest.getParameters().put(BTN_SendEmailController.TYPE_PARAMETER_NAME,
                    BTN_SendEmailController.RESOURCE_REQUEST_ID_PARAMETER_NAME);
            Test.setCurrentPage(pageTest);
            BTN_SendEmailController controller = new BTN_SendEmailController();
            controller.emailBody = TEST_EMAIL_CONTENT;
            controller.recipientEmail = newRecruit.Email;
            controller.generateTemplate();
            System.assert(new BTN_DAO_Task().findTasksByParent(resreq.Id).isEmpty());
            Test.startTest();
            System.assertNotEquals(null, controller.sendEmail());
            Test.stopTest();
            /*System.assertEquals(
                    EMAIL_ACTIVITY_SUBJECT_PREFIX + controller.subject,
                    new BTN_DAO_Task().findTasksByParent(resreq.Id).get(0).Subject
            );*/
            System.assertEquals(new PageReference('/' + resreq.Id).getURL(), controller.goBack().getURL());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-30
     * @description Test if page is creating properly. For the case when button on Candidate page
     *              has been clicked.
     */
    @isTest static void testConstructionSendEmailControllerPageFromCVSide() {
        BTN_DAO_ResourceRequest resourceRequestDAO = new BTN_DAO_ResourceRequest();
        // to create RR with record type AUTO
        BTN_ResourceRequest__c resreq = BTN_TestDataFactory.getAutoResourceRequest(
                BTN_TestDataFactory.getOpportunity(Test.getStandardPricebookId())
        );
        // fix for flow: Assign requestor for new resource request disabled during deployment
        // set RequestorUser__c to owner
        if (resreq.RequestorUser__c == null) {
            resreq.RequestorUser__c = BTN_TestDataFactory.USER_MAP_BY_PROFILE.get(BTN_ConstantRepo.SALES_PROFILE_NAME).Id;
        }

        Account acc = BTN_TestDataFactory.getBriteNetAccount();
        Contact requestor = BTN_TestDataFactory.getRequestorInternalContact(acc.Id);

        resreq.Resource_Manager__c = requestor.Id;
        update resreq;
       

        System.RunAs(new BTN_DAO_User().findUserByProfileName(BTN_ConstantRepo.RESOURCE_MANAGER_PROFILE_NAME)) {
             Contact hrContact = BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .withAccount(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id)
                .withEmail('hruser' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL)
                .withFirstName('Donald')
                .withLastName('Tusk')
                .get();
        insert hrContact;
        BTN_CV__c cv = BTN_TestDataFactory.getCV(resreq.Id, hrContact.Id);
        insert new Attachment(ParentId = cv.Id, Name = TEST_CANDIDATE_NAME,
                Body = Blob.valueOf(TEST_BLOB_CONTENT));
            PageReference pageTest = Page.BTN_SendMailFormPage;
            pageTest.getParameters().put(BTN_SendEmailController.ID_PARAMETER_NAME, cv.Id);
            pageTest.getParameters().put(BTN_SendEmailController.TYPE_PARAMETER_NAME,
                    BTN_SendEmailController.SEND_CANDIDATES_FROM_CANDIDATE_TYPE_NAME);
            pageTest.getParameters().put(BTN_SendEmailController.RESOURCE_REQUEST_ID_PARAMETER_NAME, resreq.Id);
            Test.setCurrentPage(pageTest);
            BTN_SendEmailController controller = new BTN_SendEmailController();
            controller.emailBody = TEST_EMAIL_CONTENT;
            controller.recipientEmail = hrContact.Email;
            controller.generateTemplate();
            System.assert(new BTN_DAO_Task().findTasksByParent(cv.Id).isEmpty());
            Test.startTest();
            System.assertNotEquals(null, controller.sendEmail());
            Test.stopTest();
            /*System.assertEquals(
                    EMAIL_ACTIVITY_SUBJECT_PREFIX + controller.subject,
                    new BTN_DAO_Task().findTasksByParent(cv.Id).get(0).Subject
            );*/
            System.assertEquals(new PageReference('/' + cv.Id).getURL(), controller.goBack().getURL());
        }
    }
}