@RestResource(urlMapping='/survey-rest-api/*')
global with sharing class SurveyRESTApi {

    final static private String GET_USERS = 'getusers';
    final static private String GET_TREE_CATEGORIES = 'getcategories';
    final static private String URL_MAPPING = 'survey-rest-api';

    @HttpGet
    global static String getData() {
        String data = '';
        RestRequest req = RestContext.request;
        String[] dataFromUrl = req.requestURI.substring(req.requestURI.indexOf(URL_MAPPING) + URL_MAPPING.length() + 1).split('/');
        if (dataFromUrl[0] == GET_USERS) {
            data = JSON.serialize(AchievementSurveyUtils.getEmployees(null));
        } else if (dataFromUrl[0] == GET_TREE_CATEGORIES) {
            data = JSON.serialize(AchievementService.getCategoriesTree());
        }
        return data;
    }
}