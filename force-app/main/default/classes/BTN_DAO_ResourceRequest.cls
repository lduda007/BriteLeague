/**
 * Created by britenet on 2016-07-05.
 * @description DAO class for BTN_ResourceRequest__c - Data Access Object
 */
public class BTN_DAO_ResourceRequest extends BTN_DAO {
    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor
    */
    public BTN_DAO_ResourceRequest() {
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor setting custom List of fields
    */
    public BTN_DAO_ResourceRequest(List<Schema.SObjectField> customFields) {
        setCustomFields(customFields);
    }

    public override Schema.SObjectType getSObjectType() {
        return BTN_ResourceRequest__c.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                BTN_ResourceRequest__c.Id,
                BTN_ResourceRequest__c.Name,
                BTN_ResourceRequest__c.Position_frm__c,
                BTN_ResourceRequest__c.Opportunity__c,
                BTN_ResourceRequest__c.OpportunityName_frm__c,
                BTN_ResourceRequest__c.RequestorContact__c,
                BTN_ResourceRequest__c.RequestorUser__c,
                BTN_ResourceRequest__c.Position__c,
                BTN_ResourceRequest__c.Account_frm__c,
                BTN_ResourceRequest__c.CreatedDate,
                BTN_ResourceRequest__c.ZOHOUrl_frm__c,
                BTN_ResourceRequest__c.Location__c,
                BTN_ResourceRequest__c.DeliveryDeadline_frm__c,
                BTN_ResourceRequest__c.CVsAllInFinal__c,
                BTN_ResourceRequest__c.CVsApprovedRequested__c,
                BTN_ResourceRequest__c.CustomerAccount__c,
                BTN_ResourceRequest__c.Billing_Type__c,
                BTN_ResourceRequest__c.ContractStart_frm__c,
                BTN_ResourceRequest__c.NumberOfCVs1__c,
                BTN_ResourceRequest__c.RequestorEmail_frm__c,
                BTN_ResourceRequest__c.Resource_Manager__c
        };
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description find all Resource Requests connected with Opportunity opportunityId
         * @param  sObjectIds - collection of Id to search for
         * @return            - collection of found sObjectsDAO.query
         */
    public List<BTN_ResourceRequest__c> findResourceRequestsByOpportunity(Id opportunityId) {
        return findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('Opportunity__c', '=', opportunityId)
        });
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description find all Resource Requests connected with Opportunity opportunityId
         * @param  sObjectIds - collection of Id to search for
         * @return            - collection of found sObjectsDAO.query
         */
    public List<BTN_ResourceRequest__c> findAutoResourceRequests() {
        return findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('RecordType.Name', '=', BTN_ConstantRepo.RESOURCE_REQUEST_RECORD_TYPE_AUTO)
        });
    }
    
    /**
         * @author Wojciech Mazur
         * @date   2016-09-16
         * @description find all Resource Requests with Billing type = Unbillable
         * 
         * @return            - collection of found sObjectsDAO.query
         */
    public List<BTN_ResourceRequest__c> findUnbillableRequests() {
        return findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('Billing_Type__c', '=', BTN_ConstantRepo.BILLING_TYPE_UNBILLABLE)
        });
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description find Resource Request
         * @param  resourceRequestId - collection of Id to search for
         * @return     BTN_ResourceRequest__c       - collection of found Resource Requests
         */
    public BTN_ResourceRequest__c findResourceRequestsById(Id resourceRequestId) {
        return (BTN_ResourceRequest__c) findSObjectById(resourceRequestId);
    }
    
       /**
         * @author Wojciech Mazur
         * @date   2016-09-14
         * @description find all Resource Requests connected with Account (Business) and Contact (Internal)
         * @param  businessId - Business Account id
         * @param  contactId - internal contact id
         * @return            - collection of found sObjectsDAO.query
         */
    public List<BTN_ResourceRequest__c> findByBusinessAndContact(Id businessId, Id contactId) {
    	
    	BTN_DAO_Candidate daoCandidate = new BTN_DAO_Candidate();
    	List<BTN_CV__c> candidates = daoCandidate.findCandidatesBuContact(contactId);
    	Set<Id> affectedResourceRequests = new Set<Id>();
    	for(BTN_CV__c c:candidates){
    		affectedResourceRequests.add(c.ResourceRequest__c);
    	}
        return findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('CustomerAccount__c', '=', businessId),
                new SearchCondition(' AND Id', 'IN', affectedResourceRequests)
        });
    }
    
        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description add RequestorContact fields to Query
         * @return void
         */
    public void addRequestorContactFields() {
        currentFields.addAll(new List<String>{
                'RequestorContact__r.Name',
                'RequestorContact__r.Email'
        });
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-22
     * @description add RequestorUser fields to Query
     * @return void
     */
    public void addRequestorUserFields() {
        currentFields.addAll(new List<String>{
                'RequestorUser__r.Email', 'RequestorUser__r.Name'});
    }
        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description add Record Type fields to Query
         * @return void
         */
    public void addRecordTypeFields() {
        currentFields.add('RecordType.DeveloperName');
        currentFields.add('RecordType.Name');
    }
    /**
     * @author Piotr Pitera
     * @date 2016-09-08
     * @description adds Rich Text fields to the Query
     * @return void
     */
    public void addRichTextFields() {
        currentFields.addAll(new List<String>{
                'MainSkills__c', 'SecondarySkills__c', 'Description__c'});
    }
    
     /**
     * @author Wojciech Mazur
     * @date 2016-09-16
     * @description adds Candidates to the Query
     * @return void
     */
    public void addCandidates() {
        currentFields.add('(SELECT id,Contact__c,DateApproved__c from CVs_lkp__r)');
    }
    
       
}