/*
	@Author Wojciech Mazur
	@Date 2016-10-04
*/
trigger BTN_ResourceRequestTrigger on BTN_Resourcerequest__c (before insert, after insert) {
	if(!BTN_TriggerUtils.skipTrigger('BTN_ResourceRequestTrigger')) {
		Id curruserId =  BTN_Utils.getCurrentUser().Id;
		if(trigger.isBefore && trigger.isInsert){
			for (BTN_ResourceRequest__c rr:trigger.new){
				if(rr.RequestorUser__c==null){
					rr.RequestorUser__c = curruserId;
				}
			}

		}

		if(trigger.isAfter && trigger.isInsert){
			set<Id> rrIds = new Set<Id>();
			for (BTN_ResourceRequest__c rr:trigger.new){
				rrIds.add(rr.Id);
			}
			if(rrIds.size()>0){
				//insert shares
				List<BTN_ResourceRequest__Share> sharesToInsert = new List<BTN_ResourceRequest__Share>();
				for(Id aid:rrIds){
					BTN_ResourceRequest__Share aShare = new BTN_ResourceRequest__Share();
					aShare.UserOrGroupId = curruserId;
					aShare.ParentId = aId;
					aShare.AccessLevel = 'Edit';
					aSHare.RowCause = BTN_ResourceRequest__Share.RowCause.Requestor__c;
					sharesToInsert.add(aShare);
				}
				insert sharesToInsert;
			}
		}
	}

}