({
    openLeaveCompetitionModal : function(component) {
        $A.util.addClass(component.find('backdrop'), "slds-backdrop_open");
        $A.util.addClass(component.find('leaveCompetitionModal'), "slds-slide-down-cancel");
    },
    closeLeaveCompetitionModal : function(component, event, helper) {
        helper.closeLeaveCompetitionModal(component);
    },
    leaveCompetitionAction : function(component, event, helper) {
        helper.leaveCompetition(component);
    },
})