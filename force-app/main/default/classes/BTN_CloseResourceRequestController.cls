/**
 * Created by Adam on 12/20/2017.
 */

public with sharing class BTN_CloseResourceRequestController
{
	@TestVisible
	private BTN_ResourceRequest__c resourceRequest;
	@TestVisible
	private List<BTN_CV__c> candidates;

	public BTN_CloseResourceRequestController(ApexPages.StandardController stdController){
		this.resourceRequest = getResourceRequest(stdController);
	}

	public List<BTN_CV__c> getCandidates(){
		try{
			this.candidates = new BTN_DAO_Candidate().findCandidatesByResourceRequest(this.resourceRequest.Id);
			return this.candidates;
		}catch(Exception e){
			ApexPages.addMessages(e);
			return null;
		}
	}

	public PageReference save(){
		try{
			update this.candidates;
			update this.resourceRequest;
			return new PageReference('/'+this.resourceRequest.Id);
		}catch(Exception e){
			ApexPages.addMessages(e);
			return null;
		}
	}

	public PageReference cancel(){
		return new PageReference('/'+this.resourceRequest.Id);
	}

	private BTN_ResourceRequest__c getResourceRequest(ApexPages.StandardController stdController){
		if(!Test.isRunningTest()){
			List<String> queryFields = new List<String>{
					BTN_ResourceRequest__c.Name.getDescribe().getLocalName(),
					BTN_ResourceRequest__c.Status__c.getDescribe().getLocalName()
			};
			stdController.addFields(queryFields);
		}
		return (BTN_ResourceRequest__c) stdController.getRecord();
	}
}