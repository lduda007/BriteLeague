/**
 * @author Mateusz Przywara
 * @date   2016-08-04
 * @description BTN_AssignmentUtils Utils methods for Assignment sObject
 */
public class BTN_AssignmentUtils {
    /**
     * @author Mateusz Przywara
     * @date   2016-08-04
     * @description Method parse List of BSS Assignments to List of BTN_Assignments.
     * @param bssAssignments List of BSS Assignments.
     * @param contacts List of SFDC Contacts.
     * @param projects List of SFDC Projects.
     * @return List<BTN_Assignment__c> List of Salesforce Assignments
    */
    public static List<BTN_Assignment__c> parseDTOAssignmentsFromBSSToSObjects(
            List<BTN_BSS_DTO.Assignment> bssAssignments,
            List<Contact> contacts,
            List<BTN_Project__c> projects
    ) {
        List<BTN_Assignment__c> assignments = new List<BTN_Assignment__c>();
        Id matchedContactId;
        Id matchedProjectId;
        for (BTN_BSS_DTO.Assignment assignmentDTOItem : bssAssignments) {
            matchedContactId = null;
            matchedProjectId = null;
            try {
                if (BTN_ValidationHandler.isBSSAssignmentValid(assignmentDTOItem)) {
                    //Match valid Contact by BSS Id
                    for (Contact contactItem : contacts) {
                        if (contactItem.BSexternalId__c == assignmentDTOItem.projectuser_user_id) {
                            matchedContactId = contactItem.Id;
                            break;
                        }
                    }
                    //Match valid Project by BSS Id
                    for (BTN_Project__c projectItem : projects) {
                        if (projectItem.BritesheetProjectId__c == assignmentDTOItem.projectuser_project_id) {
                            matchedProjectId = projectItem.Id;
                            break;
                        }
                    }
                    assignments.add(buildAssignment(assignmentDTOItem, matchedContactId, matchedProjectId));
                }
            } catch (Exception ex) {
                BTN_LogUtils logSystem = new BTN_LogUtils('BTN_AssignmentUtils');
                logSystem.error(ex.getMessage(), BTN_Utils.getCurrentUser().Id);
                System.debug(LoggingLevel.ERROR, System.Label.ExceptionInAssignmentProcessing);
                System.debug(LoggingLevel.ERROR, ex.getMessage());
            }
        }
        return assignments;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-18
     * @description buildAssignment - Creates instance of BTN_Assignment__c
     * @param bssAssignments List of BSS Assignments.
     * @return List<BTN_Assignment__c> List of Salesforce Assignments
    */
    public static BTN_Assignment__c buildAssignment(
            BTN_BSS_DTO.Assignment assignmentDTOItem,
            Id ContactId,
            Id ProjectId
    ) {
        return new BTN_Assignment__c(
                BritesheetExternalId__c = assignmentDTOItem.projectuser_id,
                // Correct dates Dates can have year 9999 but on DML max is 4000-12-31T00:00:00Z GMT
                // and minimal date is  January 1, 1700
                StartDate__c = assignmentDTOItem.projectuser_asgn_start,
                EndDate__c = correctMaxDate(assignmentDTOItem.projectuser_asgn_end),
                Contact__c = ContactId,
                Allocation__c = assignmentDTOItem.projectuser_asgn_rate,
                Project__c = ProjectId
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-23
     * @description correctMaxDate - Make possible to insert Date to DB.
     *  Max Date allowed by SF 4000-12-31T00:00:00Z GMT,
     * @param inputDate
     * @return Date
    */
    public static Date correctMaxDate(Date inputDate) {
        if (inputDate.year() > 4000) {
            inputDate = Date.newInstance(4000, inputDate.month(), inputDate.day());
        }
        return inputDate;
    }
}