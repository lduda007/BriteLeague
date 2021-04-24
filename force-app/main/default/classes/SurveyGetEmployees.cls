@RestResource(urlMapping='/getusers/*')
global with sharing class SurveyGetEmployees {
    @HttpGet
    global static String getUsers() {
        return JSON.serialize(AchievementSurveyUtils.getEmployees(null));
    }
}