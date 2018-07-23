
({
    loadTeamGoalsByRound: function(component, event, team, round){
        if(parseInt(team) == 1){
            return event.getParam("team1Goals")[round-1];
        }
        if(parseInt(team) == 2){
            return event.getParam("team2Goals")[round-1];
        }else{
            return 0;
        }
    },
    updateLeagueStatistics: function(component, event){
        console.log("changed fields: "+JSON.stringify(event.getParam("changedFields")));
        let action = component.get("c.updateCompetitorStatistics");
        let param1 = {"valuesmap" : event.getParam("changedFields")}

        action.setParams({
            "matchId": component.get("v.recordId"),
            "changedFields" : JSON.stringify(param1)
//            "changedFields" : event.getParam("changedFields")

        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                console.log("");

            }else{
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert('Error when creating pricebookentry');
                }else{
                    resultsToast.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": "Error when creating pricebookentry"
                    });
                    resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    updateMatchFinalScore: function(component, event){
        console.log('event params: '+JSON.stringify(event.getParams()));
        let action = component.get("c.updateMatchScore");
        action.setParams({
            "matchId": component.get("v.recordId"),
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                console.log("");

            }else{
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert('Error when creating pricebookentry');
                }else{
                    resultsToast.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": "Error when creating pricebookentry"
                    });
                    resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
})