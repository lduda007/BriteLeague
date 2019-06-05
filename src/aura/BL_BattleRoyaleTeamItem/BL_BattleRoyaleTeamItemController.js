({
    onInit: function(component, event, helper) {
        helper.setColumns(component);
    },

    onTeamNameClick: function(component, event, helper) {
        let teamId = event.getSource().get("v.value");
        let utils = helper.getUtils(component);
        utils.goToRecord(teamId);
    },

    onRowAction: function(component, event, helper) {
        let action = event.getParam("action");
        let row = event.getParam("row");

        switch(action.name) {
            case 'goToRecord':
                let utils = helper.getUtils(component);
                utils.goToRecord(row.teamId);
                break;
            case 'selectTeam':
                let teamId = row.teamId;
                let teamSelectedEvent = $A.get("e.c:BL_TeamSelectedEvent");
                teamSelectedEvent.setParams({
                    teamId : teamId
                });
                teamSelectedEvent.fire();
                break;
        }
    }
});