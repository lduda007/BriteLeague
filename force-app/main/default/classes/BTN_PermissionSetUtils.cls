/*
 * @author Dariusz Chmiela
 * @date 2016-09-09
 * @description BTN_PermissionSetUtil util for Permission sets
*/
public with sharing class BTN_PermissionSetUtils {
    public final static String PERMISSION_SET_ADMIN = 'Admin';
    public final static String PERMISSION_SET_BTN_ADMINISTRATION = 'BTN_Administration';
    public final static String PERMISSION_SET_BTN_BACKOFFICE = 'BTN_Backoffice';
    public final static String PERMISSION_SET_BTN_CVDELIVERY = 'BTN_CvDelivery';
    public final static String PERMISSION_SET_HR = 'BTN_Human_Resources';
    public final static String PERMISSION_SET_PRIVATE_SECTOR_SALES_USER = 'PrivateSectorSalesUser';
    public final static String PERMISSION_SET_PUBLIC_SECTOR_SALES_USER = 'PublicSectorSalesUser';
    public final static String PERMISSION_SET_BTN_RESOURCE_REQUESTOR = 'BTN_Resource_Requestor';
    public final static String PERMISSION_SET_SEE_ENCRYPTED_DATA = 'See_encrypted_data';

    public final static Map<String,PermissionSet> NAME_2_PERMISSION_SET_MAP = new Map<String,PermissionSet>();
    public final static Map<Id,PermissionSet> ID_2_PERMISSION_SET_MAP = new Map<Id, PermissionSet>();
    public final static Map<String,PermissionSetAssignment> USER_ID_2_PERMISSION_ASSIGMENT_MAP = new Map<String,PermissionSetAssignment>();
    public final static Map<String,List<User>> PERMISSION_SET_NAME_2_USERS_LIST_MAP = new Map<String, List<User>>();
    public final static List<PermissionSet> ALL_PERMISSION_SETS;
    public final static List<PermissionSetAssignment> ALL_PERMISSION_SETS_ASSIGNMENTS;
    static{
        ALL_PERMISSION_SETS = new BTN_DAO_PermissionSet().getAllPermissionSets();
        for(PermissionSet permissionSet : ALL_PERMISSION_SETS){
            NAME_2_PERMISSION_SET_MAP.put(permissionSet.Name,PermissionSet);
            ID_2_PERMISSION_SET_MAP.put(permissionSet.Id,permissionSet);
        }
        ALL_PERMISSION_SETS_ASSIGNMENTS = new BTN_DAO_PermissionSetAssigment().getAllPermissionSets();
        for(PermissionSetAssignment permissionSetAssignment : ALL_PERMISSION_SETS_ASSIGNMENTS){
            USER_ID_2_PERMISSION_ASSIGMENT_MAP.put(permissionSetAssignment.AssigneeId,permissionSetAssignment);
            if(PERMISSION_SET_NAME_2_USERS_LIST_MAP.containsKey(ID_2_PERMISSION_SET_MAP.get(permissionSetAssignment.PermissionSetId).Name)){
                PERMISSION_SET_NAME_2_USERS_LIST_MAP.get(ID_2_PERMISSION_SET_MAP.get(permissionSetAssignment.PermissionSetId).Name).add(PermissionSetAssignment.Assignee);
            }else{
                PERMISSION_SET_NAME_2_USERS_LIST_MAP.put(ID_2_PERMISSION_SET_MAP.get(permissionSetAssignment.PermissionSetId).Name, new List<User>());
            }
        }
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-13
     * @description assignPermissionSetToUser assigns given permission set to given user
     * @param permissionSetName - name of permission set to assign
     * @param User - user that permission set will be assigned to
    */
    public static void assignPermissionSetToUser(String permissionSetName, User user){
        if(!checkIfUserIsAlreadyAssignedToPermSet(permissionSetName,user)){
            assignPermSetToUser(permissionSetName,user);
        }
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-13
     * @description find all Requestors
     * @return List<User>
     */
    public static List<User> findRequestors(){
        return PERMISSION_SET_NAME_2_USERS_LIST_MAP.get(PERMISSION_SET_BTN_RESOURCE_REQUESTOR);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-24
     * @description find all HR Users
     * @return List<User>
     */
    public static List<User> findHRUsers() {
        return PERMISSION_SET_NAME_2_USERS_LIST_MAP.get(PERMISSION_SET_HR);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-13
     * @description find all Requestors
     * @return List<User>
     */
    public static List<User> getUsersByPermissionSetName(String permissionSetName){
        return PERMISSION_SET_NAME_2_USERS_LIST_MAP.get(permissionSetName);
    }

    public static Boolean checkIfUserIsAdmin(User usr) {
        return checkIfUserIsAlreadyAssignedToPermSet(PERMISSION_SET_BTN_ADMINISTRATION, usr);
    }

    private static void assignPermSetToUser(String permissionSetName, User user){
        PermissionSetAssignment permissionSetAssignment;
        permissionSetAssignment = new PermissionSetAssignment(
                PermissionSetId = NAME_2_PERMISSION_SET_MAP.get(permissionSetName).Id,
                AssigneeId = user.Id
        );
        ALL_PERMISSION_SETS_ASSIGNMENTS.add(permissionSetAssignment);
        if(PERMISSION_SET_NAME_2_USERS_LIST_MAP.get(permissionSetName) == null){
            PERMISSION_SET_NAME_2_USERS_LIST_MAP.put(permissionSetName, new List<User>{user});
        }else{
            PERMISSION_SET_NAME_2_USERS_LIST_MAP.get(permissionSetName).add(user);
        }
    }
    private static Boolean checkIfUserIsAlreadyAssignedToPermSet(String permissionSetName, User user){
        if(PERMISSION_SET_NAME_2_USERS_LIST_MAP.get(permissionSetName) != null){
            for(User u : PERMISSION_SET_NAME_2_USERS_LIST_MAP.get(permissionSetName)){
                if(u.Id.equals(user.Id)){
                    return true;
                }
            }
        }
        return false;
    }
}