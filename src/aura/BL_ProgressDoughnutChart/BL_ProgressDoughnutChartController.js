({
    onDataLoaded: function(component, event, helper) {
        component.set("v.isDataLoaded", true);
        if(component.get("v.isScriptsLoaded")) {
            helper.generateCharts(component);
        }
    },

    onScriptsLoaded: function(component, event, helper) {
        component.set("v.isScriptsLoaded", true);
        if(component.get("v.isDataLoaded")) {
            helper.generateCharts(component);
        }
    }
});