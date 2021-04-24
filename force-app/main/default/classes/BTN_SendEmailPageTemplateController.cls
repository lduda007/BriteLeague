public with sharing class BTN_SendEmailPageTemplateController {
    transient public final BTN_ResourceRequest__c mysObject{set; get;}
    transient public final Contact contactPerson{set; get;}
    transient public final Id candidateRequestId{set; get;}
    transient public List<BTN_CV__c> candidates{set; get;}
    private BTN_DAO_Contact contactDAOLayer{set;
        get {
            if (BTN_ValidationHandler.isNull(contactDAOLayer)) {
                contactDAOLayer = new BTN_DAO_Contact();
            }
            return contactDAOLayer;
        }
    }
    private BTN_DAO_User userDAOLayer{set;
        get {
            if (BTN_ValidationHandler.isNull(userDAOLayer)) {
                userDAOLayer = new BTN_DAO_User();
            }
            return userDAOLayer;
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-01
     * @description Contructor responsible for proper link generating and retrieving Contact data for template
    */
    public BTN_SendEmailPageTemplateController(ApexPages.StandardController stdController) {
        this.mysObject = (BTN_ResourceRequest__c) stdController.getRecord();
        this.candidateRequestId = ApexPages.currentPage().getParameters().get(BTN_ConstantRepo.URL_PARAM_CANDIDATE_REQUEST_ID);
        Id contactId = ApexPages.currentPage().getParameters().get(BTN_ConstantRepo.CONTACT_PARAMETER_NAME);
        //userDAOLayer.addUserFields();
        //contactPerson = userDAOLayer.findUserById(userId);
        contactPerson = new BTN_DAO_Contact().findContactById(contactId);
        candidates = new List<BTN_CV__c>(new BTN_DAO_Candidate().addContactFields().findCandidatesByResourceRequest(mysObject.Id));
    }
}