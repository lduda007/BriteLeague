/**
 * @author Mateusz Przywara
 * @date   2016-08-23
 * @description Builder for Case
 */
public class BTN_CaseBuilderHelper {
    private Case record;
    public static final String DEFAULT_RECORD_TYPE = BTN_RecordTypeUtils.getRecordTypeCaseExternalOnBoarding().Id;
    public static final String DEFAULT_STATUS = Case.Status.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_FIRST_NAME = 'DEFAULT_FIRST_NAME';
    public static final String DEFAULT_LAST_NAME = 'DEFAULT_LAST_NAME';
    public static final String DEFAULT_TITLE = 'DEFAULT_TITLE';
    public static final String DEFAULT_EMAIL = 'DEFAULT_EMAIL@britenet.com.pl';
    public static final String DEFAULT_SEX = Case.Sex__c.getDescribe().getPicklistValues().get(0).value;
    public static final Boolean DEFAULT_B2B = true;
    private User owner;
    private BTN_Assignment__c assignment;
    private Contact contact;
    private String status;
    private Id assignmentId;
    private Id contactId;
    private Id accountId;
    private Id recordTypeId;
    private String statusValue;
    private String firstName;
    private String lastName;
    private String title;
    private String projectRole;
    private String email;
    private String sex;
    private Boolean b2b;
    private Id leaderId;
    private String projectManagerEmail;
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWithInternalOffBoardingRecordType Method builds Case sObject with Internal OffBouarding record type
     * @return BTN_CaseBuilderHelper - current instance
    */
    public static BTN_CaseBuilderHelper buildWithInternalOffBoardingRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeCaseInternalOffBoarding().Id);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWithInternalOnBoardingRecordType Method builds Case sObject with Internal OnBouarding record type
     * @return BTN_CaseBuilderHelper - current instance
    */
    public static BTN_CaseBuilderHelper buildWithInternalOnBoardingRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeCaseInternalOnBoarding().Id);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWithExternalOnBoardingRecordType Method builds Case sObject with External OnBouarding record type
     * @return BTN_CaseBuilderHelper - current instance
    */
    public static BTN_CaseBuilderHelper buildWithExternalOnBoardingRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeCaseExternalOnBoarding().Id);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWithExternalOffBoardingRecordType Method builds Case sObject with External OffBouarding record type
     * @return BTN_CaseBuilderHelper - current instance
    */
    public static BTN_CaseBuilderHelper buildWithExternalOffBoardingRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeCaseExternalOffBoarding().Id);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWith Method builds Case sObject with given Record Type
     * @param String - given record type to set
     * @return BTN_CaseBuilderHelper - current instance
    */
    private static BTN_CaseBuilderHelper buildWith(String recordTypeId){
        BTN_CaseBuilderHelper caseBuilderHelper = new BTN_CaseBuilderHelper();
        caseBuilderHelper.record = applyDefaults(recordTypeId);
        return caseBuilderHelper;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description applyDefaults Method applies default values to record for given Record Type
     * @param String - Record Type Id to set
     * @return Case
    */
    private static Case applyDefaults(String recordTypeId) {
        return new Case(
                Status = DEFAULT_STATUS,
                NewUserFirstName__c = DEFAULT_FIRST_NAME,
                NewUserLastName__c = DEFAULT_LAST_NAME,
                NewUserTitle__c = DEFAULT_TITLE,
                NewUserEmail__c = DEFAULT_EMAIL,
                Sex__c = DEFAULT_SEX,
                NewUserB2B__c = DEFAULT_B2B,
                PersonalEmail__c = DEFAULT_EMAIL,
                WorkStartDate__c = Date.today(),
                RecordTypeId = recordTypeId
        );
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withAccount Set Case Account
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withAccount(Id accountId) {
        record.AccountId = accountId;
        return this;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withContact Set Case Contact
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withContact(Id contactId) {
        record.ContactId = contactId;
        return this;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withStatus Set Case Status
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withStatus(String status) {
        record.Status = status;
        return this;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withSex Set New User Sex
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withSex(String sex) {
        record.Sex__c = sex;
        return this;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withFirstName Set New User First Name
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withFirstName(String firstName) {
        record.NewUserFirstName__c = firstName;
        return this;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withLastName Set New User Last Name
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withLastName(String lastName) {
        record.NewUserLastName__c = lastName;
        return this;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withEmail Set New User Email
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withEmail(String newUserEmail) {
        record.NewUserEmail__c = newUserEmail;
        return this;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withB2b Set New User B2B
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withB2b(Boolean b2b) {
        record.NewUserB2B__c = b2b;
        return this;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withTitle Set New User Title
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withTitle(String title) {
        record.NewUserTitle__c = title;
        return this;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withProjectRole Set New User projectRole
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withProjectRole(String projectRole) {
        record.NewUserProjectRole__c = projectRole;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description withRecordType Method set recordType for Case
     * @return BTN_CaseBuilderHelper - current instance of builder
    */
    public BTN_CaseBuilderHelper withCaseOwner(String ownerId){
        record.OwnerId = ownerId;
        return this;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-08-23
     * @description withProjectRole Set New User projectRole
     * @return  BTN_CaseBuilderHelper
    */
    public BTN_CaseBuilderHelper withLeader(Id leaderId) {
        record.Leader__c = leaderId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-13
     * @description withRecordTypeInternalOnboarding set recordType INTERNAL ONBOARDING for Case
     * @return BTN_CaseBuilderHelper - current instance of builder
    */
    public BTN_CaseBuilderHelper withRecordTypeInternalOnboarding(){
        this.recordTypeId = BTN_RecordTypeUtils.getRecordTypeCaseInternalOnBoarding().Id;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-13
     * @description withRecordTypeInternalOffboarding set recordType INTERNAL OFFBOARDING for Case
     * @return BTN_CaseBuilderHelper - current instance of builder
    */
    public BTN_CaseBuilderHelper withRecordTypeInternalOffboarding(){
        this.recordTypeId = BTN_RecordTypeUtils.getRecordTypeCaseInternalOffBoarding().Id;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-13
     * @description withRecordTypeExternalOffboarding set recordType EXTERNAL OFFBOARDING for Case
     * @return BTN_CaseBuilderHelper - current instance of builder
    */
    public BTN_CaseBuilderHelper withRecordTypeExternalOffboarding(){
        this.recordTypeId = BTN_RecordTypeUtils.getRecordTypeCaseExternalOffBoarding().Id;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-13
     * @description withRecordTypeExternalOnboarding set recordType EXTERNAL ONBOARDING for Case
     * @return BTN_CaseBuilderHelper - current instance of builder
    */
    public BTN_CaseBuilderHelper withRecordTypeExternalOnboarding(){
        this.recordTypeId = BTN_RecordTypeUtils.getRecordTypeCaseExternalOnBoarding().Id;
        return this;
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description get Method gets building record
     * @return Case building record
    */
    public Case get(){
        return record;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description save Method saves building record
     * @return Case building record
    */
    public Case save(){
        insert record;
        return record;
    }

    /**
     * @author Mateusz Przywara
     * @date 2016-09-23
     * @description withAssignmentId Set Assignment Id - source of dates etc.
     * @return Case building record
    */
    public BTN_CaseBuilderHelper withAssignmentId(Id assignmentId){
        this.assignmentId = assignmentId;
        this.record.Assignment__c = assignmentId;
        return this;
    }
}