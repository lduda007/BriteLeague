({
    doInit : function(component, event, helper){
        helper.loadTeamMembers(component);
        let lookupFilters = "RecordType.DeveloperName = 'Classic' AND Id NOT IN (SELECT Member__c FROM BL_TeamMember__c WHERE Team__c = '" + component.get("v.recordId") + "')";
        component.set("v.lookupFilters", lookupFilters);
    },

    recordUpdated : function(component, event, helper) {
        helper.getCurrentPlayer(component);
    },

    newTeamSelected : function(component, event, helper) {
        helper.tryToSelectTeam(component);
    },

    unselectTeam: function(component, event, helper) {
        event.preventDefault();
        let teamId = event.getSource().get('v.name');
        let selectedTeams = component.get("v.selectedTeams");
        selectedTeams = selectedTeams.filter((team) => team.Id != teamId);
        component.set("v.selectedTeams", selectedTeams);
    },

    saveTeamMembers: function(component, event, helper) {
        helper.addSelectedTeams(component);
    },

    removeTeam: function(component, event, helper) {
        //   TODO: ability to remove teams if the league haven't started yet
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