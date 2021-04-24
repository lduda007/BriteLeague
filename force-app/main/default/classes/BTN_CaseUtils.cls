/**
 * @author Mateusz Przywara
 * @date   2016-08-22
 * @description Utils class for Record Type
 */
public class BTN_CaseUtils {
    private static final String TRIGGER_ERROR_SOURCE = 'Case Trigger';
    private static final String CONTACT_FIRSTNAME_PARAM = 'user_fname';
    private static final String CONTACT_LASTNAME_PARAM = 'user_lname';
    private static final String CONTACT_SEX_PARAM = 'user_sex';
    private static final String CONTACT_MAIL_PARAM = 'user_mail';
    private static final String CONTACT_JOINDATE_PARAM = 'user_join_date';
    private static final String CONTACT_B2B_PARAM = 'user_b2b';
    private static final String CONTACT_TITLE_PARAM = 'user_title';
    private static final String CONTACT_PROJECT_ROLE_ID_PARAM = 'user_projectrole';
    private static final String CONTACT_PERSONAL_PHONE_PARAM = 'user_phone';
    private static final String CONTACT_LEADER_ID_PARAM = 'user_leader_id';
    private static final String CONTACT_GUARDIAN_ID_PARAM = 'user_guardian_id';
    private static final String CONTACT_IS_FREELANCER = 'user_is_freelancer';

    public static final String STATUS_OPEN = 'Open';

    /**
     * @author Mateusz Przywara
     * @date   2016-08-19
     * @description buildParamMapForNewBSUserFromContact Method build Map on the Contact Data
     *      for Britesheet.
     * @param contactUser SFDC Contact - source of Data for new BS User
     * @return Map<String, String> Params Map with values for request body
    */
    public static Map<String, String> buildParamMapForNewBSUserFromCase(Case caseUser) {
        Map<String, String> result = new Map<String, String>();
        result.put(CONTACT_FIRSTNAME_PARAM, caseUser.NewUserFirstName__c);
        result.put(CONTACT_LASTNAME_PARAM, caseUser.NewUserLastName__c);
        result.put(CONTACT_SEX_PARAM, String.valueOf(caseUser.Sex__c).left(1));
        result.put(CONTACT_MAIL_PARAM, caseUser.NewUserEmail__c);
        result.put(CONTACT_JOINDATE_PARAM, ((DateTime)caseUser.WorkStartDate__c).format(System.Label.BSDateFormat));
        result.put(CONTACT_B2B_PARAM, String.valueOf(caseUser.NewUserB2B__c));
        result.put(CONTACT_TITLE_PARAM, caseUser.NewUserTitle__c);
        result.put(CONTACT_PROJECT_ROLE_ID_PARAM, String.valueOf(caseUser.NewUserProjectRoleId__c));
        result.put(CONTACT_PERSONAL_PHONE_PARAM, caseUser.PersonalPhone__c);
        result.put(CONTACT_IS_FREELANCER, String.valueOf(caseUser.Freelancer__c));
        if (caseUser.Leader__r.BSexternalId__c != null) {
            result.put(CONTACT_LEADER_ID_PARAM, String.valueOf(caseUser.Leader__r.BSexternalId__c));
        }
        if (caseUser.Guardian__r.BSexternalId__c != null) {
            result.put(CONTACT_GUARDIAN_ID_PARAM, String.valueOf(caseUser.Guardian__r.BSexternalId__c));
        }
        return result;
    }

	public static Map<String, String> buildParamMapForNewBSUserFromCase(Case newInternalOnboardingCase, Map<Id, Decimal> leaderAndGuardianBSIdsBySalesforceIds) {
		Map<String, String> result = new Map<String, String>();

		result.put(CONTACT_FIRSTNAME_PARAM, newInternalOnboardingCase.NewUserFirstName__c);
		result.put(CONTACT_LASTNAME_PARAM, newInternalOnboardingCase.NewUserLastName__c);
		result.put(CONTACT_SEX_PARAM, String.valueOf(newInternalOnboardingCase.Sex__c).left(1));
		result.put(CONTACT_MAIL_PARAM, newInternalOnboardingCase.NewUserEmail__c);
		result.put(CONTACT_JOINDATE_PARAM, ((DateTime)newInternalOnboardingCase.WorkStartDate__c).format(System.Label.BSDateFormat));
		result.put(CONTACT_B2B_PARAM, String.valueOf(newInternalOnboardingCase.NewUserB2B__c));
		result.put(CONTACT_TITLE_PARAM, newInternalOnboardingCase.NewUserTitle__c);
		result.put(CONTACT_PROJECT_ROLE_ID_PARAM, String.valueOf(newInternalOnboardingCase.NewUserProjectRoleId__c));
		result.put(CONTACT_PERSONAL_PHONE_PARAM, newInternalOnboardingCase.PersonalPhone__c);
		result.put(CONTACT_IS_FREELANCER, String.valueOf(newInternalOnboardingCase.Freelancer__c));

		if (newInternalOnboardingCase.Leader__c != null) {
			result.put(CONTACT_LEADER_ID_PARAM, String.valueOf(leaderAndGuardianBSIdsBySalesforceIds.get(newInternalOnboardingCase.Leader__c)));
		}

		if (newInternalOnboardingCase.Guardian__c != null) {
			result.put(CONTACT_GUARDIAN_ID_PARAM, String.valueOf(leaderAndGuardianBSIdsBySalesforceIds.get(newInternalOnboardingCase.Guardian__c)));
		}

		return result;
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-08-24
     * @description updateInternalContactBSExternalId update Contact by BS response.
     * @param contactId Contact to be updated
     * @param bsId BS External Id from response
     * @param projectRole Project Role Name to fill Contact title
     * @param leaderId Leader(SFDC Contact) selected on New Internal Onboarding form
     * @return Contact Updated Contact with only necessary fields
    */
    public static Contact updateInternalContactBSExternalId(Id contactId, Integer bsId, Case onboardingCase) {
        Contact result = new Contact(
                Id = contactId,
                RecordTypeId = BTN_RecordTypeUtils.getRecordTypeContactInternal().Id,
                BSexternalId__c = bsId,
                Title = onboardingCase.NewUserProjectRole__c,
                ReportsToId = onboardingCase.Leader__c,
                Leader__c = onboardingCase.Leader__c,
                Guardian__c = onboardingCase.Guardian__c,
                Email = onboardingCase.NewUserEmail__c,
                joinDateBS__c = onboardingCase.WorkStartDate__c,
                MailingPostalCode = onboardingCase.ZipCode__c,
                MailingStreet = onboardingCase.Street__c,
                MailingCity = onboardingCase.City__c,
                PersonalEmail__c = onboardingCase.PersonalEmail__c,
                PersonalPhone__c = onboardingCase.PersonalPhone__c,
                Position__c = onboardingCase.NewUserTitle__c,
                Location__c = onboardingCase.Location__c,
                SkillAssessment__c = true,
                Freelancer__c = onboardingCase.Freelancer__c
        );
        update result;
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-31
     * @description updateCaseContactInfo
     * @param caseItemToUpdate Case being updated
     * @param contactId Source of Contact Id for Case
     * @return Case
    */
    public static Case updateCaseContactInfo(Case caseItemToUpdate, Id contactId) {
        caseItemToUpdate.ContactId = contactId;
        update caseItemToUpdate;
        return caseItemToUpdate;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-01
     * @description executeCaseStandardAssignmentRule Execute Assignment Rule from Apex Code to Assign Ownership to
     *  Resource Managment Queue
     * @param caseIds Case Ids
     * @return
    */
    public static void executeCaseStandardAssignmentRule(Set<Id> caseIds) {
        List<Case> cases = new BTN_DAO_Case().findCasesInIdSet(caseIds);
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        Id caseAssignmentRuleId =
                new BTN_DAO_AssignmentRule().findCaseAssignmentRule().Id;
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        for (Case caseItem : cases) {
            caseItem.setOptions(dmlOpts);
        }
        update cases;
    }

    public static void addCaseSharingForLeader(List<Case> caseList){
        List<CaseShare> caseShareToInsert = new List<CaseShare>();
        Map<Id,Id> contactToUserMap = BTN_Utils.getContactToUserMap(BTN_Utils.getSetOfIds(caseList,'Leader__c'));

        for(Case newCase : caseList){
            if(contactToUserMap.get(newCase.Leader__c) != null && !newCase.Freelancer__c) {
                CaseShare share = new CaseShare();
                share.CaseAccessLevel = 'Edit';
                share.CaseId = newCase.Id;
                share.RowCause = 'Manual';
                share.UserOrGroupId = contactToUserMap.get(newCase.Leader__c);
                caseShareToInsert.add(share);
            }
        }
        insert caseShareToInsert;
    }

    public static void replaceCaseSharingForLeader(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        List<Case> caseToInsert = new List<Case>();
        Map<Id,Id> caseToDelete = new Map<Id,Id>();

        for(Id caseId : newCaseMap.keySet()){
            if(newCaseMap.get(caseId).Leader__c != oldCaseMap.get(caseId).Leader__c){
                caseToInsert.add(newCaseMap.get(caseId));
                caseToDelete.put(oldCaseMap.get(caseId).Leader__c, caseId);
            }
        }
        addCaseSharingForLeader(caseToInsert);
        removeCaseSharingForLeader(caseToDelete);
    }

    public static void removeCaseSharingForLeader(Map<Id,Id> caseMap){
        Map<Id,Id> contactToUserMap = BTN_Utils.getContactToUserMap(caseMap.keySet());

        List<CaseShare> caseShareToDelete = [select id from CaseShare where CaseId in : caseMap.values()
                                                and UserOrGroupId in: contactToUserMap.values()];
        delete caseShareToDelete;
    }
}