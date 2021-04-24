/**
 * @author Mateusz Przywara
 * @date   2016-07-15
 * @description BTN_GoogleLoginHandler_Test test SSO flow
*/
@isTest
private class BTN_GoogleLoginHandler_Test {
    private static final String USER_PROFILE_NAME = BTN_ConstantRepo.RESOURCE_MANAGER_PROFILE_NAME;

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description testIfSSOFlowValidatesCorrectlyAndAssignUser test User Validation method and
     * assignment to SF User
    */
	@isTest static void testIfSSOFlowValidatesCorrectlyAndAssignUser() {
        
        EmailsToGenericAccount__c etga = new EmailsToGenericAccount__c(Name='testFirsttestLast'+BTN_ConstantRepo.BRITENET_MAIL_SUFFIX, GenericAccount__c = BTN_ConstantRepo.ADMIN_EMAIL);
        insert etga;

        System.RunAs(BTN_Utils.getCurrentUser()) {
            User testUser = BTN_TestDataFactory.getActiveUser(
                    'testFirst', 'testLast', null, BTN_TestDataFactory.getProfileId(USER_PROFILE_NAME));
            Auth.UserData briteNetSampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testFirst testLast', testUser.Email, null, 'testuserlong',
                    'en_US', 'facebook',
                null, new Map<String, String>{'language' => 'en_US'});
            BTN_GoogleLoginHandler newAuthObj = new BTN_GoogleLoginHandler();
            newAuthObj.updateUser(null, null, briteNetSampleData);
            System.assert(newAuthObj.canUserBeAssigned(briteNetSampleData));
            System.assertEquals(BTN_ConstantRepo.ADMIN_EMAIL, newAuthObj.getProperUserEmail(briteNetSampleData.Email));
            System.assertEquals(testUser.Email, briteNetSampleData.email);
        }
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description testIfSSOFlowNOTValidateCorrectlyAndAssignUser test Case when User not existing in SF
    */
    @isTest static void testIfSSOFlowNOTValidateCorrectlyAndAssignUser() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                    'testFirst testLast', 'defUserName', null, 'testuserlong', 'en_US', 'facebook',
                    null, new Map<String, String>{'language' => 'en_US'});

            BTN_GoogleLoginHandler newAuthObj = new BTN_GoogleLoginHandler();
            System.assert(!newAuthObj.canUserBeAssigned(sampleData));
            System.assertEquals(null, newAuthObj.createUser(null, sampleData));
        }
    }
}