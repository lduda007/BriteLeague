({
	doInit : function(component, event, helper){
		helper.loadTeamMembers(component);
    },

    goToRecord : function(component, event, handler) {
    	let recordId = event.currentTarget.dataset.recordid;
    	var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    }
})