/**
 * @author Mateusz Przywara
 * @date   2016-09-02
 * @description BTN_RecordTypeUtils_Test Test for Utils class for Record Type
 */
@isTest
private class BTN_RecordTypeUtils_Test {
    /**
     * @author Mateusz Przywara
     * @date   2016-09-02
     * @description testIsCaseInternalOffboarding
    */
    @isTest static void testIsCaseInternalOffboarding() {
        Contact internalContact =
                BTN_TestDataFactory.getRequestorInternalContact(BTN_TestDataFactory.getBriteNetAccount().Id);
        System.RunAs(BTN_Utils.getCurrentUser()) {
            System.assert(
                    BTN_RecordTypeUtils.isCaseInternalOffBoarding(
                            BTN_TestDataFactory.getInternalOffboardingCase(internalContact.Id)
                    )
            );
            System.assert(
                    !BTN_RecordTypeUtils.isCaseInternalOffBoarding(BTN_TestDataFactory.getInternalOnboardingCase())
            );
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-02
     * @description testIsCaseInternalOnboarding
    */
    @isTest static void testIsCaseInternalOnboarding() {
        Contact internalContact =
                BTN_TestDataFactory.getRequestorInternalContact(BTN_TestDataFactory.getBriteNetAccount().Id);
        System.RunAs(BTN_Utils.getCurrentUser()) {
            System.assertEquals(
                    true,
                    BTN_RecordTypeUtils.isCaseInternalOnBoarding(BTN_TestDataFactory.getInternalOnboardingCase())
            );
            System.assertEquals(
                    true,
                    BTN_RecordTypeUtils.isCaseInternalOffBoarding(
                            BTN_TestDataFactory.getInternalOffboardingCase(internalContact.Id)
                    )
            );
        }
    }

    /**
    * @author Dariusz Chmiela
    * @date 2016-09-29
    * @description getRecordTypePrivateSectorTest
    */
    @isTest static void getRecordTypePrivateSectorTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeAccountPrivateSector());
    }

    /**
    * @author Dariusz Chmiela
    * @date 2016-09-29
    * @description getRecordTypePublicSectorTest
    */
    @isTest static void getRecordTypePublicSectorTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeAccountPublicSector());
    }

    /**
    * @author Dariusz Chmiela
    * @date 2016-09-29
    * @description getRecordTypeAccountBritenetTest
    */
    @isTest static void getRecordTypeAccountBritenetTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeAccountBritenet());
    }

    /**
    * @author Dariusz Chmiela
    * @date 2016-09-29
    * @description getRecordTypeCaseInternalOnBoardingTest
    */
    @isTest static void getRecordTypeCaseInternalOnBoardingTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeCaseInternalOnBoarding());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeCaseExternalOnBoardingTest
    */
    @isTest static void getRecordTypeCaseExternalOnBoardingTest() {
        BTN_TestDataFactory.getTriggerSkipperCustomSetting();
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeCaseExternalOnBoarding());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeCaseInternalOffBoardingTest
    */
    @isTest static void getRecordTypeCaseInternalOffBoardingTest() {
        BTN_TestDataFactory.getTriggerSkipperCustomSetting();
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeCaseInternalOffBoarding());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeCaseExternalOffBoardingTest
    */
    @isTest static void getRecordTypeCaseExternalOffBoardingTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeCaseExternalOffBoarding());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeContactBusinessTest
    */
    @isTest static void getRecordTypeContactBusinessTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeContactBusiness());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeContactInternalTest
    */
    @isTest static void getRecordTypeContactInternalTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeContactInternal());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeEventInternalTest
    */
    @isTest static void getRecordTypeEventInternalTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeEventInternal());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeEventExternalTest
    */
    @isTest static void getRecordTypeEventExternalTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeEventExternal());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeOpportunityFixedPriceTest
    */
    @isTest static void getRecordTypeOpportunityFixedPriceTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeOpportunityFixedPrice());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeOpportunityTimeMaterialTest
    */
    @isTest static void getRecordTypeOpportunityTimeMaterialTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeOpportunityTimeMaterial());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeOpportunitySupportTest
    */
    @isTest static void getRecordTypeOpportunitySupportTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeOpportunitySupport());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeResourceRequestAutoTest
    */
    @isTest static void getRecordTypeResourceRequestAutoTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeResourceRequestAuto());
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-29
     * @description getRecordTypeResourceRequestManualTest
    */
    @isTest static void getRecordTypeResourceRequestManualTest() {
        System.assertNotEquals(null,BTN_RecordTypeUtils.getRecordTypeResourceRequestManual());
    }
}