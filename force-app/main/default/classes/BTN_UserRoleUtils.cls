/**
 * @author Dariusz Chmiela
 * @date 2016-08-24
 * @description BTN_UserRoleUtils
*/
public with sharing class BTN_UserRoleUtils {
    private static final BTN_DAO_Role daoRole = new BTN_DAO_Role();
    public final static String ROLE_NAME_CEO = 'CEO';
    public final static String ROLE_NAME_ADMINS_MANAGER = 'Admins Manager';
    public final static String ROLE_NAME_ADMIN = 'Admin';
    public final static String ROLE_NAME_BACKOFFICE_MANAGER = 'Backoffice Manager';
    public final static String ROLE_NAME_BACKOFFICE = 'Backoffice';
    public final static String ROLE_NAME_BTN_CUSTOMER_USER = 'Britenet Sp. z o.o. Customer User';
    public final static String ROLE_NAME_HR_DIRECTOR = 'HR Director';
    public final static String ROLE_NAME_HR = 'HR';
    public final static String ROLE_NAME_RESOURCE_MANAGER  = 'Resource Manager';
    public final static String ROLE_NAME_SALES_DIRECTOR  = 'Sales Director';
    public final static String ROLE_NAME_SALES  = 'Sales';
    public final static String ROLE_NAME_SALES_PRIVATE_SECTOR = 'Sales Private Sector';
    public final static String ROLE_NAME_SALES_PUBLIC_SECTOR  = 'Sales Public Sector ';

    public final static Map<String,UserRole> ROLE_NAME_2_ROLE_MAP;
    public final static Map<Id,UserRole> ROLE_ID_2_ROLE_MAP;
    public final static List<UserRole> ALL_ROLES;
    static{
        ROLE_NAME_2_ROLE_MAP = new Map<String,UserRole>();
        ROLE_ID_2_ROLE_MAP = new Map<Id,UserRole>();
        ALL_ROLES = daoRole.getAllRoles();

        for(UserRole userRole : ALL_ROLES){
            ROLE_NAME_2_ROLE_MAP.put(userRole.Name,userRole);
            ROLE_ID_2_ROLE_MAP.put(userRole.Id,userRole);
        }
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-15
     * @description addUserRole add user role to map and insert into db
     * @param UserRole SObject to insert/add
    */
    public static void addUserRole(UserRole userRole){
        if(!ROLE_NAME_2_ROLE_MAP.containsKey(userRole.Name)){
            insert userRole;
            ALL_ROLES.add(userRole);
            ROLE_NAME_2_ROLE_MAP.put(userRole.Name,userRole);
            ROLE_ID_2_ROLE_MAP.put(userRole.Id,userRole);
        }
    }

}