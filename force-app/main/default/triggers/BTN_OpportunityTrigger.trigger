trigger BTN_OpportunityTrigger on Opportunity (before insert, before update) {
    private static String contractLengthEqualsZeroErrorMsg = 'Contract length equals 0 - cannot divide by 0';
    if(!BTN_TriggerUtils.skipTrigger('BTN_OpportunityTrigger')) {
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            for (Opportunity opportunity : Trigger.New) {
                try {
                    opportunity.CurrentMonthAmount__c = calculateOpportunityRevenueForCurrentMonth(opportunity);
                    opportunity.NextMonthAmount__c = calculateOpportunityRevenueForNextMonth(opportunity);
                } catch (Exception ex) {
                    opportunity.CurrentMonthAmount__c = 0;
                    opportunity.NextMonthAmount__c = 0;
                    System.debug(LoggingLevel.ERROR, contractLengthEqualsZeroErrorMsg);
                }
            }
        }
    }

    private Double calculateOpportunityRevenueForCurrentMonth(Opportunity opportunity) {
        Date firstDayOfMonth = Date.newInstance(
                System.today().year(),
                System.today().month(),
                1
        );
        Date lastDayOfMonth = Date.newInstance(
                System.today().year(),
                System.today().month(),
                Date.daysInMonth(System.today().year(), System.today().month())
        );
        Double result;
        if ((lastDayOfMonth < opportunity.ContractStart__c)
                || (firstDayOfMonth > opportunity.ContractEnd_frm__c)) {
            result = 0;
        } else if ((lastDayOfMonth > opportunity.ContractEnd_frm__c)
                && (firstDayOfMonth < opportunity.ContractEnd_frm__c)
                && (lastDayOfMonth > opportunity.ContractStart__c)
                && (firstDayOfMonth < opportunity.ContractStart__c)
                ) {
            result = (opportunity.ContractEnd_frm__c.day() - opportunity.ContractStart__c.day()) + 1;
        } else if ((lastDayOfMonth > opportunity.ContractStart__c)
                && (firstDayOfMonth < opportunity.ContractStart__c)
                ) {
            result = lastDayOfMonth.day() - opportunity.ContractStart__c.day();
        } else if ((lastDayOfMonth > opportunity.ContractEnd_frm__c)
                && (firstDayOfMonth < opportunity.ContractEnd_frm__c)
                ) {
            result = opportunity.ContractEnd_frm__c.day();
        } else {
            result = lastDayOfMonth.day();
        }
        return result *
                (opportunity.Amount_frm__c / opportunity.ContractStart__c.daysBetween(opportunity.ContractEnd_frm__c));
    }

    private Double calculateOpportunityRevenueForNextMonth(Opportunity opportunity) {
        Date firstDayOfNextMonth = Date.newInstance(
                System.today().year(),
                System.today().month() + 1,
                1
        );
        Date lastDayOfNextMonth = Date.newInstance(
                System.today().year(),
                System.today().month() + 1,
                Date.daysInMonth(System.today().year(), System.today().month())
        );
        Double result;
        if ((lastDayOfNextMonth < opportunity.ContractStart__c)
                || (firstDayOfNextMonth > opportunity.ContractEnd_frm__c)) {
            result = 0;
        } else if ((lastDayOfNextMonth > opportunity.ContractEnd_frm__c)
                && (firstDayOfNextMonth < opportunity.ContractEnd_frm__c)
                && (lastDayOfNextMonth > opportunity.ContractStart__c)
                && (firstDayOfNextMonth < opportunity.ContractStart__c)
                ) {
            result = (opportunity.ContractEnd_frm__c.day() - opportunity.ContractStart__c.day()) + 1;
        } else if ((lastDayOfNextMonth > opportunity.ContractStart__c)
                && (firstDayOfNextMonth < opportunity.ContractStart__c)
                ) {
            result = lastDayOfNextMonth.day() - opportunity.ContractStart__c.day();
        } else if ((lastDayOfNextMonth > opportunity.ContractEnd_frm__c)
                && (firstDayOfNextMonth < opportunity.ContractEnd_frm__c)
                ) {
            result = opportunity.ContractEnd_frm__c.day();
        } else {
            result = lastDayOfNextMonth.day();
        }
        return result *
                (opportunity.Amount_frm__c / opportunity.ContractStart__c.daysBetween(opportunity.ContractEnd_frm__c));
    }
}