@isTest
private class ContactAchievementSetPageExtensionTest {

    @isTest
    private static void shouldGetAchievementSet() {
        //GIVEN
        Contact c = new Contact(FirstName = 'test', LastName = 'test', Email='test@test.com.pl', SkillAssessment__c=true);
        insert c;
        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c =: c.Id]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Achievement_Set__c achievementSet = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c.Id)).buildAndSave();

        PageReference pageRef = Page.ContactDetailsPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c.Id);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(achievementSet);

        //WHEN
        ContactAchievementSetPageExtension ext = new ContactAchievementSetPageExtension(stdCtrl);

        //THEN
        System.assertEquals('test' + ' ' + 'test'+ ' - Employee Profile', ext.achievementSet.Name);
    }

}