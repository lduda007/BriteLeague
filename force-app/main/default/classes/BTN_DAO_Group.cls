/**
 * @author Mateusz Przywara
 * @date   2016-07-14
 * @description DAO class - Data Access Object for Group
 */
public class BTN_DAO_Group extends BTN_DAO {

    public static final String GROUP_NAME_SYS_ADMINS = 'Sys_Admins';

   /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor
    */
    public BTN_DAO_Group() {
    }

    public override Schema.SObjectType getSObjectType() {
        return Group.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                Group.Id,
                Group.Name,
                Group.DeveloperName,
                Group.Type
        };
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-14
         * @description find Group with provided Developer Name
         * @return Group
        */
    public Group findGroupByName(String groupName) {
        List<Group> objects = findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('DeveloperName', '=', groupName)
                }
        );
        return objects.isEmpty() ? null : objects.get(0);
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-31
         * @description find Group with provided Developer Name
         * @return Group
        */
    public Group findResourceManagersQueue() {
        return findGroupByName(BTN_ConstantRepo.RESOURCE_MANAGERS_GROUP_NAME);
    }

    /**
     * @author Adam Jedrys
     * @date   2018-05-23
     * @description get Sys Admins group
     * @return Group
    */
    public Group getSysAdmins(){
        return findGroupByName(GROUP_NAME_SYS_ADMINS);
    }
}