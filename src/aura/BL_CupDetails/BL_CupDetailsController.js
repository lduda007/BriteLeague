({
    doInit : function(component, event, helper){
        helper.loadCupDetails(component);
        helper.loadCupMatches(component);
        helper.getCurrentUser(component);
    },
    goToTeamPage: function (component, event, helper) {
        let recordId = event.currentTarget.dataset.recordid;
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/bl-team/"+recordId
        });
        urlEvent.fire();
    },
    startCupNowAction: function (component, event, helper) {
        helper.startCupNow(component);
    },
    onScoreSubmitted: function (component, event, helper) {
        helper.loadCupMatches(component);
    },
    openJoinToCompetitionModal : function(component, event, helper) {
        let joinComponent = component.find('joinComponent');
        joinComponent.getTeams(component.get("v.cupId"));
        document.getElementById('backdrop').classList.add("slds-backdrop_open");
        document.getElementById('joinToCompetitionModal').classList.add("slds-slide-down-cancel");
    },
    closeJoinToCompetitionModal : function(component, event, helper) {
        helper.closeJoinToCompetitionModal();
    },
    openLeaveCompetitionModal : function(component, event, helper) {
//        let leaveLeagueComponent = component.find('leaveLeagueComponent');
//        leaveLeagueComponent.getTeams(component.get("v.leagueId"));
        document.getElementById('backdrop').classList.add("slds-backdrop_open");
        document.getElementById('leaveCompetitionModal').classList.add("slds-slide-down-cancel");
    },
    closeLeaveCompetitionModal : function(component, event, helper) {
        document.getElementById('backdrop').classList.remove("slds-backdrop_open");
        document.getElementById('leaveCompetitionModal').classList.remove("slds-slide-down-cancel");
    },
    handleCompetitorCreated : function(component, event, helper) {
        helper.loadCupDetails(component);
        helper.closeJoinToCompetitionModal();
    },
    handleCompetitorLeftCompetition : function(component, event, helper) {
        helper.loadCupDetails(component);
    },
})