/**
 * @author Mateusz Przywara
 * @date   2016-08-18
 * @description DAO class - Data Access Object for Case
 */
public class BTN_DAO_Case extends BTN_DAO {
    /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description Constructor
    */
    public BTN_DAO_Case() {
        addRecordTypeFields();
    }

    public override Schema.SObjectType getSObjectType() {
        return Case.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                Case.Id,
                Case.Assignment__c,
                Case.ContactId,
                Case.AccountId,
                Case.ContactLastDayAtWork__c,
                Case.UserEndDate__c,
                Case.NewUserFirstName__c,
                Case.NewUserLastName__c,
                Case.AssignmentEndDate__c,
                Case.AssignmentStartDate__c,
                Case.City__c,
                Case.ContractLength__c,
                Case.NewUserEmail__c,
                Case.Location__c,
                Case.NewUserB2B__c,
                Case.OtherLocation__c,
                Case.PersonalEmail__c,
                Case.PersonalPhone__c,
                Case.NewUserTitle__c,
                Case.Responsibilities__c,
                Case.SalaryUoP__c,
                Case.SalaryB2B__c,
                Case.NewUserProjectRole__c,
                Case.Sex__c,
                Case.WorkStartDateComment__c,
                Case.ZipCode__c,
                Case.Recommender__c,
                Case.WorkStartDate__c,
                Case.WorkEndDate__c,
                Case.Notice_Period_Comment__c,
                Case.NoticePeriod__c,
                Case.Freelancer__c,
                Case.Leader__c,
                Case.Guardian__c,
                Case.Street__c
        };
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-18
         * @description add Record Type fields to Query
         * @return void
         */
    public void addRecordTypeFields() {
        currentFields.add('RecordType.DeveloperName');
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-18
         * @description find all Cases
         * @return List<Contact>
         */
    public List<Case> findCases() {
        return findSObjects();
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-18
         * @description find Cases added to SFDC from BSS
         * @return List<Case>
         */
    public List<Case> findExternalOnboardingCases() {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'RecordType.DeveloperName',
                                '=',
                                BTN_ConstantRepo.CASE_EXTERNAL_ONBOARDING_RECORDTYPE
                        )
                }
        );
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-24
         * @description findCaseById find Case
         * @return Case
         */
    public Case findCaseById(Id caseId) {
        return (Case) findSObjectById(caseId);
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-18
         * @description find Cases added to SFDC from BSS
         * @return List<Case>
         */
    public List<Case> findExternalOffboardingCases() {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'RecordType.DeveloperName',
                                '=',
                                BTN_ConstantRepo.CASE_EXTERNAL_OFFBOARDING_RECORDTYPE
                        )
                }
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-30
     * @description find Cases for specified Ids
     * @return List<Case> - found Cases in arranged List
    */
    public List<Case> findCasesInIdSet(Set<Id> caseIdSet) {
        return (List<Case>) findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('Id', 'IN', caseIdSet)
                }
        );
    }
}