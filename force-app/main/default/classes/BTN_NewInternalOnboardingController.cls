/**
 * Created by Adam on 4/22/2018.
 */

public class BTN_NewInternalOnboardingController {
	public Case newInternalOnboardingCase { set; get; }
	public Contact sourceRecruit { set; get; }
	public String ownerName {
		get {
			return BTN_Utils.getCurrentUser().Name;
		}
	}


	public BTN_NewInternalOnboardingController(ApexPages.StandardController stdController) {
		this.newInternalOnboardingCase = (Case) stdController.getRecord();

		//New Onboarding ContactId param exist
		Id candidateId = ApexPages.currentPage().getParameters().get(BTN_ConstantRepo.URL_PARAM_CANDIDATE_ID);
		initialiseInternalOnboardingCase(candidateId);
	}

	private void initialiseInternalOnboardingCase(Id candidateId){
		BTN_CV__c candidate = (BTN_CV__c) new BTN_DAO_Candidate().findSObjectById(candidateId);

		if(candidate != null) {
			sourceRecruit = new BTN_DAO_Contact().addMailingFields().findContactById(candidate.Contact__c);
			this.newInternalOnboardingCase.Project_Manager_Email__c = candidate.Project_Manager_Email__c;
			this.newInternalOnboardingCase.NewUserTitle__c = candidate.Position_Name_frm__c;
			this.newInternalOnboardingCase.Resource_Request__c = candidate.ResourceRequest__c;
		} else {
			sourceRecruit = new BTN_DAO_Contact().addMailingFields().findContactById(newInternalOnboardingCase.ContactId);
		}

		if (this.newInternalOnboardingCase.Status == null) {
			this.newInternalOnboardingCase.Status = BTN_ConstantRepo.CASE_STATUS_OPEN;
		}

		this.newInternalOnboardingCase.RecordTypeId = BTN_RecordTypeUtils.getRecordTypeCaseInternalOnBoarding().Id;
		this.newInternalOnboardingCase.ContactId = sourceRecruit.Id;
		this.newInternalOnboardingCase.NewUserTitle__c = sourceRecruit.Position__c;
		this.newInternalOnboardingCase.PersonalPhone__c = sourceRecruit.PersonalPhone__c;
		this.newInternalOnboardingCase.PersonalEmail__c = sourceRecruit.PersonalEmail__c;
		this.newInternalOnboardingCase.City__c = sourceRecruit.CityLocation__c;
		this.newInternalOnboardingCase.NewUserTitle__c = sourceRecruit.Position__c;
		this.newInternalOnboardingCase.NewUserEmail__c = BTN_ContactUtils.setBritenetEmailForInternalContact(sourceRecruit);
		this.newInternalOnboardingCase.OwnerId = new BTN_DAO_Group().findGroupByName(BTN_ConstantRepo.QUEUE_HUMAN_RESOURCES).Id;
		this.newInternalOnboardingCase.Freelancer__c = sourceRecruit.Freelancer__c;

		if(sourceRecruit.Sex__c != null){
			this.newInternalOnboardingCase.Sex__c = sourceRecruit.Sex__c;
		}

		this.newInternalOnboardingCase.NewUserFirstName__c = sourceRecruit.FirstName;
		this.newInternalOnboardingCase.NewUserLastName__c = sourceRecruit.LastName;
	}

	/**
	 * @author Mateusz Przywara
	 * @date   2016-09-07
	 * @description getPageRecordTypeName
	 * @return Internal Onboarding Record Type Name
	*/
	public String getPageRecordTypeName() {
		return BTN_RecordTypeUtils.CASE_INTERNAL_ONBOARDING_RECORDTYPE;
	}

	/**
	 * @author Mateusz Przywara
	 * @date   2016-09-07
	 * @description addPageError
	*/
	public void addPageError(BTN_BSS_DTO.ResponseStatus response, String msg) {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.NewInternalOnboardingError));
		if ((!BTN_ValidationHandler.isNull(response)) && (!BTN_ValidationHandler.isNull(response.error))) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, response.error));
		}
		if (!BTN_ValidationHandler.isEmpty(msg)) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, msg));
		}
	}

	/**
	 * @author Adam Jedrys
	 * @date   2018-05-24
	 * @description saveInternalOnboardingCase
	*/
	public PageReference saveInternalOnboardingCase() {
		PageReference newCasesPageReference;

		if(newInternalOnboardingCase.NewUserProjectRoleId__c != null){
			newInternalOnboardingCase.NewUserProjectRole__c = BTN_ContactUtils.MAP_PROJECT_ROLE_DESC_BY_ID.get(Integer.valueOf(newInternalOnboardingCase.NewUserProjectRoleId__c));
		}

		newInternalOnboardingCase.NewUserB2B__c = newInternalOnboardingCase.ContractType__c != null && !newInternalOnboardingCase.ContractType__c.startsWith(BTN_ConstantRepo.CASE_CONTRACT_TYPE_UOP);

		// create user BS account
		if(sourceRecruit.BSexternalId__c == null){
			try {
				// get bs external ids for leader and guardian
				Map<Id, Decimal> leaderAndGuardianBSIdsBySalesforceIds = getRelatedContactsBSIds(newInternalOnboardingCase);

				// fill request body with data provided by user on the form
				Map<String, String> requestParamMap = BTN_CaseUtils.buildParamMapForNewBSUserFromCase(newInternalOnboardingCase, leaderAndGuardianBSIdsBySalesforceIds);

				// send request to BS to create new user
				BTN_BSS_DTO.ResponseStatus response = BTN_BSS_Service.sendToBSNewUser(requestParamMap);

				if (BTN_ValidationHandler.isUserAddedToBSWithSuccess(response)) {
					// update recruit contact to internal, save BS details
					BTN_ContactUtils.updateInternalContactWithBSAccountDetails(sourceRecruit.Id, response.user_id);
				} else {
					addPageError(response, null);
					notifyAboutFailure(response.error, null);
				}

			} catch(Exception e) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e.getMessage()));
				notifyAboutFailure(e.getMessage(), e.getStackTraceString());
			}
		}

		// upsert onboarding case
		try{
			upsert newInternalOnboardingCase;
		} catch(Exception e){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e.getMessage()));
			notifyAboutFailure(e.getMessage(), e.getStackTraceString());
		}

		// update recruit to internal, add onboarding details
		try {
			BTN_ContactUtils.updateToInternalWithOnboardingDetails(sourceRecruit.Id, newInternalOnboardingCase);
		} catch(Exception e){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e.getMessage()));
			notifyAboutFailure(e.getMessage(), e.getStackTraceString());
		}

		try {
			List<BTN_Contract__c> relatedContracts = new BTN_DAO_Contract().findByContactsIds(new Set<Id>{sourceRecruit.Id});
			if(relatedContracts.isEmpty()){
				BTN_ContractUtils.createContractFromOnboardingCase(newInternalOnboardingCase);
			}
		} catch (Exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e.getMessage()));
			notifyAboutFailure(e.getMessage(), e.getStackTraceString());
		}

		if(newInternalOnboardingCase.Id != null){
			newCasesPageReference = new PageReference('/' + newInternalOnboardingCase.Id);
		}

		return newCasesPageReference;
	}


	/**
	 * @author Adam Jedrys
	 * @date   2018-03-26
	 * @description
	*/

	private Map<Id, Decimal> getRelatedContactsBSIds(Case newInternalOnboardingCase){
		Set<Id> contactsIds = new Set<Id>();

		if(newInternalOnboardingCase.Leader__c != null)
			contactsIds.add(newInternalOnboardingCase.Leader__c);

		if(newInternalOnboardingCase.Guardian__c != null)
			contactsIds.add(newInternalOnboardingCase.Guardian__c);

		BTN_DAO_Contact contactDao = new BTN_DAO_Contact(new List<Schema.SObjectField>{Contact.BSexternalId__c});
		List<Contact> contacts = contactDao.findContactsByIds(contactsIds);

		Map<Id, Decimal> relatedContactsBSIdsBySalesforceIds = new Map<Id, Decimal>();

		for(Contact c : contacts)
			relatedContactsBSIdsBySalesforceIds.put(c.Id, c.BSexternalId__c);

		return relatedContactsBSIdsBySalesforceIds;
	}

	/**
	 * @author Adam Jedrys
	 * @date   2018-05-23
	 * @description
	*/

	private void notifyAboutFailure(String errorMessage, String stackTrace){
		String emailBody = 'Message: ' + errorMessage;
		if(String.isNotBlank(stackTrace))
			emailBody += '\n\nStack trace: ' + stackTrace;
		BTN_Email_Utils.sendWarningEmailToAdmin('Failure on internal onboarding for contact: ' + sourceRecruit.Name + ', ' + sourceRecruit.Id, emailBody);
	}

	/**
	 * @author Mateusz Przywara
	 * @date   2016-09-28
	 * @description getProjectRoles
	*/
	public List<SelectOption> getProjectRoles() {
		List<SelectOption> result = new List<SelectOption>{
				BTN_Utils.getNullSelectOption()
		};
		for (Integer keyItem : BTN_ContactUtils.MAP_PROJECT_ROLE_DESC_BY_ID.keySet()) {
			result.add(
					new SelectOption(
							String.valueOf(keyItem),
							BTN_ContactUtils.MAP_PROJECT_ROLE_DESC_BY_ID.get(keyItem)
					)
			);
		}
		return result;
	}
}