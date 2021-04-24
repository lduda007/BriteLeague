/**
 * Created by Adam on 4/22/2018.
 */

@IsTest
private class BTN_NewInternalOnboardingController_Test
{
	@testSetup
	static void testSetup() {
		BTN_TestDataFactory.getTriggerSkipperCustomSetting();
		BTN_TestDataFactory.getHRCollaborationGroup();
		BTN_TestDataFactory.getNewBssDummyConnections();
		BTN_TestDataFactory.getProjectRolesCustomSetting();

		Account britenet = BTN_TestDataFactory.getBriteNetAccount();
		Contact requestor = BTN_TestDataFactory.getRequestorInternalContact(britenet.Id);
		Contact leader = BTN_TestDataFactory.getLeaderInternalContact(britenet.Id);
		Contact recruit = BTN_TestDataFactory.getRecruitContact(britenet.Id, '');

		BTN_BriteCRM_settings__c companySetting = new BTN_BriteCRM_settings__c(
				Name = BTN_ConstantRepo.CUSTOM_SETTING_DEFAULT_CONTRACT_COMPANY,
				Value__c = britenet.Id
		);
		insert companySetting;

		BTN_ResourceRequest__c resourceRequest = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().get();
		resourceRequest.NumberOfCVs1__c = 0;
		resourceRequest.Resource_Manager__c = requestor.Id;
		insert resourceRequest;

		BTN_DAO_ResourceRequest resourceRequestDao = new BTN_DAO_ResourceRequest();
		resourceRequest = resourceRequestDao.findResourceRequestsById(resourceRequest.id);
		System.assert(resourceRequest.NumberOfCVs1__c == 0);

		BTN_TestDataFactory.getCV(resourceRequest.Id, recruit.Id);
	}

	static void setupTestPage(){
		BTN_CV__c candidate = new BTN_DAO_Candidate().findCandidates()[0];
		PageReference testPage = Page.BTN_NewInternalOnboarding;
		testPage.getParameters().put(BTN_ConstantRepo.URL_PARAM_CANDIDATE_ID, candidate.Id);
		Test.setCurrentPage(testPage);
	}

	static BTN_NewInternalOnboardingController setupController(Contact recruit, Contact leader){
		ApexPages.StandardController stdController = new ApexPages.StandardController(new Case());
		BTN_NewInternalOnboardingController controller = new BTN_NewInternalOnboardingController(stdController);

		controller.newInternalOnboardingCase.NewUserProjectRole__c = 'Salesforce';
		controller.newInternalOnboardingCase.Leader__c = leader.Id;
		controller.newInternalOnboardingCase.Guardian__c = leader.Id;
		controller.newInternalOnboardingCase.Location__c = 'Lublin Morwowa';
		controller.newInternalOnboardingCase.PersonalEmail__c = recruit.PersonalEmail__c;
		controller.newInternalOnboardingCase.PersonalPhone__c = recruit.PersonalPhone__c;
		controller.newInternalOnboardingCase.ContractType__c = 'B2B';
		controller.newInternalOnboardingCase.SalaryB2B__c = 100;
		controller.newInternalOnboardingCase.ContractLength__c = '12';
		controller.newInternalOnboardingCase.NoticePeriod__c = '2 miesiące';
		controller.newInternalOnboardingCase.Responsibilities__c = 'Working';
		controller.newInternalOnboardingCase.WorkStartDate__c = Date.today().addDays(30);

		return controller;
	}

	@isTest
	static void saveInternalOnboarding_test(){
		Test.setMock(HttpCalloutMock.class, new BTN_BSS_SendToBSNewUser_Mock(BTN_BSS_SendToBSNewUser_Mock.STATUS_CODE_SUCCESS));

		setupTestPage();

		BTN_DAO_Contact contactDao = new BTN_DAO_Contact();
		Contact recruit = contactDao.findRecruits()[0];
		Contact leader = contactDao.findLeaders()[0];

		BTN_NewInternalOnboardingController controller = setupController(recruit, leader);

		Test.startTest();

		PageReference returnedReference = controller.saveInternalOnboardingCase();

		Test.stopTest();

		List<Case> existingCases = new BTN_DAO_Case().findCases();
		System.assertEquals(1, existingCases.size());

		Case insertedOnboardingCase = existingCases[0];

		System.assertNotEquals(null, returnedReference);
		System.assertEquals(new PageReference('/'+insertedOnboardingCase.Id).getUrl(), returnedReference.getUrl());

		List<Contact> existingRecruits = contactDao.findRecruits();
		System.assertEquals(true, existingRecruits.isEmpty());

		List<Contact> existingInternals = contactDao.findInternals();
		System.assertEquals(3, existingInternals.size());

		Contact convertedInternal = contactDao.addMailingFields().findContactById(recruit.Id);

		System.assertNotEquals(null, convertedInternal.BSexternalId__c);
		System.assertNotEquals(null, convertedInternal.joinDateBS__c);
		System.assertEquals(insertedOnboardingCase.NewUserProjectRole__c, convertedInternal.Title);
		System.assertEquals(insertedOnboardingCase.Leader__c, convertedInternal.ReportsToId);
		System.assertEquals(insertedOnboardingCase.Leader__c, convertedInternal.Leader__c);
		System.assertEquals(insertedOnboardingCase.Guardian__c, convertedInternal.Guardian__c);
		System.assertEquals(insertedOnboardingCase.NewUserEmail__c, convertedInternal.Email);
		System.assertEquals(insertedOnboardingCase.WorkStartDate__c, convertedInternal.joinDateBS__c);
		System.assertEquals(insertedOnboardingCase.ZipCode__c, convertedInternal.MailingPostalCode);
		System.assertEquals(insertedOnboardingCase.Street__c, convertedInternal.MailingStreet);
		System.assertEquals(insertedOnboardingCase.City__c, convertedInternal.MailingCity);
		System.assertEquals(insertedOnboardingCase.PersonalEmail__c, convertedInternal.PersonalEmail__c);
		System.assertEquals(insertedOnboardingCase.PersonalPhone__c, convertedInternal.PersonalPhone__c);
		System.assertEquals(insertedOnboardingCase.NewUserTitle__c, convertedInternal.Position__c);
		System.assertEquals(insertedOnboardingCase.Location__c, convertedInternal.Location__c);
		System.assertEquals(true, convertedInternal.SkillAssessment__c);
		System.assertEquals(insertedOnboardingCase.Freelancer__c, convertedInternal.Freelancer__c);

		List<BTN_Contract__c> existingContracts = new BTN_DAO_Contract().findByContactsIds(new Set<Id>{convertedInternal.Id});
		System.assertEquals(1, existingContracts.size());
	}

	@isTest
	static void saveInternalOnboarding_BSCalloutFailure_test(){
		Test.setMock(HttpCalloutMock.class, new BTN_BSS_SendToBSNewUser_Mock(BTN_BSS_SendToBSNewUser_Mock.STATUS_CODE_BAD_REQUEST));

		setupTestPage();

		BTN_DAO_Contact contactDao = new BTN_DAO_Contact();
		Contact recruit = contactDao.findRecruits()[0];
		Contact leader = contactDao.findLeaders()[0];

		BTN_NewInternalOnboardingController controller = setupController(recruit, leader);

		Test.startTest();

		PageReference returnedReference = controller.saveInternalOnboardingCase();

		Test.stopTest();

		List<Case> existingCases = new BTN_DAO_Case().findCases();
		System.assertEquals(1, existingCases.size());

		Case insertedOnboardingCase = existingCases[0];

		System.assertNotEquals(null, returnedReference);
		System.assertEquals(new PageReference('/'+insertedOnboardingCase.Id).getUrl(), returnedReference.getUrl());

		List<Contact> existingRecruits = contactDao.findRecruits();
		System.assertEquals(0, existingRecruits.size());

		List<Contact> existingInternals = contactDao.findInternals();
		System.assertEquals(3, existingInternals.size());

		Contact convertedInternal = contactDao.addMailingFields().findContactById(recruit.Id);

		System.assertEquals(null, convertedInternal.BSexternalId__c);

		List<BTN_Contract__c> existingContracts = new BTN_DAO_Contract().findByContactsIds(new Set<Id>{convertedInternal.Id});
		System.assertEquals(1, existingContracts.size());
	}

	@isTest
	static void saveInternalOnboarding_ExceptionCatchOnBsCallLevel_test(){
		Test.setMock(HttpCalloutMock.class, new BTN_BSS_SendToBSNewUser_Mock(BTN_BSS_SendToBSNewUser_Mock.STATUS_CODE_SUCCESS));

		setupTestPage();

		BTN_DAO_Contact contactDao = new BTN_DAO_Contact();
		Contact recruit = contactDao.findRecruits()[0];
		Contact leader = contactDao.findLeaders()[0];

		BTN_NewInternalOnboardingController controller = setupController(recruit, leader);

		controller.newInternalOnboardingCase.WorkStartDate__c = null;

		Test.startTest();

		PageReference returnedReference = controller.saveInternalOnboardingCase();

		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1, msgs.size());

		List<Case> existingCases = new BTN_DAO_Case().findCases();
		System.assertEquals(1, existingCases.size());

		Case insertedOnboardingCase = existingCases[0];

		System.assertNotEquals(null, returnedReference);
		System.assertEquals(new PageReference('/'+insertedOnboardingCase.Id).getUrl(), returnedReference.getUrl());

		List<Contact> existingRecruits = contactDao.findRecruits();
		System.assertEquals(0, existingRecruits.size());

		List<Contact> existingInternals = contactDao.findInternals();
		System.assertEquals(3, existingInternals.size());

		Contact convertedInternal = contactDao.addMailingFields().findContactById(recruit.Id);

		System.assertEquals(null, convertedInternal.BSexternalId__c);

		List<BTN_Contract__c> existingContracts = new BTN_DAO_Contract().findByContactsIds(new Set<Id>{convertedInternal.Id});
		System.assertEquals(1, existingContracts.size());
	}

	@isTest
	static void saveInternalOnboarding_ExceptionCatchOnContractCreation_test(){
		Test.setMock(HttpCalloutMock.class, new BTN_BSS_SendToBSNewUser_Mock(BTN_BSS_SendToBSNewUser_Mock.STATUS_CODE_SUCCESS));

		setupTestPage();

		BTN_BriteCRM_settings__c companySetting = BTN_BriteCRM_settings__c.getInstance(BTN_ConstantRepo.CUSTOM_SETTING_DEFAULT_CONTRACT_COMPANY);
		delete companySetting;

		BTN_DAO_Contact contactDao = new BTN_DAO_Contact();
		Contact recruit = contactDao.findRecruits()[0];
		Contact leader = contactDao.findLeaders()[0];

		BTN_NewInternalOnboardingController controller = setupController(recruit, leader);

		Test.startTest();

		PageReference returnedReference = controller.saveInternalOnboardingCase();

		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1, msgs.size());

		List<Case> existingCases = new BTN_DAO_Case().findCases();
		System.assertEquals(1, existingCases.size());

		Case insertedOnboardingCase = existingCases[0];

		System.assertNotEquals(null, returnedReference);
		System.assertEquals(new PageReference('/'+insertedOnboardingCase.Id).getUrl(), returnedReference.getUrl());

		List<Contact> existingRecruits = contactDao.findRecruits();
		System.assertEquals(0, existingRecruits.size());

		List<Contact> existingInternals = contactDao.findInternals();
		System.assertEquals(3, existingInternals.size());

		Contact convertedInternal = contactDao.addMailingFields().findContactById(recruit.Id);

		System.assertNotEquals(null, convertedInternal.BSexternalId__c);

		List<BTN_Contract__c> existingContracts = new BTN_DAO_Contract().findByContactsIds(new Set<Id>{convertedInternal.Id});
		System.assertEquals(0, existingContracts.size());
	}

	@isTest
	static void getProjectRoles_test(){
		setupTestPage();

		ApexPages.StandardController stdController = new ApexPages.StandardController(new Case());
		BTN_NewInternalOnboardingController controller = new BTN_NewInternalOnboardingController(stdController);

		Test.startTest();

		List<SelectOption> projectRoles = controller.getProjectRoles();

		Test.stopTest();

		System.assertNotEquals(true, projectRoles.isEmpty());
	}
}