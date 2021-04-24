public with sharing class BTN_UserPINController {

	public Contact contact {get;set;}
	public String syncedValue {get; private set;}
	public Boolean userCannotEditPin {get; private set;}

	private String username;
	private Boolean syncWithBSEnabled;

	public BTN_UserPINController(ApexPages.StandardController stdCtrl) {
		stdCtrl.addFields(new List<String> {'Email'});
		contact = (Contact) stdCtrl.getRecord();

		username = contact.Email.split('@').get(0);

		syncWithBSEnabled = Boolean.valueOf(BTN_Utils.getBTNPropertyValue('PIN.BSEnabled'));

		User currentUser = BTN_Utils.getCurrentUser();

		Boolean userIsOwner = contact.Id == currentUser.ContactId;
		Boolean currentUserIsAdmin = BTN_PermissionSetUtils.checkIfUserIsAdmin(currentUser) || currentUser.Profile.Name == 'System Administrator';

		if (userCannotEditPin = (userIsOwner || currentUserIsAdmin) == false) {
			contact.WiFi_PIN__c = '******';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.WiFi_PIN_Uneditable));
		} else if (syncWithBSEnabled) {
			syncedValue = BTN_BSS_Service.getRadcheck(username);
			if (syncedValue != contact.WiFi_PIN__c) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.WiFi_PIN_Changed));
			}
		}
	}

	public PageReference refreshPIN() {
		try {
			contact.WiFi_PIN__c = syncedValue;
			update  contact;
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
			return null;
		}

		return new PageReference('/' + contact.Id);
	}

	public PageReference savePin() {
		try {
			if (syncWithBSEnabled) {
				BTN_BSS_DTO.ResponseStatus res = BTN_BSS_Service.setRadcheck(username, contact.WiFi_PIN__c);
				if (String.isNotBlank(res.error)) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, res.error));
					return null;
				}
			}

			update contact;
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
			return null;
		}

		return new PageReference('/' + contact.Id);
	}

}