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
    }
});