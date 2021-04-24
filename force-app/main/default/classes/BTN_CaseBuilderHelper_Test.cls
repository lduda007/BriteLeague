/*
 * @author Dariusz Chmiela
 * @date 2016-09-09
 * @description BTN_BuilderHelper class to test BTN_CaseBuilderHelper
*/
@isTest
public class BTN_CaseBuilderHelper_Test {

    /**
     * @author Mateusz Przywara
     * @date   2016-08-31
     * @description Prepare data for tests
    */
    @testSetup static void createDataStructure() {
        BTN_TestDataFactory.getHRCollaborationGroup();
        Account britenetAcc = BTN_TestDataFactory.getBriteNetAccount();
        BTN_TestDataFactory.getRequestorInternalContact(britenetAcc.Id);
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description test geting Case
    */
    @isTest
    private static void getCaseTest(){
        //prepare Assignment
        BTN_Assignment__c assignment = BTN_TestDataFactory.getPreparedAssignments(1, 0, 0).get(0);
        // given
        Case ca  =
                BTN_CaseBuilderHelper.buildWithInternalOffBoardingRecordType().withAssignmentId(assignment.Id).get();
        // when
        Test.startTest();
        insert ca;
        Test.stopTest();
        // then
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description test saving Case
    */
    @isTest
    private static void saveCaseTest(){
        //prepare Assignment
        BTN_Assignment__c assignment = BTN_TestDataFactory.getPreparedAssignments(1, 0, 0).get(0);
        // given
        Case ca;
        // when
        Test.startTest();
        ca = BTN_CaseBuilderHelper.buildWithExternalOnBoardingRecordType().withAssignmentId(assignment.Id).save();
        Test.stopTest();
        // then
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-16
     * @description test saving Case with given fields
    */
    @isTest
    private static void saveCaseWithGivenFieldsTest(){
        //prepare Assignment
        BTN_Assignment__c assignment = BTN_TestDataFactory.getPreparedAssignments(1, 0, 0).get(0);
        // given
        RecordType recordType = BTN_RecordTypeUtils.getRecordTypeCaseInternalOffBoarding();
        System.assertNotEquals(null, recordType.Id);
        Contact contact = BTN_ContactBuilderHelper.buildWithBusinessRecordType().save();
        Case ca  = BTN_CaseBuilderHelper.buildWithInternalOffBoardingRecordType()
                .withStatus(BTN_CaseBuilderHelper.DEFAULT_STATUS)
                .withFirstName(BTN_CaseBuilderHelper.DEFAULT_FIRST_NAME)
                .withLastName(BTN_CaseBuilderHelper.DEFAULT_LAST_NAME)
                .withEmail(BTN_CaseBuilderHelper.DEFAULT_EMAIL)
                .withSex(BTN_CaseBuilderHelper.DEFAULT_SEX)
                .withB2b(BTN_CaseBuilderHelper.DEFAULT_B2B)
                .withAssignmentId(assignment.Id)
                .withLeader(contact.Id)
                .get();
        // when
        Test.startTest();
        insert ca;
        Test.stopTest();
        // then
        System.assertNotEquals(null,ca.Id);
        System.assertEquals(
                1,
                [SELECT Id
                FROM Case
                WHERE Status = : ca.Status AND PersonalEmail__c = :ca.PersonalEmail__c LIMIT 3].size());
    }
}