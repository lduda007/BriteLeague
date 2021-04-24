/**
 * @author Mateusz Przywara
 * @date   2016-07-05
 * @description DAO class - Data Access Object for User
*/
public class BTN_DAO_User extends BTN_DAO {
    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor
    */
    public BTN_DAO_User() {
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor setting custom List of fields
    */
    public BTN_DAO_User(List<Schema.SObjectField> customFields) {
        setCustomFields(customFields);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description find Contact
     * @param  userName - Name of User to search for
     * @return     User       - found User
    */
    public User findUserById(Id userId) {
        return (User) findSObjectById(userId);
    }

    /**
     * @author Adam Jedrys
     * @date   2018-05-23
     * @description find users by ids
     * @param  userId
     * @return     list of users
    */
    public List<User> findUsersByIds(Set<Id> usersIds) {
        return (List<User>) findSObjectsById(usersIds);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description find Contact
     * @param  userName - Name of User to search for
     * @return     User       - found User
    */
    public User findUserByName(String userName) {
        return (User) findSObjectByName(userName);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description find Contact
     * @param  userEmail - Email of User to search for
     * @return     User       - found User
    */
    public User findUserByEmail(String userEmail) {
        List<User> users = findSObjectsBy(
                                new List<SearchCondition>{
                                        new SearchCondition(
                                                'Email',
                                                '=',
                                                userEmail
                                        ),
                                        new SearchCondition(
                                                'AND isActive = true'
                                        )
                                }
        );
        return users.isEmpty() ? null : users.get(0);
    }
    
    
        /**
         * @author Wojciech Mazur
         * @date   2016-11-23
         * @description find Users
         * @param  userEmails - Emails of Users to search for
         * @return     List<User>       - found Users
         */
    public List<User> findUsersByEmails(Set<String> userEmails) {
        List<User> users = findSObjectsBy(
                                new List<SearchCondition>{
                                        new SearchCondition(
                                                'Email',
                                                'in',
                                                userEmails
                                        ),
                                        new SearchCondition(
                                                'AND isActive = true'
                                        )
                                }
        );
        return users;
    }
    
     /**
         * @author Wojciech Mazur
         * @date   2016-10-05
         * @description find User
         * @param  userName - UserName of User to search for 
         * @return     User       - found User
         */
    public User findUserByUserName(String userName) {
        List<User> users = findSObjectsBy(
                                new List<SearchCondition>{
                                        new SearchCondition(
                                                'UserName',
                                                '=',
                                                userName
                                        )
                                }
        );
        return users.isEmpty() ? null : users.get(0);
    }
    
    /**
         * @author Wojciech Mazur
         * @date   2016-11-22
         * @description find Users by Contact ids
         * @param  ids - Ids of contacts to search for 
         * @return     User       - found Users
         */
    public List<User> findUsersByContactIds(Set<Id> ids) {
    	if (ids==null || ids.size()==0)
    		return null;
        List<User> users = findSObjectsBy(
                                new List<SearchCondition>{
                                        new SearchCondition(
                                                'ContactId',
                                                'in',
                                                ids
                                        )
                                }
        );
        return users.isEmpty() ? null : users;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description find Contact
     * @param  profileName - UserProfile Name
     * @return     User       - found User
    */
    public User findTestUserByProfileName(String profileName) {
        return BTN_TestDataFactory.USER_MAP_BY_PROFILE.get(profileName);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description find Contact
     * @param  profileName - UserProfile Name
     * @return     User       - found User
    */
    public User findUserByProfileName(String profileName) {
        List<User> users = findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Profile.Name',
                                '=',
                                profileName
                        ),
                        new SearchCondition('AND isActive = true')
                }
        );
        return users.isEmpty() ? null : users.get(0);
    }
    
    /**
     * @author Wojciech Mazur
     * @date   2016-07-05
     * @description check user profile
     * @param  userId - User Id
     * @return     User       - found User
    */
    public Boolean isCommunityUser(String userId) {
    	Map<Id, UserLicense> commounityLicenses = new Map<Id, UserLicense>([SELECT Id From UserLicense where Name like :BTN_ConstantRepo.LICENSE_COMMUNITY+'%']);
    	Set<Id> licenseIds = commounityLicenses.keySet();
        List<User> users = findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Profile.UserLicenseId',
                                'in',
                                licenseIds
                        ),
                        new SearchCondition(
                        		'AND Id',
                        		'=',
                        		userId
                        )
                }
        );
        return users.isEmpty() ? false : true;
    }

    public override Schema.SObjectType getSObjectType() {
        return User.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                User.Id,
                User.Name,
                User.Email,
                User.ContactId
        };
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-09
     * @description findSystemAdministrators
     * @return     List<User>       - found Users
    */
    public List<User> findSystemAdministrators() {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Profile.Name',
                                '=',
                                BTN_ConstantRepo.ADMIN_PROFILE_NAME
                        )
                }
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-08-24
     * @description find all HR Users
     * @return List<User>
    */
    public List<User> findHRUsers() {
        List<PermissionSetAssignment> permissionSetsList = [
                SELECT AssigneeId, Assignee.Name
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = :BTN_ConstantRepo.PERM_SET_NAME_HR
        ];
        List<Id> assigneeIdsSet = new List<Id>();
        for(PermissionSetAssignment ps: permissionSetsList){
            assigneeIdsSet.add(ps.AssigneeId);
        }
        List<User> users = [SELECT Id, Name, FirstName, Email, ContactId FROM User WHERE Id IN :assigneeIdsSet];
        return users;
    }

    /**
     * @author Dariusz Chmiela
     * @date   2016-08-24
     * @description addUserFields method adds user fields to Query
     * @return void
    */
    public void addUserFields() {
        currentFields.add('FirstName');
        currentFields.add('LastName');
    }

    public BTN_DAO_User addProfileName() {
        currentFields.add('Profile.Name');
        return this;
    }
    
    /**
     * @author Wojciech Mazur
     * @date   2016-11-07
     * @description addGoogleFields method adds Google fields to Query
     * @return void
    */
    public BTN_DAO_User addGoogleFields() {
        currentFields.add('FirstName');
        currentFields.add('GoogleAccessToken__c');
        currentFields.add('GoogleAuthCode__c');
        currentFields.add('GoogleRefreshToken__c');
        currentFields.add('GoogleTokenDate__c');
        currentFields.add('GoogleTokenExpiresIn__c');
        return this;
    }
}