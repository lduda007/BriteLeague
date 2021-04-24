/**
 *  SurveyTemplate Trigger Test
 * @author Michał Banasik
 */
@isTest
private class SurveyTemplateTriggerTest {

    @isTest
    private static void shouldSetApiNameSpacesToUnderline() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('test template name with s p a c e s').buildAndSave();

        System.assertEquals('test_template_name_with_s_p_a_c_e_s', [SELECT ApiName__c FROM SurveyTemplate__c LIMIT 1].ApiName__c);
    }

    @isTest
    private static void shouldSetApiNameCharactersToLowerCase() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('TESTAPINAMEUPPERCASE').buildAndSave();

        System.assertEquals('testapinameuppercase', [SELECT ApiName__c FROM SurveyTemplate__c LIMIT 1].ApiName__c);
    }

    @isTest
    private static void shouldDeleteApiNamesSpecialCharacters() {
        SurveyTemplate__c template = new SurveyTestUtils.TemplateBuilder('special%name@characters#yoo!@#$%^&*()_-+=?/.,|;:]}[{').buildAndSave();

        System.assertEquals('specialnamecharactersyoo', [SELECT ApiName__c FROM SurveyTemplate__c LIMIT 1].ApiName__c);
    }
}