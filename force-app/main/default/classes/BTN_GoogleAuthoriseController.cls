/**
 * @author Wojciech Mazur
 * @date   2016-11-10
 * @description handles google user integration
*/
public class BTN_GoogleAuthoriseController {

    public Boolean googleConfSet {get;set;}
    public Boolean integrationComplete{get;set;}
    private string googleClientId {get;set;}
    private string googleSecret {get;set;}
    private string googleRedirect {get;set;}
    public string accessCode{get;set;}
    
     public BTN_GoogleAuthoriseController (){
        accessCode = apexpages.currentpage().getparameters().get('code');
        integrationComplete = false;
        BTN_BriteCRM_settings__c briteCSGoogleSecret = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_SECRET);
        BTN_BriteCRM_settings__c briteCSGoogleId = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_CLIENT_ID);
        BTN_BriteCRM_settings__c briteCSGoogleRedirect = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_REDIRECT);
        BTN_BriteCRM_settings__c briteCSGoogleRedirectCommunity = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_REDIRECT_COMMUNITY);
        BTN_DAO_User userDao = new BTN_DAO_User();
        if(briteCSGoogleSecret !=null && briteCSGoogleId!=null && briteCSGoogleRedirect!=null && briteCSGoogleRedirectCommunity!=null){
        	if(userDao.isCommunityUser(UserInfo.getUserId())){
        		googleRedirect = briteCSGoogleRedirectCommunity.Value__c;
        	}else{
        		googleRedirect = briteCSGoogleRedirect.Value__c;	
        	}
            
            googleSecret = briteCSGoogleSecret.Value__c;
            googleClientId = briteCSGoogleId.Value__c;
            googleConfSet = true;
        }else{
            googleConfSet = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Google integration not configured, contact Adminstrator'));
        }        
    }
    
    public pagereference connect(){
     if(googleConfSet){
         String x=BTN_ConstantRepo.OAUTH_CODE_END_POINT_URL+'?scope='+EncodingUtil.urlEncode(BTN_ConstantRepo.SCOPE,'UTF-8')+'&state='+EncodingUtil.urlEncode(BTN_ConstantRepo.STATE,'UTF-8')+'&redirect_uri='+EncodingUtil.urlEncode(googleRedirect,'UTF-8')+'&response_type=code&client_id='+googleClientId+'&approval_prompt='+BTN_ConstantRepo.APPROVAL_PROMPT+'&access_type=offline';
         pagereference p=new pagereference(x);
         return p;
     }
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Google integration not configured, contact Adminstrator'));
     return null;     
   }
   
   public pagereference requestTokens(){
        if(!googleConfSet){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Google integration not configured, contact Adminstrator'));
            return null;
        }
                // Instantiate a new http object
        Http h = new Http();
        String body='code='+accessCode+'&client_id='+googleClientId+'&client_secret='+googleSecret+'&redirect_uri='+googleRedirect+'&'+BTN_ConstantRepo.GRANT_TYPE_AUTH_CODE;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BTN_ConstantRepo.OAUTH_TOKEN_URL);
        req.setHeader(BTN_GoogleCalendarHandler.HTTP_HEADER_CONTENTTYPE,'application/x-www-form-urlencoded');
        req.setMethod(BTN_GoogleCalendarHandler.HTTP_METHOD_POST);
        req.setBody(body);
        HttpResponse res = h.send(req);
        map<string, string> jsonValues = new map<string, string>();
        jsonValues = parseJSONToMap(res.getBody());
            if(jsonValues.containsKey('error')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Error while integrating your user with google. '+res.getBody()));
            }else{
                String accessToken = jsonValues.get(BTN_GoogleCalendarHandler.G_JSON_ACCESS_TOKEN);
                String refreshToken = jsonValues.get(BTN_GoogleCalendarHandler.G_JSON_REFRESH_TOKEN);
                String expiresIn = jsonValues.get(BTN_GoogleCalendarHandler.G_JSON_EXPIRES);
                String tokenType = jsonValues.get(BTN_GoogleCalendarHandler.G_JSON_TOKEN_TYPE);       
                //save tokens
                BTN_DAO_User userDao = new BTN_DAO_User();
                userDao.addGoogleFields();
                User currUser = userDao.findUserById(UserInfo.getUserId());
                currUser.GoogleAccessToken__c = accessToken;
                currUser.GoogleRefreshToken__c = refreshToken;
                currUser.GoogleTokenDate__c = system.now();
                currUser.GoogleTokenExpiresIn__c = Integer.valueOf(expiresIn);
                currUser.GoogleAuthCode__c = accessCode;
                update currUser;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Sukces'));
                integrationComplete = true;
            }       
        return null;
   
   }
   
    private map<string, string> parseJSONToMap(string JSONValue){
        JSONParser parser = JSON.createParser(JSONValue);
        map<string, string> jsonMap = new map<string, string>();
        string keyValue = '';
        string tempValue = '';
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                keyValue = parser.getText();
                parser.nextToken();
                tempValue = parser.getText();
                jsonMap.put(keyValue, tempValue);               
            }
        }
        return jsonMap;
    }
    
    
}