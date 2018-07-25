trigger BL_UserTrigger on User (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        String communityUserProfileId = BL_Utils.getBLCommunitySettings('BL_CommunityUserProfileId__c');

        for(User newUser : Trigger.NEW){
            if(newUser.ProfileId == communityUserProfileId){
                BL_UserActivationManager.enqueuePlayerPermissionSetAssignement(newUser.Id);
                BL_UserActivationManager.enqueueOldestLoggingUserDeactivation();
            }
        }
    }
}