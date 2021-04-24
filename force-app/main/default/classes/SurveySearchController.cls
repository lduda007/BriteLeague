@RestResource(urlMapping='/searchContact/*')
global with sharing class SurveySearchController {

    @HttpPost 
    global static String search() {
        AchievementContactsSearchController.SearchCriteria criteria = (AchievementContactsSearchController.SearchCriteria) JSON.deserialize(RestContext.request.requestBody.tostring(), AchievementContactsSearchController.SearchCriteria.class);
        return JSON.serialize(AchievementContactsSearchController.search(criteria));
    }

    @HttpGet
    global static String getOptions() {
        return JSON.serialize(AchievementContactsSearchController.getOptions());
    }
}