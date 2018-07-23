({
    loadLeagueWithCompetitors : function(component){
        let action = component.get('c.loadLeagueWithCompetitors');
        let leagueId = component.get("v.leagueId");
        action.setParams({
            leagueId: leagueId
        })

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                let league = response.getReturnValue();
                component.set("v.league", league);
            }else{
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert('Error when loading league details');
                }else{
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "Error when loading league details"
                    });
                    resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    loadLeagueMatches : function(component, competitorId){
        let action = component.get('c.loadLeagueMatches');
        let leagueId = component.get("v.leagueId");
        action.setParams({
            leagueId: leagueId,
            competitorId: competitorId
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
    removeHighlightFromAllRows: function(component) {
        let rows = component.find("competitorRow")
        for(var ii=0; ii< rows.length; ii++){
            $A.util.removeClass(rows[ii], "row-highlighted");
        }
    },
    startLeagueNow : function(component){
        let action = component.get('c.startLeagueNow');
        let leagueId = component.get("v.leagueId");
        action.setParams({
            leagueId: leagueId
        })

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                let league = response.getReturnValue();
                component.set("v.league", league);
                this.loadLeagueMatches(component, null);
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": "Success",
                    "message": "League has started"
                });
                resultsToast.fire();
            }else{
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert(response.getError()[0].message);
                }else{
                    resultsToast.setParams({
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