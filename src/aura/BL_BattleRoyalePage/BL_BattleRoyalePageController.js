({
    getData: function(component, event, helper) {
        let action = component.get("c.getMatchesDataWrapper");
        let leagueId = component.get("v.leagueId");
        action.setParam("leagueId", leagueId);

        action.setCallback(this, (response) => {
            let state = response.getState();
            if (state === "SUCCESS") {
                let settings = response.getReturnValue();
                component.set("v.settings", settings);
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
})