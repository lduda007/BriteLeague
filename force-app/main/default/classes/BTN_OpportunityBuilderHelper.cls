/*
 * @author Dariusz Chmiela
 * @date 2016-08-18
 * @description BTN_OpportunityBuilderHelper Builder for Opportunity
*/
public with sharing class BTN_OpportunityBuilderHelper implements BTN_BuilderHelper{
    // record
    private Opportunity record;

    public static final Decimal DEFAULT_AMOUNT;
    public static final Date DEFAULT_CLOSE_DATE = Date.today().addMonths(1);
    public static final String DEFAULT_DESCRIPTION = 'Opportunity description';
    public static final String DEFAULT_FORECAST_CATEGORY_NAME = Opportunity.ForecastCategoryName.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_NEXT_STEP = 'Phone call';
    public static final String DEFAULT_LEAD_SOURCE = Opportunity.LeadSource.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_CURRENCY_ISO_CODE = Opportunity.CurrencyIsoCode.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_NAME = 'Opportunity ' + System.currentTimeMillis();
    public static final Boolean DEFAULT_IS_PRIVATE = false;
    public static final Double DEFAULT_PROBABILITY = 1.0;
    public static final Decimal DEFAULT_TOTAL_OPPORTUNITY_QUANTITY = 5;
    public static final String DEFAULT_STAGE_NAME = Opportunity.StageName.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_TYPE = Opportunity.Type.getDescribe().getPicklistValues().get(0).value;
    public static final Decimal DEFAULT_AMOUNT_FP = 10;
    public static final Boolean DEFAULT_ASAP = false;
    public static final Boolean DEFAULT_BUDGET_CONFIRMED = false;
    public static final String DEFAULT_WON_REASON = 'Sold';
    public static final String DEFAULT_CLOSE_DETAILS = 'DEFAULT_CLOSE_DETAILS';
    public static final Decimal DEFAULT_CONTRACT_DURATION_NUMBER = 1;
    public static final String DEFAULT_CONTRACT_DURATION = Opportunity.Contract_Duration__c.getDescribe().getPicklistValues().get(0).value;
    public static final Date DEFAULT_CONTRACT_END = Date.today().addYears(3);
    public static final String DEFAULT_CONTRACT_END_DESCRIPTION = 'DEFAULT_CONTRACT_END_DESCRIPTION';
    public static final Date DEFAULT_CONTRACT_START = Date.today().addDays(7);
    public static final String DEFAULT_CONTRACT_START_DESCRIPTION = 'DEFAULT_CONTRACT_START_DESCRIPTION';
    public static final Decimal DEFAULT_RATE = 10.0;
    public static final Date DEFAULT_CV_DELIVERY_DEADLINE = Date.today().addMonths(1);
    public static final Boolean DEFAULT_DISCOVERY_COMPLETED = false;
    public static final String DEFAULT_CV_LANGUAGE = Opportunity.CVLanguage__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_LAST_STAGE_BEFORE_CLOSE_LOST = Opportunity.Last_Stage_Before_Close_Lost__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_LOCATION = Opportunity.Location__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_LOSS_REASON = Opportunity.Loss_Reason__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_PRODUCT_MAIN_SKILLS = 'DEFAULT_PRODUCT_MAIN_SKILLS';
    public static final Date DEFAULT_NEXT_STEP_DEADLINE = Date.today().addDays(7);
    public static final String DEFAULT_OTHER_LOCATION = 'Szczecin';
    public static final String DEFAULT_POSITION = Opportunity.Position__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_PRIORITY = Opportunity.Priority__c.getDescribe().getPicklistValues().get(0).value;
    public static final Decimal DEFAULT_PLACEMENT = 1.0;
    public static final String DEFAULT_REMARKS = 'DEFAULT_REMARKS';
    public static final Boolean DEFAULT_ROI_ANALYSIS_COMPLETED = false;
    public static final String DEFAULT_SALES_REP_MANAGER_EMAIL = 'sales_rep_manager@britenet.com.pl';
    public static final String DEFAULT_PRODUCT_SECONDARY_SKILLS = 'DEFAULT_PRODUCT_SECONDARY_SKILLS';
    public static final String DEFAULT_SECTOR = Opportunity.Sector__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_SENIORITY = Opportunity.Seniority__c.getDescribe().getPicklistValues().get(0).value;
    public static final String DEFAULT_SOURCE_STATUS_FOR_CLOSED_LOST = 'DEFAULT_SOURCE_STATUS_FOR_CLOSED_LOST';
    public static final DateTime DEFAULT_STAGE_CHANGE = Datetime.now().addDays(2);
    public static final String DEFAULT_STAGE_DETAILS = 'DEFAULT_STAGE_DETAILS';
    public static final String DEFAULT_TECHNOLOGY = 'DEFAULT_TECHNOLOGY';
    public static final Date DEFAULT_OPPORTUNITY_START = Date.today().addDays(1);
    public static final String FIXED_TYPE = 'Fixed';
    public static final String TM_TYPE = 'Time & Material';
    
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWithTimeMaterialRecordType Method builds Opportunity sObject with Time & Material record type
     * @return BTN_OpportunityBuilderHelper - current instance
    */
    public static BTN_OpportunityBuilderHelper buildWithTimeMaterialRecordType() {
        return buildWith(TM_TYPE);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description getRecordTypeOpportunityFixedPrice Method builds Opportunity sObject with Fixed Price record type
     * @return BTN_OpportunityBuilderHelper - current instance
    */
    public static BTN_OpportunityBuilderHelper buildWithFixedPriceRecordType() {
        return buildWith(FIXED_TYPE);
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description buildWith Method builds Opportunity sObject with given Record Type
     * @param String - given record type to set
     * @return BTN_OpportunityBuilderHelper - current instance
    */
    private static BTN_OpportunityBuilderHelper buildWith(String recordTypeId){
        BTN_OpportunityBuilderHelper opportunityBuilderHelper = new BTN_OpportunityBuilderHelper();
        opportunityBuilderHelper.record = applyDefaults(recordTypeId);
        return opportunityBuilderHelper;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-20
     * @description applyDefaults Method applies default values to record for given Record Type
     * @param String - Record Type Id to set
     * @return Opportunity
    */
    private static Opportunity applyDefaults(String recordTypeId) {
        return new Opportunity(
                Amount = DEFAULT_AMOUNT,
                CloseDate = DEFAULT_CLOSE_DATE,
                Description = DEFAULT_DESCRIPTION,
                ForecastCategoryName = DEFAULT_FORECAST_CATEGORY_NAME,
                NextStep = DEFAULT_NEXT_STEP,
                NextStep__c = DEFAULT_LEAD_SOURCE,
                CurrencyIsoCode = DEFAULT_CURRENCY_ISO_CODE,
                Name = DEFAULT_NAME,
                IsPrivate = DEFAULT_IS_PRIVATE,
                Probability = DEFAULT_PROBABILITY,
                TotalOpportunityQuantity = DEFAULT_TOTAL_OPPORTUNITY_QUANTITY,
                StageName = DEFAULT_STAGE_NAME,
                Type = recordTypeId,
                Amount_FP__c = DEFAULT_AMOUNT_FP,
                ASAP__c = DEFAULT_ASAP,
                Budget_Confirmed__c = DEFAULT_BUDGET_CONFIRMED,
                Won_Reason__c = DEFAULT_WON_REASON,
                Close_Details__c = DEFAULT_CLOSE_DETAILS,
                Contract_Duration_Number__c = DEFAULT_CONTRACT_DURATION_NUMBER,
                Contract_Duration__c = DEFAULT_CONTRACT_DURATION,
                ContractEnd__c = DEFAULT_CONTRACT_END,
                ContractEndDescription__c = DEFAULT_CONTRACT_END_DESCRIPTION,
                ContractStart__c = DEFAULT_CONTRACT_START,
                ContractStartDescription__c = DEFAULT_CONTRACT_START_DESCRIPTION,
                Rate__c = DEFAULT_RATE,
                CVDeliveryDeadline__c = DEFAULT_CV_DELIVERY_DEADLINE,
                Discovery_Completed__c = DEFAULT_DISCOVERY_COMPLETED,
                CVLanguage__c = DEFAULT_CV_LANGUAGE,
                Last_Stage_Before_Close_Lost__c = DEFAULT_LAST_STAGE_BEFORE_CLOSE_LOST,
                Location__c = DEFAULT_LOCATION,
                Loss_Reason__c = DEFAULT_LOSS_REASON,
                Product_Main_Skills__c = DEFAULT_PRODUCT_MAIN_SKILLS,
                NextStepDeadline__c = DEFAULT_NEXT_STEP_DEADLINE,
                OtherLocation__c = DEFAULT_OTHER_LOCATION,
                Position__c = DEFAULT_POSITION,
                Priority__c = DEFAULT_PRIORITY,
                Placement__c = DEFAULT_PLACEMENT,
                Remarks__c = DEFAULT_REMARKS,
                ROI_Analysis_Completed__c = DEFAULT_ROI_ANALYSIS_COMPLETED,
                SalesRepManagerEmail__c = DEFAULT_SALES_REP_MANAGER_EMAIL,
                Product_Secondary_Skills__c = DEFAULT_PRODUCT_SECONDARY_SKILLS,
                Sector__c = DEFAULT_SECTOR,
                Seniority__c = DEFAULT_SENIORITY,
                SourceStatusForClosedLost__c = DEFAULT_SOURCE_STATUS_FOR_CLOSED_LOST,
                Stage_Change__c = DEFAULT_STAGE_CHANGE,
                Stage_Details__c = DEFAULT_STAGE_DETAILS,
                Technology__c = DEFAULT_TECHNOLOGY,
                OpportunityStart__c = DEFAULT_OPPORTUNITY_START
        );
    }



    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withName Method set up Opportunity Name
     * @return BTN_OpportunityBuilderHelper - instance of Builder
    */
    public BTN_OpportunityBuilderHelper withName(String Name) {
        record.Name = name;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withStageName Method set up Opportunity StageName
     * @return BTN_OpportunityBuilderHelper - instance of Builder
    */
    public BTN_OpportunityBuilderHelper withStageName(String stageName) {
        record.StageName = stageName;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-18
     * @description withCloseDate Method set up Opportunity CloseDate
     * @return BTN_OpportunityBuilderHelper - instance of Builder
    */
    public BTN_OpportunityBuilderHelper withCloseDate(Date closeDate) {
        record.CloseDate = closeDate;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-19
     * @description withContact Method set up Opportunity ContactId__c
     * @return BTN_OpportunityBuilderHelper - instance of Builder
    */
    public BTN_OpportunityBuilderHelper withContact(String contactId) {
        record.ContactId__c = contactId;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-19
     * @description withContractStart Method set up Opportunity ContractStart__c
     * @return BTN_OpportunityBuilderHelper - instance of Builder
    */
    public BTN_OpportunityBuilderHelper withContractStart(Date contractStart) {
        record.ContractStart__c = contractStart;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-19
     * @description withDescription Method set up Opportunity Description
     * @return BTN_OpportunityBuilderHelper - instance of Builder
    */
    public BTN_OpportunityBuilderHelper withDescription(String description) {
        record.Description = description;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-19
     * @description withDescription Method set up Opportunity Location__c
     * @return BTN_OpportunityBuilderHelper - instance of Builder
    */
    public BTN_OpportunityBuilderHelper withLocation(String location) {
        record.Location__c = location;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-19
     * @description withProductMainSkills Method set up Opportunity Product_Main_Skills__c
     * @return BTN_OpportunityBuilderHelper - instance of Builder
    */
    public BTN_OpportunityBuilderHelper withProductMainSkills(String ProductMainSkills) {
        record.Product_Main_Skills__c = productMainSkills;
        return this;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description get Method gets building record
     * @return Opportunity building record
    */
    public Opportunity get(){
        return record;
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-09-09
     * @description save Method saves building record
     * @return Opportunity building record
    */
    public Opportunity save(){
        insert record;
        return record;
    }
}