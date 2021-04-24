/**
 * @author Mateusz Przywara
 * @date   2016-08-19
 * @description BTN_ContactUtils Utils Class to support SFDC Contact
*/
public with sharing class BTN_ContactUtils {
    private static final String PARSE_DATE_FAIL_MSG = 'System was unable to parse Contact Date from BSS for Name: ';
    private static final String WHITE_SPACE = ' ';
    private static BTN_DAO_Contact doaContact = new BTN_DAO_Contact();

    private static BTN_DAO_Account accountDAO {
        set;
        get {
            if (BTN_ValidationHandler.isNull(accountDAO)) {
                accountDAO = new BTN_DAO_Account();
            }
            return accountDAO;
        }
    }

    /**
     * @author Konrad Kozaczuk
     * @date 2016-10-13
     * @description addContact Method upserts given contact
     * @param Contact
    */
    public static void addContact(Contact contact){
        insert contact;
    }

    public static Map<String, Integer> MAP_PROJECT_ROLE_ID_BY_DESC {
        set;
        get {
            if (MAP_PROJECT_ROLE_ID_BY_DESC == null) {
                MAP_PROJECT_ROLE_ID_BY_DESC = new Map<String, Integer>();
                for (BTN_ProjectRolesSetting__c item : BTN_ProjectRoleUtils.getProjectRoles()) {
                    MAP_PROJECT_ROLE_ID_BY_DESC.put(item.Name, Integer.valueOf(item.BSExternalId__c));
                }
            }
            return MAP_PROJECT_ROLE_ID_BY_DESC;
        }
    }

    public static Map<Integer, String> MAP_PROJECT_ROLE_DESC_BY_ID {
        set;
        get {
            if (MAP_PROJECT_ROLE_DESC_BY_ID == null) {
                MAP_PROJECT_ROLE_DESC_BY_ID = new Map<Integer, String>();
                for (BTN_ProjectRolesSetting__c item : BTN_ProjectRoleUtils.getProjectRoles()) {
                    MAP_PROJECT_ROLE_DESC_BY_ID.put(Integer.valueOf(item.BSExternalId__c), item.Name);
                }
            }
            return MAP_PROJECT_ROLE_DESC_BY_ID;
        }
    }

    public static List<Contact> newContactFromBS(List<BTN_BSS_DTO.User> bsUserList) {
        return BTN_ContactFactory.createContactsFromBSUsers(bsUserList);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-24
     * @description Method parse Recruit Skills to child Objects for SOQL search handling.
     * @param contacts Contacts for which Search Fragments will be created
     * @return List<Database.SaveResult> Insert Result
    */
    @future
    public static void createSearchFragments(Set<Id> contactIds) {
        List<BTN_SearchFragment__c> searchFragments = new List<BTN_SearchFragment__c>();
        String tmp;
        String baseTextPart;
        Integer indx;
        for (Contact contactItem : new BTN_DAO_Contact().findContactsInIdSet(contactIds)) {
            if (String.isNotBlank(contactItem.Skills__c)) {
                tmp = contactItem.Skills__c;
                do {
                    baseTextPart = tmp.left(255);
                    if (((indx = baseTextPart.lastIndexOf(WHITE_SPACE)) < 1) || (baseTextPart.length() == (tmp.length()))) {
                        indx = baseTextPart.length();
                    }
                    searchFragments.add(
                            new BTN_SearchFragment__c(
                                    Contact__c = contactItem.Id,
                                    TextPart__c = baseTextPart.left(indx).toLowerCase()
                            )
                    );
                    tmp = tmp.substring(indx);// + 1 correction to substract whitespace
                } while (String.isNotBlank(tmp));
            }

            // Add 1 : 1 other fields (text 255)
            if (String.isNotBlank(contactItem.Comment__c)) {
                searchFragments.add(
                        new BTN_SearchFragment__c(
                                Contact__c = contactItem.Id,
                                TextPart__c = contactItem.Comment__c.toLowerCase()
                        )
                );
            }
            if (String.isNotBlank(contactItem.Position__c)) {
                searchFragments.add(
                        new BTN_SearchFragment__c(
                                Contact__c = contactItem.Id,
                                TextPart__c = contactItem.Position__c.toLowerCase()
                        )
                );
            }
            if (String.isNotBlank(contactItem.Location__c)) {
                searchFragments.add(
                        new BTN_SearchFragment__c(
                                Contact__c = contactItem.Id,
                                TextPart__c = contactItem.Location__c.toLowerCase()
                        )
                );
            }
        }
        Database.insert(searchFragments);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-10-24
     * @description Method deletes Search fragments for specified Contacts.
     * @param contacts Contacts for which Search Fragments will be deleted
     * @return List<Database.SaveResult> Delete Result
    */
    @future
    public static void deleteSearchFragmentsForContacts(Set<Id> contactIds) {
        Database.delete(
                new List<BTN_SearchFragment__c>(new BTN_DAO_SearchFragment().findSearchFragmentsForContact(contactIds))
        );
    }

	public static Contact updateInternalContactWithBSAccountDetails(Id contactId, Integer bsId) {
		Contact result = new Contact(
				Id = contactId,
				BSexternalId__c = bsId
		);
		update result;
		return result;
	}

	public static Contact updateToInternalWithOnboardingDetails(Id contactId, Case onboardingCase) {
		Contact result = new Contact(
				Id = contactId,
				RecordTypeId = BTN_RecordTypeUtils.getRecordTypeContactInternal().Id,
				Title = onboardingCase.NewUserProjectRole__c,
				ReportsToId = onboardingCase.Leader__c,
				Leader__c = onboardingCase.Leader__c,
				Guardian__c = onboardingCase.Guardian__c,
				Email = onboardingCase.NewUserEmail__c,
				joinDateBS__c = onboardingCase.WorkStartDate__c,
				MailingPostalCode = onboardingCase.ZipCode__c,
				MailingStreet = onboardingCase.Street__c,
				MailingCity = onboardingCase.City__c,
				PersonalEmail__c = onboardingCase.PersonalEmail__c,
				PersonalPhone__c = onboardingCase.PersonalPhone__c,
				Position__c = onboardingCase.NewUserTitle__c,
				Location__c = onboardingCase.Location__c,
				SkillAssessment__c = true,
				Freelancer__c = onboardingCase.Freelancer__c
		);
		update result;
		return result;
	}

	public static String setBritenetEmailForInternalContact(Contact contactData) {
		String result;
		if (contactData.Email == null) {
			Integer emailSuffix = 1;
			result = contactData.FirstName + '.' + contactData.LastName;
			result =
					result.deleteWhitespace()
							.toLowerCase()
							.replaceAll('\\ł', 'l')
							.replaceAll('\\ę', 'e')
							.replaceAll('\\ó', 'o')
							.replaceAll('\\ś', 's')
							.replaceAll('\\ź', 'z')
							.replaceAll('\\ż', 'z')
							.replaceAll('\\ć', 'c')
							.replaceAll('\\ń', 'n')
							.replaceAll('\\ą', 'a');
			while (new BTN_DAO_Contact().findContactByBritenetEmail(result + BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL) != null) {
				result += String.valueOf(emailSuffix);
				emailSuffix++;
			}
			result += BTN_ConstantRepo.BRITENET_MAIL_SUFFIX_PL;
		} else {
			result = contactData.Email;
		}
		return result;
	}
}