public with sharing class BTN_CandidateEventsSectionController {
	
	public BTN_CV__c cv {get;set;}
	public Contact aContact {get;set;}
	public list<BTN_Event__c> events {get;set;}

	public BTN_CandidateEventsSectionController (ApexPages.StandardController std){
		cv = (BTN_CV__c)std.getRecord();
		BTN_DAO_Contact contactDao = new BTN_DAO_Contact().addInterviews();
		aContact = contactDao.findContactById(cv.Contact__c);
		events = aContact.Interviews__r;
	}
}