/**
 * @author Mateusz Przywara
 * @date   2016-07-05
 * @description DAO class - Data Access Object for BTN_CV__c (Candidate)
 */
public with sharing class BTN_DAO_Candidate extends BTN_DAO {
    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor
    */
    public BTN_DAO_Candidate() {
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor setting custom List of fields
    */
    public BTN_DAO_Candidate(List<Schema.SObjectField> customFields) {
        setCustomFields(customFields);
    }

    public override Schema.SObjectType getSObjectType() {
        return BTN_CV__c.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                BTN_CV__c.Id,
                BTN_CV__c.Name,
                BTN_CV__c.ContactFirstName_frm__c,
                BTN_CV__c.ContactLastName_frm__c,
                BTN_CV__c.ContactName_frm__c,
                BTN_CV__c.Contact__c,
                BTN_CV__c.Comment__c,
                BTN_CV__c.LastAttachmentId__c,
                BTN_CV__c.Position_Name_frm__c,
                BTN_CV__c.Project_Manager_Email__c,
                BTN_CV__c.ResourceRequest__c,
                BTN_CV__c.ResourceRequestName_frm__c,
                BTN_CV__c.Status__c
        };
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description find all Candidates connected with Resource Request
         * @param  resourceRequestId - Id of Resource request
         * @return      List<BTN_CV__c>      Candidates affiliated with Resource Request
         */
    public List<BTN_CV__c> findCandidatesByResourceRequest(Id resourceRequestId) {
        return findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('ResourceRequest__c', '=', resourceRequestId)
        });
    }
    
       /**
         * @author Wojciech Mazur
         * @date   2016-09-14
         * @description find all Candidates related to Contact (Internal)
         * @param  contactId - Id of contact
         * @return      List<BTN_CV__c>      Candidates affiliated with contact
         */
    public List<BTN_CV__c> findCandidatesBuContact(Id contactId) {
        return findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('Contact__c', '=', contactId)
        });
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-05
         * @description find Resource Request
         * @param  candidateId - collection of Id to search for
         * @return     BTN_CV__c       - collection of found Resource Requests
         */
    public BTN_CV__c findCandidateById(Id candidateId) {
        return (BTN_CV__c) findSObjectById(candidateId);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-12
     * @description findCandidatesInContactSet
     * @param contactIds search set of Contact Ids
     * @return Candidates
    */
    public List<BTN_CV__c> findCandidatesInContactSet(Set<Id> contactIds) {
        return findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('Contact__c', 'IN', contactIds)
        });
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-11-09
     * @description findCandidatesInId
     * @param contactIds search set of Contact Ids
     * @return Candidates
    */
    public List<BTN_CV__c> findCandidatesInId(Set<Id> candidateIds) {
        return findSObjectsBy(new List<SearchCondition>{
                new SearchCondition('Id', 'IN', candidateIds)
        });
    }

    /**
     * @author Konrad Kozaczuk
     * @date   2016-10-21
     * @description findCandidatesInContactSet
     * @param contactIds search set of Contact Ids
     * @return Candidates
    */
    public List<BTN_CV__c> findCandidates() {
        return (List<BTN_CV__c>)findSObjects();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description add ResourceRequest Fields to Query
     * @return BTN_DAO_Candidate
    */
    public BTN_DAO_Candidate addResourceRequestFields() {
        currentFields.add('ResourceRequest__r.Opportunity__c');
        currentFields.add('ResourceRequest__r.RecordType.Name');
        currentFields.add('ResourceRequest__r.ContractStart_frm__c');
        currentFields.add('ResourceRequest__r.Account_frm__c');
        currentFields.add('ResourceRequest__r.Level__c');
        currentFields.add('ResourceRequest__r.Position_frm__c');
        return this;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-11-09
     * @description add ResourceRequest Fields to Query
     * @return BTN_DAO_Candidate
    */
    public BTN_DAO_Candidate addResourceRequestName() {
        this.currentFields.add('ResourceRequest__r.Name');
        return this;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-07
     * @description add Contact Fields to Query
     * @return void
    */
    public BTN_DAO_Candidate addContactFields() {
        currentFields.add('Contact__r.FirstName');
        currentFields.add('Contact__r.LastName');
        currentFields.add('Contact__r.MobilePhone');
        currentFields.add('Contact__r.PersonalPhone__c');
        currentFields.add('Contact__r.PersonalEmail__c');
        currentFields.add('Contact__r.Email');
        currentFields.add('Contact__r.MailingCity');
        currentFields.add('Contact__r.MailingPostalCode');
        currentFields.add('Contact__r.MailingStreet');
        currentFields.add('Contact__r.BSexternalId__c');
        return this;
    }
}