({
    goToTeamPage: function(component, event, helper) {
        let recordId = event.currentTarget.dataset.recordid;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
})