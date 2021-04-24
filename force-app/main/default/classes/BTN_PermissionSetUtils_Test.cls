/*
 * @author Dariusz Chmiela
 * @date 2016-09-18
 * @description BTN_PermissionSetUtils_Test test class for BTN_PermissionSetUtils
*/
@isTest
public with sharing class BTN_PermissionSetUtils_Test {
    @isTest
    private static void coverageTest(){
        BTN_PermissionSetUtils permissionSetUtils = new BTN_PermissionSetUtils();
        BTN_PermissionSetUtils.assignPermissionSetToUser(
                BTN_PermissionSetUtils.ALL_PERMISSION_SETS.get(0).Name, BTN_Utils.getCurrentUser());
        BTN_PermissionSetUtils.findRequestors();
        BTN_PermissionSetUtils.findHRUsers();
        BTN_PermissionSetUtils.getUsersByPermissionSetName(BTN_PermissionSetUtils.PERMISSION_SET_ADMIN);
    }
}