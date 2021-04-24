/**
 * @author Dariusz Chmiela
 * @date 2016-09-14
 * @description BTN_ProfileUtils_Test to test BTN_ProfileUtils
 */
@isTest
public class BTN_ProfileUtils_Test {
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description test get Account method
    */
    @isTest
    private static void codeCoverageTest(){
        // given when then
        BTN_ProfileUtils profileUtils = new BTN_ProfileUtils();
        Map<String,Id> profileName2ProfileIfMap = BTN_ProfileUtils.MAP_PROFILE_NAME_2_PROFILE_ID;
        Map<String,Profile> profileName2ProfilesMap = BTN_ProfileUtils.MAP_PROFILE_NAME_2_PROFILES;
        String profileNameBtnCommunityUser = BTN_ProfileUtils.PROFILE_NAME_BTN_COMMUNITY_USER;
    }

}