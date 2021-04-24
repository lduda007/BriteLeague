/**
 * @author Mateusz Przywara
 * @date   2016-07-05
 * @description DAO class - Data Access Object for Contact
 */
public class BTN_DAO_Contact extends BTN_DAO {
    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor
    */
    public BTN_DAO_Contact() {
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description Constructor setting custom List of fields
    */
    public BTN_DAO_Contact(List<Schema.SObjectField> customFields) {
        setCustomFields(customFields);
    }

    public override Schema.SObjectType getSObjectType() {
        return Contact.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                Contact.Id,
                Contact.Email,
                Contact.AccountId,
                Contact.FirstName,
                Contact.PersonalPhone__c,
                Contact.PersonalEmail__c,
                Contact.LastName,
                Contact.Phone,
                Contact.CreatedDate,
                Contact.Comment__c,
                Contact.Position__c,
                Contact.Location__c,
                Contact.CityLocation__c,
                Contact.Title,
                Contact.Token__c,
                Contact.BSexternalId__c,
                Contact.Skills__c,
                Contact.Name_frm__c,
                Contact.Level__c,
                Contact.Name,
                Contact.RecordTypeId,
                Contact.Current_Position__c,
                Contact.TargetPosition__c,
                Contact.Freelancer__c,
                Contact.Sex__c,
                Contact.joinDateBS__c,
                Contact.ReportsToId,
                Contact.Leader__c,
                Contact.Guardian__c,
                Contact.SkillAssessment__c
        };
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description find Contact
     * @param  contactId - collection of Id to search for
     * @return     Contact       - collection of found Contacts
    */
    public Contact findContactById(Id contactId) {
        return (Contact) findSObjectById(contactId);
    }

    public List<Contact> findContactsByIds(Set<Id> contactIds) {
        return findSObjectsBy(new List<SearchCondition> {
                new SearchCondition('Id', 'IN', contactIds)
        });
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-05
     * @description add Record Type fields to Query
     * @return void
    */
    public void addRecordTypeFields() {
        currentFields.add('RecordType.DeveloperName');
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-06
     * @description find Requestor matching unique token
     * @return List<Contact>
    */
    public List<Contact> findRequestorsMatchingToken(String token) {
        return findSObjectsBy(
                new List<SearchCondition>{
                    new SearchCondition('ResourceRequestor__c', '=', true),
                    new SearchCondition('AND Token__c', '=', token)
                }
        );
    }

    /**
      * @author Mateusz Przywara
      * @date   2016-08-24
      * @description findContacByBSExternalId find Contact with specified Britesheet Id
      * @return Contact
    */
    public Contact findContacByBSExternalId(Integer briteSheetExternalId) {
        List<Object> objects = findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('BSexternalId__c', '=', briteSheetExternalId)
                }
        );
        return objects.isEmpty() ? null : (Contact) objects.get(0);
    }

    public List<Contact> findContactsByBSExternalIds(Set<Integer> briteSheetExternalIds) {
        return findSObjectsBy(
                new List<SearchCondition> {
                        new SearchCondition(
                                'BSexternalId__c',
                                'IN',
                                briteSheetExternalIds
                        )
                }
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-15
     * @description findContacByEmail find Contacts with given email
     * @return List<Contact>
     */
    public List<Contact> findContacByEmail(String email) {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Active__c',
                                '=',
                                true
                        ),
                        new SearchCondition(
                                'AND Email',
                                '=',
                                email
                        )
                }
        );
    }

    /**
     * @author Mateusz Przywara
     * @date 2016-11-24
     * @description findContactByBritenetEmail find Contacts with given Britenet Email
     * @return Contact - Email is unique
    */
    public Contact findContactByBritenetEmail(String email) {
        List<sObject> objects = findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Email',
                                '=',
                                email
                        )
                }
        );
        return objects.isEmpty() ? null : (Contact) objects.get(0);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-06
     * @description find all Internal Requestors // to DCh double SOQL!!! Method name obvious
     * @return List<Contact>
    */
    public List<Contact> findRequestors() {
        List<PermissionSetAssignment> permissionSetsList = [
                SELECT Assignee.ContactId
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = :BTN_ConstantRepo.PERM_SET_NAME_HR
                ];
        List<Id> assigneeIdsSet = new List<Id>();
        for(PermissionSetAssignment ps: permissionSetsList){
            assigneeIdsSet.add(ps.Assignee.ContactId);
        }
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id IN :assigneeIdsSet];
        return contacts;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description find all Internal Requestors
     * @return List<Contact>
    */
    public List<Contact> findInternals() {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'RecordType.DeveloperName',
                                '=',
                                BTN_ConstantRepo.INTERNAL_CONTACT_RECORDTYPE_NAME
                        )
                }
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description findBSSContacts search for active BSS Contacts
     * @return List<Contact>
    */
    public List<Contact> findBSSContacts() {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Active__c',
                                '=',
                                true
                        )
                }
        );
    }

    /**
     * @author Dariusz Chmiela
     * @date 2016-09-15
     * @description findBSSContacts search for active BSS Contacts
     * @return List<Contact>
     */
    public List<Contact> getAllContacts() {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Active__c',
                                '=',
                                true
                        )
                }
        );
    }

    /**
     * @author Mateusz Przywara
     * @date 2016-11-08
     * @description findRecruits get all Contacts with Recruit Record Type
     * @return List<Contact>
     */
    public List<Contact> findRecruits() {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'RecordType.Id',
                                '=',
                                BTN_RecordTypeUtils.getRecordTypeContactRecruit().Id
                        )
                }
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-24
     * @description findContactsInIdSet
     * @return List<Contact>
    */
    public List<Contact> findContactsInIdSet(Set<Id> ids) {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'Id',
                                'IN',
                                ids
                        )
                }
        );
    }
    
    /**
     * @author Wojciech Mazur
     * @date   2016-10-28
     * @description add ailing Fields to Query
     * @return BTN_DAO_Contact
    */
    public BTN_DAO_Contact addMailingFields() {
        currentFields.add('MailingCity');
        currentFields.add('MailingPostalCode');
        currentFields.add('MailingStreet');
        return this;
    }
    
    /**
     * @author Wojciech Mazur
     * @date   2016-12-14
     * @description add Position Fields to Query
     * @return BTN_DAO_Contact
    */
    public BTN_DAO_Contact addCurrentPositionFields() {
        currentFields.add('Current_Position__r.Name');
        return this;
    }

    /**
     * @author Wojciech Mazur
     * @date   2016-12-01
     * @description add ailing Fields to Query
     * @return void
    */
    public BTN_DAO_Contact addInterviews() {
        currentFields.add('(select id, name, Type__c, Start_Time__c, Candidate__c, Candidate__r.name, Title__c, Interviewer_Contact__c, Interviewer_Contact__r.name, Location__c, Description__c, CreatedDate, OwnerId, Owner.Name from Interviews__r ORDER BY ' +
                'Start_Time__c desc nulls last)');
        return this;
    }

    /**
     * @author Adam Jedrys
     * @date   2018-05-23
     * @description get list of leaders
     * @return list of contacts
    */
    public List<Contact> findLeaders() {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition(
                                'IsLeader__c',
                                '=',
                                true
                        )
                }
        );
    }

    /**
     * @author Adam Jedrys
     * @date   2018-05-23
     * @description get leaders by name
     * @return map of contacts by name
    */
    public Map<String, Contact> getLeadersByName() {
        Map<String, Contact> leadersByNameMap = new Map<String, Contact>();
        List<Contact> leaders = findLeaders();

        for(Contact leader : leaders){
            leadersByNameMap.put(leader.Name, leader);
        }

        return leadersByNameMap;
    }
}