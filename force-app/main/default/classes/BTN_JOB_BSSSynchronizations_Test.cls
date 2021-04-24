/**
 * @author Mateusz Przywara
 * @date   2016-08-10
 * @description BTN_JOB_BSSSynchronizations_Test test if BSS Sync is scheduling properly.
*/
@isTest
private class BTN_JOB_BSSSynchronizations_Test {
	private static final Set<String> JOB_STATUS = new Set<String>{'Completed', 'Queued'};
	private static final String JOB_CRON = '0 0 1 * * ?';
	private static final String JOB_NAME = 'test Job sync with BS (internal contacts)';
    private static final Integer CONTACT_QUANTITY = 20;
    private static final Integer PROJECT_QUANTITY = 20;
    private static final Integer ASSIGNMENT_QUANTITY = 200;

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description Prepare data for tests
     */
    @testSetup static void createDataStructure() {
        // UnCommited Data cannot use Default TestSetup Method with callouts test
        //BTN_TestDataFactory.createDataStructureForBriteRM();
        BTN_TestDataFactory.getNewBssDummyConnections();
        BTN_TestDataFactory.getBriteNetAccount();
        BTN_TestDataFactory.getProjectRolesCustomSetting();
        BTN_TestDataFactory.getTriggerSkipperCustomSetting();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-10
     * @description Method Test if job run correctly
     * @return
     */
	@isTest static void testingIsJobSchedulable() {
		System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_JOB_BSSSynchronizations apexJob = new BTN_JOB_BSSSynchronizations();
            System.schedule(JOB_NAME, JOB_CRON, apexJob);
            Test.startTest();
            System.schedule(JOB_NAME + BTN_DateUtils.getPastUNIXTimeStamp(0), JOB_CRON, apexJob);
            System.schedule(JOB_NAME + BTN_DateUtils.getPastUNIXTimeStamp(0), JOB_CRON, apexJob);
            System.schedule(JOB_NAME + BTN_DateUtils.getPastUNIXTimeStamp(0), JOB_CRON, apexJob);
            System.schedule(JOB_NAME + BTN_DateUtils.getPastUNIXTimeStamp(0), JOB_CRON, apexJob);
            BTN_TestDataFactory.scheduleBSSSync();
            Test.stopTest();
            System.assertEquals(6, new BTN_DAO_AsyncApexJob().findAsyncApexJobsByStatus(JOB_STATUS).size());
        }
	}

    /**
     * @author Mateusz Przywara
     * @date   2016-08-10
     * @description testingIsJobParseContacts Method Test if job run correctly and parse Contacts
     */
    @isTest static void testingIsJobParseContacts() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_DAO_Contact contactDAO = new BTN_DAO_Contact();
            Integer contactsQuantityBeforeSync = contactDAO.findBSSContacts().size();
            BTN_JOB_BSSSynchronizations apexJob = new BTN_JOB_BSSSynchronizations();
            // set MockAPI response with  CONTACT_QUANTITY BSS Contacts -
            // Number of Contacts should be low enough to read whole log.
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.USER_MODE, 200, CONTACT_QUANTITY));
            Test.startTest();
            BTN_JOB_BSSSynchronizations.futureSyncBSS();
            Test.stopTest();
            List<Contact> contacts = new BTN_DAO_Contact().findBSSContacts();
            System.assertEquals(contactsQuantityBeforeSync + CONTACT_QUANTITY, contacts.size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-10
     * @description testingIsJobParseProjects Method Test if job run correctly and parse Projects
     */
    @isTest static void testingIsJobParseProjects() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_DAO_Project projectDAO = new BTN_DAO_Project();
            Integer projectsQuantityBeforeSync = projectDAO.findProjects().size();
            BTN_JOB_BSSSynchronizations apexJob = new BTN_JOB_BSSSynchronizations();
            // set MockAPI response with  PROJECT_QUANTITY BSS Projects -
            // Number of Projects should be low enough to read whole log.
            Test.setMock(HttpCalloutMock.class, new BTN_BSS_Mockup(BTN_BSS_Mockup.PROJECT_MODE, 200, PROJECT_QUANTITY));
            Test.startTest();
            BTN_JOB_BSSSynchronizations.futureSyncBSS();
            Test.stopTest();
            // MockAPI Projects were connected to BritenetAccount by Company Name
            System.assertEquals(projectsQuantityBeforeSync + PROJECT_QUANTITY, projectDAO.findProjects().size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-10
     * @description testingIsJobParseAssignments Method Test if job run correctl and parse Assignments.
     */
    @isTest static void testingIsJobParseAssignments() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_DAO_Assignment assignmentDAO = new BTN_DAO_Assignment();
            Integer assignmentsQuantityBeforeSync = assignmentDAO.findAssignments().size();
            BTN_JOB_BSSSynchronizations apexJob = new BTN_JOB_BSSSynchronizations();
            // set MockAPI response with  ASSIGNMENT_MODE BSS Assignments -
            // Number of Assignments should be low enough to read whole log.
            BTN_BSS_Mockup mockAPI = new BTN_BSS_Mockup(BTN_BSS_Mockup.ASSIGNMENT_MODE, 200, ASSIGNMENT_QUANTITY);
            Test.setMock(HttpCalloutMock.class, mockAPI);
            // Provide Contacts for Assignments
            BTN_BSS_Mockup.TEST_USER_QUANTITY = 1;
            insert BTN_ContactUtils.newContactFromBS(
                    BTN_BSS_DTO.parseUser(mockAPI.generateUserJSON(1))
            );
            // Provide Projects for Assignments
            BTN_BSS_Mockup.TEST_PROJECT_QUANTITY = 1;
            insert BTN_ProjectUtils.parseDTOProjectsFromBSSToSObjects(
                    BTN_BSS_DTO.parseProject(mockAPI.generateProjectJSON(1)),
                    new BTN_DAO_Account().findAccounts()
            );
            Test.startTest();
            BTN_JOB_BSSSynchronizations.futureSyncBSS();
            Test.stopTest();

            System.assertEquals(
                    assignmentsQuantityBeforeSync + ASSIGNMENT_QUANTITY, assignmentDAO.findAssignments().size()
            );
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-10
     * @description testingIsJobParseProjects Method Test if job run correctly and parse Projects
     */
    @isTest static void testingIsJobParseProjectRoles() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            Integer projectsRolesQuantityBeforeSync = BTN_ProjectRoleUtils.getProjectRoles().size();
            BTN_JOB_BSSSynchronizations apexJob = new BTN_JOB_BSSSynchronizations();
            // set MockAPI response with  PROJECTROLE_QUANTITY
            Test.setMock(
                    HttpCalloutMock.class, new BTN_BSS_Mockup(
                            BTN_BSS_Mockup.PROJECTROLE_MODE,
                            BTN_BSS_Mockup.SUCCESS_STATUS_CODE,
                            BTN_BSS_Mockup.TEST_PROJECTROLE_QUANTITY)
            );
            Test.startTest();
            BTN_JOB_BSSSynchronizations.futureSyncBSS();
            Test.stopTest();
            //
            System.assert(
                    !BTN_ContactUtils.MAP_PROJECT_ROLE_ID_BY_DESC.isEmpty()
            );
        }
    }
}