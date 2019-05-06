({
    doInit : function(component, event, helper){
        helper.fetchRecords(component);
        helper.fetchReceivedInvitations(component);
        helper.fetchSentInvitations(component);
        helper.getCurrentUser(component);
    },
    
    saveRecord : function(component, event, helper) {
        helper.saveRecord(component,event);
    },

    onTeamCreatedAction : function(component, event, helper) {
        helper.fetchSentInvitations(component);
        helper.fetchRecords(component);
        component.set("v.selectedTabId", 'sentInvitations');
    },
    
    newTeam : function(component, event, helper) {
        document.getElementById("newTeamModal").style.display = "block";
        $A.util.addClass(component.find("modal-dialog-background"), "slds-backdrop_open");
    },

    hideModal : function(component,event, helper){
        document.getElementById("newTeamModal").style.display = "none" ;
        $A.util.removeClass(component.find("modal-dialog-background"), "slds-backdrop_open");
        component.set("v.selectedPlayer" , {});
        component.set("v.team.Name" , '');
    },

    acceptInvitation : function(component,event,helper){
        helper.confirmInvitation(component,event,true);
    },

    rejectInvitation : function(component,event,helper){
        helper.confirmInvitation(component,event,false);
    },

    deleteTeam : function(component,event,helper){
        helper.deleteTeam(component,event);
    },

    goToTeam : function(component,event,helper){
        helper.goToTeam(component,event);
    }
})