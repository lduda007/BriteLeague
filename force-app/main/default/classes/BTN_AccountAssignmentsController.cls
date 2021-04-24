public class BTN_AccountAssignmentsController{

	public List<BTN_Assignment__c> assignments {get;set;}

    public BTN_AccountAssignmentsController(ApexPages.StandardController std){

    	Account acc = (Account)std.getRecord();
    	BTN_DAO_Assignment assignmentsDAO = new BTN_DAO_Assignment();

    	assignments = assignmentsDAO.findAssignmentsByAccount(acc.Id);
    }
}