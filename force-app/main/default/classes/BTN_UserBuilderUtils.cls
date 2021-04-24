/**
 * @author Dariusz Chmiela
 * @date 2016-08-24
 * @description BTN_UserBuilderUtils
*/
public with sharing class BTN_UserBuilderUtils {
    private static Account acc;
    private static Contact cont;
    private static Contact hrCont;
    private static String contactEmail = 'contact_emial@britenet.com.pl';
    private static Id communityProfileId = BTN_ProfileUtils.MAP_PROFILE_NAME_2_PROFILE_ID
            .get(BTN_ProfileUtils.PROFILE_NAME_BTN_COMMUNITY_USER);
    private static UserRole hrRole = BTN_UserRoleUtils.ROLE_NAME_2_ROLE_MAP.get(BTN_UserRoleUtils.ROLE_NAME_HR);
    private static Id salesRepProfileId = BTN_ProfileUtils.MAP_PROFILE_NAME_2_PROFILE_ID
            .get(BTN_ProfileUtils.PROFILE_NAME_BTN_SALES_USER);
    private static Id salesRepRoleId = BTN_UserRoleUtils.ROLE_NAME_2_ROLE_MAP.get(BTN_UserRoleUtils.ROLE_NAME_HR).Id;
    public static String email = contactEmail;
    public static String hrUserEmail = EncodingUtil.base64encode(Crypto.generateAesKey(128)) + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX;
    public static String salesUserEmail = 'sales_contact_emial@britenet.com.pl';

    public BTN_UserBuilderUtils(){
        acc = BTN_AccountBuilderHelper.buildWithPublicSectorRecordType().save();
        cont = BTN_ContactBuilderHelper.buildWithBusinessRecordType()
                .withFirstName('First Name')
                .withLastName('Last Name' + EncodingUtil.base64encode(Crypto.generateAesKey(128)))
                .withAccount(acc.Id)
                .withEmail(EncodingUtil.base64encode(Crypto.generateAesKey(128)) + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX)
                .save();
        hrCont = BTN_ContactBuilderHelper.buildWithBusinessRecordType()
                .withAccount(acc.Id)
                .withEmail(hrUserEmail)
                .save();
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-24
     * @description buildRRCommunityUser method returns Resource Requestor user
    */
    public User buildRRCommunityUser(){
        User u = BTN_UserBuilderHelper.buildUserWithDefaults()
                .withLastName('Last' + EncodingUtil.base64encode(Crypto.generateAesKey(128)))
                .withUserName('testUser@britenet.com.pl')
                .withAlias('testAlia')
                .withEmailEncoding('ISO-8859-1')
                .withLanguage('en_US')
                .withLocal('en_GB')
                .withNickName('Nick')
                .withProfile(communityProfileId)
                .withContactId(cont.Id)
                .withLanguage('en_US')
                .withTimeZone('GMT')
                .withEmail(cont.Email)
                .get();
        return u;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-29
     * @description buildHRCommunityUser method returns HR Community user
    */
    public User buildHRCommunityUser(){
        User hrUser  = BTN_UserBuilderHelper.buildUserWithDefaults()
                .withLastName('Last' + EncodingUtil.base64encode(Crypto.generateAesKey(128)))
                .withUserName(System.currentTimeMillis()+'testUser@britenet.com.pl')
                .withAlias('testAlia')
                .withEmailEncoding('ISO-8859-1')
                .withLanguage('en_US')
                .withLocal('en_GB')
                .withNickName('Nick2')
                .withProfile(communityProfileId)
                .withContactId(hrCont.Id)
                .withLanguage('en_US')
                .withTimeZone('GMT')
                .withEmail(hrCont.Email)
                .get();
        return hrUser;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-31
     * @description buildSalesRepUser Method returns sales rep user
     * @return User
    */
    public User buildSalesRepUser(){
        User salesRepUser = BTN_UserBuilderHelper.buildUserWithDefaults()
                .withUserName(BTN_UserBuilderHelper.DEFAULT_USER_NAME)
                .withLastName(BTN_UserBuilderHelper.DEFAULT_LAST_NAME + EncodingUtil.base64encode(Crypto.generateAesKey(128)))
                .withAlias(BTN_UserBuilderHelper.DEFAULT_ALIAS)
                .withNickName(BTN_UserBuilderHelper.DEFAULT_NICK_NAME)
                .withTimeZone(BTN_UserBuilderHelper.DEFAULT_TIME_ZONE_SID_KEY)
                .withLocal(BTN_UserBuilderHelper.DEFAULT_LOCALE_SID_KEY)
                .withEmailEncoding(BTN_UserBuilderHelper.DEFAULT_EMAIL_ENCODING_KEY)
                .withLanguage(BTN_UserBuilderHelper.DEFAULT_LANGUAGE_LOCALE_KEY)
                .withRole(salesRepRoleId)
                .withProfile(salesRepProfileId)
                .withEmail(salesUserEmail)
                .get();
        return salesRepUser;
    }
}