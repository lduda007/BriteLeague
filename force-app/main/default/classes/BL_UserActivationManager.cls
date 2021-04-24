public with sharing class BL_UserActivationManager {
    public static void activateUser(User user){
        activateInactiveUserTryingToLogIn(user);
    }

    public static void deactivateLastLoggingUser(String profileName){
        User lastLoggedUser = String.isEmpty(profileName) ? getLastLoggedUserForNotRestrictedCommunityProfile() :
                getLastLoggedUserForRestrictedCommunityProfile(profileName);
        try{
            lastLoggedUser.IsActive = false;
            update lastLoggedUser;
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
        }

    }

    private static User getLastLoggedUserForRestrictedCommunityProfile(String profileName) {
        List<AggregateResult> ar = [
                SELECT MIN(LastLoginDate) Min_Login
                FROM User
                WHERE Profile.Name =: profileName AND IsActive = true
        ];

        Datetime lastLoginDate = (Datetime)ar[0].get('Min_Login');

        User lastLoggedUser = [
                SELECT Id, IsActive
                FROM User
                WHERE  Profile.Name =: profileName AND (LastLoginDate =: lastLoginDate OR LastLoginDate = null) AND IsActive = true
                ORDER BY LastLoginDate
                LIMIT 1
        ];
        return lastLoggedUser;
    }

    private static User getLastLoggedUserForNotRestrictedCommunityProfile(){
        String customerCommunityProfileName = BL_Utils.getBLCommunitySettings('BL_CommunityUserProfileName__c');
        String communityPlusUserProfileName = BL_Utils.getBLCommunitySettings('BL_CommunityPlusUserProfileName__c');

        List<AggregateResult> ar = [
                SELECT MIN(LastLoginDate) Min_Login
                FROM User
                WHERE (Profile.Name = :customerCommunityProfileName OR Profile.Name = :communityPlusUserProfileName) AND IsActive = true
        ];

        Datetime lastLoginDate = (Datetime)ar[0].get('Min_Login');
        User lastLoggedUser = [
                SELECT Id, IsActive
                FROM User
                WHERE (Profile.Name =: customerCommunityProfileName OR Profile.Name =: communityPlusUserProfileName)  AND (LastLoginDate =: lastLoginDate OR LastLoginDate = null) AND IsActive = true
                ORDER BY LastLoginDate
                LIMIT 1
        ];

        return lastLoggedUser;
    }

    public static void activateInactiveUserTryingToLogIn(User user){
        try{
            user.IsActive = true;
            String csAvailableLicencesFieldName;
            if(user.Profile.Name == BL_Utils.getBLCommunitySettings('BL_CommunityUserProfileName__c')){
                csAvailableLicencesFieldName = 'BL_NumberOfCommunityLicenses__c';
            }else{
                csAvailableLicencesFieldName = 'BL_Number_Of_Community_Plus_Licenses__c';
            }
            if(getNumberOfAvailableCommunityLicenses(user.Profile.Name, csAvailableLicencesFieldName) < 1){
                deactivateLastLoggingUser(user.Profile.Name);
            }
            update user;
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
        }
    }

    public static void enqueueOldestLoggingUserDeactivation(){
        String customerCommunityProfileName = BL_Utils.getBLCommunitySettings('BL_CommunityUserProfileName__c');
        String communityPlusUserProfileName = BL_Utils.getBLCommunitySettings('BL_CommunityPlusUserProfileName__c');

        if(getNumberOfAvailableCommunityLicenses(customerCommunityProfileName, 'BL_NumberOfCommunityLicenses__c') < 1 &&
                getNumberOfAvailableCommunityLicenses(communityPlusUserProfileName, 'BL_Number_Of_Community_Plus_Licenses__c') < 1){
            BL_OldestLoggingUserDeactivator oldestLoggingUserDeactivator = new BL_OldestLoggingUserDeactivator();
            ID jobID = System.enqueueJob(oldestLoggingUserDeactivator);
        }
    }

    public static void enqueuePlayerPermissionSetAssignement(String userId){
        BL_PlayerPermissionSetAssigner playerPermissionSetAssigner = new BL_PlayerPermissionSetAssigner(userId);
        ID jobID = System.enqueueJob(playerPermissionSetAssigner);
    }

    public static void assignPlayerPermissionSet(String userId){
        String playerPermissionSetId = BL_Utils.getBLCommunitySettings('BL_PlayerPermissionSetId__c');
        PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = playerPermissionSetId, AssigneeId = userId);
        insert psa;
    }

    public static Integer getNumberOfAvailableCommunityLicenses(String profileName, String csAvailableLicencesFieldName){
        List<User> activeCommunityUsers = [SELECT Id FROM User WHERE Profile.Name =: profileName AND IsActive = true];
        Integer numberOfAllLicenses = Integer.valueOf(BL_Utils.getBLCommunitySettings(csAvailableLicencesFieldName));
        return numberOfAllLicenses - activeCommunityUsers.size();
    }
}