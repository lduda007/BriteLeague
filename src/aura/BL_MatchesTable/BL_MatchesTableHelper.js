({
    loadLeagueMatches : function(component, competitorId) {
        let action = component.get('c.loadLeagueMatches');
        action.setParams({
            leagueId: component.get("v.recordId"),
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

    getCurrentUser : function(component){
        let action = component.get('c.getCurrentUser');
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                let user = response.getReturnValue();
                component.set("v.playerId", user.ContactId);
            }
        });
        $A.enqueueAction(action);
    },

    getMatchesForTeam: function(matches, teamId) {
        let teamMatches = [];

        for(let i = 0; i < matches.length; i++) {
            let match = matches[i];
            if(match.Team1__r.Team__c == teamId || match.Team2__r.Team__c == teamId) {
                teamMatches.push(match);
            }
        }

        return teamMatches;
    }
});