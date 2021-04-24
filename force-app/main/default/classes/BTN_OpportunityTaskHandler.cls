/**
* @author Pawel Iwanowicz
* @date 20/05/2016
* @description BTN_OpportunityTaskHandler class designated to handle all actions regarding Tasks for Opportunities
*/
public class BTN_OpportunityTaskHandler {

    /**
    * @author Pawel Iwanowicz
    * @date 20/05/2016
    * @description deleteTasksCreatedAutomatically method - deletes tasks that were created automatically by the system
    * @param List<Opportunity>
    */
    @InvocableMethod(label='Delete Tasks' description='Deletes tasks that were created automatically by the system')
    public static void deleteTasksCreatedAutomatically(List<Opportunity> oppList) {

        Set<Id> opportunitiesIds = new Map<Id, Opportunity>(oppList).keySet();
        List<Task> tasksToChange = new List<Task>();

        for (Task singleTask : new BTN_DAO_Task().findTasksByParents(opportunitiesIds, true)) {
            singleTask.Status = BTN_ConstantRepo.TASK_STATUS_COMPLETED;
            tasksToChange.add(singleTask);
        }
        update tasksToChange;
    }
}