({
    onInit: function(component, event, helper) {
        helper.doInit(component);
        helper.setAllLeaguesColumns(component);
    },

    handleCompetitorCreated: function(component, event, helper) {
        component.find("tabset").set("v.selectedTabId", 'myLeagues');
        component.find('myLeaguesComponent').retrieve();
    },

    handleCompetitionCreated: function(component, event, helper) {
        component.find("tabset").set("v.selectedTabId", 'open');
    },

    handleRowAction: function (component, event, helper) {
        let action = event.getParam("action");
        let row = event.getParam("row");
        switch (action.name) {
            case "view":
                helper.goToRecord(component, row);
                break;
        }
    }
});