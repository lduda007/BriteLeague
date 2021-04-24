/**
 * Achievement Service Test
 * @author Adam Siwek
 */
@isTest
private class AchievementServiceTest {

    @isTest
    private static void shouldNotCalculateProfilesWhenNoData() {
        AchievementService.calculateContactProfileScores(null, null);
        System.assertEquals(0, [SELECT Count() FROM Contact_Profile_Score__c]);

        AchievementService.calculateContactProfileScores(new Set<Id>(), new Set<Id>());
        System.assertEquals(0, [SELECT Count() FROM Contact_Profile_Score__c]);
    }

    @isTest
    private static void groupItemShouldBeUnique() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();
        
        Achievement__c skill1 = new AchievementUtils.AchievementBuilder('Skill1', base).asSkill().buildAndSave();
        Achievement__c grp = new AchievementUtils.AchievementBuilder('Group1', base).asGroup().addGroupItem(skill1).build();
        
        try {
            insert new Achievement_Group_Item__c(Achievement__c = skill1.Id, Group__c = grp.Id);
            System.assert(false, 'Group Items should be unique');
        } catch (DMLException e){}
        
    }

    @isTest
    private static void achievementSetItemShouldBeUnique() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();
        
        Achievement__c skill1 = new AchievementUtils.AchievementBuilder('Skill1', base).asSkill().buildAndSave();

        Achievement_Set__c spec1 = new AchievementUtils.AchievementSetBuilder('Junior Java Developer').
                asProfile(careerPath).
                addSkill(skill1, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                buildAndSave();

        try {
            insert new Achievement_Set_Item__c(Achievement_Set__c = spec1.Id, Achievement__c = skill1.Id);
            System.assert(false, 'Group Items should be unique');
        } catch (DMLException e){}
    }

    @isTest
    private static void shouldCalculateProfiles() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();

        Achievement__c skill = new AchievementUtils.AchievementBuilder('Skill', base).asSkill().build();
        Achievement__c cert = new AchievementUtils.AchievementBuilder('Cert1', base).asCert().build();
        Achievement__c cert2 = new AchievementUtils.AchievementBuilder('Cert2', base).asCert().build();
        Achievement__c badge = new AchievementUtils.AchievementBuilder('Badge', base).asBadge().build();
        Achievement__c date_c = new AchievementUtils.AchievementBuilder('Date', base).asDate().build();
        insert new Achievement__c[] {skill, cert, cert2, badge, date_c};
        Achievement__c attribute = new AchievementUtils.AchievementBuilder('Attribute', base)
            .asAttribute()
            .addAttributeValue('option 1', 1)
            .addAttributeValue('option 2', 2)
            .addAttributeValue('option 3', 4)
            .addAttributeValue('option 4', 8)
            .buildAndSave();

        Contact c1 = new Contact(FirstName='Janusz', LastName='D', Email='j@text.com', SkillAssessment__c = true);
        Contact c2 = new Contact(FirstName='Andrzej', LastName='U', Email='a@text.com', SkillAssessment__c = true);
        Contact c3 = new Contact(FirstName='Grazyna', LastName='P', Email='g@text.com', SkillAssessment__c = true);
        Contact c4 = new Contact(FirstName='Zbigniew', LastName='E', Email='z@text.com', SkillAssessment__c = true);
        Contact c5 = new Contact(FirstName='Helena', LastName='K', Email='h@text.com', SkillAssessment__c = true);
        Contact c6 = new Contact(FirstName='Kamil', LastName='C', Email='ka@text.com', SkillAssessment__c = true);
        Contact[] contacts = new Contact[]{c1, c2, c3, c4, c5, c6};
        insert contacts;
        Map<ID, Contact> contactsMap = new Map<ID, Contact>(contacts);

        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c IN : contactsMap.keySet()]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        Date dateInstance = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Test.startTest();
        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c1.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_3).
                addBadge(badge, 3).
                addAttribute(attribute, 8).
                addDate(date_c, dateInstance.addMonths(-8)).
                addCert(cert).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c2.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addBadge(badge, 2).
                addAttribute(attribute, 8).
                addDate(date_c, dateInstance.addMonths(-8)).
                addCert(cert).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c3.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_1).
                addCert(cert).
                addAttribute(attribute, 2).
                addDate(date_c, dateInstance.addMonths(-2)).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c4.Id)).
                addBadge(badge, 1).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c5.Id)).
                addCert(cert).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c5.Id)).
                addCert(cert2).
                buildAndSave();

        Achievement_Set__c pos = new AchievementUtils.AchievementSetBuilder('Senior Java Developer').
                asPositionProfile(careerPath).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addCert(cert).
                addBadge(badge, 2).
                addAttribute(attribute, 8).
                addDate(date_c, dateInstance.addMonths(-5)).
                buildAndSave();
                
        Database.executeBatch(new AchievementProfileCalcuationJob());
        Test.stopTest();
        System.assertEquals(1.0, [SELECT Match__c FROM Contact_Profile_Score__c WHERE Contact__c=:c1.Id LIMIT 1].Match__c);
        System.assertEquals(1.0, [SELECT Match__c FROM Contact_Profile_Score__c WHERE Contact__c=:c2.Id LIMIT 1].Match__c);
        System.assertEquals(0.5, [SELECT Match__c FROM Contact_Profile_Score__c WHERE Contact__c=:c3.Id LIMIT 1].Match__c);
        System.assertEquals(0, [SELECT Count() FROM Contact_Profile_Score__c WHERE Contact__c=:c4.Id LIMIT 1]);
        System.assertEquals(0, [SELECT Count() FROM Contact_Profile_Score__c WHERE Contact__c=:c5.Id LIMIT 1]);
        System.assertEquals(0, [SELECT Count() FROM Contact_Profile_Score__c WHERE Contact__c=:c6.Id LIMIT 1]);
    }
    
    @isTest
    private static void shouldRemoveProbeWhenProfileDoesNotMatch() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();

        Achievement__c skill = new AchievementUtils.AchievementBuilder('Skill', base).asSkill().build();
        Achievement__c cert = new AchievementUtils.AchievementBuilder('Cert1', base).asCert().build();
        insert new Achievement__c[] {skill, cert};

        Contact c1 = new Contact(FirstName='Janusz', LastName='D', Email='j@test.com', SkillAssessment__c = true);
        Contact[] contacts = new Contact[]{c1};
        insert contacts;
        Map<ID, Contact> contactsMap = new Map<ID, Contact>(contacts);

        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c IN : contactsMap.keySet()]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        
        Achievement_Set__c prof = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c1.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_1).
                addCert(cert).
                buildAndSave();

        Achievement_Set__c pos = new AchievementUtils.AchievementSetBuilder('Senior Java Developer').
                asPositionProfile(careerPath).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addCert(cert).
                buildAndSave();

        insert new Contact_Profile_Score__c(
                Contact__c = c1.Id,
                Contact_Profile__c = prof.Id,
                Achievement_Profile__c = pos.Id,
                unique_name__c = String.valueOf(c1.Id)+String.valueOf(pos.Id),
                Match__c = 0.75);

        Test.startTest();
        pos.Score_Minimal_Value__c = 1;
        update pos;
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Count() FROM Contact_Profile_Score__c WHERE Contact__c=:c1.Id LIMIT 1]);
        
    }

    @isTest
    private static void shouldRewriteProfileScoreToAchievementsetItem() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();

        Achievement__c skill = new AchievementUtils.AchievementBuilder('Skill', base).asSkill().build();
        Achievement__c cert = new AchievementUtils.AchievementBuilder('Cert1', base).asCert().build();
        Achievement__c cert2 = new AchievementUtils.AchievementBuilder('Cert2', base).asCert().build();
        Achievement__c badge = new AchievementUtils.AchievementBuilder('Badge', base).asBadge().build();
        insert new Achievement__c[] {skill, cert, cert2, badge};

        Contact c1 = new Contact(FirstName='Janusz', LastName='D', Email='j@text.com', SkillAssessment__c = true);
        Contact c2 = new Contact(FirstName='Andrzej', LastName='U', Email='a@text.com', SkillAssessment__c = true);
        Contact c3 = new Contact(FirstName='Grazyna', LastName='P', Email='g@text.com', SkillAssessment__c = true);
        Contact c4 = new Contact(FirstName='Zbigniew', LastName='E', Email='z@text.com', SkillAssessment__c = true);
        Contact c5 = new Contact(FirstName='Helena', LastName='K', Email='h@text.com', SkillAssessment__c = true);
        Contact c6 = new Contact(FirstName='Kamil', LastName='C', Email='k@text.com', SkillAssessment__c = true);
        Contact[] contacts = new Contact[]{c1, c2, c3, c4, c5, c6};
        insert contacts;
        Map<ID, Contact> contactsMap = new Map<ID, Contact>(contacts);

        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c IN : contactsMap.keySet()]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }

        Test.startTest();
        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c1.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_3).
                addBadge(badge, 3).
                addCert(cert).
                addCert(cert2).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c2.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addBadge(badge, 2).
                addCert(cert).
                addCert(cert2).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c3.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_1).
                addCert(cert).
                addCert(cert2).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c4.Id)).
                addBadge(badge, 1).
                buildAndSave();

        new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c5.Id)).
                addCert(cert).
                addCert(cert2).
                buildAndSave();

        Achievement_Set__c pos = new AchievementUtils.AchievementSetBuilder('Senior Java Developer').
                asPositionProfile(careerPath).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addCert(cert).
                addBadge(badge, 2).
                buildAndSave();

        Achievement_Set__c specialization = new AchievementUtils.AchievementSetBuilder('Specialization').
                asProfile(careerPath).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_2).
                addBadge(badge, 2).
                addCert(cert).
                addCert(cert2).
                buildAndSave();

        new AchievementUtils.AchievementBuilder('Spec', base).asSpecialization(specialization).buildAndSave();

        Database.executeBatch(new AchievementProfileCalcuationJob());
        Test.stopTest();

        System.assertEquals(4, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Type__c =: AchievementUtils.ACHIEVEMENT_SPECIALIZATION_RECORD_TYPE]);
    }

    @isTest
    private static void shouldArchiveAchievementSetrItems() {
        Achievement_Category__c base = new AchievementUtils.AchievementCategoryBuilder('Base Category').buildAndSave();
        Career_Path__c careerPath = new AchievementUtils.CareerPathBuilder('Career Path 1').buildAndSave();

        Achievement__c skill = new AchievementUtils.AchievementBuilder('Skill', base).asSkill().build();
        Achievement__c cert = new AchievementUtils.AchievementBuilder('Cert1', base).asCert().build();
        Achievement__c badge = new AchievementUtils.AchievementBuilder('Badge', base).asBadge().build();
        Achievement__c date_c = new AchievementUtils.AchievementBuilder('Date', base).asDate().build();
        Achievement__c attribute = new AchievementUtils.AchievementBuilder('Attribute', base)
            .asAttribute()
            .addAttributeValue('option 1', 1)
            .addAttributeValue('option 2', 2)
            .addAttributeValue('option 3', 4)
            .addAttributeValue('option 4', 8)
            .build();

        insert new Achievement__c[] {skill, cert, badge, date_c, attribute};

        Contact c1 = new Contact(FirstName='Janusz', LastName='D', Email='j@test.com', SkillAssessment__c = true);
        Contact[] contacts = new Contact[]{c1};
        insert contacts;
        Map<ID, Contact> contactsMap = new Map<ID, Contact>(contacts);
        Date dateInstance = Date.newInstance(Date.today().year(), Date.today().month(), 1);

        Map<ID, Achievement_Set__c> contactIdToAchievementSetMap  = new Map<ID, Achievement_Set__c>();
        for (Achievement_Set__c cpp : [SELECT Contact__c, Name FROM Achievement_Set__c WHERE Contact__c IN : contactsMap.keySet()]) {
            contactIdToAchievementSetMap.put(cpp.Contact__c, cpp);
        }
        
        Achievement_Set__c prof = new AchievementUtils.AchievementSetBuilder(contactIdToAchievementSetMap.get(c1.Id)).
                addSkill(skill, AchievementUtils.ACHIEVEMENT_LEVEL_1).
                addBadge(badge, 2).
                addCert(cert).
                addDate(date_c, dateInstance).
                addAttribute(attribute, 2).
                buildAndSave();

        system.assertEquals(1, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Achievement__c = : skill.Id]);
        system.assertEquals(1, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Achievement__c = : cert.Id]);
        system.assertEquals(1, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Achievement__c = : badge.Id]);
        system.assertEquals(1, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Achievement__c = : date_c.Id]);
        system.assertEquals(1, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Achievement__c = : attribute.Id]);

        List<Achievement_Set_Item__c> items = [SELECT Id, Amount__c, Level__c, Type__c FROM Achievement_Set_Item__c];
        List<Achievement_Set_Item__c> deleteItems = new List<Achievement_Set_Item__c>();
        for (Achievement_Set_Item__c item : items) {
            if (item.Type__c == AchievementUtils.ACHIEVEMENT_SKILL_RECORD_TYPE) {
                item.Level__c = AchievementUtils.ACHIEVEMENT_LEVEL_3;
            } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_MONTHSFROMDATE_RECORD_TYPE) {
                item.Date__c = dateInstance.addMonths(5);
            } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_ATTRIBUTE_RECORD_TYPE) {
                item.Amount__c = 8;
            } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_BADGE_RECORD_TYPE) {
                item.Amount__c = 4;
            } else if (item.Type__c == AchievementUtils.ACHIEVEMENT_CERTIFICATE_RECORD_TYPE) {
                deleteItems.add(item);
            }
        }
        update items;
        delete deleteItems;
        System.assertEquals(5, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE HistoryRecord__c = true]);
        System.assertEquals(4, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE HistoryRecord__c = false]);
        System.assertEquals(2, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Achievement__c = : skill.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Achievement__c = : cert.Id]);
        System.assertEquals(2, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Achievement__c = : badge.Id]);
        System.assertEquals(2, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Achievement__c = : date_c.Id]);
        System.assertEquals(2, [SELECT COUNT() FROM Achievement_Set_Item__c WHERE Achievement__c = : attribute.Id]);
    }

    @isTest
    private static void shouldGetSubCategoriesStartWithFirstLevel() {
        //GIVEN
        buildTreeCateogry();

        //WHEN
        Set<Id> ids = AchievementService.getSubCategoriesIds('Category 1');

        //THEN
        System.assertEquals(3, ids.size());
    }

    @isTest
    private static void shouldGetSubCategoriesStartWithSecondLevel() {
        //GIVEN
        buildTreeCateogry();

        //WHEN
        Set<Id> ids = AchievementService.getSubCategoriesIds('Category 1.1');

        //THEN
        System.assertEquals(2, ids.size());
    }

    @isTest
    private static void shouldGetSubCategoriesStartWithThirdLevel() {
        //GIVEN
        buildTreeCateogry();

        //WHEN
        Set<Id> ids = AchievementService.getSubCategoriesIds('Category 1.1.1');

        //THEN
        System.assertEquals(1, ids.size());
    }

    private static void buildTreeCateogry() {
        Achievement_Category__c category1 = new AchievementUtils.AchievementCategoryBuilder('Category 1').buildAndSave();
        Achievement_Category__c category2 = new AchievementUtils.AchievementCategoryBuilder('Category 1.1').addParent(category1.Id).buildAndSave();
        Achievement_Category__c category3 = new AchievementUtils.AchievementCategoryBuilder('Category 1.1.1').addParent(category2.Id).buildAndSave();
    }
}