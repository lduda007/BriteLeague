({
    leaveCompetition : function(component, user, competition){
        let action = component.get('c.removeCompetitorFromCompetition');
        let playerId = component.get("v.playerId");
        let competitionId = component.get("v.competitionId");

        action.setParams({
            playerId: playerId,
            competitionId: competitionId
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": $A.get("$Label.c.BL_Success"),
                    "message": $A.get("$Label.c.BL_You_ve_left_the_competition")
                });
                resultsToast.fire();
                let evt = component.getEvent('BL_CompetitorLeftCompetition');
                evt.fire();
                this.closeLeaveCompetitionModal();
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
    closeLeaveCompetitionModal : function() {
        document.getElementById('backdrop').classList.remove("slds-backdrop_open");
        document.getElementById('leaveCompetitionModal').classList.remove("slds-slide-down-cancel");
    },
})