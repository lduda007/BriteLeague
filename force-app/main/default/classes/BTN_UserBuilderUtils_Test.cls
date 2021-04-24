/**
 * @author Dariusz Chmiela
 * @date 2016-09-16
 * @description BTN_UserBuilderUtil_Test to test BTN_UserBuilderUtil
 */
@isTest
public class BTN_UserBuilderUtils_Test {
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description codeCoverageTest to cover test
    */
    @isTest
    private static void codeCoverageTest(){
        // given when then
        BTN_UserBuilderUtils userBuilderUtils = new BTN_UserBuilderUtils();
        userBuilderUtils.buildHRCommunityUser();
        userBuilderUtils.buildRRCommunityUser();
        userBuilderUtils.buildSalesRepUser();
    }
}