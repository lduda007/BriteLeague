({
    onInit: function(component, event, helper) {
        helper.getDataWrapper(component);
        helper.setColumns(component);
    },

    onToggleViewMode: function(component, event, helper) {
        let viewMode = component.get("v.viewMode");

        if(viewMode === "COMPACT") {
            viewMode = "DETAILS";
        } else {
            viewMode = "COMPACT";
        }

        component.set("v.viewMode", viewMode);
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