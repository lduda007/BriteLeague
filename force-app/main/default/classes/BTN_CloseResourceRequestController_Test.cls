/**
 * Created by Adam on 12/20/2017.
 */

@IsTest(seeAllData=false)
private class BTN_CloseResourceRequestController_Test
{
	static final Integer CONTACT_REQUESTOR = 0;
	static final Integer CONTACT_INTERNAL = 1;
	static final Integer CONTACT_RECRUIT = 2;

	static final String INITIAL_RR_STATUS = 'Open';
	static final String UPDATED_RR_STATUS = 'Closed - Success';
	static final String INITIAL_CANDIDATE_STATUS = 'Open';
	static final String UPDATED_CANDIDATE_1_STATUS = 'Contract signed';
	static final String UPDATED_CANDIDATE_2_STATUS = 'Rejected by us';

	static final String COLLABORATION_GROUP_NAME = 'BlahGroup';

	static Account britenetAccount;
	static Account clientAccount;

	static List<Contact> britenetContacts;
	static Contact clientContact;

	static BTN_ResourceRequest__c resourceRequest;
	static List<BTN_CV__c> resourceRequestCandidates;
	static BTN_CloseResourceRequestController controllerExtension;

	static Contact requestor;

	@TestSetup
	static void createDataModel(){
		BTN_TestDataFactory.getTriggerSkipperCustomSetting();

		setCollaborationGroup();
		setBritenetAccount();
		setClientAccount();
		setBritenetContacts();
		setClientContacts();
		setOpportunity();
		setResourceRequest();
		setCandidates();
	}

	static testMethod void testGetCandidates(){
		prepControllerExtension();

		Test.startTest();

		List<BTN_CV__c> queriedCandidates = controllerExtension.getCandidates();

		Test.stopTest();

		System.assertEquals(resourceRequestCandidates.size(), queriedCandidates.size());
	}

	static testMethod void testGetCandidatesUnsuccessful(){
		prepControllerExtension();

		controllerExtension.resourceRequest = null;

		Test.startTest();

		List<BTN_CV__c> queriedCandidates = controllerExtension.getCandidates();

		Test.stopTest();

		System.assertEquals(null, queriedCandidates);
	}

	static testMethod void testSaveSuccessful(){
		prepControllerExtension();

		controllerExtension.getCandidates();

		controllerExtension.resourceRequest.Status__c = UPDATED_RR_STATUS;
		controllerExtension.candidates[0].Status__c = UPDATED_CANDIDATE_1_STATUS;
		controllerExtension.candidates[1].Status__c = UPDATED_CANDIDATE_2_STATUS;

		Test.startTest();

		PageReference returnedReference = controllerExtension.save();

		Test.stopTest();

		System.assertNotEquals(null, returnedReference);

		resourceRequest = [SELECT Status__c FROM BTN_ResourceRequest__c WHERE Id = :resourceRequest.Id][0];
		System.assertEquals(UPDATED_RR_STATUS, resourceRequest.Status__c);

		List<BTN_CV__c> candidates = new BTN_DAO_Candidate().findCandidatesByResourceRequest(resourceRequest.Id);
		System.assertEquals(resourceRequestCandidates.size(), candidates.size());
		System.assertNotEquals(INITIAL_CANDIDATE_STATUS, candidates[0].Status__c);
		System.assertNotEquals(INITIAL_CANDIDATE_STATUS, candidates[1].Status__c);
	}

	static testMethod void testSaveUnsuccessful(){
		prepControllerExtension();

		controllerExtension.getCandidates();

		controllerExtension.resourceRequest.Status__c = UPDATED_RR_STATUS;

		Test.startTest();

		PageReference returnedReference = controllerExtension.save();

		Test.stopTest();

		System.assertEquals(null, returnedReference);
	}

	static testMethod void testCancel(){
		prepControllerExtension();

		Test.startTest();

		PageReference returnedReference = controllerExtension.cancel();

		Test.stopTest();

		System.assertNotEquals(null, returnedReference);
	}

	static void setCollaborationGroup(){
		BTN_TestDataFactory.getHRCollaborationGroup();
	}

	static void setBritenetAccount(){
		britenetAccount = new Account(
				Name = BTN_ConstantRepo.BRITENET_ACCOUNT_NAME,
				CurrencyIsoCode = BTN_TestDataFactory.TESTCURRENCY,
				RecordTypeId = BTN_RecordTypeUtils.getRecordTypeAccountBritenet().Id
		);
		insert britenetAccount;
	}

	static void setClientAccount(){
		clientAccount = new Account(
				Name = BTN_ConstantRepo.ACCOUNT_PRIVATE_NAME,
				CurrencyIsoCode = BTN_TestDataFactory.TESTCURRENCY,
				RecordTypeId = BTN_RecordTypeUtils.getRecordTypeAccountPrivateSector().Id
		);
		insert clientAccount;
	}

	static void setBritenetContacts(){
		requestor = new Contact(
				AccountId = britenetAccount.Id,
				FirstName = 'Britenet',
				LastName = 'Requestor',
				ResourceRequestor__c = true,
				Email = 'requestor' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL,
				RecordTypeId = BTN_RecordTypeUtils.getRecordTypeContactInternal().Id
		);
		
		Contact internal = new Contact(
				AccountId = britenetAccount.Id,
				FirstName = 'Britenet',
				LastName = 'Internal',
				ResourceRequestor__c = true,
				Email = 'internal' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL,
				RecordTypeId = BTN_RecordTypeUtils.getRecordTypeContactInternal().Id
		);

		Contact recruit = new Contact(
				AccountId = britenetAccount.Id,
				FirstName = 'Britenet',
				LastName = 'Recruit',
				ResourceRequestor__c = true,
				Email = 'recruit' + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL,
				RecordTypeId = BTN_RecordTypeUtils.getRecordTypeContactRecruit().Id
		);

		britenetContacts = new List<Contact>{ requestor, internal, recruit };
		insert britenetContacts;
	}

	static void setClientContacts(){
		clientContact = new Contact(
				AccountId = clientAccount.Id,
				FirstName = 'Some',
				LastName = 'Client',
				ResourceRequestor__c = true,
				Email = 'some@client.com',
				RecordTypeId = BTN_RecordTypeUtils.getRecordTypeContactBusiness().Id
		);
		insert clientContact;
	}

	static void setOpportunity(){
		Opportunity opportunity = new Opportunity(
				AccountId = clientAccount.Id,
				ContactId__c = clientContact.Id,
				Name = 'clientOpportunity',
				StageName = 'Draft',
				CloseDate = (System.today() + 15),
				CurrencyIsoCode = BTN_TestDataFactory.testCurrency,
				Pricebook2Id = Test.getStandardPricebookId(),
				NextStep__c = 'dummy stepping',
				NextStepDeadline__c = (System.today() + 10),
				ContractStart__c = Date.newInstance(2000, 1, 1),
				ContractEnd__c = Date.newInstance(2010, 1, 1),
				Description = 'sample Description',
				Location__c = 'Lublin',
				Product_Main_Skills__c = 'main skillzz',
				Product_Secondary_Skills__c = 'sec600',
				Type = 'T&M'
		);
		insert opportunity;

		opportunity.StageName = 'In progress';
		update opportunity;
	}

	static void setResourceRequest(){
		resourceRequest = new BTN_DAO_ResourceRequest().findAutoResourceRequests()[0];
		resourceRequest.Resource_Manager__c = requestor.Id;
		update resourceRequest;
	}

	static void setCandidates(){
		BTN_CV__c internalCandidate = new BTN_CV__c(
				ResourceRequest__c = resourceRequest.Id,
				Contact__c = britenetContacts.get(CONTACT_INTERNAL).Id,
				Status__c = INITIAL_CANDIDATE_STATUS
		);

		BTN_CV__c recruitCandidate = new BTN_CV__c(
				ResourceRequest__c = resourceRequest.Id,
				Contact__c = britenetContacts.get(CONTACT_RECRUIT).Id,
				Status__c = INITIAL_CANDIDATE_STATUS
		);

		resourceRequestCandidates = new List<BTN_CV__c>{ internalCandidate, recruitCandidate };
		insert resourceRequestCandidates;
	}

	static void prepControllerExtension(){
		resourceRequest = new BTN_DAO_ResourceRequest().findAutoResourceRequests()[0];
		resourceRequestCandidates = new BTN_DAO_Candidate().findCandidatesByResourceRequest(resourceRequest.Id);

		PageReference closeResourceRequestPage = Page.BTN_CloseResourceRequest;
		closeResourceRequestPage.getParameters().put('id', resourceRequest.Id);
		Test.setCurrentPage(closeResourceRequestPage);

		ApexPages.StandardController standardController = new ApexPages.StandardController(resourceRequest);
		controllerExtension = new BTN_CloseResourceRequestController(standardController);
	}
}