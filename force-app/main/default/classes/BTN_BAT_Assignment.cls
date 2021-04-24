/**
 * @author Mateusz Przywara
 * @date   2016-08-10
 * @description BTN_BAT_Assignment Batch Processing Assignments
*/
public class BTN_BAT_Assignment extends BTN_BAT_BaseBatch {
    public static final Integer MAX_END_DATE_DIFFERENCE = 7;

    /**
    * @author Mateusz Przywara
    * @date   2016-08-12
    * @description start prepare data for further processing
    */
    public override System.Iterable<Object> start(Database.batchableContext bc) {
        BTN_DAO_Assignment assignmentDAO = new BTN_DAO_Assignment();
        // prepare group list
        Set<String> groups = new Set<String>();
        for (BTN_Assignment__c assignmentItem : Database.query(assignmentDAO.getAssignmentsLocator().getQuery())) {
            groups.add(assignmentItem.AssignmentGroup__c);
        }
        return (Iterable<Object>) new List<String>(groups);
    }

    /**
    * @author Mateusz Przywara
    * @date   2016-08-12
    * @description execute Executes chunk of data
    * @param Database.BatchableContext Context
    * @param scope Chunk of Data
    */
    public override void execute(Database.BatchableContext BC, List<Object> scope) {
        // Flag to controll Time Line Section Creation process
        // True then proper section was found and no need to create new one
        Boolean assignmentFoundSection = false;
        // Flags to controll Case to edit Time Line Section
        BTN_DAO_Assignment assignmentDAO = new BTN_DAO_Assignment();
        assignmentDAO.addRelatedCases();
        assignmentDAO.addAccountId();
        // Sections for TimeLine
        List<TimeLineSection> timeLineSections = new List<TimeLineSection>();
        // Case changes
        List<Case> casesToUpdate = new List<Case>();
        // List with Assignments to Reject On Boarding
        Set<BTN_Assignment__c> onBoardingtoReject = new Set<BTN_Assignment__c>();
        // List with Assignments to Reject Off Boarding
        Set<BTN_Assignment__c> offBoardingtoReject = new Set<BTN_Assignment__c>();
        // List for Cases to avoid DML in scope loop
        List<Case> cases = new List<Case>();
        // Assignment agregated by Groups
        for (String groupValue : (List<String>) scope) {
            addNumberOfRecords();
                // Iterate through Assignments ORDER BY StartDate is VERY important
                for (
                        BTN_Assignment__c assignmentItem :
                        assignmentDAO.findAssignmentsByGroup(groupValue)) {
                        // Process Assignment Start Date
                    for (TimeLineSection section : timeLineSections) {
                        // Check where is StartDate !!! it cannot be before current Assingment - ORDER BY
                        Boolean isAssignmentStartInSectionRange =
                                ((assignmentItem.StartDate__c <
                                        section.endDateAssignment.EndDate__c.addDays(MAX_END_DATE_DIFFERENCE)) &&
                                        (assignmentItem.StartDate__c > section.endDateAssignment.EndDate__c));

                        Boolean isAssignmentStartInsideSection =
                                (( assignmentItem.StartDate__c <= section.endDateAssignment.EndDate__c) &&
                                        (assignmentItem.StartDate__c >= section.startDateAsssignment.StartDate__c));

                        Boolean isAssignmentEndAfterSection =
                                    (assignmentItem.EndDate__c > section.endDateAssignment.EndDate__c);

                        // If Start Date is in Section reject Assignment onBoarding case.
                        // Set flag that Script found proper Section for Assignment
                        if (isAssignmentStartInsideSection) {
                            onBoardingtoReject.add(assignmentItem);
                            assignmentFoundSection = true;
                        }
                        // If Start Date is after(provided value) section End Date - prolong Section.
                        // Reject old offboarding, reject Assignment On boarding(section already has start)
                        // Set flag that Script found proper Section for Assignment
                        if (isAssignmentStartInSectionRange) {
                            offBoardingtoReject.add(section.endDateAssignment);
                            onBoardingtoReject.add(assignmentItem);
                            assignmentFoundSection = true;
                        }
                        // If Start Date is in Section or in provided range
                        // - prolong section by Assignment End Date and Reject old off boarding
                        // and prolonging Assignment Onboarding Case
                        // Flag was set earlier
                        if ((isAssignmentStartInsideSection || isAssignmentStartInSectionRange) &&
                                isAssignmentEndAfterSection) {
                            offBoardingtoReject.add(section.endDateAssignment);
                            onBoardingtoReject.add(assignmentItem);
                            section.endDateAssignment = assignmentItem;
                        } else if ((isAssignmentStartInsideSection || isAssignmentStartInSectionRange) &&
                                !isAssignmentEndAfterSection) {
                            offBoardingtoReject.add(assignmentItem);
                        }
                    }
                    // No proper section - create new one
                    if (!assignmentFoundSection) {
                        timeLineSections.add(new TimeLineSection(assignmentItem));
                    }
                    assignmentFoundSection = false;

            }
            // End of Assignment iteration - time to process Time Lines
            // Set On / Off boarding Cases
                /*System.debug('timelineSectionsSize ' + timeLineSections.size());
                System.debug(timeLineSections);
                System.debug('setgroups ' + calculatedGroups);*/
            cases.addAll(processTimeLines(timeLineSections));
            timeLineSections.clear();
                /*System.debug(onBoardingtoReject);
                System.debug(offBoardingtoReject);*/
        }
        //End of Scope time to process items to Reject.
        processToRejectOnBoardingItems(onBoardingtoReject);
        processToRejectOffBoardingItems(offBoardingtoReject);
        // And update TimeLine Sections Cases
        upsert cases;
    }

     /**
    * @author Mateusz Przywara
    * @date   2016-08-16
    * @description isOnboardingCaseExist
    * @param assignment
    * @param Case Existing OnBoarding Case
    */
    private Case getOnboardingCase(BTN_Assignment__c assignment) {
        Case result;
        for (Case caseItem : assignment.Cases__r) {
            if (caseItem.RecordType.DeveloperName == BTN_ConstantRepo.CASE_EXTERNAL_ONBOARDING_RECORDTYPE) {
                result = caseItem;
                break;
            }
        }
        return result;
    }

     /**
    * @author Mateusz Przywara
    * @date   2016-08-16
    * @description isOnboardingCaseExist
    * @param assignment
    * @param Case Existing OffBoardingCase
    */
    private Case getOffboardingCase(BTN_Assignment__c assignment) {
        Case result;
        for (Case caseItem : assignment.Cases__r) {
            if (caseItem.RecordType.DeveloperName == BTN_ConstantRepo.CASE_EXTERNAL_OFFBOARDING_RECORDTYPE) {
                result = caseItem;
                break;
            }
        }
        return result;
    }

    /**
    * @author Mateusz Przywara
    * @date   2016-08-16
    * @description createNewCase
    * @param assignment Assignment sObject base for new Case
    * @param recordTypeName Record Type for new Case
    * @param Case New Case
    */
    private Case createNewCase(BTN_Assignment__c assignment, Id caseRecordTypeId) {
        return new Case(
                ContactId = assignment.Contact__c,
                AccountId = assignment.Project__r.Account__c,
                Assignment__c = assignment.Id,
                Status = BTN_ConstantRepo.CASE_STATUS_OPEN,
                RecordTypeId = caseRecordTypeId
        );
    }

    /**
    * @author Mateusz Przywara
    * @date   2016-08-16
    * @description processTimeLines
    * @param sections List of generated sections
    * @param Boolean
    */
    private List<Case> processTimeLines(List<TimeLineSection> sections) {
        List<Case> newCases = new List<Case>();
        Case tmpCase;
        for (TimeLineSection sectionItem : sections) {
            if ((tmpCase = getOnboardingCase(sectionItem.startDateAsssignment)) == null) {
                newCases.add(createNewCase(
                        sectionItem.startDateAsssignment,BTN_RecordTypeUtils.getRecordTypeCaseExternalOnBoarding().Id
                ));
            } else if ((tmpCase != null) && (tmpCase.Status != BTN_ConstantRepo.CASE_STATUS_OPEN)) {
                tmpCase.Status = BTN_ConstantRepo.CASE_STATUS_OPEN;
                newCases.add(tmpCase);
            }
            if ((tmpCase = getOffboardingCase(sectionItem.endDateAssignment)) == null) {
                newCases.add(createNewCase(
                        sectionItem.endDateAssignment, BTN_RecordTypeUtils.getRecordTypeCaseExternalOffBoarding().Id
                ));
            } else if (
                    (tmpCase != null) &&
                            (tmpCase.Status != BTN_ConstantRepo.CASE_STATUS_OPEN) &&
                            (tmpCase.Status != BTN_ConstantRepo.CASE_STATUS_SUBMITTED)
                    ) {
                tmpCase.Status = BTN_ConstantRepo.CASE_STATUS_OPEN;
                newCases.add(tmpCase);
            }
        }
        return newCases;
    }

    /**
    * @author Mateusz Przywara
    * @date   2016-08-16
    * @description processToRejectOnBoardingItems rejects all OnBoarding Cases for toReject list
    * Every Assignment has list of Cases Cases__r
    * @param toReject List of Assignments to be processed
    */
    private void processToRejectOnBoardingItems(Set<BTN_Assignment__c> toReject) {
        List<Case> updateList = new List<Case>();
        for (BTN_Assignment__c assignmentItem : toReject) {
            for (Case caseItem : assignmentItem.Cases__r) {
                if ((BTN_RecordTypeUtils.isCaseExternalOnBoarding(caseItem)) &&
                        (caseItem.Status != BTN_ConstantRepo.CASE_STATUS_REJECTED)) {
                    caseItem.Status = BTN_ConstantRepo.CASE_STATUS_REJECTED;
                    updateList.add(caseItem);
                }
            }
        }
        update updateList;
    }

    /**
    * @author Mateusz Przywara
    * @date   2016-08-16
    * @description processToRejectOffBoardingItems rejects all OffBoarding Cases for toReject list
    * Every Assignment has list of Cases Cases__r
    * @param toReject List of Assignments to be processed
    */
    private void processToRejectOffBoardingItems(Set<BTN_Assignment__c> toReject) {
        List<Case> updateList = new List<Case>();
        for (BTN_Assignment__c assignmentItem : toReject) {
            for (Case caseItem : assignmentItem.Cases__r) {

                if ((BTN_RecordTypeUtils.isCaseExternalOffBoarding(caseItem)) &&
                        (caseItem.Status != BTN_ConstantRepo.CASE_STATUS_REJECTED)) {
                    caseItem.Status = BTN_ConstantRepo.CASE_STATUS_REJECTED;
                    updateList.add(caseItem);
                }
            }
        }
        update updateList;
    }

    /**
    * @author Mateusz Przywara
    * @date   2016-08-16
    * @description checkIfGroupHasBeenAlreadyCalculated
    * @param assignment BTN_Assignment
    * @param Boolean
    */
/*    private Boolean checkIfGroupHasBeenAlreadyCalculated (BTN_Assignment__c assignment) {
        return !calculatedGroups.contains(assignment.AssignmentGroup__c);
    }*/


    /**
    * @author Mateusz Przywara
    * @date   2016-08-12
    * @description groupBy Implementation of Group By expression
    * @param records Records List
    * @param Map<Id, List<sObject>> Data grouped by Id
    */
/*    private Map<Id, List<sObject>> groupBy(List<sObject> records) {
        Map<Id, List<sObject>> returnMap = new Map<Id, List<sObject>>();
        for (sObject record : records) {
            Id key = (Id) record.get( 'Id' ); // field name to group by
            if (!returnMap.containsKey(key)) {
                returnMap.put(key, new List<sObject>());
            }
            returnMap.get(key).add(record);
        }
        return returnMap;
    }*/

    /**
    * @author Mateusz Przywara
    * @date   2016-08-12
    * @description checkIfTimeLineListIsNull
    * @param sections TimeLine
    * @param List<TimeLineSection> new TimeLine
    */
/*    private List<TimeLineSection> checkIfTimeLineListIsNull(
            List<TimeLineSection> sections,
            BTN_Assignment__c assignment
    ) {
        if (sections == null) {
            sections = new List<TimeLineSection>{
                new TimeLineSection(assignment, assignment)
            };
        }
       return sections;
    }*/


    class TimeLineSection {
        public BTN_Assignment__c startDateAsssignment;
        public BTN_Assignment__c endDateAssignment;

        public TimeLineSection(BTN_Assignment__c startDateAsssignment, BTN_Assignment__c endDateAssignment) {
            this.startDateAsssignment = startDateAsssignment;
            this.endDateAssignment = endDateAssignment;
        }

        public TimeLineSection(BTN_Assignment__c asssignment) {
            this.startDateAsssignment = asssignment;
            this.endDateAssignment = asssignment;
        }
    }
}