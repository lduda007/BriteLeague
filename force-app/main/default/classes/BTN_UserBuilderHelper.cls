/**
 * @author Dariusz Chmiela
 * @date 2016-08-16
 * @description BTN_UserBuilderHelper
*/
public with sharing class BTN_UserBuilderHelper implements BTN_BuilderHelper{
    private User record;
    public static final String DEFAULT_ALIAS = 'Edward';
    public static final String DEFAULT_LAST_NAME = 'Tomaszewski';
    public static final String DEFAULT_EMAIL = System.currentTimeMillis() + 'test@britenet.com.pl';
    public static final String DEFAULT_USER_NAME = DEFAULT_EMAIL;
    public static final String DEFAULT_NICK_NAME = 'E';
    public static final String DEFAULT_EMAIL_ENCODING_KEY = 'ISO-8859-1';
    public static final String DEFAULT_TIME_ZONE_SID_KEY = 'GMT';
    public static final String DEFAULT_LOCALE_SID_KEY = 'en_GB';
    public static final String DEFAULT_LANGUAGE_LOCALE_KEY = 'en_US';
    public static final Profile DEFAULT_PROFILE = BTN_ProfileUtils.MAP_PROFILE_NAME_2_PROFILES
            .get(BTN_ProfileUtils.PROFILE_NAME_BTN_RESOURCE_MANAGER);
    public static final Boolean DEFAULT_IS_ACTIVE = true;
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildUserWithDefaults Method builds User sObject
     * @return BTN_UserBuilderHelper - current instance
    */
    public static BTN_UserBuilderHelper buildUserWithDefaults() {
        return buildUser();
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWith Method builds User sObject
     * @param String - given record type to set
     * @return BTN_AccountBuilderHelper - current instance
    */
    private static BTN_UserBuilderHelper buildUser(){
        BTN_UserBuilderHelper userBuilderHelper = new BTN_UserBuilderHelper();
        userBuilderHelper.record = applyDefaults();
        return userBuilderHelper;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description applyDefaults Method applies default values to record
     * @param String - Record Type Id to set
     * @return User
    */
    private static User applyDefaults() {
        return new User(
                Alias = DEFAULT_ALIAS,
                LastName = DEFAULT_LAST_NAME,
                Email = DEFAULT_EMAIL,
                Username = DEFAULT_USER_NAME,
                CommunityNickname = DEFAULT_NICK_NAME + EncodingUtil.base64encode(Crypto.generateAesKey(128)),
                EmailEncodingKey = DEFAULT_EMAIL_ENCODING_KEY,
                TimeZoneSidKey = DEFAULT_TIME_ZONE_SID_KEY,
                LocaleSidKey = DEFAULT_LOCALE_SID_KEY,
                LanguageLocaleKey = DEFAULT_LANGUAGE_LOCALE_KEY,
                IsActive = DEFAULT_IS_ACTIVE,
                ProfileId = DEFAULT_PROFILE.Id
        );
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withLastName Method set up User Last Name
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withLastName(String lastName) {
        record.LastName = lastName;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withAlias Method set up User Alias
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withAlias(String alias) {
        record.Alias = alias;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withEmail Method set up User Email
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withEmail(String email) {
        record.Email = email;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withUserName Method set up User userName
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withUserName(String userName) {
        record.Username = userName;
        record.CommunityNickname = userName;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withNickName Method set up User Community Nick Name
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withNickName(String nick) {
        record.CommunityNickname = nick;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withRole Method set up User Role ID
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withRole(ID roleId) {
        record.UserRoleId = roleId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withProfile Method set up User Profile Id
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withProfile(Id profileId) {
        record.ProfileId = profileId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withEmailEncoding Method set up User Email Encoding Key
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withEmailEncoding(String emailEncoding) {
        record.EmailEncodingKey = emailEncoding;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withTimeZone Method set up User Time Zone Sid Key
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withTimeZone(String timeZoneSidKey) {
        record.TimeZoneSidKey = timeZoneSidKey;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withLocal Method set up User Locale Sid Key
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withLocal(String localeSidKey) {
        record.LocaleSidKey = localeSidKey;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withLocal Method set up User Language Locale Key
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withLanguage(String languageLocaleKey) {
        record.LanguageLocaleKey = languageLocaleKey;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-12
     * @description isActive Method set up Active flag
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper isActive(Boolean active) {
        record.IsActive = active;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description withContactId Method set up User Contact Id
     * @return BTN_UserBuilderHelper - instance of Builder
    */
    public BTN_UserBuilderHelper withContactId(String contactId) {
        record.ContactId = contactId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description get Method gets building record
     * @return User building record
    */
    public User get(){
        return record;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description save Method saves building record
     * @return User building record
    */
    public User save(){
        insert record;
        return record;
    }
}