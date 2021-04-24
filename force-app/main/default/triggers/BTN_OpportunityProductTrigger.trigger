trigger BTN_OpportunityProductTrigger on OpportunityLineItem (before insert, before update) {
	for(OpportunityLineItem item : Trigger.New) {

	}
}