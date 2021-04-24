@isTest
private class AchievementContactsSearchControllerTest
{
    @isTest
    static void itShouldGetEmployeeWithBadgeGratenThenOne() {
        // Given
        List<Achievement__c> achievements = prepareData();
        List<AchievementContactsSearchController.AchievementSearchCriteria> achievementSearchCriteria = new List<AchievementContactsSearchController.AchievementSearchCriteria> {
                new AchievementContactsSearchController.AchievementSearchCriteria(achievements[3].Id, 'Badge', null, 2.0, null, AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE)
        };
        AchievementContactsSearchController.SearchCriteria searchCriteria = new AchievementContactsSearchController.SearchCriteria(null, achievementSearchCriteria);

        // When
        List<Achievement_Set__c> employeeProfile =  AchievementContactsSearchController.search(searchCriteria);

        // Then
        System.assertEquals(2, employeeProfile.size());
    }

    @isTest
    static void itShouldGetEmployeeWithSkillGratenThenJunior() {
        // Given
        List<Achievement__c> achievements = prepareData();
        List<AchievementContactsSearchController.AchievementSearchCriteria> achievementSearchCriteria = new List<AchievementContactsSearchController.AchievementSearchCriteria> {
                new AchievementContactsSearchController.AchievementSearchCriteria(achievements[0].Id, 'Skill', AchievementUtils.ACHIEVEMENT_LEVEL_2_VALUE, null, null, AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE)
        };
        AchievementContactsSearchController.SearchCriteria searchCriteria = new AchievementContactsSearchController.SearchCriteria(null, achievementSearchCriteria);

        // When
        List<Achievement_Set__c> employeeProfile =  AchievementContactsSearchController.search(searchCriteria);

        // Then
        System.assertEquals(3, employeeProfile.size());
    }

    @isTest
    static void itShouldGetEmployeeWithCertificate() {
        // Given
        List<Achievement__c> achievements = prepareData();
        List<AchievementContactsSearchController.AchievementSearchCriteria> achievementSearchCriteria = new List<AchievementContactsSearchController.AchievementSearchCriteria> {
                new AchievementContactsSearchController.AchievementSearchCriteria(achievements[1].Id, 'Cert1',null, null, true, AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE)
        };
        AchievementContactsSearchController.SearchCriteria searchCriteria = new AchievementContactsSearchController.SearchCriteria(null, achievementSearchCriteria);

        // When
        List<Achievement_Set__c> employeeProfile =  AchievementContactsSearchController.search(searchCriteria);

        // Then
        System.assertEquals(4, employeeProfile.size());
    }

    @isTest
    static void itShouldGetEmployeeWithCertificateSkillEqualsSenior() {
        // Given
        List<Achievement__c> achievements = prepareData();
        List<AchievementContactsSearchController.AchievementSearchCriteria> achievementSearchCriteria = new List<AchievementContactsSearchController.AchievementSearchCriteria> {
                new AchievementContactsSearchController.AchievementSearchCriteria(achievements[1].Id, 'Cert1',null, null, true, AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE),
                new AchievementContactsSearchController.AchievementSearchCriteria(achievements[0].Id, 'Skill', AchievementUtils.ACHIEVEMENT_LEVEL_3_VALUE, null, null, AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE)
        };
        AchievementContactsSearchController.SearchCriteria searchCriteria = new AchievementContactsSearchController.SearchCriteria(null, achievementSearchCriteria);

        // When
        List<Achievement_Set__c> employeeProfile =  AchievementContactsSearchController.search(searchCriteria);

        // Then
        System.assertEquals(1, employeeProfile.size());
    }

    @isTest
    static void itShouldGetEmployeeWithCertificateSkillEqualsSeniorAndAchievmentsName() {
        // Given
        List<Achievement__c> achievements = prepareData();
        List<AchievementContactsSearchController.AchievementSearchCriteria> achievementSearchCriteria = new List<AchievementContactsSearchController.AchievementSearchCriteria> {
                new AchievementContactsSearchController.AchievementSearchCriteria(achievements[1].Id, 'Cert1',null, null, true, AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE),
                new AchievementContactsSearchController.AchievementSearchCriteria(achievements[0].Id, 'Skill', AchievementUtils.ACHIEVEMENT_LEVEL_2_VALUE, null, null, AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE)
        };
        AchievementContactsSearchController.SearchCriteria searchCriteria = new AchievementContactsSearchController.SearchCriteria(new List<String>{achievements[0].Id}, achievementSearchCriteria);

        // When
        List<Achievement_Set__c> employeeProfile =  AchievementContactsSearchController.search(searchCriteria);

        // Then
        System.assertEquals(2, employeeProfile.size());
    }

    @isTest
    static void itShouldGetOption() {
        // Given
        List<Achievement__c> achievements = prepareData();

        // When
        Map<String, List<AchievementContactsSearchController.Option>> options =  AchievementContactsSearchController.getOptions();

        // Then
        System.assertEquals(1, options.get('achievmentsSets').size());
        System.assertEquals(4, options.get('achievments').size());
    }

    static private List<Achievement__c> prepareData() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();

        Achievement__c skill = new AchievementUtils.AchievementBuilder('Skill', base).asSkill().build();
        Achievement__c cert = new AchievementUtils.AchievementBuilder('Cert1', base).asCert().build();
        Achievement__c cert2 = new AchievementUtils.AchievementBuilder('Cert2', base).asCert().build();
        Achievement__c badge = new AchievementUtils.AchievementBuilder('Badge', base).asBadge().build();
        List<Achievement__c> achievements = new Achievement__c[] {skill, cert, cert2, badge};
        insert achievements;

        Contact c1 = new Contact(FirstName='Janusz', LastName='D', Email='Janusz@d.com.pl', SkillAssessment__c = true);
        Contact c2 = new Contact(FirstName='Andrzej', LastName='U', Email='Andrzej@u.com.pl', SkillAssessment__c = true);
        Contact c3 = new Contact(FirstName='Grazyna', LastName='P', Email='Grazyna@p.com.pl', SkillAssessment__c = true);
        Contact c4 = new Contact(FirstName='Zbigniew', LastName='E', Email='Zbigniew@e.com.pl', SkillAssessment__c = true);
        Contact c5 = new Contact(FirstName='Helena', LastName='K', Email='Helena@k.com.pl', SkillAssessment__c = true);
        Contact[] contacts = new Contact[]{c1, c2, c3, c4, c5};
        insert contacts;
        Map<ID, Contact> contactsMap = new Map<ID, Contact>(contacts);

        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c IN : contactsMap.keySet()]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c1.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_3).
                addBadge(badge, 3).
                addCert(cert).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c2.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addBadge(badge, 2).
                addCert(cert).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c3.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_1).
                addCert(cert).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c4.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addBadge(badge, 1).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c5.Id)).
                addCert(cert).
                addCert(cert2).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder('Senior Java Developer').
                asPositionProfile(careerPath).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addCert(cert).
                addBadge(badge, 2).
                buildAndSave();

        return achievements;
    }
}