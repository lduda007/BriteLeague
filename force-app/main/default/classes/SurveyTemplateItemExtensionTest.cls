@isTest
private class SurveyTemplateItemExtensionTest {
    
    @isTest 
    private static void shouldEditTemplateItemConfig() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        SurveyTemplateItem__c templateItem = SurveyTestUtils.buildDefaultTemplateItem(template).buildAndSave();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(templateItem);
        SurveyTemplateItemExtensions ext = new SurveyTemplateItemExtensions(stdCtrl);

        ext.setConfig();

        System.assertEquals(SurveyTestUtils.DEFAULT_SURVEY_CONFIGURATION_SIGNATURE, ext.templateItem.Config__c);
    }

    @isTest
    private static void shouldSaveTemplateItem() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        SurveyTemplateItem__c templateItem = SurveyTestUtils.buildDefaultTemplateItem(template).build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(templateItem);
        SurveyTemplateItemExtensions ext = new SurveyTemplateItemExtensions(stdCtrl);

        ext.templateItem.SurveyTemplate__c = template.Id;
        System.assertNotEquals(null, ext.save());

        System.assertEquals(1, [SELECT Count() FROM SurveyTemplateItem__c]);
    }

    @isTest
    private static void shouldSaveAndNewTemplateItem() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        SurveyTemplateItem__c templateItem = SurveyTestUtils.buildDefaultTemplateItem(template).build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(templateItem);
        SurveyTemplateItemExtensions ext = new SurveyTemplateItemExtensions(stdCtrl);

        ext.templateItem.SurveyTemplate__c = template.Id;
        System.assertNotEquals(null, ext.saveNew());
        
        System.assertEquals(1, [SELECT Count() FROM SurveyTemplateItem__c]);
    }

    @isTest
    private static void shouldGetExceptionWhenSaveWithoutTemplate() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        SurveyTemplateItem__c templateItem = SurveyTestUtils.buildDefaultTemplateItem(template).build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(templateItem);
        SurveyTemplateItemExtensions ext = new SurveyTemplateItemExtensions(stdCtrl);

        try {
            ext.save();
        } catch(DmlException e) {
            System.assert(false, 'Should throw exception when request data are invalid!');
        }
    }

    @isTest
    private static void shouldGetExceptionWhenSaveNewWithoutTemplate() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('surveyTemplateTest').buildAndSave();
        SurveyTemplateItem__c templateItem = SurveyTestUtils.buildDefaultTemplateItem(template).build();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(templateItem);
        SurveyTemplateItemExtensions ext = new SurveyTemplateItemExtensions(stdCtrl);

        try {
            ext.saveNew();
        } catch(DmlException e) {
            System.assert(false, 'Should throw exception when request data are invalid!');
        }
    }
}