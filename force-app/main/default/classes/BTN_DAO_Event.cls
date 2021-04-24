public class BTN_DAO_Event extends BTN_DAO{

/**
     * @author Wojciech Mazur
     * @date   2016-11-08
     * @description Constructor
    */
    public BTN_DAO_Event () {
    }
    
    public override Schema.SObjectType getSObjectType() {
        return BTN_Event__c.sObjectType;
    }
    
    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                BTN_Event__c.Id,
                BTN_Event__c.Name,
                BTN_Event__c.Candidate__c,
                BTN_Event__c.Description__c,
                BTN_Event__c.DescriptionTechnical__c,
                BTN_Event__c.End_Time__c,
                BTN_Event__c.Location__c,
                BTN_Event__c.Start_Time__c,
                BTN_Event__c.SubType__c,
                BTN_Event__c.Title__c,
                BTN_Event__c.GoogleId__c,
                BTN_Event__c.UserUsedForGoogleIntegration__c,
                BTN_Event__c.RecordTypeId,
                BTN_Event__c.Interviewer_Contact__c,
                BTN_Event__c.Technical_Interviewer__c,
                BTN_Event__c.CreatedDate,
                BTN_Event__c.Meeting_Room__c
        };
    }

   
        /**
         * @author Wojciech Mazur
         * @date   2016-11-08
         * @description find Event
         * @param  userName - Name of User to search for
         * @return     User       - found User
         */
    public BTN_Event__c findEventById(Id eventId) {
        return (BTN_Event__c) findSObjectById(eventId);
    }
    
     /**
     * @author Wojciech Mazur
     * @date   2016-11-08
     * @description find by Ids
     * @return List<Contact>
    */
    public List<BTN_Event__c> findEventsByIds(Set<Id> ids) {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Id',
                                'in',
                                ids
                        )
                }
        );
    }
    
    /**
     * @author Wojciech Mazur
     * @date   2016-12-14
     * @description get previos periodic assessment
     * @return BTN_Event__c
    */
    public BTN_Event__c findPreviousAssessment(Id contactId, Id currentAssessmentId, DateTime currentAssessmentDate) {
    	if(currentAssessmentDate ==null){
    		currentAssessmentDate = system.now();
    	}
        List<BTN_Event__c> objects = findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('Interviewed__c', '=', contactId),
                        new SearchCondition('AND RecordTypeid', '=', BTN_RecordTypeUtils.getRecordTypeCustomEventPeriodicAssessment().Id),
                        new SearchCondition('And id', '<>', currentAssessmentId),
                        new SearchCondition('And createdDate < '+ currentAssessmentDate.formatGMT('YYYY-MM-dd')+'T'+currentAssessmentDate.formatGMT('HH:mm:ss')+'Z'),
                        new SearchCondition('order by createdDate desc LIMIT 1')
                        
                }
        );
        return objects.isEmpty() ? null : (BTN_Event__c) objects.get(0);
    }
    
    /**
     * @author Wojciech Mazur
     * @date   2016-11-08
     * @description add Interviewer fields
     * @return void
    */
    public BTN_DAO_Event addInterviewerUsersFields() {
        currentFields.add('Technical_Interviewer_User__r.GoogleTokenExpiresIn__c');
        currentFields.add('Technical_Interviewer_User__r.GoogleTokenDate__c');
        currentFields.add('Technical_Interviewer_User__r.GoogleRefreshToken__c');
        currentFields.add('Technical_Interviewer_User__r.GoogleAccessToken__c');
        currentFields.add('Technical_Interviewer_User__r.GoogleAuthCode__c');
        currentFields.add('Technical_Interviewer_User__r.Email');
        currentFields.add('Technical_Interviewer_User__r.Name');
        currentFields.add('Technical_Interviewer_User__r.FirstName');
        currentFields.add('Technical_Interviewer_User__r.LastName');
        currentFields.add('Technical_Interviewer_User__r.Id');
        currentFields.add('Interviewer_user__r.GoogleTokenExpiresIn__c');
        currentFields.add('Interviewer_user__r.GoogleTokenDate__c');
        currentFields.add('Interviewer_user__r.GoogleRefreshToken__c');
        currentFields.add('Interviewer_user__r.GoogleAccessToken__c');
        currentFields.add('Interviewer_user__r.GoogleAuthCode__c');
        currentFields.add('Interviewer_user__r.Email');
        currentFields.add('Interviewer_user__r.Name');
        currentFields.add('Interviewer_user__r.FirstName');
        currentFields.add('Interviewer_user__r.LastName');
        currentFields.add('Interviewer_user__r.Id');
        currentFields.add('Technical_Interviewer__r.Email');
        currentFields.add('Interviewer_Contact__r.Email');
        currentFields.add('CreatedBy.Id');
        currentFields.add('CreatedBy.Email');
        currentFields.add('CreatedBy.GoogleAccessToken__c');
        return this;
    }
    
    /**
     * @author Wojciech Mazur
     * @date   2016-11-08
     * @description add integrated user  fields
     * @return void
    */
    public BTN_DAO_Event addIntegratedUserFields() {
        currentFields.add('UserUsedForGoogleIntegration__r.GoogleTokenExpiresIn__c');
        currentFields.add('UserUsedForGoogleIntegration__r.GoogleTokenDate__c');
        currentFields.add('UserUsedForGoogleIntegration__r.GoogleRefreshToken__c');
        currentFields.add('UserUsedForGoogleIntegration__r.GoogleAccessToken__c');
        currentFields.add('UserUsedForGoogleIntegration__r.GoogleAuthCode__c');
        currentFields.add('UserUsedForGoogleIntegration__r.Email');
        currentFields.add('UserUsedForGoogleIntegration__r.Name');
        currentFields.add('UserUsedForGoogleIntegration__r.FirstName');
        currentFields.add('UserUsedForGoogleIntegration__r.LastName');
        currentFields.add('UserUsedForGoogleIntegration__r.Id');
        return this;
    }
    
    /**
     * @author Wojciech Mazur
     * @date   2016-11-08
     * @description add Interviewed contact fields
     * @return void
    */
    public BTN_DAO_Event addInterviewedContactFields() {
        currentFields.add('Interviewed__r.Email');
        currentFields.add('Interviewed__r.Name');
        currentFields.add('Interviewed__r.FirstName');
        currentFields.add('Interviewed__r.LastName');
        currentFields.add('Interviewed__c');
        return this;
    }
    
    /**
     * @author Wojciech Mazur
     * @date   2016-12-14
     * @description add Periodic assessment fields
     * @return void
    */
    public BTN_DAO_Event addPeriodicAssessmentFields() {
        currentFields.add('Current_Position__c');
        currentFields.add('Career_path__c');
        currentFields.add('General_assessment__c');
        currentFields.add('(select id, name, Type__c, Target__c, Comments__c, Achieved_percent__c, Event__c, Due_date__c, Certificate__c from BTN_PersonalTarget__r)');
        
        
        return this;
    }

}