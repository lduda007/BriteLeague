/**
 * @author Mateusz Przywara
 * @date   2016-08-18
 * @description BTN_BAT_Assignment_Test Test Class for Assignment Processing
*/
trigger BTN_AssignmentTrigger on BTN_Assignment__c (before insert, before update) {
    private static String calculatingCoefficientError = 'Error during coefficient calculation';
    BTN_DAO_Assignment assignmentDAO = new BTN_DAO_Assignment();
    assignmentDAO.addAccountId();
    Set<Id> projectIds = new Set<Id>();

    if(!BTN_TriggerUtils.skipTrigger('BTN_AssignmentTrigger')) {
        for (BTN_Assignment__c assignment : Trigger.New) {
            if (!BTN_ValidationHandler.isNull(assignment.Project__c)) {
                projectIds.add(assignment.Project__c);
            }
        }
        Map<Id, BTN_Project__c> projectsMap =
                new Map<Id, BTN_Project__c>(new BTN_DAO_Project().findProjectsIn(projectIds));

        for (BTN_Assignment__c assignment : Trigger.New) {
            try {
                assignment.PercentageCoefficientNextMonth__c = calculateAssignmentCoefficientForNextMonth(assignment);
                assignment.PercentageCoefficientAfterNextMonth__c = calculateAssignmentCoefficientForAfterNextMonth(assignment);
            } catch (Exception ex) {
                System.debug(LoggingLevel.ERROR, calculatingCoefficientError);
            }
            if (
                    !(BTN_ValidationHandler.isNull(assignment.Contact__c) ||
                            BTN_ValidationHandler.isNull(projectsMap.get(assignment.Project__c)))
                    ) {
                assignment.AssignmentGroup__c =
                        BTN_Utils.buldAssignmentGroupString(
                                assignment.Contact__c,
                                projectsMap.get(assignment.Project__c).Account__c
                        );
            }
        }
    }

    private Decimal calculateAssignmentCoefficientForNextMonth(BTN_Assignment__c assignment) {
        Decimal result;
        if ((assignment.NextMonthLastDay_frm__c < assignment.StartDate__c)
                || (assignment.NextMonthFirstDay_frm__c > assignment.EndDate__c)) {
            result = 0;
        } else if ((assignment.NextMonthLastDay_frm__c > assignment.EndDate__c)
                && (assignment.NextMonthFirstDay_frm__c < assignment.EndDate__c)
                && (assignment.NextMonthLastDay_frm__c > assignment.StartDate__c)
                && (assignment.NextMonthFirstDay_frm__c < assignment.StartDate__c)
                ) {
            result = (assignment.EndDate__c.day() - assignment.StartDate__c.day()) + 1;
        } else if ((assignment.NextMonthLastDay_frm__c > assignment.StartDate__c)
                && (assignment.NextMonthFirstDay_frm__c < assignment.StartDate__c)
                ) {
            result = assignment.NextMonthLastDay_frm__c.day() - assignment.StartDate__c.day();
        } else if ((assignment.NextMonthLastDay_frm__c > assignment.EndDate__c)
                && (assignment.NextMonthFirstDay_frm__c < assignment.EndDate__c)
                ) {
            result = assignment.EndDate__c.day();
        } else {
            result = assignment.NextMonthLastDay_frm__c.day();
        }
        return (result / assignment.NextMonthLastDay_frm__c.day()) * assignment.Allocation__c;
    }

    private Decimal calculateAssignmentCoefficientForAfterNextMonth(BTN_Assignment__c assignment) {
        Decimal result;
        if ((assignment.MonthAfterNextMonthLastDay_frm__c < assignment.StartDate__c)
                || (assignment.MonthAfterNextMonthFirstDay_frm__c > assignment.EndDate__c)) {
            result = 0;
        } else if ((assignment.MonthAfterNextMonthLastDay_frm__c > assignment.EndDate__c)
                && (assignment.MonthAfterNextMonthFirstDay_frm__c < assignment.EndDate__c)
                && (assignment.MonthAfterNextMonthLastDay_frm__c > assignment.StartDate__c)
                && (assignment.MonthAfterNextMonthFirstDay_frm__c < assignment.StartDate__c)
                ) {
            result = (assignment.EndDate__c.day() - assignment.StartDate__c.day()) + 1;
        } else if ((assignment.MonthAfterNextMonthLastDay_frm__c > assignment.StartDate__c)
                && (assignment.MonthAfterNextMonthFirstDay_frm__c < assignment.StartDate__c)
                ) {
            result = assignment.MonthAfterNextMonthLastDay_frm__c.day() - assignment.StartDate__c.day();
        } else if ((assignment.MonthAfterNextMonthLastDay_frm__c > assignment.EndDate__c)
                && (assignment.MonthAfterNextMonthFirstDay_frm__c < assignment.EndDate__c)
                ) {
            result = assignment.EndDate__c.day();
        } else {
            result = assignment.MonthAfterNextMonthLastDay_frm__c.day();
        }
        return (result / assignment.MonthAfterNextMonthLastDay_frm__c.day()) * assignment.Allocation__c;
    }
}