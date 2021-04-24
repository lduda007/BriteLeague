/**
 * @author Mateusz Przywara
 * @date   2016-08-09
 * @description BTN_ProjectUtils Utils methods for BTN_Project__c sObject
 */
public with sharing class BTN_ProjectUtils {
    private static final String BS_ACCOUNT_NAME = 'Britenet';
    /**
     * @author Mateusz Przywara
     * @date   2016-08-09
     * @description Method parse List of BSS Projects to List of BTN_Projects.
     * @param bssProjects List of deserialized Projects from BSS
     * @param accounts List of SFDC Accounts.
     * @return List<BTN_Project__c> List of Salesforce Projects
    */
    public static List<BTN_Project__c> parseDTOProjectsFromBSSToSObjects(
            List<BTN_BSS_DTO.Project> bssProjects,
            List<Account> accounts
    ) {
        List<BTN_Project__c> projects = new List<BTN_Project__c>();
        Id matchedAccountId;
        for (BTN_BSS_DTO.Project projectDTOItem : bssProjects) {
            matchedAccountId = null;
            if (projectDTOItem.company_name == BS_ACCOUNT_NAME) {
                projectDTOItem.company_name = BTN_ConstantRepo.BRITENET_ACCOUNT_NAME;
            }
            try {
                if (BTN_ValidationHandler.isBSSProjectValid(projectDTOItem)) {
                    //Match valid Account by BSS company_name
                    for (Account accountItem : accounts) {
                        if (accountItem.Name == projectDTOItem.company_name) {
                            matchedAccountId = accountItem.Id;
                            break;
                        }
                    }

                    projects.add(
                            new BTN_Project__c(
                                    Name = projectDTOItem.project_name,
                                    BritesheetProjectId__c = projectDTOItem.project_id,
                                    ProjectCode__c = projectDTOItem.project_code,
                                    ProjectType__c = projectDTOItem.project_type,
                                    Account__c = matchedAccountId
                            )
                    );
                }
            } catch (Exception ex) {
                BTN_LogUtils logSystem = new BTN_LogUtils('BTN_ProjectUtils');
                logSystem.error(ex.getMessage(), BTN_Utils.getCurrentUser().Id);
                System.debug(System.Label.ExceptionInProjectProcessing);
                System.debug(ex.getMessage());
            }
        }
        return projects;
    }
}