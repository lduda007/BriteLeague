({
	doInit : function(component, event, helper){
		helper.loadParentTeams(component);
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