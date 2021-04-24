/*
 * @author Dariusz Chmiela
 * @date 2016-08-18
 * @description BTN_ResourceRequestBuilderHelper Builder for BTN_ResourceRequest__c
*/
public with sharing class BTN_ResourceRequestBuilderHelper implements BTN_BuilderHelper{
    private static BTN_DAO_Account daoAccount = new BTN_DAO_Account();
    private BTN_ResourceRequest__c record;
    public static final String DEFAULT_CONTRACT_START = String.valueOf(Date.today());
    public static final String DEFAULT_CONTRACT_DURATION = '2';
    public static final String DEFAULT_RATE = '1';
    public static final Date DEFAULT_DELIVERY_DEADLINE = Date.today().addDays(1);
    public static final String DEFAULT_LEVEL = 'BEGINER';
    public static final String DEFAULT_LANGUAGE = BTN_ResourceRequest__c.Language__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_LOCATION = BTN_ResourceRequest__c.Location__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_MAIN_SKILLS = 'JAVA';
    public static final String DEFAULT_OPPORTUNITY_TYPE = BTN_ResourceRequest__c.OpportunityType__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_POSITION = 'Java Developer';
    public static final String DEFAULT_DESCRIPTION = 'Fluent in english';
    public static final Decimal DEFAULT_QUANTITY = 100;
    public static final String DEFAULT_SECONDARY_SKILLS = 'C++';
    public static final String DEFAULT_SENIORITY = 'Pan';
    public static final String DEFAULT_STATUS = BTN_ResourceRequest__c.Status__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_TECHNOLOGY = 'JAVA';
    public static final String DEFAULT_ZOHOURL = 'https://www.zoho.pl/129321';
    public static final RecordType DEFAULT_RECORDTYPE = BTN_RecordTypeUtils.getRecordTypeResourceRequestManual();
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWithAutoRecordType Method builds BTN_ResourceRequest__c sObject with Auto record type
     * @return BTN_ResourceRequestBuilderHelper - current instance
    */
    public static BTN_ResourceRequestBuilderHelper buildWithAutoRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeResourceRequestAuto().Id);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWithManualRecordType Method builds BTN_ResourceRequest__c sObject with Manual record type
     * @return BTN_ResourceRequestBuilderHelper - current instance
    */
    public static BTN_ResourceRequestBuilderHelper buildWithManualRecordType() {
        return buildWith(BTN_RecordTypeUtils.getRecordTypeResourceRequestManual().Id);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWith Method builds BTN_ResourceRequest__c with given Record Type
     * @param String - given record type to set
     * @return BTN_ResourceRequestBuilderHelper - current instance
    */
    private static BTN_ResourceRequestBuilderHelper buildWith(String recordTypeId){
        BTN_ResourceRequestBuilderHelper resourceRequestBuilderHelper = new BTN_ResourceRequestBuilderHelper();
        resourceRequestBuilderHelper.record = applyDefaults(recordTypeId);
        return resourceRequestBuilderHelper;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description applyDefaults Method applies default values to record for given Record Type
     * @param String - Record Type Id to set
     * @return Account
    */
    private static BTN_ResourceRequest__c applyDefaults(String recordTypeId) {
        return new BTN_ResourceRequest__c(
                ContractStart__c = DEFAULT_CONTRACT_START,
                ContractDuration__c = DEFAULT_CONTRACT_DURATION,
                Rate__c = DEFAULT_RATE,
                DeliveryDeadline__c = DEFAULT_DELIVERY_DEADLINE,
                Level__c = DEFAULT_LEVEL,
                Language__c = DEFAULT_LANGUAGE,
                Location__c = DEFAULT_LOCATION,
                MainSkills__c = DEFAULT_MAIN_SKILLS,
                OpportunityType__c = DEFAULT_OPPORTUNITY_TYPE,
                Position__c = DEFAULT_POSITION,
                Description__c = DEFAULT_DESCRIPTION,
                Placement__c = DEFAULT_QUANTITY,
                SecondarySkills__c = DEFAULT_SECONDARY_SKILLS,
                Seniority__c = DEFAULT_SENIORITY,
                Status__c = DEFAULT_STATUS,
                Technology__c = DEFAULT_TECHNOLOGY,
                ZohoUrl__c = DEFAULT_ZOHOURL,
                RecordTypeId = recordTypeId
        );
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withContractDuration Method set up BTN_ResourceRequest__c ContractDuration__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withContractDuration(String duration) {
        record.ContractDuration__c = duration;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withOpportunityType Method set up BTN_ResourceRequest__c OpportunityType__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withOpportunityType(String opportunityType) {
        record.OpportunityType__c = opportunityType;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withOpportunityType Method set up BTN_ResourceRequest__c OpportunityType__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withOpportunity(String oppId) {
        record.Opportunity__c = oppId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withRequestorContact Method set up BTN_ResourceRequest__c RequestorContact__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withRequestorContact(String requestorContactId) {
        record.RequestorContact__c = requestorContactId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withRequestorUser Method set up BTN_ResourceRequest__c RequestorUser__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withRequestorUser(String requestorUserId) {
        record.RequestorUser__c = requestorUserId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withCustomerAccount Method set up BTN_ResourceRequest__c CustomerAccount__c
     * @param String Account Id
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withCustomerAccount(String customerAccountId) {
        record.CustomerAccount__c = customerAccountId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withCustomerAccount Method set up BTN_ResourceRequest__c Position__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withPosition(String position) {
        record.Position__c = position;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withLocation Method set up BTN_ResourceRequest__c Location__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withLocation(String location) {
        record.Location__c = location;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withDeliveryDeadline Method set up BTN_ResourceRequest__c DeliveryDeadline__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withDeliveryDeadline(Date deliveryDeadline) {
        record.DeliveryDeadline__c = deliveryDeadline;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withDescription Method set up BTN_ResourceRequest__c Description__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withDescription(String description) {
        record.Description__c = description;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withAssignedTo Method set up BTN_ResourceRequest__c AssignedTo__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withAssignedTo(String assignedToId) {
        record.AssignedTo__c = assignedToId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withSecondarySkills Method set up BTN_ResourceRequest__c SecondarySkills__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withSecondarySkills(String secondarySkills) {
        record.SecondarySkills__c = secondarySkills;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withContractStart Method set up BTN_ResourceRequest__c ContractStart__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withContractStart(Date contractStart) {
        record.ContractStart__c = String.valueOf(contractStart);
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withContractStart Method set up BTN_ResourceRequest__c ContractStart__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withContractStart(String contractStart) {
        record.ContractStart__c = contractStart;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withCustomerRate Method set up BTN_ResourceRequest__c Rate__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withCustomerRate(Decimal customerRate) {
        record.Rate__c = String.valueOf(customerRate);
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withCustomerRate Method set up BTN_ResourceRequest__c Rate__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withCustomerRate(String customerRate) {
        record.Rate__c = customerRate;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withQuantity Method set up BTN_ResourceRequest__c Placement__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withQuantity(Integer quantity) {
        record.Placement__c = quantity;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withLanguage Method set up BTN_ResourceRequest__c Language__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withLanguage(String language) {
        record.Language__c = language;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withExpirienceLevel Method set up BTN_ResourceRequest__c Level__c
     * @return BTN_ResourceRequestBuilderHelper - instance of Builder
    */
    public BTN_ResourceRequestBuilderHelper withExpirienceLevel(String expirienceLevel) {
        record.Level__c = expirienceLevel;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @inherited from interface
    */
    public BTN_ResourceRequest__c get() {
        return record;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @inherited from interface
    */
    public BTN_ResourceRequest__c save(){
        insert record;
        return record;
    }
}