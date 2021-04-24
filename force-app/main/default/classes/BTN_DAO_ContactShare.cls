/**
 * Created by Adam on 5/28/2018.
 */

public class BTN_DAO_ContactShare extends BTN_DAO {

	public BTN_DAO_ContactShare(){}

	public BTN_DAO_ContactShare(List<Schema.SObjectField> customFields) {
		setCustomFields(customFields);
	}

	public override Schema.SObjectType getSObjectType() {
		return ContactShare.sObjectType;
	}

	public override List<Schema.SObjectField> getSObjectFields() {
		return new List<Schema.SObjectField>{
				ContactShare.Id,
				ContactShare.ContactId,
				ContactShare.UserOrGroupId,
				ContactShare.RowCause,
				ContactShare.ContactAccessLevel
		};
	}

	public List<ContactShare> findByContactIdAndRowCause(Id contactId, String rowCause) {
		return findSObjectsBy(new List<SearchCondition> {
				new SearchCondition('ContactId', '=', contactId),
				new SearchCondition('AND RowCause', '=', rowCause)
		});
	}
}