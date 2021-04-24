/**
 * @author Mateusz Przywara
 * @date   2016-10-12
 * @description BTN_CustomEventTrigger Trigger handling Chatter
 * Post Information on Contact and optional Candidates
*/
trigger BTN_CustomEventTrigger on BTN_Event__c (after insert, after update, after delete, before insert, before update) {
    if(!BTN_TriggerUtils.skipTrigger('BTN_CustomEventTrigger')) {
        if (Trigger.isInsert && Trigger.isAfter) {
            BTN_ChatterUtils.postEvents(Trigger.new);
            BTN_GoogleCalendarHandler gHandler = new BTN_GoogleCalendarHandler(Trigger.new, BTN_GoogleCalendarHandler.IS_INSERT);
            Database.executeBatch(gHandler,1);

        }

        if (Trigger.isUpdate && Trigger.isAfter) {
            if(!BTN_GoogleCalendarHandler.SKIP_BTN_GoogleCalendarHandler){
                BTN_GoogleCalendarHandler gHandler = new BTN_GoogleCalendarHandler(Trigger.new, BTN_GoogleCalendarHandler.IS_UPDATE);
                Database.executeBatch(gHandler,1);
            }
        }

        if (Trigger.isDelete && Trigger.isAfter) {
            BTN_GoogleCalendarHandler gHandler = new BTN_GoogleCalendarHandler(Trigger.old, BTN_GoogleCalendarHandler.IS_DELETE);
            Database.executeBatch(gHandler,1);
        }
        
        if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        	// step 1. clear all interviewver users
        	Set<Id> relatedContactsIds = new Set<Id>();
        	for(BTN_Event__c e: Trigger.new){
        		e.Interviewer_user__c = null;
        		e.Technical_Interviewer_User__c = null;
        		if(e.Technical_Interviewer__c != null)
        			relatedContactsIds.add(e.Technical_Interviewer__c);
        		if(e.Interviewer_Contact__c != null)
        			relatedContactsIds.add(e.Interviewer_Contact__c);
        	}
        	// step 2 find external users for contacts
        	BTN_DAO_User userDao = new BTN_DAO_User();
        	userDao.addUserFields();
        	List<User> usersMatchedByIds = userDao.findUsersByContactIds(relatedContactsIds);
        	Map<Id,User> contactIdToUser = new Map<Id,User>();
        	if(usersMatchedByIds!=null){
		        for(User u:usersMatchedByIds){
		        	contactIdToUser.put(u.ContactId,u);
		        }
        	}
	        // step 3 set external users if found, else store contact ids that do not have external users
	        Set<Id> notMatchedContactsIds = new Set<Id>();
	        for(BTN_Event__c e: Trigger.new){
	        	if(contactIdToUser.containsKey(e.Technical_Interviewer__c)){
	        		e.Technical_Interviewer_User__c = contactIdToUser.get(e.Technical_Interviewer__c).Id;
	        	}else{
	        		if(e.Technical_Interviewer__c!=null)
	        			notMatchedContactsIds.add(e.Technical_Interviewer__c);
	        	}
	        	if(contactIdToUser.containsKey(e.Interviewer_Contact__c)){
	        		e.Interviewer_user__c = contactIdToUser.get(e.Interviewer_Contact__c).Id;
	        	}else{
	        		if(e.Interviewer_Contact__c!=null)
	        			notMatchedContactsIds.add(e.Interviewer_Contact__c);
	        	}
	        }
	        // step 4 find possible matches by first/last name and email
	        BTN_DAO_Contact contactDao = new BTN_DAO_Contact();
	        Map<Id,Contact> notMatchedContacts = new Map<Id,Contact>(contactDao.findContactsInIdSet(notMatchedContactsIds));
	        Set<String> contactEmails = new Set<String>();
	        for(Contact c: notMatchedContacts.values()){
	        	if (c.Email != null)
	        		contactEmails.add(c.Email);
	        }
	        if (contactEmails.size()>0){
	        	List <User> possibleUsers = userDao.findUsersByEmails(contactEmails);
	        	for(BTN_Event__c e: Trigger.new){
	        		if(e.Technical_Interviewer__c != null && e.Technical_Interviewer_User__c == null){
	        			for(User u:possibleUsers){
	        				if(u.Email == notMatchedContacts.get(e.Technical_Interviewer__c).Email &&
	        				   u.FirstName == notMatchedContacts.get(e.Technical_Interviewer__c).FirstName &&
	        				   u.LastName == notMatchedContacts.get(e.Technical_Interviewer__c).LastName){
	        						e.Technical_Interviewer_User__c = u.Id;
	        				}
	        			}
	        		}
	        		
	        		if(e.Interviewer_Contact__c != null && e.Interviewer_user__c == null){
	        			for(User u:possibleUsers){
	        				if(u.Email == notMatchedContacts.get(e.Interviewer_Contact__c).Email &&
	        				   u.FirstName == notMatchedContacts.get(e.Interviewer_Contact__c).FirstName &&
	        				   u.LastName == notMatchedContacts.get(e.Interviewer_Contact__c).LastName){
	        						e.Interviewer_user__c = u.Id;
	        				}
	        			}
	        		}
	        	}
	        }
	        
        }
    }

}