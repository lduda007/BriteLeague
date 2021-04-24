@isTest
private class BTN_EventPeriodicController_Test {

	/**
     * @author Wojciech Mazur
     * @date   2016-12-28
     * @description Prepare data for tests
    */
    @TestSetup static void createDataStructure() {
        CollaborationGroup cg = BTN_TestDataFactory.getHRCollaborationGroup();
        BTN_TestDataFactory.getNewBssDummyConnections();
        Account acc = BTN_TestDataFactory.getBriteNetAccount();
        //Contact internalCon = BTN_TestDataFactory.getRequestorInternalContact(acc.Id);
        /*BTN_TestDataFactory.getCV(
                BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().save().Id,
                internalCon.Id
        );*/
    }

	/**
     * @author Wojciech Mazur
     * @date   2016-12-28
     * @description test constructor
    */
    static testMethod void testConstructor() {
        PageReference pageTest = Page.BTN_EventPeriodic;
        Test.setCurrentPage(pageTest);
        Contact hrContact = BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .withAccount(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id)
                .withEmail('hruser' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL)
                .withFirstName('Donald')
                .withLastName('Tusk')
                .get();
        insert hrContact;
        Contact internalCon = BTN_TestDataFactory.getRequestorInternalContact(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id);

         pageTest.getParameters().put(
                BTN_EventPeriodicController.URL_PARAM_CONTACT_ID,
                internalCon.Id
        );
        ApexPages.StandardController stdController = new ApexPages.StandardController(new BTN_Event__c());
        BTN_EventPeriodicController controller = new BTN_EventPeriodicController(stdController);
        system.assert(controller.assessment.interviewed__c==internalCon.Id);

    }

    /**
     * @author Wojciech Mazur
     * @date   2016-12-28
     * @description test save method
    */
    static testmethod void testSave(){
    	PageReference pageTest = Page.BTN_EventPeriodic;
        Test.setCurrentPage(pageTest);
        Contact internalCon = BTN_TestDataFactory.getRequestorInternalContact(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id);
        Contact hrContact = BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .withAccount(new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id)
                .withEmail('hruser' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL)
                .withFirstName('Donald')
                .withLastName('Tusk')
                .get();
        hrcontact.ReportsToId = internalCon.Id;
        internalCon.ReportsToId =hrcontact.Id;
        upsert internalCon;
        insert hrContact;
        User internalUser = BTN_TestDataFactory.getCommunityUser(internalCon.Id, internalCon.Email);

        insert internalUser;
        User hrUser = BTN_TestDataFactory.getCommunityUser(hrContact.Id, hrContact.Email);
        insert hrUser;
        //BTN_PermissionSetUtils.assignPermissionSetToUser(BTN_ConstantRepo.PERM_SET_NAME_HR, hrUser);
        //system.runAs(hrUser){

	         pageTest.getParameters().put(
	                BTN_EventPeriodicController.URL_PARAM_CONTACT_ID,
	                internalCon.Id
	        );
	        ApexPages.StandardController stdController = new ApexPages.StandardController(new BTN_Event__c());
	        BTN_EventPeriodicController controller = new BTN_EventPeriodicController(stdController);
	        controller.assessment.NextAssessmentDate__c = system.today()+10;
	        controller.addCurrentTarget();
	        system.assertEquals(1,controller.currentTargets.size());
	        controller.currentTargets.get(0).Type__c = 'Technical';
	        controller.currentTargets.get(0).Target__c = 'test target1';
	        controller.currentTargets.get(0).Due_date__c = system.today()+20;
	        controller.currentTargets.get(0).Achieved_percent__c = 10;
            controller.addCurrentTarget();
            system.assertEquals(2,controller.currentTargets.size());
	        controller.currentTargets.get(1).Type__c = 'Technical';
	        controller.currentTargets.get(1).Target__c = 'test target2';
	        controller.currentTargets.get(1).Due_date__c = system.today()+20;
	        controller.currentTargets.get(1).Achieved_percent__c = 10;
	        controller.targetToDel = '1'; //remove first from the list
	        controller.delCurrentTarget();

	        system.assertEquals(1,controller.currentTargets.size());
			system.assertEquals('test target2',controller.currentTargets.get(0).Target__c);

			system.assert(controller.save()!=null);
        //}


    }
}