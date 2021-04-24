public with sharing class BTN_CaseEditRedirect {
    public Case myCase {set; get;}

    public BTN_CaseEditRedirect (ApexPages.StandardController stdController) {
        this.myCase = (Case) stdController.getRecord();
    }

    /**
     * @author Wojciech Mazur
     * @date   2016-10-31
     * @description does proper redirect depending on record type
     * @return PageReference to apex edt page or standard layout
    */
    public PageReference checkRecordType() {
        PageReference res = new PageReference('/'+myCase.Id+'/e?');
        if (
                myCase != null && myCase.Id !=null
                && BTN_RecordTypeUtils.isCaseInternalOnBoarding(new BTN_DAO_Case().findCaseById(myCase.Id))
                ) {
            res = Page.BTN_NewInternalOnboarding;
            //res.getParameters().putAll(ApexPages.currentPage().getParameters());
            res.getParameters().put('Id', myCase.Id);
            
        }
        res.getParameters().put(BTN_ConstantRepo.URL_PARAM_NOOVERRIDE, BTN_ConstantRepo.NOOVERRIDE);
        return res;
    }
}