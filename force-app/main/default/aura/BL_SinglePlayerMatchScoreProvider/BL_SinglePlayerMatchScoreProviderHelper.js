({
    getMatchDetails : function(component){
        var self = this;
        let action = component.get('c.getMatchDetails');
        let matchId = component.get("v.matchId");
        action.setParams({
            matchId: matchId
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                let match = response.getReturnValue();
                component.set("v.match", match);
                self.generateScoreOptions(component);
            }
        });
        $A.enqueueAction(action);
    },
    generateScoreOptions : function(component){
        let scoreOptions = component.get("v.scoreOptions");
        if(component.get("v.editMode")){
            if($A.util.isEmpty(scoreOptions)){
                for(let ii=0; ii<10; ii++){
                    scoreOptions.push(ii);
                }
                component.set("v.scoreOptions", scoreOptions);
            }
            component.set("v.match.Team1_Score__c", 0);
            component.set("v.match.Team2_Score__c", 0);
        }
    },
    saveMatchScore : function(component){
        let serviceDispatcher = component.find("serviceDispatcher");
        serviceDispatcher.callService('uiService','showSpinner');
        let self = this;
        let action = component.get('c.saveMatchScoreAndUpdateCompetitorsStatistics');
        let match = component.get("v.match");
        action.setParams({
            match: match
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                let appEvent = $A.get("e.c:BL_MatchScoreSaved");
                appEvent.fire();
                self.getMatchDetails(component);
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": $A.get("$Label.c.BL_Success"),
                    "message": "Score saved"
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
                console.error(response.getError()[0].message);
            }
            serviceDispatcher.callService('uiService','hideSpinner');
        });
        $A.enqueueAction(action);
    }
})