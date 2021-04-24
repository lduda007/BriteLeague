/**
 * @author Mateusz Przywara
 * @date   2016-07-15
 * @description BTN_BSS_Service_Test test BSS Services for corect parsing Contacts / Certs.
*/
@IsTest
private class BTN_BSS_Service_Test {
    private static final Set<String> JOB_STATUS = new Set<String>{'Completed', 'Queued'};
    private static final String TEST_PARAM_NAME = 'TestPARAM';
    private static final String TEST_PARAM_VALUE = 'TestPARAMvalue';

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description Prepare data for tests
     *  Be careful with adding data assiociated with workflows, flows etc.
     *  It may cause CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
     */
    @testSetup static void createDataStructure() {
        BTN_TestDataFactory.getNewBssDummyConnections();
        BTN_TestDataFactory.getTriggerSkipperCustomSetting();
        Account acc = BTN_TestDataFactory.getBriteNetAccount();
        BTN_TestDataFactory.getRequestorInternalContact(acc.Id);
        BTN_TestDataFactory.getProjectRolesCustomSetting();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description Test BSS User Webservice with Code 200
     */
	@isTest
	static void testBSSUserServiceWithCode200() {
        List<BTN_BSS_DTO.User> bssUsers;
		System.RunAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.USER_MODE, 200));
            Test.startTest();
            bssUsers = BTN_BSS_Service.getUserDetails();
            Test.stopTest();
            System.assertEquals(500, bssUsers.size());
        }
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description Test BSS Cert Webservice with Code 200
     */
	@isTest
	static void testBSSCertServiceWithCode200() {
        List<BTN_BSS_DTO.Cert> bssCerts;
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.CERT_MODE, 200));
            Test.startTest();
            bssCerts = BTN_BSS_Service.getCertDetails();
            Test.stopTest();
            System.assertEquals(5, bssCerts.size());
        }
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description Test BSS User Webservice with Code 500  Internal Server Error
     */
	@isTest
	static void testBSSUserServiceWithCode500() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.USER_MODE, 500));
            BTN_TestDataFactory.getNewBssDummyConnections();
            System.assertEquals(null, BTN_BSS_Service.getUserDetails());
        }
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description Test BSS Cert Webservice with Code 500 Internal Server Error
     */
	@isTest
	static void testBSSCertServiceWithCode500() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.CERT_MODE, 500));
            System.assertEquals(null, BTN_BSS_Service.getCertDetails());
        }
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-08-05
     * @description Test BSS Assignment Webservice with Code 200
     */
    @isTest
    static void testBSSAssignmentServiceWithCode200() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            List<BTN_BSS_DTO.Assignment> bssAssignments = new List<BTN_BSS_DTO.Assignment>();
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.ASSIGNMENT_MODE, 200));
            Test.startTest();
            bssAssignments = BTN_BSS_Service.getAssignmentDetails();
            Test.stopTest();
            System.assertEquals(3000, bssAssignments.size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-05
     * @description Test BSS Assignment Webservice with Code 500  Internal Server Error
     */
    @isTest
    static void testBSSAssignmentServiceWithCode500() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.ASSIGNMENT_MODE, 500));
            System.assertEquals(null, BTN_BSS_Service.getAssignmentDetails());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-05
     * @description Test BSS Project Webservice with Code 200
     */
    @isTest
    static void testBSSProjectServiceWithCode200() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            List<BTN_BSS_DTO.Project> bssProjects = new List<BTN_BSS_DTO.Project>();
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.PROJECT_MODE, 200));
            Test.startTest();
            bssProjects = BTN_BSS_Service.getProjectDetails();
            Test.stopTest();
            System.assertEquals(500, bssProjects.size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-05
     * @description Test BSS Project Webservice with Code 500  Internal Server Error
     */
    @isTest
    static void testBSSProjectServiceWithCode500() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.PROJECT_MODE, 500));
            System.assertEquals(null, BTN_BSS_Service.getProjectDetails());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-31
     * @description  testParamsMapBuilder Test builder which build map of params => case fields.
     * Onboarding Case and run Service method to Retrieve Response from Britesheet
     */
    @isTest
    static void testParamsMapBuilder() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
            System.assertNotEquals(
                    null,
                    BTN_CaseUtils.buildParamMapForNewBSUserFromCase(BTN_TestDataFactory.getInternalOnboardingCase())
            );
            System.assertNotEquals(
                    null,
                    BTN_CaseUtils.buildParamMapForNewBSUserFromCase(
                            BTN_TestDataFactory.getInternalOffboardingCase(internalContact.Id)
                    )
            );
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description testSendingNewUserToBriteSheetResponseSuccessCode200 Run Service method to Retrieve Response from
      * Britesheet
     */
    @isTest
    static void testSendingNewUserToBriteSheetResponseSuccessCode200() {
        BTN_BSS_DTO.ResponseStatus response;
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(
                    BTN_BSS_Mockup.SET_NEW_USER_MODE,
                    BTN_BSS_Mockup.SUCCESS_STATUS_CODE)
            );

            Map<String, String> pMap = new Map<String, String>{
                TEST_PARAM_NAME => TEST_PARAM_VALUE
            };
            Test.startTest();
            response = BTN_BSS_Service.sendToBSNewUser(pMap);
            Test.stopTest();

            System.assertEquals(BTN_BSS_Service.NEW_BS_RESPONSE_SUCCESS_STATUS, response.status);
            System.assertEquals(BTN_BSS_Service.NEW_BS_USER_RESPONSE_SUCCESS_MESSAGE, response.error);
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description testAddingNewUserToBSByCreatingInternalOnboardingCaseWithCodeSuccessCode400 Adds New User to BS
     * reponse will have error message for example validation error
     */
    @isTest
    static void testAddingNewUserToBSByCreatingInternalOnboardingCaseWithErrorCode400() {
        BTN_BSS_DTO.ResponseStatus response;
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(
                    BTN_BSS_Mockup.SET_NEW_USER_MODE,
                    BTN_BSS_Mockup.BADREQUEST_ERROR_STATUS_CODE) // 400
            );
            // Query internal Contact
            Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
            // Add Internal OnBoarding Case to Contact
            Case internalOnboarding = BTN_TestDataFactory.getInternalOnboardingCase();

            Test.startTest();
            response =
                    BTN_BSS_Service.sendToBSNewUser(
                            BTN_CaseUtils.buildParamMapForNewBSUserFromCase(internalOnboarding)
                    );
            Test.stopTest();

            //System.assertEquals(BTN_BSS_Service.NEW_BS_RESPONSE_ERROR_STATUS, response.status);
            System.assertEquals(null, response);
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description testAddingNewUserToBSByCreatingInternalOnboardingCaseWithInternalErrorCode500 Adds New User to BS
     * reponse will have no error message.
     */
    @isTest
    static void testAddingNewUserToBSByCreatingInternalOnboardingCaseWithInternalErrorCode500() {
        BTN_BSS_DTO.ResponseStatus response;
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(
                    BTN_BSS_Mockup.SET_NEW_USER_MODE,
                    BTN_BSS_Mockup.INTERNAL_ERROR_STATUS_CODE) // 500
            );
            // Query internal Contact
            Contact internalContact = new BTN_DAO_Contact().findInternals().get(0);
            // Add Internal OnBoarding Case to Contact
            Case internalOnboarding = BTN_TestDataFactory.getInternalOnboardingCase();
            Test.startTest();
            response =
                    BTN_BSS_Service.sendToBSNewUser(
                            BTN_CaseUtils.buildParamMapForNewBSUserFromCase(internalOnboarding)
                    );
            Test.stopTest();
            //System.assertEquals(BTN_BSS_Service.NEW_BS_RESPONSE_ERROR_STATUS, response.status);
            System.assertEquals(null, response);
        }
    }

    @isTest
    static void testGearServiceWithStatusCode200() {
        List<BTN_BSS_DTO.Gear> response;
        System.runAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(
                    BTN_BSS_Mockup.GEAR_MODE,
                    BTN_BSS_Mockup.SUCCESS_STATUS_CODE)
            );

            Map<String, String> pMap = new Map<String, String>{
                    TEST_PARAM_NAME => TEST_PARAM_VALUE
            };
            Test.startTest();
            response = BTN_BSS_Service.getGears();
            Test.stopTest();

            System.assert(!response.isEmpty());
        }
    }

    @isTest
    static void testSendingNewGearToBriteSheetResponseSuccessCode200() {
        BTN_BSS_DTO.GearResponseStatus response;
        System.runAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(
                    BTN_BSS_Mockup.SET_NEW_GEAR_MODE,
                    BTN_BSS_Mockup.SUCCESS_STATUS_CODE)
            );

            Map<String, String> pMap = new Map<String, String>{
                    TEST_PARAM_NAME => TEST_PARAM_VALUE
            };
            Test.startTest();
            response = BTN_BSS_Service.setGear(pMap);
            Test.stopTest();

            System.assertEquals(BTN_BSS_Service.NEW_BS_RESPONSE_SUCCESS_STATUS, response.status);
            System.assertEquals(BTN_BSS_Service.NEW_BS_GEAR_RESPONSE_SUCCESS_MESSAGE, response.error);
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-28
     * @description Test BSS ProjectRole Webservice with Code 200
     */
    @isTest
    static void testBSSProjectRoleServiceWithCode200() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            List<BTN_BSS_DTO.ProjectRole> bssProjectRoles = new List<BTN_BSS_DTO.ProjectRole>();
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.PROJECTROLE_MODE, 200));
            Test.startTest();
            bssProjectRoles = BTN_BSS_Service.getProjectRoleDetails();
            Test.stopTest();
            System.assertEquals(BTN_BSS_Mockup.TEST_PROJECTROLE_QUANTITY, bssProjectRoles.size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-28
     * @description Test BSS Project Role Webservice with Code 500  Internal Server Error
     */
    @isTest
    static void testBSSProjectRoleServiceWithCode500() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.PROJECTROLE_MODE, 500));
            System.assertEquals(null, BTN_BSS_Service.getProjectRoleDetails());
        }
    }
}