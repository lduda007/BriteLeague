/*
 * @author Dariusz Chmiela, Piotr Pitera
 * @date 2016-08-12
 * @description BTN_ContactBuilderHelper Builder for SFDC Contact
*/
public with sharing class BTN_ContactBuilderHelper implements BTN_BuilderHelper {
    //  record
    private Contact record;
    //  defaults
    public static final String DEFAULT_FIRST_NAME = 'Jan';
    public static final String DEFAULT_LAST_NAME = 'Kowalski';
    public static final String DEFAULT_ADDRESS = 'NaKowalska';
    public static final Boolean DEFAULT_IS_ACTIVE = true;
    //****************************************************************************************************************//
    //************************************************   Builders    ************************************************//
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description buildWithInternalRecordType Method builds Contact sObject with Internal record type
     * @return BTN_ContactBuilderHelper - current instance
    */
    public static BTN_ContactBuilderHelper buildWithInternalRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeContactInternal().Id);
    }
    
    /**
     * @author Wojciech Mazur
     * @date 2016-08-12
     * @description buildWithRecruitRecordType Method builds Contact sObject with Recruit record type
     * @return BTN_ContactBuilderHelper - current instance
    */
    public BTN_ContactBuilderHelper buildWithRecruitRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeContactRecruit().Id);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description buildWithBusinessRecordType Method builds Contact sObject with Business record type
     * @return BTN_ContactBuilderHelper - current instance
    */
    public static BTN_ContactBuilderHelper buildWithBusinessRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeContactBusiness().Id);
    }
    //****************************************************************************************************************//
    //************************************************   Defaults    ************************************************//
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWith Method builds Contact sObject with given Record Type
     * @param String - given record type to set
     * @return BTN_ContactBuilderHelper - current instance
    */
    private static BTN_ContactBuilderHelper buildWith(String recordTypeId){
        BTN_ContactBuilderHelper contactBuilderHelper = new BTN_ContactBuilderHelper();
        contactBuilderHelper.record = applyDefaults(recordTypeId);
        return contactBuilderHelper;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description applyDefaults Method applies default values to record for given Record Type
     * @param String - Record Type Id to set
     * @return Contact
    */
    private static Contact applyDefaults(String recordTypeId) {
        return new Contact(
                FirstName = DEFAULT_FIRST_NAME,
                LastName = DEFAULT_LAST_NAME,
                Email = EncodingUtil.base64encode(Crypto.generateAesKey(128)) + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX,
                Active__c = DEFAULT_IS_ACTIVE,
                RecordTypeId = recordTypeId,
                Sex__c = 'Male'
                );
    }
    //****************************************************************************************************************//
    //*******************************************   Attributes setters    *******************************************//
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description withFirstName Method set up Contact First Name
     * @return BTN_ContactBuilderHelper - instance of Builder
    */
    public BTN_ContactBuilderHelper withFirstName(String firstName) {
        record.FirstName = firstName;
        return this;
    }

    /**
     * @author Mateusz Przywara
     * @date 2016-10-20
     * @description Set default Mailing Address
     * @return BTN_ContactBuilderHelper - instance of Builder
    */
    public BTN_ContactBuilderHelper buildWithDefaultAddress() {
        record.MailingCity = DEFAULT_ADDRESS;
        record.MailingCountry = DEFAULT_ADDRESS;
        record.MailingPostalCode = DEFAULT_ADDRESS;
        record.MailingState = DEFAULT_ADDRESS;
        record.MailingStreet = DEFAULT_ADDRESS;
        return this;
    }

    /**
     * @author Mateusz Przywara
     * @date 2016-10-20
     * @description Set default Mailing Address
     * @return BTN_ContactBuilderHelper - instance of Builder
    */
    public BTN_ContactBuilderHelper withSkills(String skills) {
        record.Skills__c = skills;
        return this;
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description withLastName Method set up Contact Last Name
     * @return BTN_ContactBuilderHelper - instance of Builder
    */
    public BTN_ContactBuilderHelper withLastName(String lastName) {
        record.LastName = lastName;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-15
     * @description isActive Method set active flag on Contact
     * @return BTN_ContactBuilderHelper - instance of Builder
    */
    public BTN_ContactBuilderHelper isActive(Boolean active) {
        record.Active__c = active;
        return this;
    }
     /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description withAccount Method set up AccountId Required for SFDC Contact to be public
     * @return BTN_ContactBuilderHelper - instance of Builder
    */
    public BTN_ContactBuilderHelper withAccount(Id accountId) {
        record.AccountId = accountId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description withEmail Method set up email for Contact
     * @return BTN_ContactBuilderHelper - instance of Builder
    */
    public BTN_ContactBuilderHelper withEmail(String email) {
        record.email = email;
        return this;
    }
    /**
     * @author  Dariusz Chmiela
     * @date 2016-09-09
     * @description get() Method gets current Contact
     * @return Contact current instance
    */
    public Contact get() {
        return record;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description save Method saves current Contact
     * @return Contact current instance
    */
    public Contact save() {
        insert record;
        return record;
    }
}