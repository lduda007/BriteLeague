/**
 * @author Mateusz Przywara
 * @date   2016-08-10
 * @description BTN_DAO_Assignment Controller DAO Layer for BTN_Assignment
*/
public class BTN_DAO_Assignment extends BTN_DAO {
   /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description Constructor
    */
    public BTN_DAO_Assignment() {
    }

    public override Schema.SObjectType getSObjectType() {
        return BTN_Assignment__c.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                BTN_Assignment__c.Id,
                BTN_Assignment__c.BritesheetExternalId__c,
                BTN_Assignment__c.Contact__c,
                BTN_Assignment__c.Project__c,
                BTN_Assignment__c.StartDate__c,
                BTN_Assignment__c.EndDate__c,
                BTN_Assignment__c.AssignmentGroup__c,
                BTN_Assignment__c.LastModifiedDate
        };
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-10
         * @description getAssignmentsLocator Method returns all Assignments Locator
         * @return List<BTN_Project__c>
        */
    public Database.QueryLocator getAssignmentLocator() {
        return getSObjectsLocator(
                /*new List<SearchCondition>{
                        new SearchCondition(
                                'Account__c != null'
                        )
                }*/
        );
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-10
         * @description findAssignments Method returns all Assignments
         * @return List<BTN_Assignment__c>
        */
    public List<BTN_Assignment__c> findAssignments() {
        return (List<BTN_Assignment__c>) findSObjects();
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-11
         * @description addRelatedAssignments Adds Cases to Query
         */
    public void addRelatedCases() {
        currentFields.add(
                '(SELECT Id, Type, Status, RecordType.DeveloperName FROM Cases__r WHERE IsDeleted = false)'
        );
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-16
         * @description addAccountId Adds Account to Querry
         */
    public void addAccountId() {
        currentFields.add(
                'Project__r.Account__c'
        );
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-16
         * @description getAssignmentGroupsLocator Method returns all Assignments Group Locator
         * Grouped by Assignment Group - Distinct Like
         * Count consumes a lot of resources
         * @return Database.QueryLocator
        */
    public Database.QueryLocator getAssignmentsLocator() {
        /*currentFields.clear();
        currentFields.add(
                'AssignmentGroup__c'
        );
        currentFields.add(
                'COUNT(Id)'
        );
        this.groupByClause = 'AssignmentGroup__c';*/
        return getSObjectsLocator();
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-16
         * @description findAssignmentsByGroup Method returns all Assignments for specified Group
         * Group is Contact Id and Account Id (relation thru Project)
         *
         * !!!!! ORDER BY Start Date ascending very important(Assignment Batch) DO NOT CHANGE
         *
         * @return List<BTN_Assignment__c>
        */
    public List<BTN_Assignment__c> findAssignmentsByGroup(String groupName) {
        this.orderClause = ' StartDate__c, EndDate__c ASC';
        return (List<BTN_Assignment__c>) findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'AssignmentGroup__c',
                                '=',
                                groupName
                        ),
                        new SearchCondition(
                                'AND IsDeleted',
                                '=',
                                false
                        )
                }
        );
    }

        /**
         * @author Konrad Kozaczuk
         * @date   2016-10-19
         * @description findAssignmentsByAccount Method returns current Assignments for specified Account
         * 
         * @return List<BTN_Assignment__c>
        */
    public List<BTN_Assignment__c> findAssignmentsByAccount(String accountId) {
        
        return new List<BTN_Assignment__c>([
            SELECT Name, Project__r.Name, Contact__r.Name, StartDate__c, EndDate__c, Allocation__c FROM BTN_Assignment__c 
            WHERE Project__r.Account__c = :accountId AND StartDate__c <= TODAY AND EndDate__c >= TODAY
            ORDER BY StartDate__c DESC
        ]);
        
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-16
         * @description findAssignmentsWithProjectAndContactIn Method returns all Assignments with Relation to Account and Contact
         * @param assignmentIds Assignments in Scope
         * @return List<BTN_Assignment__c>
        */
    public List<BTN_Assignment__c> findAssignmentsWithProjectAndContactIn(Set<Id> assignmentIds) {
        return (List<BTN_Assignment__c>) findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Contact__c != null'
                        ),
                        new SearchCondition(
                                'AND Project__r.Account__c != null'
                        ),
                        new SearchCondition(
                                'AND Id',
                                'IN',
                                assignmentIds
                        )
                }
        );
    }
}