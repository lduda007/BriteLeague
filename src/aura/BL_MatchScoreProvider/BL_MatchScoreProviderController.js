({
    handleMatchScoreModalOpen: function(component, event, helper){
        component.find("newScoreModal").show();

    },
    recordUpdated: function(component, event, helper){
        component.set("v.team1Score", component.get("v.simpleMatchRecord.Team1_Score__c"));
        component.set("v.team2Score", component.get("v.simpleMatchRecord.Team2_Score__c"));
        component.find("newScoreModal").hide();
//        helper.updateLeagueStatistics(component, event);
    },
    handleRoundScoreSaved: function(component, event, helper){
        for(let tt=1; tt<3; tt++){
            component.set("v.simpleMatchRecord.Team"+tt+"_Score__c", event.getParam("team"+tt+"score"));
            for(let rr=1; rr<4; rr++){
                component.set("v.simpleMatchRecord.Team"+tt+"Round"+rr+"Goals__c", helper.loadTeamGoalsByRound(component, event, tt, rr));
            }
        }
        helper.updateMatchFinalScore(component, event);

        component.find("matchRecordEditor").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // record is saved successfully
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "message": "Score was saved."
                });
                resultsToast.fire();


            } else if (saveResult.state === "INCOMPLETE") {
                // handle the incomplete state
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                // handle the error state
                console.log('Problem saving score, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        });
    },

})