@isTest
private class BTN_PostRefreshTest {
    
    testMethod static void  testSandboxPostCopyScript() {
        
        User thisUser = [SELECT Id,Name FROM User WHERE Id = :UserInfo.getUserId()];

        BTN_BriteCRM_settings__c defaultAdminSetting = new BTN_BriteCRM_settings__c(Name = 'PostRefresh.DefaultAdmins', Value__c = 'Piotr Murias,'+thisUser.Name);
        insert defaultAdminSetting;

        BTN_BriteCRM_settings__c activatedAdminsProp = new BTN_BriteCRM_settings__c(Name = 'PostRefresh.ActivatedAdmins', 
            Value__c = 'Test Admin2,Test Admin3');
        insert activatedAdminsProp;

        System.runAs(thisUser){
            User activeAdminUser = BTN_TestDataFactory.getActiveUser('Test', 'Admin', null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));
            activeAdminUser.LastName = 'Admin';
            insert activeAdminUser;
            User inactiveAdminUser = BTN_TestDataFactory.getActiveUser('Test', 'Admin2', null, BTN_TestDataFactory.getProfileId(BTN_ConstantRepo.ADMIN_PROFILE_NAME));
            inactiveAdminUser.LastName = 'Admin2';
            inactiveAdminUser.IsActive = false;
            insert inactiveAdminUser;

            BTN_PostRefresh postRefresh = new BTN_PostRefresh();
            Test.testSandboxPostCopyScript(postRefresh, UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), 'sandbox');
        }
    }
}