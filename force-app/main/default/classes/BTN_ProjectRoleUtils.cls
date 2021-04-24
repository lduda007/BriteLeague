/**
 * @author Mateusz Przywara
 * @date   2016-09-28
 * @description BTN_ProjectRoleUtils Utils Class to support operations on ProjectRole
*/
public class BTN_ProjectRoleUtils {

    /**
     * @author Mateusz Przywara
     * @date   2016-09-28
     * @description getProjectRoles retrieve all items from Custom Settings
     * @return List<BTN_ProjectRolesSetting__c>
    */
    public static List<BTN_ProjectRolesSetting__c> getProjectRoles() {
        return new List<BTN_ProjectRolesSetting__c>(BTN_ProjectRolesSetting__c.getAll().values());
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-29
     * @description parseBSProjectRoles2CS parse DTO to Custom Settings
     * @return List<BTN_ProjectRolesSetting__c>
    */
    public static List<BTN_ProjectRolesSetting__c> parseBSProjectRoles2CS(List<BTN_BSS_DTO.ProjectRole> projectRolesDTO) {
        List<BTN_ProjectRolesSetting__c> result = new List<BTN_ProjectRolesSetting__c>();
        for (BTN_BSS_DTO.ProjectRole prItem : projectRolesDTO) {
            result.add(new BTN_ProjectRolesSetting__c(
                    Name = prItem.projectrole_name,
                    BSExternalId__c = prItem.projectrole_id
            ));
        }
        return result;
    }
}