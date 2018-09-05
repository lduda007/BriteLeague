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
                this.checkIsCurrentUserAlreadyInCompetition(component, component.get("v.user"), cup);
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
    getCurrentCupStage : function(matches){
        var currentCupStage = 64;
        do{
            if(!$A.util.isEmpty(matches[currentCupStage])){
                for (let match of matches[currentCupStage]){
                    if($A.util.isEmpty(match.Winner__c)){
                        return currentCupStage;
                    }else{
                        if(currentCupStage == 1){
                            if($A.util.isEmpty(matches[0][0].Winner__c)){
                                return 0;
                            }else{
                                return 1;
                            }
                        }
                    }
                }
            }
            currentCupStage = currentCupStage / 2;
        }while(currentCupStage > 0);
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
                if(!$A.util.isEmpty(matches)){
                    component.set("v.selectedCupStage", this.getCurrentCupStage(matches).toString());
                }
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
                this.checkIsCurrentUserAlreadyInCompetition(component, user, component.get("v.cup"));
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
                if(competition.TeamSize__c === 'Two Players Teams' && competitor.Team__r.Player1__c === user.ContactId || competitor.Team__r.Player2__c === user.ContactId){
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
})