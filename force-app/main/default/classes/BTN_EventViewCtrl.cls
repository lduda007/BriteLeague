public with sharing class BTN_EventViewCtrl {

	RecordType eventPeriodicAssessmentRecordType = BTN_RecordTypeUtils.getRecordTypeCustomEventPeriodicAssessment();
	BTN_Event__c myEvent;

	public BTN_EventViewCtrl(ApexPages.StandardController stdController) {
		this.myEvent = (BTN_Event__c) stdController.getRecord();
	}

	 /**
	 * @author Wojciech Mazur
	 * @date   2016-12-13
	 * @description Action exectud on load
	*/
	public PageReference onLoadAction() {
		if(eventPeriodicAssessmentRecordType.Id == myEvent.RecordTypeId){
			return new PageReference('/apex/BTN_EventPeriodicView?id='+myEvent.Id);
		}else{
			return new PageReference('/'+myEvent.Id+'?nooverride=1');
		}
	}

}