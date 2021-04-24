public with sharing class BTN_ResourceRequestSelectorController {
	public Case aCase; 
	public List<BTN_ResourceRequest__c> resourceRequests{get;set;}
	public String selectedResourceRequest {get;set;}
	
	public BTN_ResourceRequestSelectorController(ApexPages.StandardController stdController){
		stdController.addFields(new List<String>{'Contact',
												'Account',
												'Assignment__r.EndDate__c',
												'Assignment__r.StartDate__c',
												'RecordType.DeveloperName'});
		aCase = (Case)stdController.getRecord();
		
		BTN_DAO_ResourceRequest rrDao = new BTN_DAO_ResourceRequest();
		rrDao.addCandidates();
		resourceRequests = rrDao.findByBusinessAndContact(aCase.Account.Id, aCase.Contact.Id);
		//add all non billable RR
		resourceRequests.addAll(rrDao.findUnbillableRequests());
		
	}
	
	/**
         * @author Wojciech Mazur
         * @date   2016-09-14
         * @description saves selected RR on the case record
         * @param  selectedResourceRequest - indirect set by apex:commandLink from VF
         */
	public PageReference selectResourceRequest() {
		if (selectedResourceRequest !=null && selectedResourceRequest.trim()!=''){
			aCase.Resource_request__c = selectedResourceRequest;
		}else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Parameter not received'));
			return null;
		}
		// BRITCRM-162 - fill relevant fields
		Map<Id, BTN_ResourceRequest__c> resourceRequestsMap = new Map<Id, BTN_ResourceRequest__c>();
		resourceRequestsMap.putAll(resourceRequests);
		if(aCase.RecordType.DeveloperName.equals(BTN_ConstantRepo.CASE_EXTERNAL_OFFBOARDING_RECORDTYPE)){
			aCase.Contract_Start__c = BTN_DateUtils.getMonthName(aCase.Assignment__r.EndDate__c);
		}else if(aCase.RecordType.DeveloperName.equals(BTN_ConstantRepo.CASE_EXTERNAL_ONBOARDING_RECORDTYPE)){
			aCase.Contract_Start__c = BTN_DateUtils.getMonthName(aCase.Assignment__r.StartDate__c);
		}
		boolean dealCloseDateFound = false;
		for (BTN_CV__c cv:resourceRequestsMap.get(selectedResourceRequest).CVs_lkp__r){
			if(cv.Contact__c == aCase.Contact.Id && cv.DateApproved__c!=null){
				aCase.Deal_Close__c = BTN_DateUtils.getMonthName(cv.DateApproved__c);
				dealCloseDateFound = true;
				break;
			}
		}
		if(!dealCloseDateFound)
			aCase.Deal_Close__c = null;
		update aCase;
	    return new PageReference('/'+aCase.Id);
	    
	}
    
}