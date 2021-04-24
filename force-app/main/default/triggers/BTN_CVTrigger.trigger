/**
 * @author Mateusz Przywara
 * @date   2016-10-13
 * @description BTN_CVTrigger Trigger for Candidate sObject, post on HR group information about Candidate update
*/
trigger BTN_CVTrigger on BTN_CV__c (after update, after insert, before update, before insert) {
    private static final String NAME_FIELD_ON_CANDIDATE = 'ContactName_frm__c';
    Set<String> fieldsToTrack = new Set<String>{'Status__c'};
    if(!BTN_TriggerUtils.skipTrigger('BTN_CVTrigger')) {
        if (Trigger.isBefore) {
            if (Trigger.isUpdate || Trigger.isInsert) {
                for (BTN_CV__c candidateItem : Trigger.new) {
                    if (!BTN_ValidationHandler.isNull(candidateItem.ResourceRequest__c)) {
                        candidateItem.ResourceRequestName__c = candidateItem.ResourceRequestName_frm__c;
                    }
                }
            }
        }
        if (Trigger.isAfter) {
            // Mateusz - BRITCRM-195 - post insert on Chatter, field in customizable list(Field Set).
            if (Trigger.isInsert) {
                    BTN_ChatterUtils.postInsertsOnHumanResourcesGroup(
                            Trigger.newMap,
                            NAME_FIELD_ON_CANDIDATE
                    );
                BTN_Utils.postInsertCandidatesStatuses(Trigger.newMap);
            }
            if (Trigger.isUpdate) {
                BTN_Utils.postUpdateCandidatesStatuses(Trigger.newMap, Trigger.oldMap);
                try {
                    BTN_ChatterUtils.postChangesOnHumanResourcesGroup(Trigger.old, Trigger.newMap, fieldsToTrack, NAME_FIELD_ON_CANDIDATE);
                } catch (System.DmlException ex) {
                    System.debug(LoggingLevel.ERROR, System.Label.ErrorWhileAddingNewPostOnChatterGroup);
                }
            }
        }
    }
}