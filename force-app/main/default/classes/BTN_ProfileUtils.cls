/**
 * @author Dariusz Chmiela
 * @date 2016-09-12
 * @description BTN_ProfileUtil
*/
public class BTN_ProfileUtils {
    public final static String PROFILE_NAME_BTN_COMMUNITY_USER = 'BTN Community user';
    public final static String PROFILE_NAME_BTN_RESOURCE_MANAGER = 'BTN Resource Manager';
    public final static String PROFILE_NAME_BTN_SALES_USER = 'BTN Sales User';
    public final static String PROFILE_NAME_BTN_SERVICE_CLOUD = 'BTN Service cloud';
    public final static String PROFILE_NAME_CHATTER_EXTERNAL_USER = 'Chatter External User';
    public final static String PROFILE_NAME_CHATTER_FREE_USER = 'Chatter Free User';
    public final static String PROFILE_NAME_CHATTER_MODERATOR_USER = 'Chatter Moderator User';
    public final static String PROFILE_NAME_COMMUNITY_USER = 'Community user';
    public final static String PROFILE_NAME_CONTRACT_MANAGER = 'Contract Manager';
    public final static String PROFILE_NAME_CUSTOMER_COMMUNITY_USER = 'Customer Community User';
    public final static String PROFILE_NAME_DEVELOPER = 'Developer';
    public final static String PROFILE_NAME_MARKETING_USER = 'Marketing User';
    public final static String PROFILE_NAME_READ_ONLY = 'Read Only';
    public final static String PROFILE_NAME_SERVICE_CLOUD_USER = 'Service Cloud User';
    public final static String PROFILE_NAME_SOLUTION_MANAGER = 'Solution Manager';
    public final static String PROFILE_NAME_STANDARD_USER = 'Standard User';
    public final static String PROFILE_NAME_SYSTEM_ADMINISTRATOR = 'System Administrator';
    public final static Map<String,Profile> MAP_PROFILE_NAME_2_PROFILES;
    public final static Map<String,Id> MAP_PROFILE_NAME_2_PROFILE_ID;
    static {
        MAP_PROFILE_NAME_2_PROFILES = new Map<String, Profile>();
        MAP_PROFILE_NAME_2_PROFILE_ID = new Map<String,Id>();
        for(Profile profile : new BTN_DAO_Profile().getAllProfiles()){
            MAP_PROFILE_NAME_2_PROFILES.put(profile.Name,profile);
            MAP_PROFILE_NAME_2_PROFILE_ID.put(profile.Name,profile.Id);
        }
    }
}