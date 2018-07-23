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
                    alert('Error when loading cup details');
                }else{
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "Error when loading cup details"
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
                    alert('Error when loading league matches');
                }else{
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "Error when loading league matches"
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
                    "title": "Success",
                    "message": "Cup has started"
                });
                resultsToast.fire();
            }else{
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert(response.getError()[0].message);
                }else{
                    resultsToast.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": response.getError()[0].message
                    });
                    resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    initializeTodayDate: function(component){
        let today = new Date();
        let monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        let dayDigit = today.getDate();
        if(dayDigit <= 9){
            dayDigit = '0' + dayDigit;
        }
        component.set('v.today', today.getFullYear() + "-" + monthDigit + "-" + dayDigit);
    }
})