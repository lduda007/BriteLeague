@isTest
global class BTN_GoogleCalendarMock implements HttpCalloutMock {

    private String operation {get;set;}
    public static final String OP_CREATE_EVENT_SUCCESS = 'OP_C_E_S';
    public static final String OP_CREATE_EVENT_AUTH_FAIL = 'OP_C_E_A_F';
    public static final String TEST_CALENDAR_ID = 'TESTCalendarID';
    public static final String TEST_CALENDAR_ID_WITH_EVENTS = 'TESTCalendarIDWithEvents';

    global BTN_GoogleCalendarMock(String operation){
        this.operation = operation;

    }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
       if(OP_CREATE_EVENT_SUCCESS .equals(operation)){
           return respondCreateEventSuccess(req);
       }else if(OP_CREATE_EVENT_AUTH_FAIL .equals(operation)){
           return respondMockError(req);
       }else if(operation.contains(TEST_CALENDAR_ID)){
           if(req.getBody().contains(BTN_ConstantRepo.GRANT_TYPE_REFRESH_TOKEN)){
               return respondMockRefresh(req);
           }else if (req.getEndpoint().contains(BTN_GoogleCalendarHandler.GOOGLE_CALENDARS_ENDPOINT)){
               return respondMockCalendars(req);
           }
           else if (req.getEndpoint().contains(BTN_GoogleCalendarHandler.GOOGLE_CALENDAR_EVENTS_ENDPOINT)){
               return respondMockCalendarEvents(req);
           }
       }else{
           return respondUpdateDeleteEventSuccess(req,operation);
        }
       return respondMockError(req);
    }

    private HTTPResponse respondCreateEventSuccess(HTTPRequest req){
         // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals(BTN_GoogleCalendarHandler.GOOGLE_EVENTS_ENDPOINT, req.getEndpoint());
        System.assertEquals(BTN_GoogleCalendarHandler.HTTP_METHOD_POST, req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"xxxxxxx"}');
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse respondUpdateDeleteEventSuccess(HTTPRequest req,String method){
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals(BTN_GoogleCalendarHandler.GOOGLE_EVENTS_ENDPOINT+TEST_CALENDAR_ID, req.getEndpoint());
        System.assertEquals(method, req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"xxxxxxx"}');
        res.setStatusCode(200);
        return res;
    }

    private HTTPResponse respondMockError(HTTPRequest req){
        // Create a fake response
        if(req.getBody().contains('grant_type=refresh_token')){
            return respondMockRefresh(req);
        }
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+ BTN_GoogleCalendarHandler.GOOGLE_NO_AUTH_RESPONSE+'"MOCK_FAIL":"something is not ok"}' );
        res.setStatusCode(200);
        return res;
    }
    private HTTPResponse respondMockRefresh(HTTPRequest req){
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token" : "testToken","expires_in" : 3600,"token_type" : "Bearer"}');
        res.setStatusCode(200);
        return res;
    }
    private HTTPResponse respondMockCalendars(HTTPRequest req){
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"items":[{"kind":"calendar#calendarListEntry","id":"'+TEST_CALENDAR_ID+'","summary":"Salka .NET (Morwowa, Lublin)","location":"Morwowa, Lublin","timeZone":"Europe/Warsaw","selected":true}]}');
        res.setStatusCode(200);
        return res;
    }
    private HTTPResponse respondMockCalendarEvents(HTTPRequest req){
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(operation.equals(TEST_CALENDAR_ID_WITH_EVENTS)){
            res.setBody('{"items":[{"status":"confirmed","created":"2015-02-02T21:20:01.000Z","updated":"2015-02-04T12:04:27.421Z","summary":"Test Event","description":"Test Event","start":{"dateTime":"2015-02-05T11:00:00+01:00"},"end":{"dateTime":"2015-02-05T11:30:00+01:00"},"attendees":[{"email":"britenet.com.pl_test@group.calendar.google.com","displayName":"Salka .NET (Morwowa, Lublin)","resource":true,"responseStatus":"accepted"}]}]}');
        }else{
            res.setBody('{"items":[]}');
        }
        res.setStatusCode(200);
        return res;
    }
    public static void prepareGoogleCalendarSettings (){
        List<BTN_BriteCRM_settings__c> settingList = new  List<BTN_BriteCRM_settings__c>();
        settingList.add( new BTN_BriteCRM_settings__c(Name = BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_SECRET, Value__c = 'fakeSecret'));
        settingList.add( new BTN_BriteCRM_settings__c(Name = BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_CLIENT_ID, Value__c = 'fakeId'));
        settingList.add( new BTN_BriteCRM_settings__c(Name = BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_REDIRECT, Value__c = 'fakeUrl'));
        settingList.add( new BTN_BriteCRM_settings__c(Name = BTN_ConstantRepo.CUSTOM_SETTING_KEY_GOOGLE_REDIRECT_COMMUNITY, Value__c = 'fakeUrl'));
        insert settingList;
    }
}