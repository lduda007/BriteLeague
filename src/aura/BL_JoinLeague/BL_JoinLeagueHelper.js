({
    getPlayerActiveTeams: function(component) {
        let leagueId = component.get("v.leagueId");
        let actionTeams = component.get('c.getPlayerTeams');
        actionTeams.setParams({
            leagueId: leagueId
        });
        actionTeams.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                let teams = response.getReturnValue();
                component.set('v.teamsList', teams);
            } else if(state === 'ERROR') {

            }
        });
        $A.enqueueAction(actionTeams);
    },

    handleSaveCompetitor: function(component, event) {
        let self = this;
        let action = component.get('c.insertCompetitor');
        let comp = component.get('v.competitorToInsert');
        comp.League__c = component.get('v.leagueId');
        action.setParams({
            'competitor': comp
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    title: "Saved",
                    message: $A.get("$Label.c.BL_You_Joined_Competition"),
                    type: 'success',
                });
                resultsToast.fire();
                self.getPlayerActiveTeams(component);
                let evt = component.getEvent('BL_CompetitorCreated');
                evt.fire();
            } else if(state === 'ERROR') {
                let showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title: 'Error',
                    type: 'error',
                    message: response.getError()[0].message
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);
    }
});