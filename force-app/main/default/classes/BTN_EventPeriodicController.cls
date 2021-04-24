public with sharing class BTN_EventPeriodicController {
	public BTN_Event__c assessment {get;set;}
	public BTN_Event__c previousAssessment {get;set;}
	private Contact aContact {get;set;}
	public static String URL_PARAM_CONTACT_ID = 'cId';
	public static String EVENT_TYPE_PERIODIC_ASSESSMENT = 'Periodic Assessment';
	public static String CERTIFICATE_TYPE_NAME = 'Certificate';
	public List<BTN_PersonalTarget__c> currentTargets {get;set;}
	public List<BTN_PersonalTarget__c> previousTargets {get;set;}
	private List<BTN_PersonalTarget__c> targetsToDel;
	private BTN_DAO_Event eventDAO = new BTN_DAO_Event();
	private BTN_DAO_Contact contactDAO = new BTN_DAO_Contact();
	private ApexPages.StandardController stdController;
	public String targetToDel {get;set;}

	public BTN_EventPeriodicController(ApexPages.StandardController stdController) {
		this.stdController = stdController;
		eventDAO.addInterviewedContactFields();
		eventDAO.addPeriodicAssessmentFields();
		contactDao.addCurrentPositionFields();
		if (!Test.isRunningTest()) {
			stdController.addFields(new List<String> {
					String.valueOF(BTN_Event__c.Interviewed__c),
					String.valueOF(BTN_Event__c.Current_Position__c),
					String.valueOF(BTN_Event__c.CreatedDate),
					String.valueOF(BTN_Event__c.NextAssessmentDate__c),
					String.valueOF(BTN_Event__c.CV_updated__c),
					String.valueOF(BTN_Event__c.BS_skills_updated__c),
					String.valueOF(BTN_Event__c.BriteSkills_updated__c),
					String.valueOF(BTN_Event__c.Customer_survey_updated__c),
					String.valueOF(BTN_Event__c.Career_path__c),
					String.valueOF(BTN_Event__c.career_path_comments__c),
					String.valueOF(BTN_Event__c.Additional_Carrer_path__c),
					String.valueOF(BTN_Event__c.Customer_feedback_summary__c),
					String.valueOF(BTN_Event__c.Coworkers_feedback__c),
					String.valueOF(BTN_Event__c.Weak_spots__c),
					String.valueOF(BTN_Event__c.Strong_spots__c),
					String.valueOF(BTN_Event__c.General_assessment__c),
					String.valueOF(BTN_Event__c.Assessment_trend__c),
					String.valueOF(BTN_Event__c.Assessment_comments__c),
					String.valueOF(BTN_Event__c.Feedback_department__c),
					String.valueOF(BTN_Event__c.Feedback_company__c),
					String.valueOF(BTN_Event__c.Feedback_other_departments__c),
					String.valueOF(BTN_Event__c.Requests_complaints__c)
			});
		}
		assessment = (BTN_Event__c)stdController.getrecord();
		assessment.Type__c = EVENT_TYPE_PERIODIC_ASSESSMENT;
		if(assessment.RecordTypeId == null){
			assessment.RecordType = BTN_RecordTypeUtils.getRecordTypeCustomEventPeriodicAssessment();
			assessment.recordTypeId = assessment.RecordType.Id;
		}
		Id contactId = assessment.Interviewed__c;
		if(contactId == null){
			String urlContactId = ApexPages.currentPage().getParameters().get(URL_PARAM_CONTACT_ID);
			if(urlContactId == null){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'{Can\' get contact information, aborting.}'));
				return;
			}
			contactId = urlContactId;
		}
		if(contactId!=null){
			aContact = contactDAO.findContactById(contactId);
			assessment.interviewed__c = contactId;
			assessment.interviewed__r = aContact;
		}
		if(assessment.Id == null){
			//new record fill defaults
			currentTargets = new List<BTN_PersonalTarget__c>();
			//assessment.Current_Position__c = aContact.Current_Position__r.Name; to jest z brite skilli
			assessment.Current_Position__c = aContact.Position__c;
			currentTargets = new List<BTN_PersonalTarget__c>();
		}else{
			currentTargets = [select id, name, Type__c, Target__c, Comments__c, Achieved_percent__c, Event__c, Due_date__c, Certificate__c from BTN_PersonalTarget__c where Event__c =:assessment.Id];
		}

		//get the previos assessment and targets
		try{
			previousAssessment = eventDAO.findPreviousAssessment(contactId, assessment.Id, assessment.createdDate);
			previousTargets = previousAssessment.BTN_PersonalTarget__r;
		}catch (Exception e){
		}


	}

	public PageReference save(){
		//PageReference retRef = stdController.save();
		if (!validateTargets()){
			return null;
		}
		Boolean isNew = assessment.id==null;
		upsert assessment;
		User interviewdUser = new User(); // just to make sure it is not null
		try{
			interviewdUser = [select id, Contact.ReportsToId from User where contactId =:assessment.interviewed__c limit 1];
		}catch(Exception e){

		}
		if(targetsToDel!=null){
			List<BTN_PersonalTarget__c> toHardDel = new List<BTN_PersonalTarget__c>();
			for(BTN_PersonalTarget__c t:targetsToDel){
				if(t.Id!=null){
					toHardDel.add(t);
				}
			}
			if(toHardDel.size()>0){
				delete toHardDel;
			}
		}
		if(currentTargets != null && currentTargets.size()>0){
			List<Task> targetTasks = new List<Task>();
			for(BTN_PersonalTarget__c t: currentTargets){
				if(t.Event__c == null){
					t.Event__c = assessment.Id;
				}
				if(t.Id==null && interviewdUser!=null && interviewdUser.Id!=null){
					Task aTask = new Task();
					aTask.WhoId = assessment.interviewed__c;
					aTask.OwnerId = interviewdUser.Id;
					aTask.Status = 'Open';
					aTask.Subject = t.Target__c;
					aTask.Whatid = assessment.Id;
					aTask.IsReminderSet = true;
					aTask.ReminderDateTime = t.Due_date__c - 7;
					aTask.ActivityDate = t.Due_date__c ;
					targetTasks.add(aTask);
				}
			}
			if(targetTasks.size()>0){
				insert targetTasks;
			}
			upsert currentTargets;
		}
		if(previousTargets != null && previousTargets.size()>0){
			upsert previousTargets;
		}

		if(isNew && interviewdUser!=null && interviewdUser.Contact.ReportsToId!=null){
			User interviewrSupervisor = new User();// just to make sure it is not null
			try{
				interviewrSupervisor = [select id, Contact.ReportsToId from User where contactId =:interviewdUser.Contact.ReportsToId limit 1];
			}catch(Exception e){

			}
			Task aTask = new Task();
			aTask.WhoId = interviewdUser.Contact.ReportsToId;
			aTask.OwnerId = interviewrSupervisor.Id;
			aTask.Status = 'Open';
			//aTask.Subject = 'Periodic assessment for '+aContact.FirstName + ' ' + aContact.LastName +' due date is'+ assessment.NextAssessmentDate__c;
			aTask.Subject = System.Label.PeriodicAssessmentTaskNotification.replace('{0}',aContact.FirstName + ' ' + aContact.LastName).replace('{1}',assessment.NextAssessmentDate__c.format());
			aTask.Whatid = assessment.Id;
			aTask.IsReminderSet = true;
			aTask.ReminderDateTime = assessment.NextAssessmentDate__c - 7;
			aTask.ActivityDate = assessment.NextAssessmentDate__c;
			insert aTask;
		}

		//tasks for targets
		return new PageReference('/'+assessment.Id);
	}

	public PageReference delCurrentTarget(){
		if(targetsToDel==null){
			targetsToDel = new List<BTN_PersonalTarget__c>();
		}
		if(targetToDel!=null){
			Integer idx = Integer.valueOf(targetToDel)-1;
			currentTargets.get(idx).Comments__c = currentTargets.get(idx).Comments__c + ', del# '+targetToDel;
			targetsToDel.add(currentTargets.get(idx));
			currentTargets.remove(idx);
		}
		return null;
	}

	public PageReference addCurrentTarget(){
		if (validateTargets()) {
			currentTargets.add(new BTN_PersonalTarget__c(
					Due_date__c = assessment.NextAssessmentDate__c,
					Achieved_percent__c = 0
			));
		}
		return null;
	}

	private Boolean validateTargets(){
		Boolean isValid = true;
		if (currentTargets != null) {
			for (BTN_PersonalTarget__c target : currentTargets) {
				if (BTN_ValidationHandler.isEmpty(target.Type__c)) {
					target.Type__c.addError(System.Label.MustEnterValue);
					isValid = false;
				}
				if (target.Due_date__c == null) {
					target.Due_date__c.addError(System.Label.MustEnterValue);
					isValid = false;
				}
				if (target.Achieved_percent__c == null) {
					target.Achieved_percent__c.addError(System.Label.MustEnterValue);
					isValid = false;
				}
				if (target.Type__c == CERTIFICATE_TYPE_NAME && BTN_ValidationHandler.isEmpty(target.Certificate__c)) {
					target.Certificate__c.addError(System.Label.MustEnterValue);
					isValid = false;
				}
				if (target.Type__c != CERTIFICATE_TYPE_NAME && BTN_ValidationHandler.isEmpty(target.Target__c)) {
					target.Target__c.addError(System.Label.MustEnterValue);
					isValid = false;
				}
			}
		}
		return isValid;
	}



}