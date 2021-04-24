/**
 * @author Mateusz Przywara
 * @date   2016-08-09
 * @description BTN_DAO_Project DAO Class
*/
public class BTN_DAO_Project extends BTN_DAO {
   /**
     * @author Mateusz Przywara
     * @date   2016-08-09
     * @description Constructor
    */
    public BTN_DAO_Project() {
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-09
     * @description Constructor setting custom List of fields
    */
    public BTN_DAO_Project(List<Schema.SObjectField> customFields) {
        setCustomFields(customFields);
    }

    public override Schema.SObjectType getSObjectType() {
        return BTN_Project__c.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                BTN_Project__c.Id,
                BTN_Project__c.Account__c,
                BTN_Project__c.BritesheetProjectId__c,
                BTN_Project__c.ProjectCode__c,
                BTN_Project__c.ProjectType__c
        };
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-09
         * @description findProjects Method returns all Projects
         * @return List<BTN_Project__c>
        */
    public List<BTN_Project__c> findProjects() {
        return (List<BTN_Project__c>) findSObjects();
    }

    /**
        * @author Mateusz Przywara
        * @date   2016-08-18
        * @description findProjectsIn with Ids
        * @param projectIds - Id List
        * @return     List<BTN_Project__c>
    */
    public List<BTN_Project__c> findProjectsIn(Set<Id> projectIds) {
        return (List<BTN_Project__c>) findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Account__c != null'
                        ),
                        new SearchCondition(
                                'AND Id',
                                'IN',
                                projectIds
                        )
                }
        );
    }
}