({
    loadTeamGoalsByRound: function(component, event, team, round) {
        if(parseInt(team) == 1) {
            return event.getParam("team1Goals")[round - 1];
        }
        if(parseInt(team) == 2) {
            return event.getParam("team2Goals")[round - 1];
        } else {
            return 0;
        }
    },

    updateLeagueStatistics: function(component, event) {
        let action = component.get("c.updateCompetitorStatistics");
        let param1 = {"valuesmap": event.getParam("changedFields")}

        action.setParams({
            "matchId": component.get("v.recordId"),
            "changedFields": JSON.stringify(param1)
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                console.log("");

            } else {
                let resultsToast = $A.get("e.force:showToast");
                if($A.util.isUndefined(resultsToast)) {
                    alert('Error updating League Table');
                } else {
                    resultsToast.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": "Error updating League Table"
                    });
                    resultsToast.fire();
                }
            }
        });

        $A.enqueueAction(action);
    },

    updateMatchFinalScore: function(component, event) {
        let action = component.get("c.updateMatchScore");
        action.setParams({
            "matchId": component.get("v.recordId"),
            "team1Score": event.getParam("team1score"),
            "team2Score": event.getParam("team2score"),
            "team1GoalsInRound": event.getParam("team1Goals"),
            "team2GoalsInRound": event.getParam("team2Goals")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                component.set('v.simpleMatchRecord.isResolved__c', true);
                component.set("v.isReadOnly", true);

                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "message": "Score was saved."
                });
                resultsToast.fire();

                $A.get("e.c:BL_MatchScoreSaved").fire();
            } else {
                let resultsToast = $A.get("e.force:showToast");
                if($A.util.isUndefined(resultsToast)) {
                    alert('Error saving score');
                } else {
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
    }
});