/**
 * @author Mateusz Przywara
 * @date   2016-08-09
 * @description BTN_JOB_ProjectSync Extended BaseJob Class to handle Project Sync
*/
global class BTN_JOB_BSSSynchronizations extends BTN_JOB_BaseJob {
    private static final Integer EXECUTE_BATCH_WITHIN_MINUTES_AFTER_SYNC = 2;
    private static final Integer SCOPE_SIZE_FOR_ASSIGNMENT_JOB = 20;
    private static final String CLASS_NAME = 'BTN_JOB_BSSSynchronizations';
    private static List<String> ERROR_LIST = new List<String>();
    /**
     * @author Mateusz Przywara
     * @date   2016-08-09
     * @description execute start ProjectSync Thread
     *  Method retrieve Projects from BSS parse to sObjects
     *  Run Batch to process Projects in the system
     * @param SchedulableContext Context of job
    */
    global override void execute(SchedulableContext sc) {
        this.batchName = 'BTN_BAT_Assignment';
        this.sc = sc;
        Boolean rescheduled = false;
            if (isBatchJobNotAlreadyRunning()) {
                if (canBatchJobRun()) {
                    BTN_JOB_BSSSynchronizations.futureSyncBSS();
                } else {
                    BTN_Email_Utils.sendWarningEmailToAdmin(
                            String.format(
                                    System.Label.EmailTemplateJobFailedAndReschedulesSubject,
                                    new String[]{JobName}
                            ),
                            System.Label.EmailTemplateJobFailedAndReschedulesBody
                    );
                    rescheduleJob();
                    rescheduled = true;
                }
            }
            if (!rescheduled && repeatJob) {
                // repeat the job in 10 mins
                repeatJob();
                //abort this job
                tidyUp();
            }    if (isBatchJobNotAlreadyRunning()) {
                if (canBatchJobRun()) {
                    BTN_JOB_BSSSynchronizations.futureSyncBSS();
                } else {
                    BTN_Email_Utils.sendWarningEmailToAdmin(
                            String.format(
                                    System.Label.EmailTemplateJobFailedAndReschedulesSubject,
                                    new String[]{JobName}
                            ),
                            System.Label.EmailTemplateJobFailedAndReschedulesBody
                    );
                    rescheduleJob();
                    rescheduled = true;
                }
            }
            if (!rescheduled && repeatJob) {
                // repeat the job in 10 mins
                repeatJob();
                //abort this job
                tidyUp();
            }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-10
     * @description Future method with callout permission.
     * Get, parse and upsert Contacts, Projects, Assignments from BSS
     * Also on the End runs Batch for ProjectAssignments and Assignments
     * @return
    */
    @future (Callout = true)
    public static void futureSyncBSS() {
        BTN_LogUtils logger = new BTN_LogUtils(CLASS_NAME);
        try {
            // CallOuts Section - MUST be first (before changes on any sObject)
            List<BTN_Project__c> projects;
            List<BTN_BSS_DTO.Project> projectsDTO = new List<BTN_BSS_DTO.Project>(requestBSProjects());
            List<Contact> contacts;
            List<BTN_BSS_DTO.User> contactsDTO = new List<BTN_BSS_DTO.User>(requestBSUsers());
            List<BTN_Assignment__c> assignments;
            List<BTN_BSS_DTO.Assignment> assignmentsDTO = new List<BTN_BSS_DTO.Assignment>(requestBSAssignments());
            List<BTN_ProjectRolesSetting__c> projectRoles;
            List<BTN_BSS_DTO.ProjectRole> projectRolesDTO = new List<BTN_BSS_DTO.ProjectRole>(requestBSProjectRoles());
            // end of Callouts, insert JSON errors
            insertJSONExceptions(logger);

            // Select Accounts
            List<Account> accounts = new BTN_DAO_Account().findAccounts();
            //Parsing to sObjectSection
            // Parse BSS Contacts
            if (!(contacts = BTN_ContactUtils.newContactFromBS(contactsDTO)).isEmpty()) {
                Database.upsert(
                        contacts,
                        Contact.BSexternalId__c,
                        false
                );
            }
            // Parse BSS Projects
            if (!(projects = BTN_ProjectUtils.parseDTOProjectsFromBSSToSObjects(projectsDTO, accounts)).isEmpty()) {
                Database.upsert(
                    projects,
                    BTN_Project__c.BritesheetProjectId__c,
                    false
                );
            }

            // Parse BSS Assignments
            List<BTN_Project__c> salesforceProjects = new BTN_DAO_Project().findProjects();
            List<Contact> salesforceContacts = new BTN_DAO_Contact().findBSSContacts();
            if (!(assignments = BTN_AssignmentUtils.parseDTOAssignmentsFromBSSToSObjects(
                    assignmentsDTO,
                    salesforceContacts,
                    salesforceProjects
            )).isEmpty()) {
                Database.upsert(
                        assignments,
                        BTN_Assignment__c.BritesheetExternalId__c,
                        false
                );
            }

            // Parse BSS ProjectRoles
            if (!(projectRoles = BTN_ProjectRoleUtils.parseBSProjectRoles2CS(projectRolesDTO)).isEmpty()) {
                Database.upsert(
                        projectRoles,
                        BTN_ProjectRolesSetting__c.BSExternalId__c,
                        false
                );
            }

            //Assignments further processing section
            //Process Assignments - fill Project Assignment lookup. Create ProjectAssignments. Deafult chunk 200.
            Datetime dt = Datetime.now().addminutes(EXECUTE_BATCH_WITHIN_MINUTES_AFTER_SYNC); //  mins
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
            BTN_JOB_BaseJob job = new BTN_JOB_BaseJob();
            job.liveBatch = new BTN_BAT_Assignment();
            job.chunkSize = SCOPE_SIZE_FOR_ASSIGNMENT_JOB;
            System.Schedule('BTN_BAT_Assignment' + dt.format(), timeForScheduler, job);

        } catch (Exception e) {
            //BTN_LogUtils logSystem = new BTN_LogUtils('BTN_JOB_BSSSynchronizations');
            logger.error(e.getMessage(), BTN_Utils.getCurrentUser().Id);
            System.debug(System.Label.failedBSSSync);
            System.debug(e.getMessage());
            BTN_Email_Utils.sendWarningEmailToAdmin(
                    String.format(
                            System.Label.EmailTemplateJobFailedSubject,
                            new String[]{CLASS_NAME}
                    ),
                    String.format(
                            System.Label.EmailTemplateJobFailedBody,
                            new String[]{CLASS_NAME, e.getMessage()}
                    )
            );
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-30
     * @description requestBSUsers ask BS for Data
     * @return
     */
    private static List<BTN_BSS_DTO.User> requestBSUsers() {
        List<BTN_BSS_DTO.User> result;
        try {// All ProjectRoles from BSS
            result = BTN_BSS_Service.getUserDetails();
        } catch (JSONException ex) {
            ERROR_LIST.add(ex.getMessage());
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-30
     * @description requestBSProjectRoles ask BS for Data
     * @return
     */
    private static List<BTN_BSS_DTO.ProjectRole> requestBSProjectRoles() {
        List<BTN_BSS_DTO.ProjectRole> result;
        try {
            result = BTN_BSS_Service.getProjectRoleDetails();
        } catch (JSONException ex) {
            ERROR_LIST.add(ex.getMessage());
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-30
     * @description requestBSProjects ask BS for Data
     * @return
     */
    private static List<BTN_BSS_DTO.Project> requestBSProjects() {
        List<BTN_BSS_DTO.Project> result;
        try { //All projects from BSS
            result = BTN_BSS_Service.getProjectDetails();
        } catch (JSONException ex) {
            ERROR_LIST.add(ex.getMessage());
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-30
     * @description requestBSAssignments ask BS for Data
     * @return
     */
    private static List<BTN_BSS_DTO.Assignment> requestBSAssignments() {
        List<BTN_BSS_DTO.Assignment> result;
        try { // Assignments from BSS (? Last week ?
            result = BTN_BSS_Service.getAssignmentDetails();
        } catch (JSONException ex) {
            ERROR_LIST.add(ex.getMessage());
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-30
     * @description insertJSONExceptions
     * @return
     */
    private static void insertJSONExceptions(BTN_LogUtils logger) {
        for (String strItem : ERROR_LIST) {
            logger.error(strItem, BTN_Utils.getCurrentUser().Id);
        }
    }
}