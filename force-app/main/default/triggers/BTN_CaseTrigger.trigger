trigger BTN_CaseTrigger on Case (after insert, after update) {
    if(!BTN_TriggerUtils.skipTrigger('BTN_CaseTrigger')) {
        if (Trigger.isAfter && Trigger.isInsert) {

            Set<Id> externalCasesIds = new Set<Id>(); 
            for (Case caseItem : Trigger.new) {
                if (BTN_RecordTypeUtils.isCaseExternal(caseItem)) {
                    externalCasesIds.add(caseItem.Id);
                }
            }
            //may be useful for process to setup future method
            if (!externalCasesIds.isEmpty()) {
                BTN_CaseUtils.executeCaseStandardAssignmentRule(externalCasesIds);
            }
            BTN_CaseUtils.addCaseSharingForLeader(Trigger.new);
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            BTN_CaseUtils.replaceCaseSharingForLeader(Trigger.newMap, Trigger.oldMap);
        }
    }
}