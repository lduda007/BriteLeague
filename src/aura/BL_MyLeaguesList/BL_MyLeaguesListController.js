({
    goToRecord: function(component, event, helper) {
        let selectedItem = event.currentTarget;
        let elementId = selectedItem.dataset.id;
        let sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": elementId
        });
        sObjectEvent.fire();
    },

    retrieveMyLeagues: function(component, event, helper) {
        component.set('v.showSpinner', true);
        let action = component.get('c.getMyLeagues');
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                component.set('v.myLeaguesList', response.getReturnValue());
            } else if(state === 'ERROR') {
                helper.handleError(component, response);
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    }
});