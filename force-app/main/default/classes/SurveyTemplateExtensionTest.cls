@isTest
private class SurveyTemplateExtensionTest {

    @isTest
    private static void shouldSaveNewSurveyTemplateWithoutQuestions() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTestSurveyTemplateExtensionTest').build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);

        System.assertNotEquals(null, ext.save());

        System.assertEquals(1, [SELECT Count() FROM SurveyTemplate__c WHERE Id = :template.Id]);
        System.assertEquals(0, [SELECT Count() FROM SurveyTemplateItem__c WHERE SurveyTemplate__c = :template.Id]);
    }

    @isTest
    private static void shouldSaveNewSurveyTemplateAddNewQuestions() {
        SurveyTestUtils.SurveyConfigBuilder cfg = SurveyTestUtils.createDefaultQuestionProvider('questionProviderSurveyTemplateExtensionTest');
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').build();  
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('name').buildAndSave();
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('Apex', category).asSkill().buildAndSave();
        SurveyTemplateItem__c templateItem = new SurveyTestUtils.TemplateItemBuilder(template, cfg.getConfigs().get('questionProviderSurveyTemplateExtensionTest')).withConfig('{"id": "'+achievement.Id+'", "getAll":"true"}').build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);

        ext.templateItem = templateItem;
        ext.addQuestion();

        System.assertNotEquals(null, ext.save());
        System.assertEquals(1, [SELECT Count() FROM SurveyTemplate__c WHERE Id = :template.Id]);
        System.assertEquals(1, [SELECT Count() FROM SurveyTemplateItem__c WHERE SurveyTemplate__c = :template.Id]);
    }

    @isTest
    private static void shouldEditSurveyTemplateAndAddNewQuestion() {
        SurveyTestUtils.SurveyConfigBuilder cfg = SurveyTestUtils.createDefaultQuestionProvider('questionProviderSurveyTemplateExtensionTest');
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('name').buildAndSave();
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('Apex', category).asSkill().buildAndSave();
        SurveyTemplateItem__c templateItem = new SurveyTestUtils.TemplateItemBuilder(template, cfg.getConfigs().get('questionProviderSurveyTemplateExtensionTest')).withConfig('{"id": "'+achievement.Id+'", "getAll":"false"}').build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);
        
        ext.templateItem = templateItem;
        ext.addQuestion();

        System.assertNotEquals(null, ext.save());
        System.assertEquals(1, [SELECT Count() FROM SurveyTemplate__c WHERE Id = :template.Id]);
        System.assertEquals(1, [SELECT Count() FROM SurveyTemplateItem__c WHERE SurveyTemplate__c = :template.Id]);
    }

    @isTest
    private static void shouldEditSurveyTemplateWithotAddOrDeleteQuestion() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);
        
        System.assertNotEquals(null, ext.save());

        System.assertEquals(1, [SELECT Count() FROM SurveyTemplate__c WHERE Id = :template.Id]);
        System.assertEquals(0, [SELECT Count() FROM SurveyTemplateItem__c WHERE SurveyTemplate__c = :template.Id]);
    }

    @isTest
    private static void shouldEditSurveyTemplateWithDeleteQuestion() {
        SurveyTestUtils.SurveyConfigBuilder cfg = SurveyTestUtils.createDefaultQuestionProvider('questionProviderSurveyTemplateExtensionTest');
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('name').buildAndSave();
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('Apex', category).asSkill().buildAndSave();
        SurveyTemplateItem__c templateItem = new SurveyTestUtils.TemplateItemBuilder(template, cfg.getConfigs().get('questionProviderSurveyTemplateExtensionTest')).withConfig('{"id": "'+achievement.Id+'", "getAll":"false"}').buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);

        ext.questionList.get(0).remove();
        System.assertNotEquals(null, ext.save());

        System.assertEquals(1, [SELECT Count() FROM SurveyTemplate__c WHERE Id = :template.Id]);
        System.assertEquals(0, [SELECT Count() FROM SurveyTemplateItem__c WHERE SurveyTemplate__c = :template.Id]);
    }

    @isTest
    private static void shouldCloneSurveyTemplateAndAddNewQuestion() {
        SurveyTestUtils.SurveyConfigBuilder cfg = SurveyTestUtils.createDefaultQuestionProvider('questionProviderSurveyTemplateExtensionTest');
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('name').buildAndSave();
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('Apex', category).asSkill().buildAndSave();
        SurveyTemplateItem__c templateItem = new SurveyTestUtils.TemplateItemBuilder(template, cfg.getConfigs().get('questionProviderSurveyTemplateExtensionTest')).withConfig('{"id": "'+achievement.Id+'", "getAll":"false"}').build();
        SurveyTemplateItem__c templateItem2 = new SurveyTestUtils.TemplateItemBuilder(template, cfg.getConfigs().get('questionProviderSurveyTemplateExtensionTest')).withConfig('{"id": "'+achievement.Id+'", "getAll":"false"}').build();
        ApexPages.currentPage().getParameters().put('clone', '1');
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);
        ext.template.ApiName__c = 'cloneTemplate';
        ext.template.Name = 'cloneTemplate';

        ext.templateItem = templateItem;
        ext.addQuestion();
        ext.templateItem = templateItem2;
        ext.addQuestion();
        System.assertNotEquals(null, ext.save());

        System.assertEquals(2, [SELECT Count() FROM SurveyTemplate__c]);
        System.assertEquals(2, [SELECT Count() FROM SurveyTemplateItem__c WHERE SurveyTemplate__c = :ext.template.Id]);
    }

    @isTest
    private static void shouldCloneSurveyTemplateWithotAddOrDeleteQuestion() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        ApexPages.currentPage().getParameters().put('clone', '1');
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);
        ext.template.ApiName__c = 'cloneTemplate';
        ext.template.Name = 'cloneTemplate';

        System.assertNotEquals(null, ext.save());

        System.assertEquals(2, [SELECT Count() FROM SurveyTemplate__c]);
        System.assertEquals(0, [SELECT Count() FROM SurveyTemplateItem__c WHERE SurveyTemplate__c = :ext.template.Id]);
    }

    @isTest
    private static void shouldCloneSurveyTemplateWithDeleteQuestion() {
        SurveyTestUtils.SurveyConfigBuilder cfg = SurveyTestUtils.createDefaultQuestionProvider('questionProviderSurveyTemplateExtensionTest');
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('name').buildAndSave();
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('Apex', category).asSkill().buildAndSave();
        SurveyTemplateItem__c templateItem = new SurveyTestUtils.TemplateItemBuilder(template, cfg.getConfigs().get('questionProviderSurveyTemplateExtensionTest')).withConfig('{"id": "'+achievement.Id+'", "getAll":"false"}').buildAndSave();
        ApexPages.currentPage().getParameters().put('clone', '1');
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);

        ext.template.ApiName__c = 'cloneTemplate';
        ext.template.Name = 'cloneTemplate';

        ext.questionList.get(0).remove();
        System.assertNotEquals(null, ext.save());

        System.assertEquals(2, [SELECT Count() FROM SurveyTemplate__c]);
        System.assertEquals(1, [SELECT Count() FROM SurveyTemplateItem__c WHERE SurveyTemplate__c = :template.Id]);
    }

    @isTest
    private static void shouldNotSaveTemplateWhereStartDateIsLargestThanEndDate() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').withEndDate(System.today() - 20).build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);

        System.assertEquals(null, ext.save());

        System.assertEquals(0, [SELECT Count() FROM SurveyTemplate__c WHERE Id = :ext.template.Id]);
    }

    @isTest
    private static void shouldSetTemplateConfig() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').withEndDate(System.today() - 20).build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);

        ext.setTemplateConfig();

        System.assertEquals('{"id": ""}', ext.template.Config__c);
    }

    @isTest
    private static void shouldSetTemplateItemConfig() {
        SurveyTestUtils.SurveyConfigBuilder cfg = SurveyTestUtils.createDefaultQuestionProvider('questionProviderSurveyTemplateExtensionTest');
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').withEndDate(System.today() - 20).build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);
        Achievement_Category__c category = new AchievementUtils.AchievementCategoryBuilder('name').buildAndSave();
        Achievement__c achievement = new AchievementUtils.AchievementBuilder('Apex', category).asSkill().buildAndSave();
        SurveyTemplateItem__c templateItem = new SurveyTestUtils.TemplateItemBuilder(template, cfg.getConfigs().get('questionProviderSurveyTemplateExtensionTest')).withConfig('{"id": "'+achievement.Id+'", "getAll":"false"}').build();

        ext.templateItem = templateItem;
        ext.setTemplateItemConfig();

        System.assertEquals('{"id": ""}', ext.templateItem.Config__c);
    }

    @isTest 
    private static void shouldSaveNewSurveyTemplateAddNewContactAccess() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').privateSurvey().build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);
        Contact c = new Contact(FirstName = 'Michal', LastName = 'Banasik');
        insert c;

        ext.templateAccess = new SurveyTestUtils.TemplateAccessBuilder(template).build();
        ext.addContact();
        ext.templateAccess = new SurveyTestUtils.TemplateAccessBuilder(template).withContact(c).build();
        ext.addContact();
        System.assertNotEquals(null, ext.save());

        System.assertEquals(1, [SELECT Count() FROM SurveyTemplate__c WHERE Id = :template.Id]);
        System.assertEquals(2, [SELECT Count() FROM SurveyTemplateAccesses__c WHERE SurveyTemplate__c = :template.Id]);
    }

    @isTest 
    private static void shouldSaveNewSurveyTemplateAddRemoveOneContactAccess() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').privateSurvey().buildAndSave();
        Contact c = new Contact(FirstName = 'Michal', LastName = 'Banasik');
        insert c;
        new SurveyTestUtils.TemplateAccessBuilder(template).buildAndSave();
        new SurveyTestUtils.TemplateAccessBuilder(template).withContact(c).buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);

        ext.contactList.get(0).remove();
        System.assertNotEquals(null, ext.save());

        System.assertEquals(1, [SELECT Count() FROM SurveyTemplate__c WHERE Id = :template.Id]);
        System.assertEquals(1, [SELECT Count() FROM SurveyTemplateAccesses__c WHERE SurveyTemplate__c = :template.Id]);
    }

    @isTest
    private static void shouldGetAllContacts() {
        Contact c1 = new Contact(FirstName='Janusz', LastName='D');
        Contact c2 = new Contact(FirstName='Andrzej', LastName='U');
        Contact c3 = new Contact(FirstName='Grazyna', LastName='P');
        Contact c4 = new Contact(FirstName='Zbigniew', LastName='E');
        Contact c5 = new Contact(FirstName='Helena', LastName='C');
        Contact c6 = new Contact(FirstName='Kamil', LastName='K');
        Contact[] contacts = new Contact[]{c1, c2, c3, c4, c5, c6};
        insert contacts;
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);

        System.assertEquals(7, ext.getContacts().size());
    }

    @isTest
    private static void shouldClearContactList() {
        Contact c1 = new Contact(FirstName='Janusz', LastName='D');
        Contact c2 = new Contact(FirstName='Andrzej', LastName='U');
        Contact c3 = new Contact(FirstName='Grazyna', LastName='P');
        Contact c4 = new Contact(FirstName='Zbigniew', LastName='E');
        Contact c5 = new Contact(FirstName='Helena', LastName='C');
        Contact c6 = new Contact(FirstName='Kamil', LastName='K');
        Contact[] contacts = new Contact[]{c1, c2, c3, c4, c5, c6};
        insert contacts;
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(template);
        SurveyTemplateExtension ext = new SurveyTemplateExtension(stdCtrl);

        ext.clearContactList();

        System.assertEquals(0, ext.contactList.size());
    }
}