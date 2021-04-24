/**
 * @author Mateusz Przywara
 * @date   2016-07-12
 * @description DAO class - Data Access Object for Task
*/
public class BTN_DAO_Task extends BTN_DAO {
  /**
     * @author Mateusz Przywara
     * @date   2016-07-12
     * @description Constructor
    */
    public BTN_DAO_Task() {
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-12
     * @description Constructor setting custom List of fields
    */
    public BTN_DAO_Task(List<Schema.SObjectField> customFields) {
        setCustomFields(customFields);
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description find Attachment
         * @param  attachmentName - Name of Account to search for
         * @return     Attachment       - found Attachment
         */
    public Task findTaskById(Id taskId) {
        return (Task) findSObjectById(taskId);
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description find Tasks
         * @param  parentId - Id of Parent sObject to search for
         * @return     Task       - found Task
         */
    public List<Task> findTasksByParent(Id parentId) {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('WhatId', '=', parentId)
                }
        );
    }
    public override Schema.SObjectType getSObjectType() {
        return Task.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                Task.Id,
                Task.Is_Automatically_Created__c,
                Task.Subject,
                Task.Status,
                Task.WhatId
        };
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description find Attachments to provided list of sObjects
         * @param setOfSObjectIds Set of Parent Ids
         * @param automaticallyCreatedTasks Return Automatically created tasks or not
         * @return List<Attachment> - found Attachments
        */
    public List<Task> findTasksByParents(Set<Id> setOfSObjectIds, Boolean automaticallyCreatedTasks) {
        return findTasksByParents(setOfSObjectIds , automaticallyCreatedTasks, null);
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description find Attachments to provided list of sObjects
         * @param setOfSObjectIds Set of Parent Ids
         * @param automaticallyCreatedTasks Return Automatically created tasks or not
         * @param withSubject Subject filter
         * @return List<Attachment> - found Attachments
        */
    public List<Task> findTasksByParents(Set<Id> setOfSObjectIds, Boolean automaticallyCreatedTasks, String
            withSubject) {
        List<SearchCondition> conditions = new List<SearchCondition>{
                new SearchCondition('Is_Automatically_Created__c', '=', automaticallyCreatedTasks),
                new SearchCondition('AND WhatId', 'IN', setOfSObjectIds)
        };
        if (!BTN_ValidationHandler.isNull(withSubject)){
            conditions.add(new SearchCondition('AND Subject', 'LIKE', withSubject));
        }
        return findSObjectsBy(conditions);
    }
}