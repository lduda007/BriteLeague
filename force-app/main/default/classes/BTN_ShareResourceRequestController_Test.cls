/**
 * @author Wojciech Mazur
 * @date   2016-10-04
 */
@isTest
private class BTN_ShareResourceRequestController_Test {

    static testMethod void testShare() {
        BTN_ResourceRequest__c rr = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().get();
        
        Test.startTest();
        insert rr;
        ApexPages.StandardController stdC = new ApexPages.StandardController(rr);
		BTN_ShareResourceRequestController controller = new BTN_ShareResourceRequestController(stdC);
		User rmUser = BTN_TestDataFactory.getActiveResourceManagerUser();
		insert rmUser;
		controller.aShare.UserOrGroupId = rmUser.Id;
		system.assert(controller.insertShare()!=null);
		List<BTN_ResourceRequest__Share> jShrs = [SELECT Id, UserOrGroupId, AccessLevel, RowCause 
														FROM BTN_ResourceRequest__Share 
														WHERE ParentId = :rr.Id AND UserOrGroupId= :rmUser.Id AND RowCause =:BTN_ResourceRequest__Share.RowCause.Shared_with_HR__c];
		system.assert(jShrs.size()==1);
        Test.stopTest();
    }
}