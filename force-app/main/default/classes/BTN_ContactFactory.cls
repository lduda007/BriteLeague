public with sharing class BTN_ContactFactory {

    public static final String PARSE_DATE_FAIL_MSG = 'System was unable to parse Contact Date from BSS for Name: ';

    public static Account britenet {
        get {
            if (britenetAccount == null) {
                britenetAccount = new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME);
            }
            return britenetAccount;
        }
    }
    private static Account britenetAccount;

    public static Contact createContactFromBSUser(BTN_BSS_DTO.User userFromBS) {
        Contact internalContact;
        if (BTN_ValidationHandler.isBSSUserValid(userFromBS)) {
            try {
                internalContact = new Contact(
                        AccountId = britenet.Id,
                        Location__c = userFromBS.user_location,
                        BSexternalId__c = userFromBS.user_id,
                        FirstName = userFromBS.user_fname,
                        LastName = userFromBS.user_lname,
                        Email = userFromBS.user_mail,
                        Phone = parseBSPhone(userFromBS.user_phone),
                        Title = userFromBS.projectrole_desc,
                        Active__c = !(userFromBS.user_deleted),
                        joinDateBS__c = parseBSDate(userFromBS.user_join_date),
                        LastDayAtWork__c = parseBSDate(userFromBS.user_lastatwork_date),
                        UserEndDate__c = parseBSDate(userFromBS.user_end_date),
                        RecordTypeId = BTN_RecordTypeUtils.getRecordTypeContactInternal().Id
                );
            } catch (BTN_Exception e) {
                BTN_LogUtils log = new BTN_LogUtils('BTN_ContactFactory');
                log.error(e.getMessage() + userFromBS.user_fname + ' ' + userFromBS.user_lname, UserInfo.getUserId());
            } catch (Exception e) {
                BTN_LogUtils log = new BTN_LogUtils('BTN_ContactFactory');
                log.error(e.getMessage(), UserInfo.getUserId());
            }
        }
        return internalContact;
    }

    public static List<Contact> createContactsFromBSUsers(List<BTN_BSS_DTO.User> usersFromBS) {
        List<Contact> crmContacts = new List<Contact>();
        List<ContactWrapper> crmContactWrappers = new List<ContactWrapper>();

        for (BTN_BSS_DTO.User userFromBS : usersFromBS) {
            Contact internalContact = createContactFromBSUser(userFromBS);
            if (internalContact == null) {
                continue;
            }
            crmContactWrappers.add(new ContactWrapper(internalContact, userFromBS));
        }
        crmContacts = assignGuardiansAndLeadersToContacts(crmContactWrappers);
        return crmContacts;
    }

    private static List<Contact> assignGuardiansAndLeadersToContacts(List<ContactWrapper> crmContactWrappers) {
        List<Contact> crmContacts = new List<Contact>();

        Set<Integer> guardiansBSIds = new Set<Integer>();
        Set<Integer> leadersBSIds = new Set<Integer>();
        for (ContactWrapper crmContactWrapper : crmContactWrappers) {
            Integer guardianBSId = crmContactWrapper.userFromBS.user_guardian_id;
            Integer leaderBSId = crmContactWrapper.userFromBS.user_leader_id;
            if (guardianBSId != null) {
                guardiansBSIds.add(guardianBSId);
            }
            if (leadersBSIds != null) {
                leadersBSIds.add(leaderBSId);
            }
        }

        List<Contact> guardians = new BTN_DAO_Contact(new List<Schema.SObjectField>{
                Contact.Id,
                Contact.BSexternalId__c
        }).findContactsByBSExternalIds(guardiansBSIds);
        List<Contact> leaders = new BTN_DAO_Contact(new List<Schema.SObjectField>{
                Contact.Id,
                Contact.BSexternalId__c
        }).findContactsByBSExternalIds(leadersBSIds);

        Map<Integer, Contact> guardianBsIdToCrmId = createContactToBSIdMap(guardians);
        Map<Integer, Contact> leaderBsIdToCrmId = createContactToBSIdMap(leaders);

        for (ContactWrapper crmContactWrapper : crmContactWrappers) {
            Contact guardian = guardianBsIdToCrmId.get(crmContactWrapper.userFromBS.user_guardian_id);
            Contact leader = leaderBsIdToCrmId.get(crmContactWrapper.userFromBS.user_leader_id);
            if (guardian != null) {
                crmContactWrapper.internalContact.Guardian__c = guardian.Id;
            }
            if (leader != null) {
                crmContactWrapper.internalContact.Leader__c = leader.Id;
            }
            crmContacts.add(crmContactWrapper.internalContact);
        }
        return crmContacts;
    }

    private static Map<Integer, Contact> createContactToBSIdMap(List<Contact> contacts) {
        Map<Integer, Contact> contactToBsId = new Map<Integer, Contact>();
        for (Contact contactItem : contacts) {
            Integer contactBSId = Integer.valueOf(contactItem.BSexternalId__c);
            contactToBsId.put(contactBSId, contactItem);
        }
        return contactToBsId;
    }

    private static Date parseBSDate(String dateExpression) {
        Date parsedDate;
        if (!BTN_ValidationHandler.isNull(dateExpression)) {
            try {
                List<String> crushedBSDateString = dateExpression.split('-');
                parsedDate = Date.newInstance(
                        Integer.valueOf(crushedBSDateString.get(0)),
                        Integer.valueOf(crushedBSDateString.get(1)),
                        Integer.valueOf(crushedBSDateString.get(2))
                );
            } catch (Exception e) {
                BTN_Exception dateParseException = new BTN_Exception();
                dateParseException.initCause(e.getCause());
                dateParseException.setMessage(PARSE_DATE_FAIL_MSG + ' ' + e.getMessage());
                throw dateParseException;
            }
        }
        return parsedDate;
    }

    private static String parseBSPhone(String phone) {
        phone = phone.replace('[\\s\\(\\)\\-]', '');
        return phone;
    }

    public class ContactWrapper {
        public Contact internalContact { get; set; }
        public BTN_BSS_DTO.User userFromBS { get; set; }

        public ContactWrapper(Contact internalContact, BTN_BSS_DTO.User userFromBS) {
            this.userFromBS = userFromBS;
            this.internalContact = internalContact;
        }
    }

}