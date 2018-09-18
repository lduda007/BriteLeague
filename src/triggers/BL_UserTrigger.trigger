trigger BL_UserTrigger on User (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        String communityUserProfileId = BL_Utils.getBLCommunitySettings('BL_CommunityUserProfileId__c');
        String communityPlusUserProfileId = BL_Utils.getBLCommunitySettings('BL_CommunityPlusUserProfileId__c');

        for(User newUser : Trigger.NEW){
            if(newUser.ProfileId == communityUserProfileId || newUser.ProfileId == communityPlusUserProfileId){
                BL_UserActivationManager.enqueuePlayerPermissionSetAssignement(newUser.Id);
                BL_UserActivationManager.enqueueOldestLoggingUserDeactivation();
                BL_BriteLeagueRegistrationHandler.setContactImageUrl(newUser.Id, newUser.ImageUrl__c);
                BL_BriteLeagueRegistrationHandler.setUserPhoto(newUser.Id, newUser.ImageUrl__c);
            }
        }
    }
}