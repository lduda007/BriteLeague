/**
 * Created by dch on 2016-09-15.
 */

public class BTN_DAO_Role extends BTN_DAO{
   /**
     * @author Mateusz Przywara
     * @date   2016-07-12
     * @description Constructor
    */
    public BTN_DAO_Role() {
    }
    public override Schema.SObjectType getSObjectType() {
        return UserRole.sObjectType;
    }
    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                UserRole.Id,
                UserRole.Name
        };
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-15
     * @description find all user Roles
     * @return List<UserRole> - all roles
    */
    public List<UserRole> getAllRoles() {
        return (List<UserRole>) findSObjects();
    }

    public UserRole findByName(String roleName){
        return (UserRole) findSObjectByName(roleName);
    }
}