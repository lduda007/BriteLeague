/**
 * @author Mateusz Przywara
 * @date   2016-12-14
 * @description BTN_ContractUtils Utility Class provides utils for BTN_Contract sObject - Contracts contains
 * employment details.
 */
public class BTN_ContractUtils {

    /**
     * @author Mateusz Przywara
     * @date   2016-12-14
     * @description createContractFromOnboardingCase
     * @param sourceInternalOnboarding Case with filled up Employment info section
     * @return Database.SaveResult Insert new BTN_Contract Result
    */
    public static Database.SaveResult createContractFromOnboardingCase(Case sourceInternalOnboarding) {
        BTN_Contract__c newContract = new BTN_Contract__c(
                Description__c = sourceInternalOnboarding.Description,
                Contact__c = sourceInternalOnboarding.ContactId,
                ContractLength__c = sourceInternalOnboarding.ContractLength__c,
                ContractType__c = sourceInternalOnboarding.ContractType__c,
                EndDate__c = sourceInternalOnboarding.EndDate__c,
                NoticePeriod__c = sourceInternalOnboarding.NoticePeriod__c,
                NoticePeriodComment__c = sourceInternalOnboarding.Notice_Period_Comment__c,
                Responsibilities__c = sourceInternalOnboarding.Responsibilities__c,
                SalaryB2B__c = sourceInternalOnboarding.SalaryB2B__c,
                SalaryUoP__c = sourceInternalOnboarding.SalaryUoP__c,
                StartDate__c = sourceInternalOnboarding.WorkStartDate__c,
                StartDateComment__c = sourceInternalOnboarding.WorkStartDateComment__c,
                Company__c = BTN_Utils.getBTNPropertyValue('Default Contract Company')
        );
        return Database.insert(newContract);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-12-14
     * @description createTaskForContactLeader
     * @param List<BTN_Contract__c> Contracts created on Onboarding etc.
     * @return Database.SaveResult Insert new Task Result
    */
    public static List<Database.SaveResult> createTaskForContactLeader(List<BTN_Contract__c> sourceContracts) {
        List<Task> outputTasks = new List<Task>();
        Set<Id> contactIds = new Set<Id>();
        for (BTN_Contract__c item : sourceContracts) {
            contactIds.add(item.Contact__c);
        }
        List<User> leaderUsers = new List<User>(new BTN_DAO_User().findUsersByContactIds(contactIds));
        if (!leaderUsers.isEmpty()) {
            for (BTN_Contract__c contractItem : sourceContracts) {
                outputTasks.add(new Task(
                        ActivityDate = contractItem.EndDate__c,
                        OwnerId = getLeaderForTaskByContactId(contractItem.Contact__c, leaderUsers), //LEADER(User) of
                        // Contact of Contract
                        Priority = BTN_ConstantRepo.NEW_OPPORTUNITY_TASK_PRIORITY_NORMAL,
                        WhoId = contractItem.Contact__c,
                        Subject = System.Label.ContractTaskSubject,
                        Status = BTN_ConstantRepo.NEW_OPPORTUNITY_TASK_STATUS_OPEN,
                        Is_Automatically_Created__c = false, //flag for Opportunity Tasks(flow: Task Reminders)
                        WhatId = contractItem.Id
                ));
            }
        }
        return Database.insert(outputTasks);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-12-14
     * @description createTaskForResourceManager
     * @param List<BTN_Contract__c> Contracts created on Onboarding etc.
     * @return Database.SaveResult Insert new Task Result
    */
    public static List<Database.SaveResult> createTaskForResourceManager(List<BTN_Contract__c> sourceContracts) {
        List<Task> outputTasks = new List<Task>();
        User rmUser = new BTN_DAO_User().findUserByName(BTN_ConstantRepo.RM_USERNAME);
        if (rmUser != null) {
            for (BTN_Contract__c contractItem : sourceContracts) {
                outputTasks.add(new Task(
                        ActivityDate = contractItem.EndDate__c,
                        OwnerId = rmUser.Id, // RM User
                        Priority = BTN_ConstantRepo.NEW_OPPORTUNITY_TASK_PRIORITY_NORMAL,
                        WhoId = contractItem.Contact__c,
                        Subject = System.Label.ContractTaskSubject,
                        Status = BTN_ConstantRepo.NEW_OPPORTUNITY_TASK_STATUS_OPEN,
                        Is_Automatically_Created__c = false, //flag for Opportunity Tasks(flow: Task Reminders)
                        WhatId = contractItem.Id
                ));
            }
        }
        return Database.insert(outputTasks);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-12-15
     * @description getLeaderForTaskByContactId
     * @param List<BTN_Contract__c> Contracts created on Onboarding etc.
     * @return Id - found User Id
    */
    private static Id getLeaderForTaskByContactId(Id contactId, List<User> users) {
        Id result;
        for (User userItem : users) {
            if (userItem.ContactId.equals(contactId)) {
                result = userItem.Id;
                break;
            }
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-12-15
     * @description createTasks
     * @param List<BTN_Contract__c> Contracts created on Onboarding etc.
    */
    @InvocableMethod(label='Create Contract Tasks' description='Creates Tasks(2) for Contract')
    public static void createTasks(List<BTN_Contract__c> contracts) {
        createTaskForResourceManager(contracts);
        createTaskForContactLeader(contracts);
    }
}