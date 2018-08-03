({
    openLeaveCompetitionModal : function(component, event, helper) {
        document.getElementById('backdrop').classList.add("slds-backdrop_open");
        document.getElementById('leaveCompetitionModal').classList.add("slds-slide-down-cancel");
    },
    closeLeaveCompetitionModal : function(component, event, helper) {
        helper.closeLeaveCompetitionModal();
    },
    leaveCompetitionAction : function(component, event, helper) {
        helper.leaveCompetition(component);
    },
})