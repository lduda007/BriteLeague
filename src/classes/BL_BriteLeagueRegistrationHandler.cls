global class BL_BriteLeagueRegistrationHandler implements Auth.RegistrationHandler{
    private static final String INTERNAL_USER_PROFILE = 'Standard User';
    private static final String TZSID = [SELECT TimeZoneSidKey FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1].TimeZoneSidKey;

    global boolean canCreateUser(Auth.UserData data) {
        String restrictedRegistrationDomain = BL_Utils.getBLCommunitySettings('BL_RestrictedRegistrationDomain__c');
        Boolean retVal = (data != null
                && data.email != null && data.email.endsWith('@'+restrictedRegistrationDomain)
                && data.lastName != null
                && data.firstName != null);
        return retVal;
    }

    global User createUser(Id portalId, Auth.UserData data){
        if(!canCreateUser(data)) {
            return null;
        }
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            Id contactId;
            List<Contact> existingContacts = [SELECT Id, Email FROM Contact WHERE Email =: data.email];
            if (existingContacts.size() > 0){
                Contact existingContact = existingContacts[0];
                contactId = existingContact.Id;
                List<User> existingUsers = [SELECT Id FROM User WHERE ContactId =: contactId];
                if (existingUsers.size() == 1){
                    return existingUsers[0];
                }
            } else {
                contactId = createContact(data);
            }
            String communityUserProfileName = BL_Utils.getBLCommunitySettings('BL_CommunityUserProfileName__c');
            Profile communityUserProfile = [SELECT Id FROM profile WHERE name =: communityUserProfileName];
            User communityUser = createUser(data,communityUserProfile);
            communityUser.contactId = contactId;
            return communityUser;
        } else {
            //This is not a community, so we Assign an internal profile
            Profile communityUserProfile = [SELECT Id FROM profile WHERE name =: INTERNAL_USER_PROFILE];
            User communityUser = createUser(data,communityUserProfile);
            return communityUser;
        }
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        BL_UserActivationManager.enqueueOldestLoggingUserDeactivation();
        if(!checkUserIsActive(userId)){
            BL_UserActivationManager.activateUser(userId);
        }
        User currentUser = [SELECT Id, IsActive FROM User WHERE Id =: userId];
        currentUser.email = data.email;
        currentUser.lastName = data.lastName;
        currentUser.firstName = data.firstName;
        update(currentUser);
    }

    private Boolean checkUserIsActive(String userId){
        User currentUser = [SELECT Id, IsActive FROM User WHERE Id =: userId];
        return currentUser.IsActive;
    }

    private Id createContact(Auth.UserData data){
        Contact contact = new Contact();
        contact.LastName = data.lastName;
        contact.FirstName = data.firstName;
        contact.Email = data.email;
        if (data.attributemap.get('accountId') != null){
            contact.accountId = data.attributemap.get('accountId');
        } else {
            contact.accountId = getCommunityUserAccountId();
        }
        insert contact;
        return contact.Id;
    }
    
    private Id getCommunityUserAccountId(){
        String communityUserAccountName = BL_Utils.getBLCommunitySettings('BL_CommunityUserAccountName__c');
        List<Account> communityUserAccount = [SELECT Id FROM Account WHERE Name =: communityUserAccountName];
        if(communityUserAccount != null && communityUserAccount.size() > 0){
            return communityUserAccount[0].Id;
        }else {
            Account newCommunityUserAccount = new Account(Name=communityUserAccountName);
            try {
                insert newCommunityUserAccount;
                return newCommunityUserAccount.Id;
            }catch (DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug(e.getDmlMessage(i));
                }
                return null;
            }
        }
    }

    private User createUser(Auth.UserData data, Profile communityUserProfile) {
        User newCommunityUser = new User();
        newCommunityUser.username = data.email + BL_Utils.getBLCommunitySettings('BL_RegistrationUsernameOrgSuffix__c');
        newCommunityUser.email = data.email;
        newCommunityUser.lastName = data.lastName;
        newCommunityUser.firstName = data.firstName;
        String alias = data.firstName + data.lastName;
        newCommunityUser.alias = alias.length() > 8 ? alias.substring(0, 8) : alias;
        newCommunityUser.languagelocalekey = UserInfo.getLanguage();
        newCommunityUser.localesidkey = UserInfo.getLocale();
        newCommunityUser.emailEncodingKey = 'UTF-8';
        newCommunityUser.timeZoneSidKey = TZSID;
        newCommunityUser.profileId = communityUserProfile.Id;
        return newCommunityUser;
    }
}