@RestResource(urlMapping='/survey/*')
global with sharing class SurveyController {

    final static private String GET_TEMPLATES_INFO = 'gettemplatesinfo';
    final static private String GET_TEMPLATE = 'gettemplate';
    final static private String GET_SURVEY = 'getsurvey';
    final static private String GET_USERS = 'getusers';
    final static private String URL_MAPPING = 'survey';

    @HttpPost
    global static String saveSurvey() {
        return JSON.serialize(SurveyFrontController.getInstance().saveSurvey(RestContext.request.requestBody.tostring()));
    }

    @HttpGet
    global static String getData() {
        String data = '';
        try {
            RestRequest req = RestContext.request;
            String[] dataFromUrl = req.requestURI.substring(req.requestURI.indexOf(URL_MAPPING) + URL_MAPPING.length() + 1).split('/');
            if (dataFromUrl[0] == GET_TEMPLATES_INFO) {
                SurveyUtils.Request request = new SurveyUtils.Request(dataFromUrl[1]);
                data = JSON.serialize(SurveyFrontController.getInstance().getTemplatesInfo(request));
            } else if (dataFromUrl[0] == GET_TEMPLATE) {
                SurveyUtils.TemplateRequest request = new SurveyUtils.TemplateRequest(dataFromUrl[1], dataFromUrl[2]);
                data = JSON.serialize(SurveyFrontController.getInstance().getTemplate(request));
            } else if (dataFromUrl[0] == GET_SURVEY) {
                SurveyUtils.SurveyRequest request = new SurveyUtils.SurveyRequest(dataFromUrl[1], dataFromUrl[2], dataFromUrl[3]);
                data = JSON.serialize(SurveyFrontController.getInstance().getSurvey(request));
            }
        } catch (Exception e) {
            throw wrappExeption(e);
        }
        return data;
    }

    private static Exception wrappExeption(Exception e) {
       if (e instanceof SurveyUtils.SurveyException) {
           e = new SurveyUtils.SurveyException(((SurveyUtils.SurveyException)e).toJSON());
       } else {
           e = new SurveyUtils.SurveyException(JSON.serialize(new Map<String, Object> {
               'type' => e.getTypeName(),
               'message' => e.getMessage(),
               'lineNumber' => e.getLineNumber(),
               'stack' => e.getStackTraceString()
           }));
       }
       return e;
   }
}