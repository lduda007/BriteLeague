@isTest
global class BTN_BSS_Mockup implements HttpCalloutMock  {
    public static final String USER_MODE = 'BSSUser';
    public static final String SET_NEW_USER_MODE = 'BSSNewUser';
    public static final String CERT_MODE = 'BSSCert';
    public static final String GEAR_MODE = 'BSSGear';
    public static final String SET_NEW_GEAR_MODE = 'BSSNewGear';
    public static final String PROJECT_MODE = 'BSSProject';
    public static final String ASSIGNMENT_MODE = 'BSSAssignment';
    public static final String PROJECTROLE_MODE = 'BSSprojectrole';
    public static Integer TEST_USER_QUANTITY = 500;
    public static Integer TEST_SET_USER_QUANTITY = 1;
    public static Integer TEST_GEAR_QUANTITY = 500;
    public static Integer TEST_SET_GEAR_QUANTITY = 1;
    public static Integer TEST_CERT_QUANTITY = 5;
    public static Integer TEST_PROJECT_QUANTITY = 500;
    public static Integer TEST_ASSIGNMENT_QUANTITY = 3000;
    public static Integer TEST_PROJECTROLE_QUANTITY = 50;
    public static final String NEW_BS_RESPONSE_ERROR = 'brak parametru ';
    public static final Integer NEW_BS_USER_RESPONSE_BS_USER_ID = 9999;
    public static final Integer NEW_BS_GEAR_RESPONSE_BS_GEAR_ID = 9999;
    public static final String NEW_BS_USER_RESPONSE_INTERNAL_SERVER_ERROR = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">';

    public static final Integer SUCCESS_STATUS_CODE = 200;
    public static final Integer INTERNAL_ERROR_STATUS_CODE = 500;
    public static final Integer NOTFOUND_ERROR_STATUS_CODE = 404;
    public static final Integer BADREQUEST_ERROR_STATUS_CODE = 400;

    private String dataForResponse{set; get;}
    private Integer responseStatusCode{set; get;}

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description Check param and creates test data.
     * @param mode determinates usage of Mockup.
     * @param responseStatusCode determinates response code ex. 200, 400, 404, 500.
     * @return
     */
    global BTN_BSS_Mockup(String mode, Integer responseStatusCode) {
        this.responseStatusCode = responseStatusCode;
        if (mode.equals(USER_MODE)) {
            this(USER_MODE, responseStatusCode, TEST_USER_QUANTITY);
        } else if (mode.equals(CERT_MODE)) {
            this(CERT_MODE, responseStatusCode, TEST_CERT_QUANTITY);
        } else if (mode.equals(GEAR_MODE)) {
            this(GEAR_MODE, responseStatusCode, TEST_GEAR_QUANTITY);
        } else if (mode.equals(PROJECT_MODE)) {
            this(PROJECT_MODE, responseStatusCode, TEST_PROJECT_QUANTITY);
        } else if (mode.equals(ASSIGNMENT_MODE)) {
            this(ASSIGNMENT_MODE, responseStatusCode, TEST_ASSIGNMENT_QUANTITY);
        } else if (mode.equals(SET_NEW_USER_MODE)) {
            // Response Success depends on Status Code
            this(SET_NEW_USER_MODE, responseStatusCode, TEST_SET_USER_QUANTITY);
        } else if (mode.equals(SET_NEW_GEAR_MODE)) {
            // Response Success depends on Status Code
            this(SET_NEW_GEAR_MODE, responseStatusCode, TEST_SET_GEAR_QUANTITY);
        } else if (mode.equals(PROJECTROLE_MODE)) {
            // Response Success depends on Status Code
            this(PROJECTROLE_MODE, responseStatusCode, TEST_PROJECTROLE_QUANTITY);
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description Check param and creates test data.
     * @param mode determinates usage of Mockup.
     * @param responseStatusCode determinates response code ex. 200, 400, 404, 500.
     * @return
     */
    global BTN_BSS_Mockup(String mode, Integer responseStatusCode, Integer dataLength) {
        this.responseStatusCode = responseStatusCode;
        if (mode.equals(USER_MODE)) {
            dataForResponse = this.generateUserJSON(dataLength);
        } if (mode.equals(GEAR_MODE)) {
            dataForResponse = this.generateGearJSON(dataLength);
        } else if (mode.equals(CERT_MODE)) {
            dataForResponse = this.generateCertJSON(dataLength);
        } else if (mode.equals(PROJECT_MODE)) {
            dataForResponse = this.generateProjectJSON(dataLength);
        } else if (mode.equals(ASSIGNMENT_MODE)) {
            dataForResponse = this.generateAssignmentJSON(dataLength);
        } else if (mode.equals(SET_NEW_USER_MODE)) {
            dataForResponse = this.generateResponseForNewUser(dataLength);
        } else if (mode.equals(PROJECTROLE_MODE)) {
            dataForResponse = this.generateProjectRoleJSON(dataLength);
        } else if (mode.equals(SET_NEW_GEAR_MODE)) {
            dataForResponse = this.generateResponseForNewGear(dataLength);
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description respond for external webservice calls.
     * @param req input request from Salesforce. Captured by Mockup.
     * @return res response for request.
     */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(responseStatusCode);
        if (responseStatusCode == SUCCESS_STATUS_CODE) {
            res.setBody(dataForResponse);
        }
        return res;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description This method generates JSON with random BSS Cert data.
     * @param length number of Certs in output
     * @return String - JSON with BSS Certs
     */
    global String generateCertJSON(Integer length) {
        List<BTN_BSS_DTO.Cert> certList = new List<BTN_BSS_DTO.Cert>();
        BTN_BSS_DTO.Cert tmpCert;
        for (Integer i = 0; i < length; i++) {
            tmpCert = new BTN_BSS_DTO.Cert();
            tmpCert.user_mail = BTN_TestDataFactory.getRandomEmail();
            tmpCert.user_id = BTN_TestDataFactory.getGeneratedInteger(1, TEST_USER_QUANTITY);
            tmpCert.userfile_description = BTN_TestDataFactory.getGeneratedString(40);
            tmpCert.userfile_id = BTN_TestDataFactory.getGeneratedInteger(1, 1000);
            certList.add(tmpCert);
        }
        return JSON.serialize(certList);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description This method generates JSON with random BSS User data.
     * @param length number of Users in output
     * @return String - JSON with BSS Users
     */
    global String generateUserJSON(Integer length) {
        List<BTN_BSS_DTO.User> userList = new List<BTN_BSS_DTO.User>();
        BTN_BSS_DTO.User tmpUser;
        for (Integer i = 0; i < length; i++) {
            tmpUser = new BTN_BSS_DTO.User();
            tmpUser.user_mail = i + BTN_TestDataFactory.getRandomEmail();
            tmpUser.user_phone = BTN_TestDataFactory.getRandomPhone();
            tmpUser.user_guardian_id = BTN_TestDataFactory.getGeneratedInteger(10, 1000);
            tmpUser.user_leader_id = BTN_TestDataFactory.getGeneratedInteger(10, 1000);
            tmpUser.user_id = i;
            tmpUser.user_fname = BTN_TestDataFactory.getGeneratedString(40);
            tmpUser.user_lname = BTN_TestDataFactory.getGeneratedString(40) + i;
            tmpUser.user_deleted = false;
            tmpUser.user_join_date = BTN_TestDataFactory.getBSSRandomDate();
            tmpUser.user_lastatwork_date = BTN_TestDataFactory.getBSSRandomDate();
            tmpUser.user_end_date = BTN_TestDataFactory.getBSSRandomDate();
            userList.add(tmpUser);
        }

        return JSON.serialize(userList);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-05
     * @description This method generates JSON with random BSS Project data.
     * @param length number of Projects in output JSON String
     * @return String - JSON with BSS Projects
     */
    global String generateProjectJSON(Integer length) {
        List<BTN_BSS_DTO.Project> projectList = new List<BTN_BSS_DTO.Project>();
        BTN_BSS_DTO.Project tmpProject;
        for (Integer i = 0; i < length; i++) {
            tmpProject = new BTN_BSS_DTO.Project();
            tmpProject.project_id = i;
            tmpProject.company_id = BTN_TestDataFactory.getGeneratedInteger(1, 1000);
            tmpProject.company_name = BTN_ConstantRepo.BRITENET_ACCOUNT_NAME;
            tmpProject.project_name = BTN_TestDataFactory.getGeneratedString(80);
            tmpProject.project_type = BTN_TestDataFactory.getGeneratedString(50);
            tmpProject.project_code = BTN_TestDataFactory.getGeneratedString(4);
            tmpProject.project_archived = false;
            tmpProject.project_overtime_code = BTN_TestDataFactory.getGeneratedString(20);
            tmpProject.project_oncall_code = BTN_TestDataFactory.getGeneratedString(20);
            tmpProject.project_oncallwe_code = BTN_TestDataFactory.getGeneratedString(20);
            tmpProject.project_working_oncall_code = BTN_TestDataFactory.getGeneratedString(20);
            tmpProject.project_working_oncallwe_code = BTN_TestDataFactory.getGeneratedString(20);
            tmpProject.project_other_code = BTN_TestDataFactory.getGeneratedString(20);
            projectList.add(tmpProject);
        }
        return JSON.serialize(projectList);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-05
     * @description This method generates JSON with random BSS Assignment data.
     * @param length number of Assignments in output JSON String
     * @return String - JSON with BSS Assignments
     */
    global String generateAssignmentJSON(Integer length) {
        List<BTN_BSS_DTO.Assignment> assignmentList = new List<BTN_BSS_DTO.Assignment>();
        BTN_BSS_DTO.Assignment tmpAssignment;
        for (Integer i = 0; i < length; i++) {
            tmpAssignment = new BTN_BSS_DTO.Assignment();
            tmpAssignment.projectuser_id = i;
            tmpAssignment.projectuser_project_id = BTN_TestDataFactory.getGeneratedInteger(1, TEST_PROJECT_QUANTITY);
            tmpAssignment.projectuser_user_id = BTN_TestDataFactory.getGeneratedInteger(1, TEST_USER_QUANTITY);
            tmpAssignment.projectuser_asgn_end = BTN_TestDataFactory.getRandomDate();
            tmpAssignment.projectuser_asgn_start = BTN_TestDataFactory.getRandomDate();
            assignmentList.add(tmpAssignment);
        }
        return JSON.serialize(assignmentList);
    }

    global String generateGearJSON(Integer length) {
        List<BTN_BSS_DTO.Gear> gearsList = new List<BTN_BSS_DTO.Gear>();
        BTN_BSS_DTO.Gear tmpGear;
        for (Integer i = 0; i < length; i++) {
            tmpGear = new BTN_BSS_DTO.Gear();
            tmpGear.geartype_description = BTN_TestDataFactory.getGeneratedString(5);
            tmpGear.gear_company_name = BTN_TestDataFactory.getGeneratedString(5);
            tmpGear.gear_serial = BTN_TestDataFactory.getRandomSerialNumber();
            tmpGear.gear_btno = BTN_TestDataFactory.getRandomBTNId();
            tmpGear.gear_phone_no = BTN_TestDataFactory.getRandomPhone();
            tmpGear.gear_model = BTN_TestDataFactory.getGeneratedString(10);
            tmpGear.gear_desc = BTN_TestDataFactory.getGeneratedString(100);
            tmpGear.usergear_user_id = BTN_TestDataFactory.getGeneratedInteger(0, 999);
            tmpGear.gear_deleted = false;
            gearsList.add(tmpGear);
        }
        return JSON.serialize(gearsList);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-22
     * @description This method generates JSON with Response from Britesheet
     * @param length number of Responses - should be set to 1
     * @return String - JSON with Response
     */
    global String generateResponseForNewUser(Integer length) {
        String response;
        BTN_BSS_DTO.ResponseStatus tmpResponse;
        List<BTN_BSS_DTO.ResponseStatus> responseList;
        if (responseStatusCode == SUCCESS_STATUS_CODE) {
                tmpResponse = new BTN_BSS_DTO.ResponseStatus(
                        BTN_BSS_Service.NEW_BS_RESPONSE_SUCCESS_STATUS,
                        BTN_BSS_Service.NEW_BS_USER_RESPONSE_SUCCESS_MESSAGE,
                        NEW_BS_USER_RESPONSE_BS_USER_ID
                );
                //responseList = new List<BTN_BSS_DTO.ResponseStatus>();
                //responseList.add(tmpResponse);
                response = JSON.serialize(tmpResponse);
        } else if (responseStatusCode == BADREQUEST_ERROR_STATUS_CODE) {
                tmpResponse = new BTN_BSS_DTO.ResponseStatus(
                        BTN_BSS_Service.NEW_BS_RESPONSE_ERROR_STATUS,
                        NEW_BS_RESPONSE_ERROR,
                        NEW_BS_USER_RESPONSE_BS_USER_ID
                );
                //responseList = new List<BTN_BSS_DTO.ResponseStatus>();
                //responseList.add(tmpResponse);
                response = JSON.serialize(tmpResponse);
        } else {
            response = NEW_BS_USER_RESPONSE_INTERNAL_SERVER_ERROR;
        }
        return response;
    }

    global String generateResponseForNewGear(Integer length) {
        String response;
        BTN_BSS_DTO.GearResponseStatus tmpResponse;
        List<BTN_BSS_DTO.GearResponseStatus> responseList;
        if (responseStatusCode == SUCCESS_STATUS_CODE) {
            tmpResponse = new BTN_BSS_DTO.GearResponseStatus(
                    BTN_BSS_Service.NEW_BS_RESPONSE_SUCCESS_STATUS,
                    BTN_BSS_Service.NEW_BS_GEAR_RESPONSE_SUCCESS_MESSAGE,
                    NEW_BS_GEAR_RESPONSE_BS_GEAR_ID
            );
            response = JSON.serialize(tmpResponse);
        } else if (responseStatusCode == BADREQUEST_ERROR_STATUS_CODE) {
            tmpResponse = new BTN_BSS_DTO.GearResponseStatus(
                    BTN_BSS_Service.NEW_BS_RESPONSE_ERROR_STATUS,
                    NEW_BS_RESPONSE_ERROR,
                    NEW_BS_GEAR_RESPONSE_BS_GEAR_ID
            );
            response = JSON.serialize(tmpResponse);
        } else {
            response = NEW_BS_USER_RESPONSE_INTERNAL_SERVER_ERROR;
        }
        return response;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-05
     * @description This method generates JSON with random BSS ProjectRole Data.
     * @param length number of Project Roles in output JSON String
     * @return String - JSON with serialized BSS Project Role Map
     */
    global String generateProjectRoleJSON(Integer length) {
        Map<Integer, String> projectRoleMap = new Map<Integer, String>();
        for (Integer i = 0; i < length; i++) {
            projectRoleMap.put(i + 30, BTN_TestDataFactory.getGeneratedString(40));
        }
        return JSON.serialize(projectRoleMap);
    }
}