({
    doInit : function(component, event, helper) {
        let action = component.get('c.getTeamCompetitions');
        action.setParams({
            'teamId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            console.log(response.getState())
            component.set('v.leaguesList', response.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    goToRecord : function(component, event, helper) {
        let selectedItem = event.currentTarget;
        let elementId = selectedItem.dataset.id;
        let sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": elementId
        })
        sObjectEvent.fire();
    }
})