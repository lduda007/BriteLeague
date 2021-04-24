@isTest
private class BTN_OpportunitySpecificTask_Test {

    @isTest static void testReduntantTaskStatusInFlow() {
        Id pbId = Test.getStandardPricebookId();
        List<Opportunity> oppoList = new List<Opportunity>();
        Opportunity oppoIgniter = BTN_TestDataFactory.getOpportunity(pbId);
        oppoList.add(oppoIgniter);
        Task newTask = new Task(Subject = BTN_ConstantRepo.TASK_SUBJECT,
                Priority = BTN_ConstantRepo.NEW_OPPORTUNITY_TASK_PRIORITY_NORMAL,
                Status = BTN_ConstantRepo.NEW_OPPORTUNITY_TASK_STATUS_OPEN,
                WhatId = oppoIgniter.Id,
                Is_Automatically_Created__c = true);

        insert newTask;

        BTN_OpportunitySpecificTask.deleteSpecificTaskCreatedAutomatically(oppoList);
        System.assertEquals(BTN_ConstantRepo.TASK_STATUS_COMPLETED, new BTN_DAO_Task().findTaskById(newTask.Id).Status);
    }
}