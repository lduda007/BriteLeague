/**
 * @author Mateusz Przywara
 * @date   2016-10-25
 * @description BTN_ContactsSearchController_Test
*/
@isTest
private class BTN_ContactsSearchController_Test {
    private static final String TEST_SKILLS = 'wiedźmak halina zając pyłek';
    private static final String TEST_SKILLS2 = 'niagara shpongle granatowa kula bób flamastry i mazaki lsd';
    private static final String TEST_SEARCH_CONDITION = 'wiedźmak, halina';
    private static final String TEST_SEARCH_CONDITION_IMPOSSIBLE = 'hałwa,werter';
    /**
     * @author Mateusz Przywara
     * @date   2016-10-25
     * @description Prepare data for tests
    */
    @testSetup static void createDataStructure() {
        BTN_TestDataFactory.getHRCollaborationGroup();
        BTN_TestDataFactory.getBriteNetAccount();
        BTN_TestDataFactory.getRecruitContactWithSkills(
                new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id,
                TEST_SKILLS
        );
        BTN_TestDataFactory.getRecruitContactWithSkills(
                new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id,
                TEST_SKILLS2
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-25
     * @description searchForAllRecruitContacts No search conditions so Page will show all Recruits with Skills
    */
    testMethod static void searchForAllRecruitContacts() {
        PageReference pageTest = Page.BTN_ContactsSearchPage;
        Test.setCurrentPage(pageTest);
        // init
        BTN_ContactsSearchController controller = new BTN_ContactsSearchController();
        // get Contacts from View - all Recruits with Skills
        System.assert(!controller.getFoundContacts().isEmpty());
        controller.resetSearch();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-25
     * @description searchForNonExistingRecruit No search results
    */
    testMethod static void searchForNonExistingRecruit() {
        PageReference pageTest = Page.BTN_ContactsSearchPage;
        Test.setCurrentPage(pageTest);
        // init
        BTN_ContactsSearchController controller = new BTN_ContactsSearchController();
        controller.searchConditions = TEST_SEARCH_CONDITION_IMPOSSIBLE;
        // get Contacts from View - should be empty.
        System.assert(controller.getFoundContacts().isEmpty());
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-25
     * @description searchFoNonExistingRecruit No search results
    */
    testMethod static void searchForExistingRecruit() {

        Contact ct = [SELECT Id FROM Contact LIMIT 1];

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = ct.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        PageReference pageTest = Page.BTN_ContactsSearchPage;
        Test.setCurrentPage(pageTest);
        // init
        BTN_ContactsSearchController controller = new BTN_ContactsSearchController();
        controller.searchConditions = TEST_SEARCH_CONDITION;
        controller.searchAnyone = TEST_SEARCH_CONDITION;
        controller.searchNone = TEST_SEARCH_CONDITION_IMPOSSIBLE;
        // get Contacts from View - result should contain one Contact due to criteria
        System.assertEquals(1, controller.getFoundContacts().size());

        Boolean hasValue = controller.hasNext;
        hasValue = controller.hasPrevious;
        Integer pageNumber = controller.pageNumber;
        controller.first();
        controller.last();
        controller.next();
        controller.previous();
        controller.refresh();
    }
    testMethod static void searchInContact() {

        Contact ct = [SELECT Id,Position__c,Level__c,CityLocation__c,Language_1__c,Language_level_1__c,RecordType.Name FROM Contact LIMIT 1];
        ct.Level__c = 'Junior';
        ct.CityLocation__c = 'Lublin';
        ct.Language_1__c = 'English';
        ct.Language_level_1__c = 'A1';
        ct.Position__c = 'Recruitment Specialist';
        update ct;

        BTN_Event__c event  = new BTN_Event__c();
        event.RecordTypeId = BTN_RecordTypeUtils.getRecordTypeCustomEventPeriodicAssessment().Id;

        BTN_ResourceRequest__c rr = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().save();
        rr.Resource_Manager__c = ct.Id;
        update rr;

        event.Candidate__c = BTN_TestDataFactory.getCV(rr.Id, ct.Id).Id;
        insert event;

        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = ct.Id;
        fixedSearchResults[1] = event.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        PageReference pageTest = Page.BTN_ContactsSearchPage;
        Test.setCurrentPage(pageTest);


        BTN_ContactsSearchController controller = new BTN_ContactsSearchController();
        System.assert(controller.getFoundContacts().size()>1);
        System.assert(controller.getRecordTypes().size()>1);
        controller.resetSearch();

        controller.searchContact = ct;
        controller.searchContactRecordType = ct.RecordTypeId;
        controller.searchConditions = ct.Position__c;

        List<Contact> results = controller.getFoundContacts();
        System.assert([SELECT Id FROM Contact].size()>1);
        System.assertEquals(1, controller.getFoundContacts().size());
        Contact result = results[0];
        System.assertEquals(ct.Id, result.Id);
    }
    testMethod static void searchForExistingRecruitWithOneWord() {

        Contact ct = [SELECT Id FROM Contact LIMIT 1];

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = ct.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        PageReference pageTest = Page.BTN_ContactsSearchPage;
        Test.setCurrentPage(pageTest);
        // init
        BTN_ContactsSearchController controller = new BTN_ContactsSearchController();
        controller.searchConditions = 'test';
        controller.searchAnyone = 'test';
        controller.searchNone = 'xyz';
        // get Contacts from View - result should contain one Contact due to criteria
        System.assertEquals(1, controller.getFoundContacts().size());
    }
    testMethod static void testErrorOnPage() {
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = ct.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        PageReference pageTest = Page.BTN_ContactsSearchPage;
        Test.setCurrentPage(pageTest);
        // init
        BTN_ContactsSearchController controller = new BTN_ContactsSearchController();
        controller.searchConditions = '\'';
        System.assertEquals(0, controller.getFoundContacts().size());
        System.assert(ApexPages.getMessages().size()>0);
    }
}