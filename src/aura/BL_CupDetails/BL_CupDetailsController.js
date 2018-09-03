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
        helper.loadCupDetails(component);
        helper.loadCupMatches(component);
    },
    openJoinToCompetitionModal : function(component, event, helper) {
        let joinComponent = component.find('joinComponent');
        joinComponent.getTeams(component.get("v.cupId"));
        $A.util.addClass(component.find('backdrop'), "slds-backdrop_open");
        $A.util.addClass(component.find('joinToCompetitionModal'), "slds-slide-down-cancel");
    },
    closeJoinToCompetitionModal : function(component, event, helper) {
        helper.closeJoinToCompetitionModal(component);
    },
    openLeaveCompetitionModal : function(component, event, helper) {
        $A.util.addClass(component.find('backdrop'), "slds-backdrop_open");
        $A.util.addClass(component.find('leaveCompetitionModal'), "slds-slide-down-cancel");
    },
    closeLeaveCompetitionModal : function(component, event, helper) {
        $A.util.removeClass(component.find('backdrop'), "slds-backdrop_open");
        $A.util.removeClass(component.find('leaveCompetitionModal'), "slds-slide-down-cancel");
    },
    handleCompetitorCreated : function(component, event, helper) {
        helper.loadCupDetails(component);
        helper.closeJoinToCompetitionModal(component);
    },
    handleCompetitorLeftCompetition : function(component, event, helper) {
        helper.loadCupDetails(component);
    },
    handleCannotJoinLeague : function(component, event, helper) {
        helper.loadCupDetails(component);
        helper.closeJoinToCompetitionModal(component);
    },
})