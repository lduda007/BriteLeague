public with sharing class BTN_ContactsSearchController {
    private static final String ALL_RECORD_TYPES = 'All';
    public Integer numberOfRecords{set; get;}
    public Integer size{set; get;}
    public String searchConditions{set; get;}
    public String searchAnyone{set; get;}
    public String searchNone{set; get;}
    private String SEARCH_CONDITION_SEPARATOR = ',';
    private ApexPages.StandardSetController stdSetController;
    private List<Contact> foundContacts;
    public BTN_DAO_Contact contactDAO;
    public Contact searchContact {get;set;}
    public String searchContactRecordType{set; get;}


    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(search());
                setCon.setPageSize(size);
                numberOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;}


    public BTN_ContactsSearchController() {
        contactDAO = new BTN_DAO_Contact();
        searchConditions = '';
        searchAnyone = '';
        searchNone = '';
        size = 20;
        searchContact = new Contact();
        searchContactRecordType = ALL_RECORD_TYPES;
    }
    public List<SelectOption> getRecordTypes(){
        List<SelectOption> options = new List<SelectOption>();
        for (RecordType rt : [SELECT Id, toLabel(Name) FROM RecordType WHERE SobjectType='Contact']){
            options.add(new SelectOption(rt.id,rt.Name));
        }
        options.add(new SelectOption(ALL_RECORD_TYPES,Label.Assignment_List_Filter_All));
        return options;
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-10-25
     * @description search Method splits conditions provided by users, Retrieve from DB valid Contacts for given
     * Search Conditions
     * @return PageReference
    */
    public List<Contact> search() {
        List<Contact> result = new List<Contact>();
        try {
            // split conditions by ','
            List<String> conditionsAllWords = new List<String>(searchConditions.toLowerCase().split(SEARCH_CONDITION_SEPARATOR));
            List<String> conditionsAnyoneWords = new List<String>(searchAnyone.toLowerCase().split(SEARCH_CONDITION_SEPARATOR));
            List<String> conditionsNoneWords = new List<String>(searchNone.toLowerCase().split(SEARCH_CONDITION_SEPARATOR));
            // look for Ids in Search Fragments

            String conditions = '';

            // All words
            if (conditionsAllWords.get(0) != '') {
                if (conditionsAllWords.size() > 1) {
                    conditions += '(';
                    for (String word : conditionsAllWords) {
                        conditions += word + ' AND ';
                    }
                    conditions = conditions.removeEnd(' AND ') + ')';
                } else {
                    conditions += conditionsAllWords.get(0);
                }
            }

            // Anyone of words
            if (conditionsAnyoneWords.get(0) != '') {
                if (conditions.length() > 0) {
                    conditions += ' AND ';
                }

                if (conditionsAnyoneWords.size() > 1) {
                    conditions += '(';
                    for (String word : conditionsAnyoneWords) {
                        conditions += word + ' OR ';
                    }
                    conditions = conditions.removeEnd(' OR ') + ')';
                } else {
                    conditions += conditionsAnyoneWords.get(0);
                }
            }

            // None of words
            if (conditionsNoneWords.get(0) != '') {
                if (conditions.length() > 0) {
                    conditions += ' AND ';
                }

                if (conditionsNoneWords.size() > 1) {
                    conditions += '( AND NOT (';
                    for (String word : conditionsNoneWords) {
                        conditions += word + ' OR ';
                    }
                    conditions = conditions.removeEnd(' OR ') + '))';
                } else {
                    conditions += '( AND NOT ' + conditionsNoneWords.get(0) + ')';
                }
            }

            // 'FIND \'(test AND test2) AND (test3 OR test4)\' IN ALL FIELDS RETURNING Contact(Id)'
            String searchQuery;
            Set<Id> foundContactIds = new Set<Id>();
            if (conditions != '') {
                searchQuery = 'FIND \'' + conditions + '\' IN ALL FIELDS RETURNING Contact(Id),BTN_Event__c(Candidate__r.Contact__c)';
                List<List<SObject>> searchList = Search.query(searchQuery);
                for (SObject obj : searchList.get(0)) {
                    Contact ct = (Contact)obj;
                    foundContactIds.add(ct.Id);
                }
                for (SObject obj : searchList.get(1)) {
                    BTN_Event__c ct = (BTN_Event__c)obj;
                    foundContactIds.add(ct.Candidate__r.Contact__c);
                }
                if (!foundContactIds.isEmpty()) {
                    foundContactIds = searchBaseOnContactFields(foundContactIds);
                }
            }else {
                foundContactIds = searchBaseOnContactFields(foundContactIds);
            }

            // find Contacts within earlier found Ids
            if (!foundContactIds.isEmpty()) {
                result = new List<Contact>(contactDAO.findContactsInIdSet(foundContactIds));
            } else {
                ApexPages.addmessage(
                        new ApexPages.message(ApexPages.severity.INFO, System.Label.SearchPageNoResults)
                );
            }
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SearchPageError));
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
        return result;
    }
    public  Set<Id> searchBaseOnContactFields(Set<Id> contacts){
        String searchQuery = 'SELECT ID from Contact WHERE';
        if(String.isNotBlank(searchContact.Level__c)){
            searchQuery += ' Level__c = \''+ searchContact.Level__c+'\' AND';
        }
        if(String.isNotBlank(searchContact.CityLocation__c)){
            searchQuery += ' CityLocation__c = \''+ searchContact.CityLocation__c+'\' AND';
        }
        if(String.isNotBlank(searchContact.Language_1__c)){
            searchQuery += ' Language_1__c = \''+ searchContact.Language_1__c+'\' AND';
        }
        if(String.isNotBlank(searchContact.Language_level_1__c)){
            searchQuery += ' Language_level_1__c = \''+ searchContact.Language_level_1__c+'\' AND';
        }
        if(String.isNotBlank(searchContactRecordType)&&!searchContactRecordType.equals(ALL_RECORD_TYPES)){
            searchQuery += ' RecordTypeId = \''+ searchContactRecordType+'\' AND';
        }
        if(!contacts.isEmpty()){
            searchQuery += ' Id in :contacts';
        }
        searchQuery = searchQuery.removeEnd(' AND');
        if(searchQuery.endsWith('WHERE')){
            searchQuery = searchQuery.replace('WHERE','ORDER BY CreatedDate DESC NULLS LAST LIMIT 100');
        }

        return new Map<Id, Contact>((List<Contact>)Database.query(searchQuery)).keySet();
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-10-25
     * @description Reset Search
    */
    public void resetSearch() {
        foundContacts = null;
        nullPagination();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-25
     * @description getFoundContacts get Contacts for View (on Page)
     * @return List<Contact> Contacts from SetCon Page
    */
    public List<Contact> getFoundContacts() {
        return setCon.getRecords();
    }

    public Boolean hasNext {
        get{
            return setCon.getHasNext();}
        set;}

    public Boolean hasPrevious {
        get{
            return setCon.getHasPrevious();}
        set;}

    public Integer pageNumber {
        get {
            return setCon.getPageNumber();}
        set;}


    public void nullPagination() {
        this.setCon = null;
    }

    public PageReference refresh() {
        setCon = null;
        setCon.setPageNumber(1);
        return null;
    }

    public void first() {
        setCon.first();
    }

    public void last() {
        setCon.last();
    }

    public void previous() {
        setCon.previous();
    }

    public void next() {
        setCon.next();
    }
}