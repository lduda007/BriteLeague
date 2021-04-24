public class BTN_SendEmailController {
    private Id itemId{set; get;}
    private Id optionalResReqId{set; get;}
    private String type{set; get;}
    private BTN_ResourceRequest__c request{set; get;}
    public List<SelectOption> emailFormatRecipients{set; get;}
    private Map<Id, sObject> recipientsContact;
    public List<Attachment> attachments{set; get;}
    public List<AttachmentWrap> attachmentsWraps {get;set;}
    public Boolean withAttachments{set; get;}
    private Id emailTemplateId;
    private Id orgWideEmailAdressId;
    public String candidateRequestId{get; set;}

    public String sender{set; get;}
    public Id recipient{set; get;}
    public String recipientEmail{set; get;}
    public String subject{set; get;}
    transient public String emailBody{set; get;}
    private BTN_DAO_ResourceRequest daoLayer{set;
        get {
            if (BTN_ValidationHandler.isNull(daoLayer)) {
                daoLayer = new BTN_DAO_ResourceRequest();
            }
            return daoLayer;
        }
    }

    private BTN_DAO_Candidate candidateDAOLayer{set;
        get {
            if (BTN_ValidationHandler.isNull(candidateDAOLayer)) {
                candidateDAOLayer = new BTN_DAO_Candidate();
            }
            return candidateDAOLayer;
        }
    }

    private BTN_DAO_Attachment attachmentDAOLayer{set;
        get {
            if (BTN_ValidationHandler.isNull(attachmentDAOLayer)) {
                attachmentDAOLayer = new BTN_DAO_Attachment();
            }
            return attachmentDAOLayer;
        }
    }
    private Map<String, Map<String, String>> sendEmailPageConfigMap;

    public static final String TYPE_PARAMETER_NAME = 'type';
    public static final String ID_PARAMETER_NAME = 'id';
    public static final String RESOURCE_REQUEST_ID_PARAMETER_NAME = 'resreq';
    public static final String REQUEST_FROM_HR_TYPE_NAME = 'hrcvreq';
    public static final String SEND_CANDIDATES_FROM_CANDIDATE_TYPE_NAME = 'cv';
    private static final String EMAIL_SUBJECT = 'subject';
    private static final String EMAIL_SENDER = 'sender';
    private static final String EMAIL_TEMPLATE = 'template';
    private static final String EMAIL_RECIPIENT = 'recipient';
    private static final String EMAIL_WITH_ATTACHMENTS = 'withAttachments';

    /**
     * @author Mateusz Przywara
     * @date   2016-05-30
     * @description Contructor get parameters which determinates source of Email Candidate / Resource Request.
     *              Creates configuration for the SendEmail page and retrieve data from data base. At the end
     *              contructor generates email template in rich text area.
     */
    public BTN_SendEmailController() {
        sendEmailPageConfigMap = new Map<String, Map<String, String>>();

        type = ApexPages.currentPage().getParameters().get(TYPE_PARAMETER_NAME); // determinated source is CV or Resource Request object
        itemId = ApexPages.currentPage().getParameters().get(ID_PARAMETER_NAME); // Id of source sObject
        // button from CV object page
        if (SEND_CANDIDATES_FROM_CANDIDATE_TYPE_NAME.equalsIgnoreCase(type)) {
            optionalResReqId =
                    ApexPages.currentPage().getParameters().get(RESOURCE_REQUEST_ID_PARAMETER_NAME); // Resource Request Id
            attachments = attachmentDAOLayer.findAttachmentsByParentId(itemId);
            Map<Id,BTN_CV__c> cvs = new Map<Id,BTN_CV__c>();
            cvs.put(itemId,candidateDAOLayer.findCandidateById(itemId));
            attachmentsWraps = wrapAttachements(attachments,cvs);


        } else { // button from Resource Request page
            optionalResReqId = itemId;
            Map<Id, BTN_CV__c> cvs =
                    new Map<Id, BTN_CV__c>(candidateDAOLayer.findCandidatesByResourceRequest(itemId));
            if(cvs.size() == 0){
                System.debug(LoggingLevel.ERROR, 'No candidates found for resource request=' + itemId);
            }
                attachmentDAOLayer.addParentNameField();
                if (cvs.size() > 0) {
                    attachments = new List<Attachment>(attachmentDAOLayer.findAttachmentsByParents(cvs.keySet()));
                    attachmentsWraps = wrapAttachements(attachments,cvs);
                } else {
                    attachments = new List<Attachment>();
                    attachmentsWraps = new List<AttachmentWrap>();
                }
        }
        daoLayer.addRequestorContactFields();
        daoLayer.addRecordTypeFields();
        daoLayer.addRequestorUserFields();
        daoLayer.addRichTextFields();
        request = daoLayer.findResourceRequestsById(optionalResReqId);
        String reqId = request.RequestorUser__r.Id;
        recipientEmail = request.RequestorEmail_frm__c;
        List<PermissionSetAssignment> psa = [
            SELECT
            	Assignee.ContactId
            FROM
            	PermissionSetAssignment
            WHERE
            	PermissionSet.Name = :BTN_PermissionSetUtils.PERMISSION_SET_HR
        ];
        List<Id> hrIdsList = new List<Id>();
        for(PermissionSetAssignment p : psa){
            hrIdsList.add(p.AssigneeId);
        }
        emailFormatRecipients = new List<SelectOption>();
        sendEmailPageConfigMap.put(RESOURCE_REQUEST_ID_PARAMETER_NAME,
                                    new Map<String, String>{
                                            EMAIL_TEMPLATE => '',
                                            EMAIL_SENDER => 'BriteERP',
                                            EMAIL_RECIPIENT => 'SELECT Id, Name, Email FROM Contact WHERE Id = :reqId',
                                            EMAIL_SUBJECT => 'Candidates for ',
                                            EMAIL_WITH_ATTACHMENTS => 'true'
                                    }
        );
        sendEmailPageConfigMap.put(SEND_CANDIDATES_FROM_CANDIDATE_TYPE_NAME,
                                    new Map<String, String>{
                                            EMAIL_TEMPLATE => '',
                                            EMAIL_SENDER => 'BriteERP',
                                            EMAIL_RECIPIENT => 'SELECT Name, Email FROM Contact WHERE Id = :reqId',
                                            EMAIL_SUBJECT => 'Candidate for ',
                                            EMAIL_WITH_ATTACHMENTS => 'true'
                                    }
        );

        Map<String, String> subjectMap = new Map<String, String>{
                BTN_ConstantRepo.RESOURCE_REQUEST_RECORD_TYPE_AUTO =>
                        String.format(System.Label.DefaultEmailSubjectRequest,
                                new String[]{request.OpportunityName_frm__c, request.Account_frm__c}
                        ),
                BTN_ConstantRepo.RESOURCE_REQUEST_RECORD_TYPE_MANUAL =>
                        String.format(System.Label.DefaultEmailSubjectRequest,
                                new String[]{request.Position__c, request.Account_frm__c}
                        )
        };

        withAttachments = Boolean.valueOf(sendEmailPageConfigMap.get(type).get(EMAIL_WITH_ATTACHMENTS));
        sender = sendEmailPageConfigMap.get(type).get(EMAIL_SENDER);
        try {
                recipientsContact =
                        new Map<Id, SObject>(
                                new List<Contact>(
                                        (List<Contact>) Database.query(
                                                sendEmailPageConfigMap.get(type).get(EMAIL_RECIPIENT)
                                        )
                                )
                        );
                for (Contact cItem : (List<Contact>) recipientsContact.values()) {
                    emailFormatRecipients.add(new SelectOption(cItem.Id, cItem.Name + ' <' + cItem.Email + '>'));
                    if (emailFormatRecipients.size() == 1) {
                        recipient = cItem.Id;
                        recipientEmail = cItem.Email;
                        break;
                    }
                }


            subject = sendEmailPageConfigMap.get(type).get(EMAIL_SUBJECT) + subjectMap.get(request.RecordType.Name);
            System.assertNotEquals(null, subject);
            candidateRequestId = '';
            generateTemplate();
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.NoRecipient));
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-30
     * @description Generates email template render html body by Salesforce Email Renderer and assign it to emailBody(on VF).
     */
    public void generateTemplate() {
        //check if user eneterd email is valid user email;
        try {
            //User u = new BTN_DAO_User().findUserByEmail(recipientEmail);
            //recipient = u.Id;
            if (!BTN_ValidationHandler.isEmpty(recipientEmail)){
                Contact c = new BTN_Dao_Contact().findContactByBritenetEmail(recipientEmail);
                recipient = c.Id;
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.NoRecipient));
                recipient = null;
                return;
            }
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.NoRecipient));
            recipient = null;
            return;
        }

        //if (sendEmailPageConfigMap.get(type).get(EMAIL_TEMPLATE) != '') {
        if(!test.isRunningTest()){
            emailBody = new PageReference(
                    '/apex/BTN_SendEmailPageTemplate?id='
                     + request.Id
                     + '&contact='
                     + recipient
                     + '&' + BTN_ConstantRepo.URL_PARAM_CANDIDATE_REQUEST_ID
                     + this.candidateRequestId
            ).getContent().toString();
        }else{
            emailBody = 'EBody';
        }
        //}
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-11
     * @description Sending email according to source sObject and provided id / type
     * @return page Reference to source sObject
     */
    public PageReference sendEmail() {
        PageReference pageReference;

        try {
            orgWideEmailAdressId = [
                    SELECT
                            Id
                    FROM
                            OrgWideEmailAddress
                    WHERE
                            DisplayName = :sender
                    LIMIT
                            1
            ].Id;
        } catch (Exception ex) {
            System.debug('**** no org wide email address');
        }

        if (!validateEmail()){
            return null;
        }

        if (!BTN_ValidationHandler.isNull(recipient)) {
            try {
                    List<String> ccRecipients = new List<String>();
                    if(!SEND_CANDIDATES_FROM_CANDIDATE_TYPE_NAME.equalsIgnoreCase(type))
                        ccRecipients.add(UserInfo.getUserEmail());

                    BTN_Email_Utils.sendEmailWithAttachments(
                            sender,
                            new List<String>{
                                    recipient
                            },
                            subject,
                            emailBody,
                            BTN_Utils.getSetOfIds(selectedAttachements()),
                            orgWideEmailAdressId,
                            itemId,
                            ccRecipients
                    );
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.EmailSuccesful));
                pageReference = new PageReference('/' + itemId);
                pageReference.setRedirect(true);
            } catch (Exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.EmailFatal));
                System.debug(LoggingLevel.ERROR, ex.getMessage());
                System.debug(LoggingLevel.ERROR, ex);
                BTN_LogUtils LOG = new BTN_LogUtils(BTN_SendEmailController.class.getName());
                LOG.debug((' Failed to send email' + ex.getMessage()).left(255), null);
            }
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.NoRecipient));
            System.debug('***** validation recipient: null');
        }
        return pageReference;
    }

    private Boolean validateEmail(){
        Boolean isValid = true;
        if (BTN_ValidationHandler.isEmpty(sender)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.NoSender));
            System.debug('***** validation sender: empty');
            isValid = false;
        }
        if (BTN_ValidationHandler.isEmpty(subject)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.NoSubject));
            System.debug('***** validation subject: empty');
            isValid = false;
        }
        if (BTN_ValidationHandler.isEmpty(emailBody)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.NoEmailBody));
            System.debug('***** validation additional comment: empty');
            isValid = false;
        }
        return isValid;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-05-12
     * @description Go back to sObject detail page
     * @return sObject page reference
     */
    public PageReference goBack() {
        return new PageReference('/' + itemId);
    }

    /**
     * @author Wojciech Mazur
     * @date   2016-11-21
     * @description get selected attachments
     * @Return returns selected attachemnts
     */
     private List<Attachment> selectedAttachements(){
        List<Attachment> selectedAtts = new List<Attachment>();
        if(attachmentsWraps ==null){
            return selectedAtts;
        }
        for(AttachmentWrap a: attachmentsWraps){
            if(a.selected){
                selectedAtts.add(a.att);
            }
        }
        return selectedAtts;
     }

    /**
     * @author Wojciech Mazur
     * @date   2016-11-21
     * @description wraps attachments
     * @Return returns wrapped attachemnts
     */
     private List<AttachmentWrap> wrapAttachements(List<Attachment> atts, Map<Id, BTN_CV__c> cvs){
        List<AttachmentWrap> wraps = new List<AttachmentWrap>();
        for(Attachment a: atts){
            AttachmentWrap aw = new AttachmentWrap(a, false, cvs.get(a.ParentId));
            wraps.add(aw);
        }
        return wraps;
     }

    /**
     * @author Wojciech Mazur
     * @date   2016-11-21
     * @description Wrapper class for Attachements
     */
    public class AttachmentWrap {
        public Attachment att {get;set;}
        public Boolean selected {get;set;}
        public BTN_CV__c cv {get;set;}

        public AttachmentWrap(Attachment a, Boolean s, BTN_CV__c c){
            this.att = a;
            this.selected = s;
            this.cv = c;
        }
    }
}