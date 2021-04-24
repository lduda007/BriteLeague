public without sharing class BTN_ShareResourceRequestController{

    public BTN_ResourceRequest__c rr {get;set;}
    public String aComment {get;set;}
    public BTN_ResourceRequest__Share aShare{get;set;}
    public List<SelectOption> availableUsers {get;set;}

    
    public BTN_ShareResourceRequestController(ApexPages.StandardController stdController){
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String>{'Comments__c'});
        }
        rr = (BTN_ResourceRequest__c)stdController.getRecord();
        aShare= new BTN_ResourceRequest__Share();
        List<PermissionSetAssignment> HRAssignments = [Select id, AssigneeId  from permissionsetAssignment where PermissionSet.Name=:BTN_ConstantRepo.PERM_SET_NAME_HR];
        
        availableUsers  = new List<SelectOption>();
        for(User u:[Select Id, FirstName, LastName, Email from User where  IsActive = true and id in:BTN_Utils.getSetOfIds(HRAssignments,'AssigneeId')]){
            availableUsers.add(new SelectOption(u.Id, u.FirstName+' '+u.LastName+' <'+u.Email+'>'));
        }
    }
    
    public PageReference insertShare(){
        PageReference pRef = new PageReference('/'+rr.Id);
        pRef.setRedirect(true);
    	if (aComment!=null && aComment.trim().length()>0){

            if (rr.Comments__c != null) {
                rr.Comments__c = rr.Comments__c +'\r\n\r\n'+ Label.Request_CV_Comment +'\r\n\r\n'+ aComment;
            } else {
                rr.Comments__c = Label.Request_CV_Comment +'\r\n\r\n'+ aComment;
            }
    		update rr;
    	}
    	
        aShare.ParentId = rr.Id;
        aShare.AccessLevel = 'Edit';
        aSHare.RowCause = BTN_ResourceRequest__Share.RowCause.Shared_with_HR__c;
        insert aShare;
        BTN_EMAIL_Utils.sendTemplatedEmail(aShare.UserOrGroupId,rr.Id,BTN_ConstantRepo.EMAIL_TEMPLATE_RR_TO_HR);
        return pRef;
    }
}