global class BTN_PostRefresh implements SandboxPostCopy {

    global void runApexClass(SandboxContext context) {
        System.debug('Sandbox Information: '
                + context.organizationId()
                + ' - '
                + context.sandboxId()
                + ' - '
                + context.sandboxName());

        List<User> defaultAdmins = getDefaultAdminUser();

        createHRCollaborationGroup();
        //deactivateUnwantedUsers(defaultAdmins);
        activateProperUsers(context.sandboxName(), defaultAdmins.get(0));
    }

    private void createHRCollaborationGroup() {

        Network myNet = [SELECT Id, Name FROM  Network WHERE Name = 'BriteERP'];
        List<CollaborationGroup> groupList = [select id from CollaborationGroup where name =: BTN_ConstantRepo.HUMAN_RESOURCES_GROUP_NAME];
        
        if(groupList.isEmpty()){
            CollaborationGroup hrGroup = new CollaborationGroup(
                    Name = BTN_ConstantRepo.HUMAN_RESOURCES_GROUP_NAME,
                    CollaborationType = 'Public',
                    NetworkId = myNet.Id
            );
    
            if (!Test.isRunningTest()) {
                insert hrGroup;
            }
        }
    }

    private void deactivateUnwantedUsers(List<User> sysAdmins) {
        List<User> usersToDeactivate = new List<User>();
        Set<Id> sysAdminIds = BTN_Utils.getSetOfIds(sysAdmins);

        for(User userToDeactivate : [SELECT IsActive,Name
                                    FROM User
                                    WHERE Profile.Name = 'System Administrator'
                                    AND IsActive = true
                                    AND Id not in : sysAdminIds]) {
            
            userToDeactivate.IsActive = false;
            usersToDeactivate.add(userToDeactivate);
        }

        update usersToDeactivate;
    }

    private void activateProperUsers(String sandboxName, User sysAdmin) {
        Set<String> userNamesToActivate = BTN_Utils.getSetValuesByName(BTN_ConstantRepo.SANDBOX_POSTREFRESH_ACTIVATED_ADMINS);
        
        List<User> usersToInsert = new List<User>();
        Map<String,User> usernameMap = new Map<String,User>();
        
        for(User userToActivate : [select id,Name,isActive from user where name in :userNamesToActivate and Profile.Name = 'System Administrator']){
            usernameMap.put(userToActivate.Name, userToActivate);
        }

        for(String userName : userNamesToActivate){
            if(!usernameMap.keySet().contains(userName)){
                usersToInsert.add(generateUserData(userName,sysAdmin,sandboxName));
            }else{
                User u = usernameMap.get(userName);
                u.isActive = true;
                usersToInsert.add(usernameMap.get(userName));
            }
        }
        Database.upsert(usersToInsert);
    }

    private User activateUser(String firstName, String lastName, String email, User sysAdmin, String sandboxName){
        return new User(FirstName = firstName,
                        LastName = lastName,
                        Email = email,
                        IsActive = true,
                        Alias = firstname.left(1)+lastname.left(4).uncapitalize(),
                        CommunityNickname = email.substringBefore('@'),
                        Username = email.substringBefore('@')+'@britenet.com.'+sandboxName,
                        ProfileId = sysAdmin.ProfileId,
                        TimeZoneSidKey = sysAdmin.TimeZoneSidKey,
                        LocaleSidKey = sysAdmin.LocaleSidKey,
                        EmailEncodingKey = sysAdmin.EmailEncodingKey,
                        LanguageLocaleKey = sysAdmin.LanguageLocaleKey);
    }

    private List<User> getDefaultAdminUser(){
        Set<String> defaultAdminNames = BTN_Utils.getSetValuesByName(BTN_ConstantRepo.SANDBOX_POSTREFRESH_DEFAULT_ADMIN);
        
        return [SELECT TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, Profile.Name, ProfileId
                FROM User
                WHERE Name in : defaultAdminNames];
    }

    private User generateUserData(String uName, User sysAdmin, String sandboxName){
        List<String> username = uName.split(' ');
        String firstName = username.get(0);
        String lastName = username.get(1);
        String email = firstName.uncapitalize()+'.'+lastName.uncapitalize()+BTN_ConstantRepo.BRITENET_MAIL_SUFFIX;
        return activateUser(firstName, lastName, email, sysAdmin, sandboxName);
    }
}