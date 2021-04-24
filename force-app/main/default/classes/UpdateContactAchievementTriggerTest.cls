/**
 * UpdateContactAchievementProfiles Trigger Test
 * @author Adam Siwek
 */
@IsTest
private class UpdateContactAchievementTriggerTest {

    static testMethod void shouldCreateContactProfileOnContactInsertion() {
        System.assertEquals(0, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c != null LIMIT 1]);

        Contact c1 = new Contact(FirstName='Janusz', LastName='D', SkillAssessment__c = true);
        insert c1;

        System.assertEquals(1, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c = :c1.Id AND Name LIKE '%Janusz%' LIMIT 2]);
    }

    static testMethod void shouldCreateContactProfileOnUpdateContact() {
        System.assertEquals(0, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c != null LIMIT 1]);

        Contact c1 = new Contact(FirstName='Janusz', LastName='D');
        insert c1;
        c1.SkillAssessment__c = true;
        update c1;

        System.assertEquals(1, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c = :c1.Id AND Name LIKE '%Janusz%' LIMIT 2]);
    }

    static testMethod void shouldCreateContactProfileOnInsertContact() {
        System.assertEquals(0, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c != null LIMIT 1]);

        Contact c1 = new Contact(FirstName='Janusz', LastName='D', SkillAssessment__c = true);
        insert c1;
        c1.SkillAssessment__c = false;
        update c1;
        c1.SkillAssessment__c = true;
        update c1;

        System.assertEquals(1, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c = :c1.Id AND Name LIKE '%Janusz%' LIMIT 2]);
    }

    static testMethod void shouldUpdateContactProfileNameOnContactNameUpdate() {
        Contact c1 = new Contact(FirstName='Janusz', LastName='D', SkillAssessment__c = true);
        insert c1;

        System.assertEquals(0, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c = :c1.Id AND Name LIKE '%Marek%' LIMIT 1]);

        c1.FirstName = 'Marek';
        update c1;

        System.assertEquals(1, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c = :c1.Id AND Name LIKE '%Marek%' LIMIT 2]);
    }

    static testMethod void shouldDeleteContactProfileOnContactDelete() {
        Contact c1 = new Contact(FirstName='Janusz', LastName='D', SkillAssessment__c = true);
        insert c1;

        System.assertEquals(1, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c = :c1.Id LIMIT 2]);

        delete c1;

        System.assertEquals(0, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c = :c1.Id LIMIT 1]);
    }

    static testMethod void shouldCutContactFirstName() {
        String firstName = generateRandomString(40);
        String lastName = generateRandomString(40);
        Contact c1 = new Contact(FirstName=firstName, LastName=lastName, SkillAssessment__c = true);
        insert c1;
        lastname = '%'+lastName+'%';
        System.assertEquals(1, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c = :c1.Id AND Name LIKE :lastname LIMIT 2]);
    }

    static testMethod void shouldCutContactName() {
        String firstName = generateRandomString(25);
        String lastName = generateRandomString(80);
        Contact c1 = new Contact(FirstName=firstName, LastName=lastName, SkillAssessment__c = true);
        insert c1;

        lastName = '%'+lastName.substring(0,15)+'%';
        System.assertEquals(1, [SELECT Count() FROM Achievement_Set__c WHERE Contact__c = :c1.Id AND Name LIKE :lastName LIMIT 2]);
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
}