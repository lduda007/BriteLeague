@isTest
private class BTN_OpportunityTaskHandler_Test {
    
    @isTest static void testReduntantTaskStatusInFlow() {
        BTN_DAO_Task taskDAO = new BTN_DAO_Task();
        Id pbId = Test.getStandardPricebookId();
        List<Opportunity> oppoList = new List<Opportunity>();
        Opportunity oppoIgniter = BTN_TestDataFactory.getOpportunity(pbId);
        oppoList.add(oppoIgniter);
        insert new Task(Subject = 'testing',
                Priority = BTN_ConstantRepo.NEW_OPPORTUNITY_TASK_PRIORITY_NORMAL,
                Status = BTN_ConstantRepo.NEW_OPPORTUNITY_TASK_STATUS_OPEN,
                WhatId = oppoIgniter.Id,
                Is_Automatically_Created__c = true);

        BTN_OpportunityTaskHandler.deleteTasksCreatedAutomatically(oppoList);

        System.assert(
                taskDAO.findTasksByParent(oppoIgniter.Id).get(0).Status == BTN_ConstantRepo.TASK_STATUS_COMPLETED);
    }
}