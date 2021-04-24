@isTest
private class BTN_ContractUtils_Test {
    private static final String PROJECT_ROLE_SALESFORCE = 'Salesforce';
    private static final String NOTICE_PERIOD_IMMEDIATE = 'Od zaraz';
    private static final String CONTRACT_LENGTH_UNDEFINED = 'Nieokreślony';
    private static final String CONTRACT_TYPE_B2B = 'B2B';

    private static Account britenet;
    private static Account customer;
    private static Contact recruit;
    private static Contact leader;
    private static Contact guardian;
    private static Case onboarding;

    @testSetup static void createDataStructure() {
        BTN_TestDataFactory.getHRCollaborationGroup();
        britenet = BTN_TestDataFactory.getBriteNetAccount();
        customer = BTN_AccountBuilderHelper.buildWithPrivateSectorRecordType().save();
        recruit = BTN_TestDataFactory.getRecruitContact(britenet.Id);
        leader = BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .withFirstName('Test')
                .withLastName('Leader')
                .withAccount(britenet.Id)
                .withEmail('test.leader@britenet.com.pl')
                .save();
        guardian = BTN_ContactBuilderHelper.buildWithInternalRecordType()
                .withFirstName('Test')
                .withLastName('Guardian')
                .withAccount(britenet.Id)
                .withEmail('test.guardian@britenet.com.pl')
                .save();
        recruit.Leader__c = leader.Id;
        recruit.Guardian__c = guardian.Id;
        update recruit;

        onboarding = BTN_CaseBuilderHelper.buildWithExternalOnBoardingRecordType().get();
        onboarding.AccountId = customer.Id;
        onboarding.ContactId = recruit.Id;
        onboarding.NewUserProjectRole__c = PROJECT_ROLE_SALESFORCE;
        onboarding.SalaryB2B__c = 40.0;
        onboarding.ContractLength__c = CONTRACT_LENGTH_UNDEFINED;
        onboarding.ContractType__c = CONTRACT_TYPE_B2B;
        onboarding.WorkStartDate__c = Date.today().addDays(7);
        onboarding.NoticePeriod__c = NOTICE_PERIOD_IMMEDIATE;
        onboarding.Description = 'Test Description';
        onboarding.Status = BTN_ConstantRepo.CASE_STATUS_OPEN;
        insert onboarding;

        BTN_BriteCRM_settings__c setting = new BTN_BriteCRM_settings__c(
                Name = 'Default Contract Company',
                Value__c = britenet.Id
        );
        insert setting;
    }

    @isTest
    static void testCreateContractFromonboarding() {
        getTestData();

        Database.SaveResult result = BTN_ContractUtils.createContractFromOnboardingCase(onboarding);
        System.assert(result.isSuccess());

        Integer contractsCount = [
                SELECT COUNT()
                FROM BTN_Contract__c
                WHERE Contact__c = :recruit.Id
                    AND ContractLength__c = :CONTRACT_LENGTH_UNDEFINED
                    AND ContractType__c = :CONTRACT_TYPE_B2B
                    AND NoticePeriod__c = :NOTICE_PERIOD_IMMEDIATE
                    AND SalaryB2B__c = 40.0
                    AND StartDate__c = :onboarding.WorkStartDate__c
        ];
        System.assertEquals(1, contractsCount);
    }

    private static void getTestData() {
        onboarding = [
                SELECT Id, AccountId, ContactId, NewUserProjectRole__c, SalaryB2B__c, SalaryUoP__c, ContractLength__c,
                        ContractType__c, WorkStartDate__c, WorkStartDateComment__c, NoticePeriod__c, Notice_Period_Comment__c,
                        Description, EndDate__c, WorkEndDate__c, Responsibilities__c
                FROM Case
                LIMIT 1
        ][0];
        recruit = [
                SELECT Id
                FROM Contact
                WHERE RecordType.Name = :BTN_RecordTypeUtils.CONTACT_RECRUIT_RECORDTYPE
                LIMIT 1
        ][0];
        leader = [
                SELECT Id
                FROM Contact
                WHERE RecordType.Name = :BTN_RecordTypeUtils.CONTACT_INTERNAL_RECORDTYPE
                    AND LastName = 'Leader'
        ][0];
    }
}