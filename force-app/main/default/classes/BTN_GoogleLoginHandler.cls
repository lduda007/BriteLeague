/**
 * @author Mateusz Przywara
 * @date   2016-07-15
 * @description BTN_GoogleLoginHandler Handler Class for Auth Provider (must be set in Setup -> Auth Provider)
 *  Provides handling for SSO flow. It will Assign Google Id to SFDC User ONCE!!!
 *  So it will be executed only one time per User. Permission for Google account can be revoked in User Detail View.
 */
global class BTN_GoogleLoginHandler implements Auth.RegistrationHandler {

    /**
     * @author Mateusz Przywara
     * @date   2016-06-22
     * @description Check if user is from Britenet
     * @param data Parsed XML data from Google
     * @return Boolean Can user move forward in register / login flow
    */
	global boolean canUserBeAssigned(Auth.UserData data) {
		if (data.email.contains(BTN_ConstantRepo.BRITENET_MAIL_SUFFIX)) {
			return true;
		}
		return false;
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-06-22
     * @description Wires Salesforce User with Google User
     * @param data Parsed XML data from Google
     * @return User sObject with User data for specified
    */
	global User createUser(Id portalId, Auth.UserData data) {
		if (!canUserBeAssigned(data)) {
			//Returning null fails the SSO flow
			return null;
		}

		//if Google username contains Britenet mail org(specified in BTN_ConstantRepo) method will return existing user
		// with criteria. Auth.UserData is data returned from Google with specified scope in Auth Provider.
        // Google User Email being checked for allegiance with Generic User for example RM.
        return new BTN_DAO_User().findUserByEmail(getProperUserEmail(data.email));
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-06-22
     * @description Method overriding Salesforce User Data with Google data. Remember
     * 		some data can be inaccessible or null according to Auth. Provider scope.
     * @param userId Assigned User Id
     * @param portalId Id of portal
     * @param data Parsed XML data from Google
     * @return void
    */
	global void updateUser(Id userId, Id portalId, Auth.UserData data) {
		User u = new User(id = userId);
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-08-29
     * @description getProperUserEmail Method transforms provided
     * @return String  User Email Assigned to generic User like HR
    */
    @TestVisible
    private String getProperUserEmail(String email) {
        String result = email;
        EmailsToGenericAccount__c listedEmailsWithGenericAccount = EmailsToGenericAccount__c.getInstance(email);

        if (listedEmailsWithGenericAccount != null) {
            result = listedEmailsWithGenericAccount.GenericAccount__c;
        }
        return result;
    }
}