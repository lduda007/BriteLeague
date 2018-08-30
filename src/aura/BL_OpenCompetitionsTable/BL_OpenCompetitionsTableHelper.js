({
    retrieveOpenLeagues  : function(component, event) {
        let action = component.get('c.getLeagues');
        component.set('v.showSpinner', true);
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS') {
                let openLeaguesList = response.getReturnValue();
                component.set('v.openLeaguesList', openLeaguesList);
            } else{
                let errToast = $A.get("e.force:showToast");
                errToast.setParams({
                    "message": "Error accured while joining to league",
                    "type": 'error'
                });
                errToast.fire();
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    onOpenModal : function(component, event) {
        let selectedItemIndex = event.getSource().get("v.value");
        let joinComponent = component.find('joinComponent');
        joinComponent.getTeams(selectedItemIndex);
        component.set('v.selectedLeagueId', component.get('v.openLeaguesList')[parseInt(selectedItemIndex)].Id);
        $A.util.addClass(component.find('backdrop'), "slds-backdrop_open");
        $A.util.addClass(component.find('joinToCompetitionModal'), "slds-slide-down-cancel");
    },
    onCloseModal : function(component, event) {
        $A.util.removeClass(component.find('backdrop'), "slds-backdrop_open");
        $A.util.removeClass(component.find('joinToCompetitionModal'), "slds-slide-down-cancel");
    },
})