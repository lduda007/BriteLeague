public with sharing class BL_UserActivationManager {
    public static void activateUser(String userId){
        User user = [SELECT Id, IsActive FROM User WHERE Id =: userId];
        activateInactiveUserTryingToLogIn(user);
    }

    public static void deactivateLastLoggingUser(){
        String customerCommunityProfileName = BL_Utils.getBLCommunitySettings('BL_CommunityUserProfileName__c');
        List<User> allUsers = new List<User>();
        List<AggregateResult> ar = [
                SELECT MIN(LastLoginDate) Min_Login, Profile.Name
                FROM User
                WHERE Profile.Name =: customerCommunityProfileName  AND IsActive = true
                GROUP BY Profile.Name
        ];

        Datetime lastLoginDate = (Datetime)ar[0].get('Min_Login');

        User lastLoggedUser = [
                SELECT Id, IsActive
                FROM User
                WHERE Profile.Name =: customerCommunityProfileName  AND (LastLoginDate =: lastLoginDate OR LastLoginDate = null) AND IsActive = true
                ORDER BY LastLoginDate
                LIMIT 1
        ];

        try{
            lastLoggedUser.IsActive = false;
            update lastLoggedUser;
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
        }

    }

    public static void activateInactiveUserTryingToLogIn(User user){
        try{
            user.IsActive = true;
            if(getNumberOfAvailableCommunityLicenses() <= 1){
                deactivateLastLoggingUser();
            }
            update user;
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
        }
    }

    public static void enqueueOldestLoggingUserDeactivation(){
        if(getNumberOfAvailableCommunityLicenses() < 1){
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

    public static Integer getNumberOfAvailableCommunityLicenses(){
        String customerCommunityProfileName = BL_Utils.getBLCommunitySettings('BL_CommunityUserProfileName__c');
        List<User> activeCommunityUsers = [SELECT Id FROM User WHERE Profile.Name =: customerCommunityProfileName AND IsActive = true];
        Integer numberOfAllLicenses = Integer.valueOf(BL_Utils.getBLCommunitySettings('BL_NumberOfCommunityLicenses__c'));
        return numberOfAllLicenses - activeCommunityUsers.size();
    }
}