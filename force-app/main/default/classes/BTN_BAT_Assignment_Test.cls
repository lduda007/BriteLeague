/**
 * @author Mateusz Przywara
 * @date   2016-08-11
 * @description BTN_BAT_Assignment_Test Test Class for Assignment Processing
*/
@isTest
private class BTN_BAT_Assignment_Test {
    private static final Integer ASSIGNMENT_TEST_LENGTH = 7;

    /**
     * @author Mateusz Przywara
     * @date   2016-08-11
     * @description Prepare data for tests
    */
    @testSetup static void createDataStructure() {
        BTN_TestDataFactory.getBriteNetAccount();
        BTN_TestDataFactory.getRequestorInternalContact(
                new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id
        );
        BTN_TestDataFactory.getNewBssDummyConnections();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-11
     * @description testingIsJobParseContacts Method Test if job run correctly and parse Contacts
    */
    @isTest static void testExecutpionForEmptyInput() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_BAT_Assignment assignmentProcessingBatch = new BTN_BAT_Assignment();
            Test.startTest();
            Database.executeBatch(assignmentProcessingBatch);
            Test.stopTest();
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description test2chunksOfAssignments Test for input with more than 200 Assignments
    */
    @isTest static void test2chunksOfAssignments() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            //Assignments to process later in Batch.
            // 401 one week Assignments with 4 days Interval
            BTN_TestDataFactory.getPreparedAssignments(401, 7, BTN_BAT_Assignment.MAX_END_DATE_DIFFERENCE - 1);
            BTN_BAT_Assignment assignmentProcessingBatch = new BTN_BAT_Assignment();
            Test.startTest();
            Database.executeBatch(assignmentProcessingBatch);
            Test.stopTest();
            // 2 Cases because all Assignments are in same time Section.
            System.assertEquals(2, new BTN_DAO_Case().findCases().size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description test2chunksOfAssignments Test for input with more than 200 Assignments
    */
    @isTest static void test2chunksOfAssignmentsAllShouldHaveCases() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            //Assignments to process later in Batch.
            // 401 one week Assignments with 8 days Interval - cause OnBoarding
            BTN_TestDataFactory.getPreparedAssignments(401, 7, BTN_BAT_Assignment.MAX_END_DATE_DIFFERENCE + 1);
            BTN_BAT_Assignment assignmentProcessingBatch = new BTN_BAT_Assignment();
            Test.startTest();
            Database.executeBatch(assignmentProcessingBatch, 1);
            Test.stopTest();
            // 2 Cases because all Assignments are in same time Section.
            System.assertEquals(802, new BTN_DAO_Case().findCases().size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description test2chunksOfAssignments Test for input with more than 200 Assignments
    */
    @isTest static void testChunkOfAssignmentsAllShouldHaveCases() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            //Assignments to process later in Batch.
            // 401 one week Assignments with 8 days Interval - cause OnBoarding
            BTN_TestDataFactory.getPreparedAssignments(200, 7, BTN_BAT_Assignment.MAX_END_DATE_DIFFERENCE + 1);
            BTN_BAT_Assignment assignmentProcessingBatch = new BTN_BAT_Assignment();
            Test.startTest();
            Database.executeBatch(assignmentProcessingBatch, 1);
            Test.stopTest();
            // All Assignments are in same time Section.
            System.assertEquals(400, new BTN_DAO_Case().findCases().size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description Method adds 2 Assignments. It should generate 2 Cases
    */
    @isTest static void
    addAssignmentsWhereSecondAssignmentHasStartDateInFirstOne() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_DAO_Case caseDAO = new BTN_DAO_Case();
            BTN_TestDataFactory.getPreparedAssignments(2, 4, -1);
            BTN_BAT_Assignment assignmentProcessingBatch = new BTN_BAT_Assignment();
            Test.startTest();
            Database.executeBatch(assignmentProcessingBatch);
            Test.stopTest();
            // 2 Cases because all Assignments are in same time Section.
            System.assertEquals(1, caseDAO.findExternalOnboardingCases().size());
            System.assertEquals(1, caseDAO.findExternalOffboardingCases().size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description Method adds 2 Assignments.
     * It should generate 2 Cases because second Assignment Start to early for onboarding
    */
    @isTest static void
    addAssignmentsWhereSecondAssignmentHasStartDateAfterFirstOneInMaxEndDate() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_DAO_Case caseDAO = new BTN_DAO_Case();
            List<BTN_Assignment__c> assignments =
                    BTN_TestDataFactory.getPreparedAssignments(2, 4, BTN_BAT_Assignment.MAX_END_DATE_DIFFERENCE + 1);
            BTN_BAT_Assignment assignmentProcessingBatch = new BTN_BAT_Assignment();

            // get second Assignment and set to be sure it's Start Date after first Assignment but in Range of max date
            assignments.get(1).StartDate__c =
                    (assignments.get(0).EndDate__c + BTN_BAT_Assignment.MAX_END_DATE_DIFFERENCE - 1);
            update assignments.get(1);
            Test.startTest();
            Database.executeBatch(assignmentProcessingBatch);
            Test.stopTest();
            System.assertEquals(2, caseDAO.findCases().size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description Method adds 2 Assignments. It should generate 2 Cases on first Assignment
    */
    @isTest static void
    addAssignmentsWhereItsStartAndAndDateAreInPreviousAssignment() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_DAO_Case caseDAO = new BTN_DAO_Case();
            List<BTN_Assignment__c> assignments =
                    BTN_TestDataFactory.getPreparedAssignments(2, 4, BTN_BAT_Assignment.MAX_END_DATE_DIFFERENCE + 1);
            BTN_BAT_Assignment assignmentProcessingBatch = new BTN_BAT_Assignment();

            // Assignments are week long. Second Assignment will be in first
            assignments.get(1).EndDate__c =
                    (assignments.get(0).EndDate__c + BTN_BAT_Assignment.MAX_END_DATE_DIFFERENCE - 1);
            assignments.get(1).StartDate__c =
                    (assignments.get(0).StartDate__c + BTN_BAT_Assignment.MAX_END_DATE_DIFFERENCE + 1);
            update assignments.get(1);
            Test.startTest();
            Database.executeBatch(assignmentProcessingBatch);
            Test.stopTest();
            System.assertEquals(2, caseDAO.findCases().size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description Method adds 2 Assignments with Equal dates. It should still generate only 2 Cases
    */
    @isTest static void
    twoAssignmentsHasSameStartAndEndDate() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_DAO_Case caseDAO = new BTN_DAO_Case();
            List<BTN_Assignment__c> assignments =
                    BTN_TestDataFactory.getPreparedAssignments(2, 4, BTN_BAT_Assignment.MAX_END_DATE_DIFFERENCE + 1);
            BTN_BAT_Assignment assignmentProcessingBatch = new BTN_BAT_Assignment();

            // Assignments are week long. Second Assignment will be in first
            assignments.get(1).EndDate__c = assignments.get(0).EndDate__c;
            assignments.get(1).StartDate__c = assignments.get(0).StartDate__c;
            update assignments.get(1);
            Test.startTest();
            Database.executeBatch(assignmentProcessingBatch);
            Test.stopTest();
            System.assertEquals(2, caseDAO.findCases().size());
        }
    }
}