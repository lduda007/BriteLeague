/** @date 02/12/2015
 * @module BSS BriteSheetService
 * @author Piotr Pitera
 * @description BTN_BSS_Service class - class providing communication with BriteSheet API.
 */
global class BTN_BSS_Service {
    public static final String EQUALS = '=';
    public static final String AMPERSAND = '&';
    public static final String SLASH = '/';

    public static final String STATUS_SUCCESS = 'success';
    //defined endpoints
    public static final String ENDPOINT_GET_USERS = 'BS:users';
    public static final String ENDPOINT_SET_USER = 'BS:users';
    public static final String ENDPOINT_GET_CERTS = 'BS:certs';
    public static final String ENDPOINT_GET_PROJECTS = 'BS:projects';
    public static final String ENDPOINT_GET_ASSIGNMENTS = 'BS:assignments';
    public static final String ENDPOINT_GET_PROJECTROLES = 'BS:projectroles';
    public static final String ENDPOINT_GET_GEARS = 'BS:gears';
    public static final String ENDPOINT_SET_GEARS = 'BS:gears';
    public static final String ENDPOINT_RADCHECK = 'BS:radcheck';

    public static Map<String, String> ENDPOINT_PARAMS = new Map<String, String>{
            ENDPOINT_GET_ASSIGNMENTS => SLASH + DateTime.now().addDays(-7).format(System.Label.BSDateFormat),
            ENDPOINT_SET_USER => '',
            ENDPOINT_SET_GEARS => '',
            ENDPOINT_GET_CERTS => '',
            ENDPOINT_GET_PROJECTS => '',
            ENDPOINT_GET_PROJECTROLES => '',
            ENDPOINT_GET_USERS => '',
            ENDPOINT_RADCHECK => '',
            ENDPOINT_GET_GEARS => ''
    };
    public static final String JSON_CONTECT_TYPE = 'application/json; charset=utf-8';
    public static final String URLENCODED_CONTENT_TYPE = 'application/x-www-form-urlencoded';

    public static final String NEW_BS_RESPONSE_SUCCESS_STATUS = 'success';
    public static final String NEW_BS_RESPONSE_ERROR_STATUS = 'failure';
    public static final String NEW_BS_USER_RESPONSE_SUCCESS_MESSAGE = 'Dodano użytkownika';
    public static final String NEW_BS_GEAR_RESPONSE_SUCCESS_MESSAGE = 'Dodano sprzęt';

    /** @date 02/12/2015
    * @Author Piotr Pitera
    * @description getUserDetails method - calls BriteSheet and fetches all users' details.
    * @return List<BTN_BSS_DTO.User> - parsed resultset from BS service
    */
    public static List<BTN_BSS_DTO.User> getUserDetails() {
        return BTN_BSS_DTO.parseUser(call(ENDPOINT_GET_USERS));
    }

    /** @date 02/12/2015
    * @Author Piotr Pitera
    * @description getCertDetails method - calls BriteSheet and fetches all users' certificates details.
    * @return List<BTN_BSS_DTO.Cert> - parsed resultset from BS service
    */
    public static List<BTN_BSS_DTO.Cert> getCertDetails() {
        return BTN_BSS_DTO.parseCert(call(ENDPOINT_GET_CERTS));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description getAssignmentDetails returns list of DTO Assignments
     * @return List<BTN_BSS_DTO.Assignment>
    */
    public static List<BTN_BSS_DTO.Assignment> getAssignmentDetails() {
        return BTN_BSS_DTO.parseAssignment(call(ENDPOINT_GET_ASSIGNMENTS));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description getAssignmentDetails returns list of DTO Assignments
     * @return List<BTN_BSS_DTO.Assignment>
    */
    public static List<BTN_BSS_DTO.ProjectRole> getProjectRoleDetails() {
        return BTN_BSS_DTO.parseProjectRole(call(ENDPOINT_GET_PROJECTROLES));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description getProjectDetails returns list of DTO Projects
     * @return List<BTN_BSS_DTO.Project>
    */
    public static List<BTN_BSS_DTO.Project> getProjectDetails() {
        return BTN_BSS_DTO.parseProject(call(ENDPOINT_GET_PROJECTS));
    }

    public static String getRadcheck(String username) {
        ENDPOINT_PARAMS.put(ENDPOINT_RADCHECK, '?user=' + username);
        return BTN_BSS_DTO.parseRadcheck(call(ENDPOINT_RADCHECK, '', JSON_CONTECT_TYPE, false));
    }

    public static BTN_BSS_DTO.ResponseStatus setRadcheck(String username, String pin) {
        ConnectionProperty__c connection = initConnectionProperty(ENDPOINT_RADCHECK);

        String authorizationHeader = EncodingUtil.base64Encode(
                Blob.valueOf(connection.Username__c + ':' + connection.Password__c)
        );

        String response = new HttpRequestBuilder(connection.Endpoint__c)
            .header('Authorization', 'Basic ' + authorizationHeader)
            .header('Accept', 'application/json ; version=1')
            .header('Accept-Encoding', 'gzip,deflate')
            .param('user', username)
            .param('pin', pin)
            .put();

        return BTN_BSS_DTO.parseResponse(response);
    }

    public static List<BTN_BSS_DTO.Gear> getGears() {
        return BTN_BSS_DTO.parseGearList(call(ENDPOINT_GET_GEARS));
    }

    public static BTN_BSS_DTO.GearResponseStatus setGear(Map<String, String> gearData) {
        String gearParams = '';
        Boolean addAmpersand = false;
        for (String key : gearData.keySet()) {
            String value = gearData.get(key);
            if (addAmpersand) {
                gearParams += AMPERSAND;
            }
            String encodedValue = value;
            if (!BTN_ValidationHandler.isNull(value)) {
                encodedValue = EncodingUtil.URLENCODE(value, BTN_ConstantRepo.UTF_ENCODING);
            }
            gearParams += (key + EQUALS + encodedValue);
            addAmpersand = true;
        }
        return BTN_BSS_DTO.parseGearResponse(call(ENDPOINT_SET_GEARS, gearParams, URLENCODED_CONTENT_TYPE, false));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description setNewBSUser creates new User in BS. Returns status message.
      * Like: { "status" : "succes", "error" : "Dodano użytkownika" }
     * @return String - JSON with response
    */
    public static BTN_BSS_DTO.ResponseStatus sendToBSNewUser(Map<String, String> userData) {
        String userParams = '';
        Boolean addAmpersand = false;
        for (String key : userData.keySet()) {
            if (!BTN_ValidationHandler.isNull(userData.get(key))) {
                if (addAmpersand) {
                    userParams += AMPERSAND;
                }
                userParams += (key + EQUALS + EncodingUtil.URLENCODE(userData.get(key), BTN_ConstantRepo.UTF_ENCODING));
                addAmpersand = true;
            }
        }

        return
                BTN_BSS_DTO.parseResponse(
                        call(ENDPOINT_SET_USER, userParams, URLENCODED_CONTENT_TYPE, false)
                );
    }

    /** @date 02/12/2015
    * @Author Piotr Pitera
    * @description call method - calls BriteSheet endpoint defined in the parameter.
    * @param String endpoint to be called
    * @return String - rest response from web service
    */
    private static String call(String endpoint, String userData, String contentType, Boolean logErrors) {
        Http http = new Http();
        HTTPResponse res;
        String restResponse;
        try {
            res = http.send(buildHttpRequest(endpoint, userData, contentType));
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Exception thrown while sending request to BriteSheet: ' + ex.getMessage());
        }

        if ( res != null ) {
            restResponse = res.getBody();
        } else {
            BTN_LogUtils customLog = new BTN_LogUtils('BTN_BSS_Service');
            if (logErrors) {
                customLog.error(System.label.BSSCallError, BTN_Utils.getCurrentUser().Id);
            }
            System.debug(LoggingLevel.ERROR, restResponse);
        }
        return restResponse;
    }

    /** @date 02/12/2015
    * @Author Piotr Pitera
    * @description call method - calls BriteSheet endpoint defined in the parameter.
    * @param String endpoint to be called
    * @return String - rest response from web service
    */
    private static String call(String endpoint) {
        return call(endpoint, '', JSON_CONTECT_TYPE, true);
    }

    /** @date 02/12/2015
    * @Author Piotr Pitera
    * @description buildHttpRequest method - builds and returns HttpRequest with BriteSheet set up and endpoint defined.
    * @param String endpoint to be called
    * @param String body for request
    * @param String contentType Request Content Type(body)
    * @return HttpRequest - rest response from web service
    */
    private static HttpRequest buildHttpRequest(String endpoint, String body, String contentType) {
        ConnectionProperty__c connection = initConnectionProperty(endpoint);

        Blob headerValue = Blob.valueOf(connection.Username__c + ':' + connection.Password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(connection.Endpoint__c + ENDPOINT_PARAMS.get(endpoint));
        req.setHeader('Authorization', authorizationHeader);
        if (!String.isBlank(body)) {
            req.setBody(body);
        }
        req.setHeader('Accept', 'application/json ; version=1');
        req.setHeader('content-type', contentType);
        req.setHeader('Accept-Encoding', 'gzip,deflate');
        return req;
    }

    private static ConnectionProperty__c initConnectionProperty(String name) {
        ConnectionProperty__c connection = null;

        List<ConnectionProperty__c> connections = [
                SELECT
                        Username__c, Password__c, Endpoint__c
                FROM
                        ConnectionProperty__c
                WHERE
                        Name = :name
        ];

        if (connections.size() != 1) {
            if (!Test.isRunningTest()) {
                throw new BTN_Exception('The connection configuration is wrong or missing!');
            } else {
                connections = new List<ConnectionProperty__c>{
                        new ConnectionProperty__c(
                                Name = 'BS:users',
                                Username__c = 'SFDC',
                                Password__c = 'SFDC',
                                Endpoint__c = 'https://bs.britenet.com.pl/api/users'
                        ),
                        new ConnectionProperty__c(
                                Name = 'BS:gears',
                                Username__c = 'SFDC',
                                Password__c = 'SFDC',
                                Endpoint__c = 'https://bs.britenet.com.pl/api/gears'
                        )
                };
            }
        }

        connection = connections.get(0);

        return connection;
    }
}