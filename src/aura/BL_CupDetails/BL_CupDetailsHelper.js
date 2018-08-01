({
    loadCupDetails : function(component, event, helper){
        let action = component.get('c.loadCupDetails');
        let cupId = component.get("v.cupId");
        action.setParams({
            cupId: cupId
        })

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                let cup = response.getReturnValue();
                component.set("v.cup", cup);
            }else{
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert($A.get("$Label.c.BL_Error_when_loading_cup_details"));
                }else{
                    resultsToast.setParams({
                        "title": $A.get("$Label.c.BL_Error"),
                        "message": $A.get("$Label.c.BL_Error_when_loading_cup_details")
                    });
                    resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    loadCupMatches : function(component, event, helper){
        let action = component.get('c.loadCupRoundToMatchesMap');
        let cupId = component.get("v.cupId");
        action.setParams({
            cupId: cupId
        })

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                let matches = response.getReturnValue();
                component.set("v.matches", matches);
            }else{
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert($A.get("$Label.c.BL_Error_when_loading_league_matches"));
                }else{
                    resultsToast.setParams({
                        "title": $A.get("$Label.c.BL_Error"),
                        "message": $A.get("$Label.c.BL_Error_when_loading_league_matches")
                    });
                    resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    startCupNow : function(component){
        let action = component.get('c.startCupNow');
        let cupId = component.get("v.cupId");
        action.setParams({
            cupId: cupId
        })

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                let cup = response.getReturnValue();
                component.set("v.cup", cup);
                this.loadCupMatches(component, null);
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": $A.get("$Label.c.BL_Success"),
                    "message": $A.get("$Label.c.BL_Cup_has_started")
                });
                resultsToast.fire();
            }else{
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert(response.getError()[0].message);
                }else{
                    resultsToast.setParams({
                        "type": "error",
                        "title": $A.get("$Label.c.BL_Error"),
                        "message": response.getError()[0].message
                    });
                    resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    getCurrentUser : function(component){
        let action = component.get('c.getCurrentUser');
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                let user = response.getReturnValue();
                component.set("v.user", user);
            }
        });
        $A.enqueueAction(action);
    },
})