/**
 * @author Mateusz Przywara
 * @date   2016-11-03
 * @description BTN_EventController handling Candidate status change to Interview-in-progress
 */
public with sharing class BTN_EventController {
    private static final String ERROR_MAIN_SECTION_NAME = System.Label.Information;
    @TestVisible private static final Integer DESCRIPTION_MAX_LENGTH = 32768;
    @TestVisible private BTN_Event__c myEvent;
    public DateTime startTime {set; get;}
    public DateTime endTime {set; get;}
    public DateTime profilingDate {set; get;}
    public Boolean meetingRoomWarning {get;set;}
    public String RT_Interview {set; get{
        return BTN_RecordTypeUtils.CUSTOMEVENT_INTERVIEW_RECORDTYPE;
    }}
    public String rt_general {set; get{
        return BTN_RecordTypeUtils.CUSTOMEVENT_GENERAL_RECORDTYPE;
    }}
    public List<SelectOption> availableMeetingRooms {get;set;}
    public String chosenRoom {get;set;}
    @TestVisible private String calendarId;
    private Boolean userChanged;
    @TestVisible private Boolean shouldSave;

    ApexPages.StandardController stdController;

    public BTN_EventController(ApexPages.StandardController stdController) {
        RecordType eventRecordType;
        this.myEvent = (BTN_Event__c) stdController.getRecord();
        this.stdController = stdController;
        if (!BTN_ValidationHandler.isNull(eventRecordType = getRecordType())) {
            myEvent.RecordTypeId = eventRecordType.Id;
            myEvent.RecordType = eventRecordType;
            myEvent.Type__c = getType();
            myEvent.Interviewed__c = getContact();
            myEvent.Candidate__c = getCandidate();
        }
        startTime = myEvent.Start_Time__c;
        endTime = myEvent.End_Time__c;

        meetingRoomWarning = false;
        availableMeetingRooms = new List<SelectOption>();
    }

     /**
     * @author Wojciech Mazur
     * @date   2016-12-13
     * @description Action exectud on load
    */
    public PageReference onLoadAction() {
    	if(BTN_RecordTypeUtils.CUSTOMEVENT_PERIODIC_RECORDTYPE == myEvent.RecordType.Name){
    		if(myEvent!=null && myEvent.Id!=null){
    			return new PageReference('/apex/BTN_EventPeriodic?id='+myEvent.Id);
    		}else{
    			return new PageReference('/apex/BTN_EventPeriodic');
    		}
    	}else{
    		return null;
    	}
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-11-03
     * @description Save override for standard Save action extended with Candidate status update
    */
    public PageReference save() {return null;}

    public PageReference beforeSaveValidation() {
        shouldSave = false;
        if (validateBeforeSave()) {
            return null;
        }
        if (myEvent.RecordType.Name == BTN_RecordTypeUtils.CUSTOMEVENT_INTERVIEW_RECORDTYPE && meetingRoomWarning == false) {
            User currUser = refreshUser();
            calendarId = BTN_MeetingRoomService.getFirstAvailableRoomCalendarIdForLocation(chosenRoom, myEvent.Location__c, startTime, endTime);
            if (availableMeetingRooms.isEmpty() == false) {
                if (String.isBlank(calendarId)) {
                    meetingRoomWarning = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.Event_Meeting_Room_Warning));
                    return null;
                } else {
                    myEvent.Meeting_Room__c = calendarId;
                    shouldSave = true;
                }
            }else{
                shouldSave = true;
            }
            if(userChanged){
                update currUser;
            }
        }else{
            shouldSave = true;
        }
        return null;
    }

    public PageReference doSaveAfterValidation() {
        if(shouldSave){
            myEvent.Start_Time__c = startTime;
            myEvent.End_Time__c = endTime;
            myEvent.Profiling_date__c = profilingDate;
            updateCandidateStatusToReviewInProgress();
            PageReference resultRef = stdController.save();
            if (resultRef != null) {
                if (myEvent.Candidate__c == null) {
                    resultRef = new PageReference('/' + myEvent.Interviewed__c);
                } else {
                    resultRef = new PageReference('/' + myEvent.Candidate__c);
                }
            }
            return resultRef;
        }
        return null;
    }

    private Boolean validateBeforeSave() {
        Boolean hasErrors = false;
        if (String.isNotBlank(myEvent.Description__c) && myEvent.Description__c.length() > DESCRIPTION_MAX_LENGTH) {
            String message = String.format(Label.MaximumFieldLengthError, new String[] {
                    SObjectType.BTN_Event__c.fields.Description__c.label,
                    String.valueOf(DESCRIPTION_MAX_LENGTH)
            });
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            hasErrors = true;
        }
        if (String.isNotBlank(myEvent.DescriptionTechnical__c) && myEvent.DescriptionTechnical__c.length() > DESCRIPTION_MAX_LENGTH) {
            String message = String.format(Label.MaximumFieldLengthError, new String[] {
                    SObjectType.BTN_Event__c.fields.DescriptionTechnical__c.label,
                    String.valueOf(DESCRIPTION_MAX_LENGTH)
            });
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            hasErrors = true;
        }

        return hasErrors;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-11-03
     * @description Update Status on related Candidate
    */
    private Boolean updateCandidateStatusToReviewInProgress() {
        Boolean result = false;
        if (!BTN_ValidationHandler.isNull(myEvent.Candidate__c)) {
            BTN_CV__c affiliatedCandidate = new BTN_DAO_Candidate().findCandidateById(myEvent.Candidate__c);
            if (BTN_Utils.isOpenCandidate(affiliatedCandidate) || BTN_Utils.isInProgressCandidate(affiliatedCandidate)) {
                result = Database.update(new BTN_CV__c(
                        Id = myEvent.Candidate__c,
                        Status__c = BTN_ConstantRepo.CANDIDATE_STATUS_INTERVIEW_IN_PROGRESS
                )).isSuccess();
            }
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-11-03
     * @description get Record Type
    */
    private RecordType getRecordType() {
        Id rtId = ApexPages.currentPage().getParameters().get(BTN_ConstantRepo.URL_PARAM_RECORDTYPE_ID);
        return (RecordType) new BTN_DAO_RecordType().findSObjectById(rtId);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-11-04
     * @description get Contact
    */
    private Id getContact() {
        return ApexPages.currentPage().getParameters().get(BTN_ConstantRepo.URL_PARAM_CONTACT_ID);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-11-04
     * @description get Contact
    */
    private String getType() {
        return ApexPages.currentPage().getParameters().get(BTN_ConstantRepo.URL_PARAM_CUSTOMEVENT_TYPE);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-11-04
     * @description get Candidate Id
    */
    private Id getCandidate() {
        String tmpId;
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get(BTN_ConstantRepo.URL_PARAM_CANDIDATE_ID))) {
            tmpId = ApexPages.currentPage().getParameters().get(BTN_ConstantRepo.URL_PARAM_CANDIDATE_ID);
        }
        return tmpId;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-11-22
     * @description get Label for Section
     * @return String Label content
    */
    public String getMainSectionLabel() {
        BTN_CV__c candidate = new BTN_DAO_Candidate().addResourceRequestFields().findCandidateById(getCandidate());
        String result;
        if (!BTN_ValidationHandler.isNull(candidate)) {
            result = String.format(System.Label.InterviewSectionLabel, new String[] {
                    candidate.ResourceRequest__r.Position_frm__c,
                    candidate.ResourceRequestName_frm__c
            });
        } else {
            result = ERROR_MAIN_SECTION_NAME;
        }
        return result;
    }

    public String getStartTimeString() {
        String res = '';
        if (startTime != null) {
            res = startTime.format('dd.MM.YYYY HH:mm');
        }
        return res;
    }

    public String getEndTimeString() {
        String res = '';
        if (endTime != null) {
            res = endTime.format('dd.MM.YYYY HH:mm');
        }
        return res;
    }

    public String getProfilingTimeString() {
        String res = '';
        if (profilingDate != null) {
            res = profilingDate.format('dd.MM.YYYY HH:mm');
        } else if (myEvent.Profiling_date__c != null) {
            res = myEvent.Profiling_date__c.format('dd.MM.YYYY HH:mm');
        }
        return res;
    }

    public PageReference refreshAvailableMeetingRooms(){
        availableMeetingRooms.clear();
        for(BTN_Meeting_Room__c room : [select Id,Name from BTN_Meeting_Room__c where Location__c =: myEvent.Location__c
                                        order by Priority__c asc]){
            availableMeetingRooms.add(new SelectOption(room.Name, room.Name));
        }
        if(!availableMeetingRooms.isEmpty()){
            chosenRoom = availableMeetingRooms[0].getLabel();
        }
        return null;
    }
    private User refreshUser(){
        userChanged = false;
        User current = BTN_Utils.getCurrentUser();
        if((current.GoogleTokenDate__c!=null)&&(((System.now().getTime() - current.GoogleTokenDate__c.getTime())/ 1000)>current.GoogleTokenExpiresIn__c-60)){
            current = BTN_GoogleCalendarHandler.refreshTokenForOneUser(current);
            BTN_Utils.currentUser = current;
            userChanged = true;
        }
        return current;
    }

}