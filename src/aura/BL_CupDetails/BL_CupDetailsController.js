({
    doInit : function(component, event, helper){
        helper.loadCupDetails(component);
        helper.loadCupMatches(component);
        helper.getCurrentUser(component);
    },
    goToTeamPage: function (component, event, helper) {
        let recordId = event.currentTarget.dataset.recordid;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
    startCupNowAction: function (component, event, helper) {
        helper.startCupNow(component);
    },
    onScoreSubmitted: function (component, event, helper) {
        helper.loadCupDetails(component);
        helper.loadCupMatches(component);
    }
})