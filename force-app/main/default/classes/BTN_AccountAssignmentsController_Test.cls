@isTest
public class BTN_AccountAssignmentsController_Test{

	public static testMethod void testQueryAssignments(){

		Account acc = BTN_TestDataFactory.getBriteNetAccount();

		Contact ct = BTN_TestDataFactory.getRequestorInternalContact(acc.Id);

		List<BTN_Assignment__c> assignments = BTN_TestDataFactory.getPreparedAssignments(1,5,1,Date.today()-2);

		Test.startTest();

			ApexPages.StandardController std = new ApexPages.StandardController(acc);
			BTN_AccountAssignmentsController ctrl = new BTN_AccountAssignmentsController(std);

			System.assertEquals(1, ctrl.assignments.size());

		Test.stopTest();
	}
}