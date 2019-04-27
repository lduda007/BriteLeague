({
    getDataWrapper: function(component) {
        this.showSpinner(component);

        let action = component.get("c.getDataWrapper");
        action.setParams({
            "leagueId": component.get("v.leagueId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            let errors = response.getError();

            if(state === "SUCCESS") {
                component.set("v.league", result.league);
                component.set("v.settings", result.settings);
            } else if(state === "ERROR") {
                this.getUtils(component).handleError(errors);
            }

            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    doStart: function(component) {
        this.showSpinner(component);

        let action = component.get("c.startLeague");
        action.setParams({
            "leagueId": component.get("v.leagueId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let errors = response.getError();

            if(state === "SUCCESS") {
                this.getUtils(component).showSuccessToast($A.get("$Label.c.BL_League_has_started"));
                // TODO: Publish "League Started" event
            } else if(state === "ERROR") {
                this.getUtils(component).handleError(errors);
            }

            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    showSpinner: function(component) {
        component.set("v.isSpinner", true);
    },

    hideSpinner: function(component) {
        component.set("v.isSpinner", false);
    },

    getUtils: function(component) {
        return component.find("utils");
    }
});