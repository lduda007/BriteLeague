({
    onInit: function(component, event, helper) {
        helper.getDataWrapper(component);
    },

    onStart: function(component, event, helper) {
        helper.doStart(component);
    },

    onJoin: function(component, event, helper) {
        let joinLeagueModal = component.find("joinLeague");
        joinLeagueModal.show();
    }
});