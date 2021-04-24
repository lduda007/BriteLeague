/**
 * Created by Adam on 5/28/2018.
 */

public without sharing class BTN_ContactShareUtils {
	/**
     * @author Adam Jedrys
     * @date   2018-05-23
     * @description Creates sharing records for Contact object to share recruits with leaders
     * @param recruitId Id of recruit contact to share
     * @param leaderId Id of leader user to share to
    */
	public static Boolean shareRecruitsWithContacts(Contact recruit, Id leaderId) {
		ContactShare contactShare = new ContactShare();
		contactShare.ContactId = recruit.Id;
		contactShare.UserOrGroupId = leaderId;
		contactShare.ContactAccessLevel = 'Read';

		Database.SaveResult sr = Database.insert(contactShare, false);

		if(!sr.isSuccess()){
			Database.Error err = sr.getErrors()[0];
			System.debug(err.getMessage());
		}

		return sr.isSuccess();
	}
}