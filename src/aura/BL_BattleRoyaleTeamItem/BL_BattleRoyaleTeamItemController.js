({
    onInit: function(component, event, helper) {
        helper.setColumns(component);
    },

    onMainTeamNameClick: function(component, event, helper) {
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
        }
    }
});