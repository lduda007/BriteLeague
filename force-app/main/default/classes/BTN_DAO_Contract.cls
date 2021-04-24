/**
 * Created by Adam on 5/24/2018.
 */

public class BTN_DAO_Contract extends BTN_DAO {

	public BTN_DAO_Contract(){}

	public BTN_DAO_Contract(List<Schema.SObjectField> customFields) {
		setCustomFields(customFields);
	}

	public override Schema.SObjectType getSObjectType() {
		return BTN_Contract__c.sObjectType;
	}

	public override List<Schema.SObjectField> getSObjectFields() {
		return new List<Schema.SObjectField>{
				BTN_Contract__c.Id,
				BTN_Contract__c.Description__c,
				BTN_Contract__c.Company__c,
				BTN_Contract__c.Contact__c,
				BTN_Contract__c.ContractLength__c,
				BTN_Contract__c.ContractType__c,
				BTN_Contract__c.EndDate__c,
				BTN_Contract__c.NoticePeriod__c,
				BTN_Contract__c.NoticePeriodComment__c,
				BTN_Contract__c.Responsibilities__c,
				BTN_Contract__c.Reviewed__c,
				BTN_Contract__c.SalaryB2B__c,
				BTN_Contract__c.SalaryB2B_frm__c,
				BTN_Contract__c.SalaryUoP__c,
				BTN_Contract__c.SalaryUoP_frm__c,
				BTN_Contract__c.StartDate__c,
				BTN_Contract__c.StartDateComment__c
		};
	}

	public List<BTN_Contract__c> findByContactsIds(Set<Id> contactIds) {
		return findSObjectsBy(new List<SearchCondition> {
				new SearchCondition('Contact__c', 'IN', contactIds)
		});
	}
}