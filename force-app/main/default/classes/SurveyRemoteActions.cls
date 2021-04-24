public with sharing class SurveyRemoteActions {

    @RemoteAction
    public static List<SurveyModel.TemplateInfo> getTemplatesInfo(SurveyUtils.Request request) {
        return SurveyFrontController.getInstance().getTemplatesInfo(request);
    }

    @RemoteAction 
    public static SurveyModel.Template getTemplate(SurveyUtils.TemplateRequest request) {
        return SurveyFrontController.getInstance().getTemplate(request);
    }

    @RemoteAction 
    public static SurveyModel.Survey getSurvey(SurveyUtils.SurveyRequest request) {
        return SurveyFrontController.getInstance().getSurvey(request);
    }

    @RemoteAction 
    public static SurveyModel.Survey saveSurvey(String rawSurvey) {
        return SurveyFrontController.getInstance().saveSurvey(rawSurvey);
    }

    @RemoteAction 
    public static Map<String, AchievementService.CategoryHierarchy> getCategoriesTree() {
        return AchievementService.getCategoriesTree();
    }
}