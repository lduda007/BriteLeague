/**
 * @author Dariusz Chmiela
 * @date 2016-09-09
 * @description DAO class - Data Access Object for PermissionSet
*/
public class BTN_DAO_PermissionSet extends BTN_DAO{
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description Constructor
    */
    public BTN_DAO_PermissionSet() {
    }
    public override Schema.SObjectType getSObjectType() {
        return PermissionSet.sObjectType;
    }
    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                PermissionSet.Id,
                PermissionSet.Name
        };
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description findPermissionSetByName finds permission set by given name
     * @param permissionSetName - name of permission set to find
     * @return PermissionSet
    */
    public PermissionSet findPermissionSetByName(String permissionSetName) {
        return (PermissionSet) findSObjectByName(permissionSetName);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description getAllPermissionSets gets all permission sets
    */
    public List<PermissionSet> getAllPermissionSets() {
        return (List<PermissionSet>) findSObjects();
    }
}