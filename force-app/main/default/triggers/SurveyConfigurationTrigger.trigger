trigger SurveyConfigurationTrigger on SurveyConfiguration__c (before insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for (SurveyConfiguration__c item : Trigger.new) {
            item.ExternalId__c = item.Name;
            if (SurveyUtils.getSurveyConfigRecordType('Survey_Question_Provider').id == item.RecordTypeId) {
                if (!(Type.forName(item.Class__c).newInstance() instanceof SurveyUtils.SurveyQuestionProvider)) {
                    item.addError('Cannot create instance ' + item.Class__c + ' in ' + item.Name);
                }
            } else if (SurveyUtils.getSurveyConfigRecordType('Survey_Handler').id == item.RecordTypeId) {
                if(!(Type.forName(item.Class__c).newInstance() instanceof SurveyUtils.SurveyHandler)) {
                    item.addError('Cannot create instance ' + item.Class__c + ' in ' + item.Name);
                }
            }
        }
    }
}