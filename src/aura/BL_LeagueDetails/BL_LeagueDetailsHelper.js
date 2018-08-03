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
                this.checkIsCurrentUserAlreadyInCompetition(component, component.get("v.user"), league);
            }else{
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert($A.get("$Label.c.BL_Error_when_loading_league_details"));
                }else{
                    resultsToast.setParams({
                        "title": $A.get("$Label.c.BL_Error"),
                        "message": $A.get("$Label.c.BL_Error_when_loading_league_details")
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
                    alert($A.get("$Label.c.BL_Error_when_loading_league_matches"));
                }else{
                    resultsToast.setParams({
                        "type": "error",
                        "title": $A.get("$Label.c.BL_Error"),
                        "message": $A.get("$Label.c.BL_Error_when_loading_league_matches")
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
                    "title": $A.get("$Label.c.BL_Success"),
                    "message": $A.get("$Label.c.BL_League_has_started")
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
                this.checkIsCurrentUserAlreadyInCompetition(component, user, component.get("v.league"));
            }
        });
        $A.enqueueAction(action);
    },
    closeJoinToCompetitionModal : function(){
        document.getElementById('backdrop').classList.remove("slds-backdrop_open");
        document.getElementById('joinToCompetitionModal').classList.remove("slds-slide-down-cancel");
    },
    checkIsCurrentUserAlreadyInCompetition : function(component, user, competition){
        if($A.util.isEmpty(user) || $A.util.isEmpty(competition)){
            return;
        }
        if(!$A.util.isEmpty(competition.Competitors__r)){
            for (let competitor of competition.Competitors__r){
                if(competitor.Team__r.Player1__c === user.ContactId || competitor.Team__r.Player2__c === user.ContactId){
                    component.set("v.isCurrentUserAlreadyInCompetition", true);
                    return;
                }
            }
        }
        component.set("v.isCurrentUserAlreadyInCompetition", false);
    },
})