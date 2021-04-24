trigger BTN_AttachmentTrigger on Attachment (after insert) {
    private static String ATTACHMENT_ID_NOT_CV = 'nie cv';
    Set<Id> affiliatedCandidates = new Set<Id>();
    Set<Id> attachments = new Set<Id>();
    if (!BTN_TriggerUtils.skipTrigger('BTN_AttachmentTrigger')) {
        for (Attachment attaItem : Trigger.New) {
            if (!attaItem.Name.contains(ATTACHMENT_ID_NOT_CV)) {
                attachments.add(attaItem.Id);
                affiliatedCandidates.add(attaItem.ParentId);
            }
        }
        List<BTN_CV__c> candidateList = new List<BTN_CV__c>([
                SELECT
                        Id, LastAttachmentId__c,
                (
                        SELECT
                                Id, Name
                        FROM
                                Attachments
                        WHERE
                                Id IN :attachments
                )
                FROM
                        BTN_CV__c
                WHERE
                        Id IN :affiliatedCandidates
        ]);

        for (BTN_CV__c candidate : candidateList) {
            candidate.LastAttachmentId__c = candidate.Attachments.get(0).Id;
        }
        update candidateList;
    }

}