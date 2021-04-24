({
    handleSaveCompetitor : function(component) {
        var self = this;
        let action = component.get('c.insertCompetitor');
        let comp = component.get('v.competitorToInsert');
        comp.Competition__c = component.get('v.competitionId');
        comp.SinglePlayer__c = component.get('v.playerId');
        action.setParams({
            'competitor' : comp
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    title: "Saved",
                    message: $A.get("$Label.c.BL_You_Joined_Competition"),
                    type: 'success',
                });
                resultsToast.fire();
                let evt = component.getEvent('BL_CompetitorCreated');
                evt.fire();
            } else if (state === 'ERROR') {
                let showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Error.',
                    type: 'error',
                    message : response.getError()[0].message
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);
    }
})