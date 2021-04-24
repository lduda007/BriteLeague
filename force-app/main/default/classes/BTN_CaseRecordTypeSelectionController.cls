/**
 * @author Mateusz Przywara
 * @date   2016-09-06
 * @description BTN_CaseRecordTypeSelectionController Controller for Page with Record Type dropdown list.
*/
public with sharing class BTN_CaseRecordTypeSelectionController {
    private static final String MASTER_RECORD_TYPE_NAME = 'Master';
    private static final String RECORD_TYPE_PARAM = 'RecordType=';
    private static final String OBJECT_PARAM = 'ent=';
    private static final String RETURL_PARAM = 'retURL=';
    private static final String RETURL = 'retURL';
    private static final String DEFAULT_RETURL = '/500';
    // Keys are Developer Names
    private Map<String, String> linkByRecordTypeName = new Map<String, String> {
            BTN_ConstantRepo.CASE_EXTERNAL_ONBOARDING_RECORDTYPE => '/500/e?',
            BTN_ConstantRepo.CASE_EXTERNAL_OFFBOARDING_RECORDTYPE => '/500/e?',
            BTN_ConstantRepo.CASE_INTERNAL_ONBOARDING_RECORDTYPE => '/apex/BTN_NewInternalOnboardingForm?',
            BTN_ConstantRepo.CASE_INTERNAL_OFFBOARDING_RECORDTYPE => '/500/e?'
    };
    public Map<Id, RecordType> recordTypeMap {set; get {
        return new Map<Id, RecordType>(new BTN_DAO_RecordType().findCaseRecordTypes());
    }}
    public Id selectedRecordType {set; get;}

    public BTN_CaseRecordTypeSelectionController() {
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-06
     * @description getCaseRecordTypes Method get Record Types for SFDC Case and
    */
    public List<SelectOption> getCaseRecordTypes() {
        List<SelectOption> selectOptions = new List<SelectOption>();
        List<RecordTypeInfo> recordTypeInfos = Case.getSobjectType().getDescribe().recordTypeInfos;
        for (RecordTypeInfo infoItem : recordTypeInfos) {
            if (infoItem.isAvailable() && (infoItem.getName() != MASTER_RECORD_TYPE_NAME)) {
                selectOptions.add(new SelectOption((String) infoItem.getRecordTypeId(), infoItem.getName()));
            }
        }
        return selectOptions;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-06
     * @description redirectToNewCaseForm
    */
    public PageReference redirectToNewCaseForm() {
        PageReference p;
        if (!BTN_ValidationHandler.isNull(selectedRecordType)) {
             p = new PageReference(getLink());
        }
        return p;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-06
     * @description getSelectedRecordTypeName
    */
    private String getSelectedRecordTypeName() {
        return recordTypeMap.get(selectedRecordType).DeveloperName;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-07
     * @description cancel
    */
    public PageReference cancel() {
        return new PageReference(getRetURL());
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-07
     * @description cancel
    */
    public String getRetURL() {
        String result;
        if ((result = ApexPages.currentPage().getParameters().get(RETURL)) == null) {
            result = DEFAULT_RETURL;
        }
        return result;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-07
     * @description getLink
    */
    public String getLink() {
        return (linkByRecordTypeName.get(getSelectedRecordTypeName()) +
                RECORD_TYPE_PARAM + selectedRecordType +
                '&' + OBJECT_PARAM + Case.getSObjectType().getDescribe().getName() +
                '&' + RETURL_PARAM + '/apex/BTN_CaseRecordTypeSelectionPage');
    }
}