/** @date 02/12/2015
 * @module BSS BriteSheetService
 * @author Piotr Pitera
 * @description BTN_BSS_DTO class - class cointaining DTOs and parsing methods used in communication with BriteSheet.
 */
global class BTN_BSS_DTO {

    public static final String STATUS_SUCCESS = 'success';
   /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description Assignment - Data Transfer Object to represent BSS Project Assignment
    */
    global class Assignment {
        public Integer projectuser_id;
        public Date projectuser_asgn_end;
        public Date projectuser_asgn_start;
        public Integer projectuser_project_id;
        public Integer projectuser_user_id;
        public Integer projectuser_asgn_rate;
    }

    /** @date 02/12/2015
     * @Author Piotr Pitera
     * @description User class - Data Transfer Object to represent BS User.
     */
    global class User {
        public Integer user_id;
        public Integer user_guardian_id;
        public Integer user_leader_id;
        public String user_fname;
        public String user_lname;
        public String user_mail;
        public String user_phone;
        public String user_location;
        public String projectrole_desc;
        public Boolean user_deleted;
        public String user_join_date;
        public String user_lastatwork_date;
        public String user_end_date;
    }

    /** @date 02/12/2015
     * @Author Piotr Pitera
     * @description Cert class - Data Transfer Object to represent BS Certificate.
     */
    public class Cert {
        public Integer user_id;
        public String user_mail;
        public String userfile_description;
        public Integer userfile_id;
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-09-27
     * @description ProjectRole - Data Transfer Object to represent BS User ProjectRole
    */
    global class ProjectRole {
        public Integer projectrole_id;
        public String projectrole_name;

        public ProjectRole(Integer bsProjectRoleId, String name) {
            this.projectrole_id = bsProjectRoleId;
            this.projectrole_name = name;
        }
    }

    /*
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description Project - Data Transfer Object to represent BSS Project
    */
    global class Project {
        public Integer project_id;
        public Integer company_id;
        public String company_name;
        public String project_name;
        public String project_type;
        public String project_code;
        public Boolean project_archived;
        public String project_overtime_code;
        public String project_oncall_code;
        public String project_oncallwe_code;
        public String project_working_oncall_code;
        public String project_working_oncallwe_code;
        public String project_other_code;
        public String sale_user_id;
        public String sale_user_fname;
        public String sale_user_lname;
        public String rd_user_id;
        public String rd_user_fname;
        public String rd_user_lname;
    }

    global class Gear {
        public Integer gear_id;
        public String geartype_description;
        public String gear_company_name;
        public String gear_serial;
        public String gear_btno;
        public String gear_phone_no;
        public String gear_model;
        public String gear_desc;
        public Integer usergear_user_id;
        public Boolean gear_deleted;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-19
     * @description ResponseStatus - Data Transfer Object representing response (Success or Not) from BS request
    */
    global class ResponseStatus {
        public String status;
        public String error;
        public Integer user_id;

        public ResponseStatus(String status, String error) {
            this(status, error, null);
        }

        public ResponseStatus(String status, String error, Integer user_Id) {
            this.status = status;
            this.error = error;
            this.user_Id = user_Id;
        }
    }

    global class GearResponseStatus {
        public String status;
        public String error;
        public Integer gear_id;

        public GearResponseStatus(String status, String error) {
            this(status, error, null);
        }

        public GearResponseStatus(String status, String error, Integer gear_id) {
            this.status = status;
            this.error = error;
            this.gear_id = gear_id;
        }
    }

    /**
     * @description Radcheck - object that store user pin
     */
    global class Radcheck {
        public String username;
        public String value;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description parseAssignment parses JSON Assignments from BSS to Assignment Objects
     * @param json JSON with Assignments
     * @return List<Assignment>
    */
    public static List<Assignment> parseAssignment(String json) {
        List<Assignment> result;
        if (json != null) {
            result = (List<Assignment>) System.JSON.deserialize(json, List<Assignment>.class);
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description parseProjectRole parses JSON ProjectRoles MAP from BSS to ProjectRole Objects List
     * @param json JSON with ProjectRoles in Map<Integer, String>()
     * @return List<Assignment>
    */
    public static List<ProjectRole> parseProjectRole(String json) {
        Map<Integer, String> parsedMap;
        List<ProjectRole> resultProjectRoles;
        if (json != null) {
            resultProjectRoles = new List<ProjectRole>();
            parsedMap = (Map<Integer, String>) System.JSON.deserialize(json, Map<Integer, String>.class);
            for (Integer keyItem : parsedMap.keyset()) {
                resultProjectRoles.add(new ProjectRole(keyItem, parsedMap.get(keyItem)));
            }
        }
        return resultProjectRoles;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-19
     * @description parseResponse parses JSON Response from BSS
     * @param json JSON with Status message and Error message. It comes as List but use case is only for one response
     * @return ResponseStatus Object
    */
    public static ResponseStatus parseResponse(String json) {
        ResponseStatus result;
        if (!BTN_ValidationHandler.isEmpty(json)) {
            result = ((BTN_BSS_DTO.ResponseStatus) System.JSON.deserialize(json, BTN_BSS_DTO.ResponseStatus.class));
        }
        return result;
    }

    public static GearResponseStatus parseGearResponse(String json) {
        GearResponseStatus result;
        if (!BTN_ValidationHandler.isEmpty(json)) {
            result = ((BTN_BSS_DTO.GearResponseStatus) System.JSON.deserialize(json, BTN_BSS_DTO.GearResponseStatus.class));
        }
        return result;
    }

    /** @date 02/12/2015
    * @Author Piotr Pitera
    * @description parseUser method - parses the json input and translates it to DTO class.
    * @param String json which will be parsed
    * @return List<User> - parsed json
    */
    public static List<User> parseUser(String json) {
        List<User> result;
        if (json != null) {
            result = (List<User>) System.JSON.deserialize(json, List<User>.class);
        }
        return result;
    }

    /** @date 02/12/2015
    * @Author Piotr Pitera
    * @description parseCert method - parses the json input and translates it to DTO class.
    * @param String json which will be parsed
    * @return List<Cert> - parsed json
    */
    public static List<Cert> parseCert(String json) {
        List<Cert> result;
        if (json != null) {
            result = (List<Cert>) System.JSON.deserialize(json, List<Cert>.class);
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description parseProject parses JSON Projects from BSS to Project Objects
     * @param json JSON with Projects
     * @return List<Project>
    */
    public static List<Project> parseProject(String json) {
        List<Project> result;
        if (json != null) {
            result = (List<Project>) System.JSON.deserialize(json, List<Project>.class);
        }
        return result;
    }

    public static String parseRadcheck(String json) {
        String result;
        if (json != null) {
            result = (String) System.JSON.deserialize(json, String.class);
        }
        return result;
    }

    public static List<Radcheck> parseRadcheckList(String json) {
        List<Radcheck> result;
        if (json != null) {
            result = (List<Radcheck>) System.JSON.deserialize(json, List<Radcheck>.class);
        }
        return result;
    }

    public static Gear parseGear(String json) {
        Gear result;
        if (json != null) {
            result = (Gear) System.JSON.deserialize(json, Gear.class);
        }
        return result;
    }

    public static List<Gear> parseGearList(String json) {
        List<Gear> result;
        if (json != null) {
            result = (List<Gear>) System.JSON.deserialize(json, List<Gear>.class);
        }
        return result;
    }

}