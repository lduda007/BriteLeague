/**
 * @author Mateusz Przywara
 * @date   2016-08-05
 * @description BTN_ValidationHandler Validation Handler for Project
 */
public class BTN_ValidationHandler {

    /**
     * @author Mateusz Przywara
     * @date   2016-06-13
     * @description check if input is null
     * @param  input SObject
     * @return             Boolean
     */
    public static Boolean isNull(Object input) {
        return (input == null);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-13
     * @description Check if input String is empty
     * @param  object
     * @return             Boolean
     */
    public static Boolean isEmpty(String input) {
        return ((input == null) || (input == ''));
    }

    public static Boolean isChanged(SObject left, SObject right) {
        Map<String, Object> leftFields = left.getPopulatedFieldsAsMap();
        Map<String, Object> rightFields = right.getPopulatedFieldsAsMap();

        for (String fieldName : leftFields.keySet()) {
            if (rightFields.containsKey(fieldName) && leftFields.get(fieldName) == rightFields.get(fieldName)) {
                return true;
            }
        }
        return false;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-20
     * @description Validate input to calc difference between dates
     * @param  Date Start date
     * @param  Date Snd date
     * @return are params valid?
     */
    public static Boolean isParamSetForDateUtilsValid(Date startD, Date endD) {
        return ((startD != null) && (endD != null));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-30
     * @description Validate input to calc difference between dates
     * @param  Date Start date
     * @param  Date Snd date
     * @return are params valid?
     */
    public static Boolean isCandidateFormValid(BTN_CV__c cv, List<sObject> cvList) {
        return !((cvList.size() == 0));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-10
     * @description isBSSProjectValid Validate Project
     * @param  projectItem DTO Object with Project Data
     * @return is Project valid?
     */
    public static Boolean isBSSProjectValid(BTN_BSS_DTO.Project projectItem) {
        return (!(isNull(projectItem.project_id) ||
                isEmpty(projectItem.project_name) ||
                isEmpty(projectItem.company_name)));
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-08-10
     * @description isBSSAssignmentValid Validate Assignment
     * @param  assignmentItem DTO Object with Project Data
     * @return is Project valid?
     */
    public static Boolean isBSSAssignmentValid(BTN_BSS_DTO.Assignment assignmentItem) {
        return (!(isNull(assignmentItem.projectuser_id) ||
                isNull(assignmentItem.projectuser_user_id) ||
                isNull(assignmentItem.projectuser_project_id) ||
                isNull(assignmentItem.projectuser_asgn_end) ||
                isNull(assignmentItem.projectuser_asgn_start)));
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-08-10
     * @description isBSSUserValid Validate BSS User = SFDC Contact
     * @param  userItem DTO Object with BSS User Data
     * @return is Project valid?
     */
    public static Boolean isBSSUserValid(BTN_BSS_DTO.User userItem) {
        return (!(isNull(userItem.user_id) ||
                isNull(userItem.user_deleted) ||
                isNull(userItem.user_fname) ||
                isNull(userItem.user_lname)));
    }

   /**
     * @author Mateusz Przywara
     * @date   2016-09-07
     * @description isUserAddedToBSWithSuccess Validate BSS Response
     * @param  response Response from BSS User API with information that User has been added or not
     * @return is Operation End with Success?
     */
    public static Boolean isUserAddedToBSWithSuccess(BTN_BSS_DTO.ResponseStatus response) {
        return (!BTN_ValidationHandler.isNull(response)) &&
                (response.status == BTN_BSS_Service.NEW_BS_RESPONSE_SUCCESS_STATUS);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-14
     * @description hasValueBeenCleared
     * @param  ob1 Object first
     * @param  ob2 Object Second
     * @return has Object1 value but Object2 not?
    */
    public static Boolean hasValueBeenCleared(Object ob1, Object ob2) {
        return (ob1 != null) && (ob2 == null);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-14
     * @description hasValueBeenUpdated
     * @param  ob1 Object first
     * @param  ob2 Object Second
     * @return has Object2 different value than OBject1?
    */
    public static Boolean hasValueBeenUpdated(Object ob1, Object ob2) {
        return (ob1 != null) && (ob2 != null) && (!ob1.equals(ob2));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-14
     * @description areBothValuesNull
     * @param  ob1 Object first
     * @param  ob2 Object Second
     * @return are Objects nulls?
    */
    public static Boolean areBothValuesNull(Object ob1, Object ob2) {
        return (ob1 == null) && (ob2 == null);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-14
     * @description hasValueBeenSet
     * @param  ob1 Object first
     * @param  ob2 Object Second
     * @return are Objects nulls?
    */
    public static Boolean hasValueBeenSet(Object ob1, Object ob2) {
        return (ob1 == null) && (ob2 != null);
    }


    /**
     * @author Mateusz Przywara
     * @date   2016-11-02
     * @description isCaseApproved MEthod check Case Status if it is Approved then return true
     * @param  Case
    */
    public static Boolean isCaseApproved(Case inputCase) {
        return (inputCase.Status.equals(BTN_ConstantRepo.CASE_STATUS_APPROVED));
    }

    public static Boolean doFormattingArgumentsSizeMatchGivenSize(String stringToFormat, Integer size) {
        return stringToFormat.split('(\\{\\d+\\})').size() == size;
    }

}