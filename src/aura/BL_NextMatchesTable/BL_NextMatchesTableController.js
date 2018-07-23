({
    goToTeamPage: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/bl-team/"+recordId
        });
        urlEvent.fire();
    },
    goToLeaguePage: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/bl-league/"+recordId
        });
        urlEvent.fire();
    },
})