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

            if(state === "SUCCESS") {
                component.set("v.league", result.league);
                component.set("v.userSettings", result.userSettings);
            } else if(state === "ERROR") {
                let errors = response.getError();
                let message = 'Unknown error';
                if(errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.error(message);
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
    }
});