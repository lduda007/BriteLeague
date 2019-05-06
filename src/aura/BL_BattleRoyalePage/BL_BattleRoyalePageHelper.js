({
    doInit: function(component) {
        let action = component.get("c.getDataWrapper");
        let leagueId = component.get("v.leagueId");
        action.setParam("leagueId", leagueId);

        action.setCallback(this, (response) => {
            let state = response.getState();
            let result = response.getReturnValue();

            if (state === "SUCCESS") {
                component.set("v.settings", result.settings);
                component.set("v.matches", result.matches);
            } else {
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert($A.get("$Label.c.BL_Error_when_loading_league_details"));
                } else {
                    resultsToast.setParams({
                        "title": $A.get("$Label.c.BL_Error"),
                        "message": $A.get("$Label.c.BL_Error_when_loading_league_details")
                    });
                    resultsToast.fire();
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    }
});