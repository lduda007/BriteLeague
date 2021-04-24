/**
 * @author Dariusz Chmiela
 * @date 2016-09-15
 * @description DAO class - Data Access Object for PermissionSetAssigment
 */
public class BTN_DAO_PermissionSetAssigment extends BTN_DAO{
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-13
     * @description Constructor
    */
    public BTN_DAO_PermissionSetAssigment() {
    }
    public override Schema.SObjectType getSObjectType() {
        return PermissionSetAssignment.sObjectType;
    }
    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                PermissionSetAssignment.Id,
                PermissionSetAssignment.AssigneeId,
                PermissionSetAssignment.PermissionSetId
        };
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-15
     * @description getAllPermissionSetsAssigment gets all permission sets assigments
    */
    public List<PermissionSetAssignment> getAllPermissionSets() {
        return (List<PermissionSetAssignment>)
                Database.query('SELECT Id, AssigneeId, PermissionSetId, Assignee.Name, Assignee.FirstName, Assignee.LastName, Assignee.Email FROM PermissionSetAssignment');
    }
}