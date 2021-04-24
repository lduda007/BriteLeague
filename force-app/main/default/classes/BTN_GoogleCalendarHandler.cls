/**
 * @author Wojciech Mazur
 * @date   2016-11-08
 * @description handles google events integration
*/
global class BTN_GoogleCalendarHandler implements Database.batchable<BTN_Event__c>,Database.Stateful,Database.AllowsCallouts {

    public string accessToken{get;set;}
    public string refreshToken {get;set;}
    public string expiresIn{get;set;}
    public string tokenType{get;set;}
    public string accessCode{get;set;}

    public Boolean googleConfSet {get;set;}
    private string googleClientId {get;set;}
    private string googleSecret {get;set;}
    private string googleRedirect {get;set;}
    private BTN_DAO_User userDao = new BTN_DAO_User();
    private List<BTN_Event__c> eventsToProcess {get;set;}
    private Integer retryCounter = 0;
    private list<User> usersToUpdate = new List<User>();
    private list<BTN_Event__c> eventsToUpdate = new List<BTN_Event__c>();

    public static Boolean SKIP_BTN_GoogleCalendarHandler = false;
    public static String IS_INSERT = 'INS';
    public static String IS_UPDATE = 'UPD';
    public static String IS_DELETE = 'DEL';
    private String operation {get;set;}

    public static final String GOOGLE_EVENTS_ENDPOINT = 'https://www.googleapis.com/calendar/v3/calendars/primary/events/';
    public static final String GOOGLE_CALENDARS_ENDPOINT = 'https://www.googleapis.com/calendar/v3/users/me/calendarList';
    public static final String GOOGLE_CALENDAR_EVENTS_ENDPOINT = 'https://www.googleapis.com/calendar/v3/calendars/';
    public static final String GOOGLE_NO_AUTH_RESPONSE = '"reason": "authError",';
    public static final String G_JSON_ACCESS_TOKEN = 'access_token';
    public static final String G_JSON_REFRESH_TOKEN = 'refresh_token';
    public static final String G_JSON_EXPIRES = 'expires_in';
    public static final String G_JSON_TOKEN_TYPE = 'token_type';
    public static final String G_JSON_ERROR = 'error';
    public static final String HTTP_METHOD_POST = 'POST';
    public static final String HTTP_METHOD_GET = 'GET';
    public static final String HTTP_METHOD_PUT = 'PUT';
    public static final String HTTP_METHOD_DELETE = 'DELETE';
    public static final String HTTP_HEADER_AUTHORIZATION = 'Authorization';
    public static final String HTTP_HEADER_CONTENTTYPE = 'Content-Type';
    public static final String HTTP_HEADER_CONTENTLENGTH = 'Content-length';
    public static final String HTTP_HEADER_BEARER = 'Bearer ';
    public static final String HTTP_HEADER_JSON_UTF8= 'application/json; charset=UTF-8';

    public BTN_GoogleCalendarHandler(List<BTN_Event__c> eventsToProcess, String operation){
    	userDao.addGoogleFields();
        this.eventsToProcess = eventsToProcess;
        this.operation = operation;
        BTN_BriteCRM_settings__c briteCSGoogleSecret = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_SECRET);
        BTN_BriteCRM_settings__c briteCSGoogleId = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_CLIENT_ID);
        BTN_BriteCRM_settings__c briteCSGoogleRedirect = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_REDIRECT);
        BTN_BriteCRM_settings__c briteCSGoogleRedirectCommunity = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_REDIRECT_COMMUNITY);
        if(briteCSGoogleSecret !=null && briteCSGoogleId!=null && briteCSGoogleRedirect!=null && briteCSGoogleRedirectCommunity!=null){
        	if (userDao.isCommunityUser(UserInfo.getUserId())) {
        		googleRedirect = briteCSGoogleRedirectCommunity.Value__c;
        	} else {
        		googleRedirect = briteCSGoogleRedirect.Value__c;
        	}
            googleSecret = briteCSGoogleSecret.Value__c;
            googleClientId = briteCSGoogleId.Value__c;
            googleConfSet = true;
        }else{
            googleConfSet = false;
            system.debug('WARNING Google - no configuration set');
        }
    }

    global List<BTN_Event__c> start(Database.BatchableContext info){
        if(!googleConfSet){
            system.debug('WARNING Google - no configuration set (createGoogleEvents)');
            return new List<BTN_Event__c>();
        }

        if(BTN_GoogleCalendarHandler.IS_DELETE != operation){
	        //query more data for event(s)
	        BTN_DAO_Event eventDao = new BTN_DAO_Event();
	        eventDao.addInterviewedContactFields().addIntegratedUserFields().addInterviewerUsersFields();
	        List<BTN_Event__c> events = eventDao.findEventsByIds((new Map<Id,BTN_Event__c>(eventsToProcess )).keySet());
	        return events;
        }

        //else
        return eventsToProcess;

    }
    global void execute(Database.BatchableContext info, List<BTN_Event__c> scope){
        if(BTN_GoogleCalendarHandler.IS_INSERT == operation)
            createGoogleEvents(scope);

        if(BTN_GoogleCalendarHandler.IS_UPDATE == operation)
            updateGoogleEvents(scope);

        if(BTN_GoogleCalendarHandler.IS_DELETE == operation)
            deleteGoogleEvents(scope);
    }

    global void finish(Database.BatchableContext info){
        if(usersToUpdate.size()>0)
            update usersToUpdate;

        if(eventsToUpdate.size()>0){
            BTN_GoogleCalendarHandler.SKIP_BTN_GoogleCalendarHandler = true;
            update eventsToUpdate;
        }
       }

    /**
     * @author Wojciech Mazur
     * @date   2016-11-08
     * @description creates events in google calendar. Events are created for interviewer user if the user has google integration set up.
    */
    public void createGoogleEvents(List<BTN_Event__c> evs){
        for(BTN_Event__c e:evs){
            if (String.isNotBlank(e.Meeting_Room__c)) {
                addGoogleCalendarEntry(e, null, e.Meeting_Room__c);
            } else {
                addGoogleCalendarEntry(e, null, null);
            }
        }
    }

    public void updateGoogleEvents(List<BTN_Event__c> evs){
        for(BTN_Event__c e:evs){

            if (String.isNotBlank(e.Meeting_Room__c)) {
                updateGoogleCalendarEntry(e, null, e.Meeting_Room__c);
            } else {
                updateGoogleCalendarEntry(e, null, null);
            }
        }
    }

    public void deleteGoogleEvents(List<BTN_Event__c> evs){
    	for(BTN_Event__c e:evs){
            deleteGoogleCalendarEntry(e, null);
        }
    }

    public void deleteGoogleCalendarEntry(BTN_Event__c event, String refreshedAccessToken){
    	 if(event.GoogleId__c == null || event.GoogleId__c.trim().length()==0)
            return;

        Http h = new Http();
        HttpRequest req = new HttpRequest();

        String endpoint = GOOGLE_EVENTS_ENDPOINT + event.GoogleId__c;
        req.setEndpoint(endpoint);

        User u = userDao.findUserById(event.UserUsedForGoogleIntegration__c);
        String accessTokenToUse = u.GoogleAccessToken__c;
        if(refreshedAccessToken != null){
            accessTokenToUse= refreshedAccessToken;
        }
        req.setHeader(HTTP_HEADER_AUTHORIZATION, HTTP_HEADER_BEARER + accessTokenToUse);
        req.setMethod(HTTP_METHOD_DELETE);
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        if(res.getBody().contains(GOOGLE_NO_AUTH_RESPONSE) && retryCounter<1){
            retryCounter++;
            deleteGoogleCalendarEntry(event,refreshToken(u));
        }
    }

    public void updateGoogleCalendarEntry(BTN_Event__c event, String refreshedAccessToken, String roomId){
        if(event.GoogleId__c == null || event.GoogleId__c.trim().length()==0)
            return;

        Http h = new Http();
        HttpRequest req = new HttpRequest();

        String endpoint = GOOGLE_EVENTS_ENDPOINT + event.GoogleId__c;
        req.setEndpoint(endpoint);

        String requestBody = buildCreateEventReqBody(event, roomId);
        req.setBody(requestBody);
        User integratedUser = event.UserUsedForGoogleIntegration__r;
        String accessTokenToUse = integratedUser.GoogleAccessToken__c;
        if(refreshedAccessToken != null){
            accessTokenToUse = refreshedAccessToken;
        }
        req.setHeader(HTTP_HEADER_AUTHORIZATION, HTTP_HEADER_BEARER + accessTokenToUse);
        req.setHeader(HTTP_HEADER_CONTENTLENGTH, string.ValueOf(requestBody.length()));
        req.setHeader(HTTP_HEADER_CONTENTTYPE, HTTP_HEADER_JSON_UTF8);
        req.setMethod(HTTP_METHOD_PUT);
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        if(res.getBody().contains(GOOGLE_NO_AUTH_RESPONSE) && retryCounter<1){
            updateGoogleCalendarEntry(event,refreshToken(integratedUser), roomId);
            retryCounter++;
        }
    }

    public void addGoogleCalendarEntry(BTN_Event__c event, String refreshedAccessToken, String roomId){
    	RecordType rtInterview = BTN_RecordTypeUtils.getRecordTypeCustomEventInterview();
    	if(rtInterview.Id != event.RecordTypeId)
    		return;

        Http h = new Http();
        HttpRequest req = new HttpRequest();

        String endpoint = GOOGLE_EVENTS_ENDPOINT;
        req.setEndpoint(endpoint);

        String requestBody = buildCreateEventReqBody(event, roomId);
        req.setBody(requestBody);
        User integratedUser = getFirstIntegratedUserForEvent(event);
        if(integratedUser == null){
        	system.debug('GOOGLE CREATE EVENT REQUEST SKIPPED: No integrated interviewer found');
        	return;
        }
        String accessTokenToUse = integratedUser.GoogleAccessToken__c;//event.Interviewer_user__r.GoogleAccessToken__c;
        if(refreshedAccessToken != null){
            accessTokenToUse= refreshedAccessToken;
        }
        req.setHeader(HTTP_HEADER_AUTHORIZATION, HTTP_HEADER_BEARER + accessTokenToUse);
        req.setHeader(HTTP_HEADER_CONTENTLENGTH, string.ValueOf(requestBody.length()));
        req.setHeader(HTTP_HEADER_CONTENTTYPE, HTTP_HEADER_JSON_UTF8);
        req.setMethod(HTTP_METHOD_POST);
        req.setTimeout(10000);
        HttpResponse res = h.send(req);
        if(res.getBody().contains(GOOGLE_NO_AUTH_RESPONSE) && retryCounter<1){
            addGoogleCalendarEntry(event,refreshToken(integratedUser), roomId);
            retryCounter++;
        }else{
            map<string, string> jsonValues = new map<string, string>();
            jsonValues = parseJSONToMap(res.getBody());
            event.GoogleId__c = jsonValues.get('id');
            event.UserUsedForGoogleIntegration__c = integratedUser.Id;
            eventsToUpdate.add(event);
        }
    }

    private User getFirstIntegratedUserForEvent(BTN_Event__c event){
    	if(event.Interviewer_user__r!=null && event.Interviewer_user__r.GoogleAccessToken__c != null)
    		return event.Interviewer_user__r;
    	if(event.Technical_Interviewer_User__r!=null && event.Technical_Interviewer_User__r.GoogleAccessToken__c != null)
    		return event.Technical_Interviewer_User__r;
        if(event.CreatedBy!=null && event.CreatedBy.GoogleAccessToken__c != null) {
            return event.CreatedBy;
        }
    	return null;
    }

    private String buildCreateEventReqBody(BTN_Event__c event, String roomId){
    	String evBody = event.Title__c+ '\\r\\n\\r\\n';
        Set<String> attendeeEmails = new  Set<String>();
     	if(event.Interviewer_user__r!=null){
            attendeeEmails.add( event.Interviewer_user__r.Email);
        }else if(event.Interviewer_Contact__r!=null){
            attendeeEmails.add(event.Interviewer_Contact__r.Email);
        }
    	if(event.Technical_Interviewer_User__r!=null){
            attendeeEmails.add( event.Technical_Interviewer_User__r.Email);
        }else if(event.Technical_Interviewer__r!=null){
            attendeeEmails.add(event.Technical_Interviewer__r.Email);
        }
        attendeeEmails.add(event.CreatedBy.Email);
     	evBody+= googleRedirect.split('apex/BTN_GoogleAuthorise')[0]+event.Id;
        String bodyRequest = '';
        bodyRequest = '{';
        bodyRequest += '\r\n';
        bodyRequest += '"summary": "[SF] Interview - '+event.Interviewed__r.FirstName+' '+event.Interviewed__r.LastName+'",';
        bodyRequest += '\r\n';
        bodyRequest += '"description": "'+evBody+'",';
        bodyRequest += '\r\n';
        bodyRequest += '"location": "'+event.Location__c+'",';
        bodyRequest += '\r\n';
        bodyRequest += '"start": {';
        bodyRequest += '\r\n';
        bodyRequest += '"dateTime": "'+event.Start_Time__c.formatGMT('YYYY-MM-dd')+'T'+event.Start_Time__c.formatGMT('HH:mm:ss')+'.000-00:00'+'",';
        bodyRequest += '\r\n';
        bodyRequest += '"timeZone": "GMT"';
        bodyRequest += '\r\n';
        bodyRequest += '},';
        bodyRequest += '\r\n';
        bodyRequest += '"end": {';
        bodyRequest += '\r\n';
        bodyRequest += '"dateTime": "'+event.End_Time__c.formatGMT('YYYY-MM-dd')+'T'+event.End_Time__c.formatGMT('HH:mm:ss')+'.000-00:00'+'",';
        bodyRequest += '\r\n';
        bodyRequest += '"timeZone": "GMT"';
        bodyRequest += '\r\n';
        bodyRequest += '},';
        bodyRequest += '"reminders": {';
        bodyRequest += '\r\n';
        bodyRequest += '"useDefault": "False",';
        bodyRequest += '\r\n';
        bodyRequest += '"overrides": [';
        bodyRequest += '\r\n';
        bodyRequest +=  '{"method": "email", "minutes": "60"},';
        bodyRequest += '\r\n';
        bodyRequest +=  '{"method": "popup", "minutes": "10"}';
        bodyRequest += '\r\n';
        bodyRequest += ']';
        bodyRequest += '\r\n';
        bodyRequest += ' }';
        if(!attendeeEmails.isEmpty()){
        	bodyRequest += ',\r\n';
	        bodyRequest += '"attendees": [';
	        bodyRequest += '\r\n';
	        Integer counter = 0;
            for(String contactEmail:attendeeEmails){
                if(counter>0){
                    bodyRequest += ',\r\n';
                }
                bodyRequest += '{';
                bodyRequest += '\r\n';
                bodyRequest += '"email": "'+contactEmail+'"';
                bodyRequest += '\r\n';
                bodyRequest += '}';
                bodyRequest += '\r\n';
                counter++;
            }
            if (String.isNotBlank(roomId)) {
                    bodyRequest += ',\r\n';
                    bodyRequest += '{';
                    bodyRequest += '\r\n';
                    bodyRequest += '"email": "'+roomId+'"';
                    bodyRequest += '\r\n';
                    bodyRequest += '}';
                    bodyRequest += '\r\n';
            }
	        bodyRequest += ']';
        }
        bodyRequest += '}';

        return bodyRequest;
    }

    private  String refreshToken(User u){
       if(!googleConfSet){
            system.debug('WARNING Google - no configuration set (refreshToken)');
            return null;
        }
        u = userDao.findUserById(u.Id);
        String storedRefreshCode = u.GoogleRefreshToken__c;
        Http h = new Http();
        String body='refresh_token='+storedRefreshCode+'&client_id='+googleClientId+'&client_secret='+googleSecret+'&redirect_uri='+googleRedirect+'&'+BTN_ConstantRepo.GRANT_TYPE_REFRESH_TOKEN;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BTN_ConstantRepo.OAUTH_TOKEN_URL);
        req.setHeader(HTTP_HEADER_CONTENTTYPE,'application/x-www-form-urlencoded');
        req.setMethod(HTTP_METHOD_POST);
        req.setBody(body);
        HttpResponse res = h.send(req);
        map<string, string> jsonValues = new map<string, string>();
        jsonValues = parseJSONToMap(res.getBody());
        if(jsonValues.containsKey(G_JSON_ERROR)){
            system.debug('ERROR Google refresh token error: '+res.getBody());
        }else{
            accessToken = jsonValues.get(G_JSON_ACCESS_TOKEN);
            refreshToken = jsonValues.get(G_JSON_REFRESH_TOKEN);
            expiresIn = jsonValues.get(G_JSON_EXPIRES);
            tokenType = jsonValues.get(G_JSON_TOKEN_TYPE);
            //save tokens
            u.GoogleAccessToken__c = accessToken;
            if(refreshToken!=null && refreshToken.trim().length()>0)
                u.GoogleRefreshToken__c = refreshToken;
            u.GoogleTokenDate__c = system.now();
            u.GoogleTokenExpiresIn__c = Integer.valueOf(expiresIn);
            usersToUpdate.add(u);
            return accessToken;
        }
        return null;
   }

   public static map<string, string> parseJSONToMap(string JSONValue){
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

    /**
     * @author Mateusz Przywara
     * @date   2016-12-23
     * @description getCalendarsForUser
     * @param u User should have access to Calendar
     * @return     Calendars in JSON like
        /*
            {
             "kind": "calendar#calendarList",
             "etag": "\"p32sdpv4uva4t20g\"",
             "nextSyncToken": "CLjc_J76idECEiBtYXRldXN6LnByenl3YXJhQGJyaXRlbmV0LmNvbS5wbA==",
             "items": [
                  {
                   "kind": "calendar#calendarListEntry",
                   "etag": "\"1482412467724000\"",
                   "id": "britenet.com.pl_6hus0ijpcq554lppuo3r346s54@group.calendar.google.com",
                   "summary": "Salka .NET (Morwowa, Lublin)",
                   "location": "Morwowa, Lublin",
                   "timeZone": "Europe/Warsaw",
                   "colorId": "22",
                   "backgroundColor": "#f691b2",
                   "foregroundColor": "#000000",
                   "accessRole": "reader",
                   "defaultReminders": []
                  }
             ]
            }
    */
    public static String getCalendarsForUser(User u) {
        //prepare data
        String googleSecret =
            BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_SECRET).Value__c;
        String googleClientId =
            BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_CLIENT_ID).Value__c;
        //send Request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        // TODO Getter for fresh User Access token!!! It should be cached to reduce SOQL querries and callouts.
        req.setHeader(BTN_GoogleCalendarHandler.HTTP_HEADER_AUTHORIZATION, BTN_GoogleCalendarHandler.HTTP_HEADER_BEARER + u.GoogleAccessToken__c);
        req.setHeader(BTN_GoogleCalendarHandler.HTTP_HEADER_CONTENTTYPE, BTN_GoogleCalendarHandler.HTTP_HEADER_JSON_UTF8);
        req.setEndpoint(BTN_GoogleCalendarHandler.GOOGLE_CALENDARS_ENDPOINT);
        req.setMethod(BTN_GoogleCalendarHandler.HTTP_METHOD_GET);
        HttpResponse res = h.send(req);
        return res.getBody();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-12-23
     * @description getCalendarsForUser
     * @param u User should have access to Calendar
     * @param calendarId Google Id of Calendar
     * @return     Events in JSON in standard Calendar format
        /*
            {
             "kind": "calendar#calendarList",
             "etag": "\"p32sdpv4uva4t20g\"",
             "nextSyncToken": "CLjc_J76idECEiBtYXRldXN6LnByenl3YXJhQGJyaXRlbmV0LmNvbS5wbA==",
             "items": [
                  {
                   "kind": "calendar#calendarListEntry",
                   "etag": "\"1482412467724000\"",
                   "id": "britenet.com.pl_6hus0ijpcq554lppuo3r346s54@group.calendar.google.com",
                   "summary": "Salka .NET (Morwowa, Lublin)",
                   "location": "Morwowa, Lublin",
                   "timeZone": "Europe/Warsaw",
                   "colorId": "22",
                   "backgroundColor": "#f691b2",
                   "foregroundColor": "#000000",
                   "accessRole": "reader",
                   "defaultReminders": []
                  }
             ]
            }
    */
    public static String getEvents(User u, String calendarId) {
        //send Request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        // TODO Getter for fresh User Access token!!! It should be cached to reduce SOQL querries and callouts.
        req.setHeader(BTN_GoogleCalendarHandler.HTTP_HEADER_AUTHORIZATION, BTN_GoogleCalendarHandler.HTTP_HEADER_BEARER + u.GoogleAccessToken__c);
        req.setHeader(BTN_GoogleCalendarHandler.HTTP_HEADER_CONTENTTYPE, BTN_GoogleCalendarHandler.HTTP_HEADER_JSON_UTF8);
        req.setEndpoint(BTN_GoogleCalendarHandler.GOOGLE_CALENDAR_EVENTS_ENDPOINT + calendarId + '/events');
        req.setMethod(BTN_GoogleCalendarHandler.HTTP_METHOD_GET);
        HttpResponse res = h.send(req);
        return res.getBody();
    }

    public static String getEvents(User u, String calendarId, Map<String, String> params) {
        String paramsUrl = '';
        if (params.isEmpty() == false) {
            for (String paramName : params.keySet()) {
                String paramValue = params.get(paramName);

                paramsUrl += String.isBlank(paramsUrl) ? '?' : '&';
                paramsUrl += paramName + '=' + paramValue;
            }
        }
        //send Request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        // TODO Getter for fresh User Access token!!! It should be cached to reduce SOQL querries and callouts.
        req.setHeader(BTN_GoogleCalendarHandler.HTTP_HEADER_AUTHORIZATION, BTN_GoogleCalendarHandler.HTTP_HEADER_BEARER + u.GoogleAccessToken__c);
        req.setHeader(BTN_GoogleCalendarHandler.HTTP_HEADER_CONTENTTYPE, BTN_GoogleCalendarHandler.HTTP_HEADER_JSON_UTF8);
        req.setEndpoint(BTN_GoogleCalendarHandler.GOOGLE_CALENDAR_EVENTS_ENDPOINT + calendarId + '/events' + paramsUrl);
        req.setMethod(BTN_GoogleCalendarHandler.HTTP_METHOD_GET);
        HttpResponse res = h.send(req);
        return res.getBody();
    }
    public static  User refreshTokenForOneUser(User givenUser){
        BTN_DAO_User userDao = new BTN_DAO_User();
        Boolean googleConfSet;
        String googleRedirect;
        BTN_BriteCRM_settings__c briteCSGoogleSecret = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_SECRET);
        BTN_BriteCRM_settings__c briteCSGoogleId = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_CLIENT_ID);
        BTN_BriteCRM_settings__c briteCSGoogleRedirect = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_REDIRECT);
        BTN_BriteCRM_settings__c briteCSGoogleRedirectCommunity = BTN_BriteCRM_settings__c.getValues(BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_REDIRECT_COMMUNITY);
        if(briteCSGoogleSecret !=null && briteCSGoogleId!=null && briteCSGoogleRedirect!=null && briteCSGoogleRedirectCommunity!=null){
            if (userDao.isCommunityUser(givenUser.Id)) {
                googleRedirect = briteCSGoogleRedirectCommunity.Value__c;
            } else {
                googleRedirect = briteCSGoogleRedirect.Value__c;
            }
            googleConfSet = true;
        }else{
            googleConfSet = false;
            system.debug('WARNING Google - no configuration set');
        }
        String storedRefreshCode = givenUser.GoogleRefreshToken__c;
        Http h = new Http();
        String body='refresh_token='+storedRefreshCode+'&client_id='+briteCSGoogleId.Value__c+'&client_secret='+briteCSGoogleSecret.Value__c+'&redirect_uri='+googleRedirect+'&'+BTN_ConstantRepo.GRANT_TYPE_REFRESH_TOKEN;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BTN_ConstantRepo.OAUTH_TOKEN_URL);
        req.setHeader(HTTP_HEADER_CONTENTTYPE,'application/x-www-form-urlencoded');
        req.setMethod(HTTP_METHOD_POST);
        req.setBody(body);
        HttpResponse res = h.send(req);
        map<string, string> jsonValues = new map<string, string>();
        jsonValues = parseJSONToMap(res.getBody());
        if(jsonValues.containsKey(G_JSON_ERROR)){
            system.debug('ERROR Google refresh token error: '+res.getBody());
        }else{
            String accessToken = jsonValues.get(G_JSON_ACCESS_TOKEN);
            String refreshToken = jsonValues.get(G_JSON_REFRESH_TOKEN);
            String expiresIn = jsonValues.get(G_JSON_EXPIRES);
            String tokenType = jsonValues.get(G_JSON_TOKEN_TYPE);
            //save tokens
            givenUser.GoogleAccessToken__c = accessToken;
            if(refreshToken!=null && refreshToken.trim().length()>0)
                givenUser.GoogleRefreshToken__c = refreshToken;
            givenUser.GoogleTokenDate__c = system.now();
            givenUser.GoogleTokenExpiresIn__c = Integer.valueOf(expiresIn);
        }
        return givenUser;
    }

}