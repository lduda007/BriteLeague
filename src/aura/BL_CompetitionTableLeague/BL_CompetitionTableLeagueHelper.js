({
    loadCompetitionWithCompetitors : function(component){
        let action = component.get('c.loadCompetitionWithCompetitors');
        action.setParams({
            competitionId: component.get("v.recordId")
        })

        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.competition", result);
                this.checkIsCurrentUserAlreadyInCompetition(component, component.get("v.user"), result);
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
            component.set("v.showSpinner", false);
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
                this.loadCompetitionMatches(component, null);
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
    closeJoinToCompetitionModal : function(component){
        $A.util.removeClass(component.find('backdrop'), "slds-backdrop_open");
        $A.util.removeClass(component.find('joinToCompetitionModal'), "slds-slide-down-cancel");
    },
    checkIsCurrentUserAlreadyInCompetition : function(component, user, competition){
        if($A.util.isEmpty(user) || $A.util.isEmpty(competition)){
            return;
        }
        if(!$A.util.isEmpty(competition.Competitors__r)){
            for (let competitor of competition.Competitors__r){
                if(competition.TeamSize__c === 'Two Players' && competitor.Team__r.Player1__c === user.ContactId || competitor.Team__r.Player2__c === user.ContactId){
                    component.set("v.isCurrentUserAlreadyInCompetition", true);
                    return;
                }else if(competition.TeamSize__c === 'Single Player' && competitor.Team__r.Player1__c === user.ContactId){
                    component.set("v.isCurrentUserAlreadyInCompetition", true);
                    return;
                }
            }
        }
        component.set("v.isCurrentUserAlreadyInCompetition", false);
    },

    loadCompetitionMatches: function(component) {

    }
});