({
    handleError : function(component, response, helper) {
        console.log(response.getError()[0].message);
        let errorData = JSON.parse(response.getError()[0].message);
        console.log(errorData.name +" (code "+ errorData.code +"): "+ errorData.message);
        let errToast = $A.get("e.force:showToast");
        errToast.setParams({
            "message": errorData.name +" (code "+ errorData.code +"): "+ errorData.message,
            "type": 'error'
        });
        errToast.fire();
    },
    retrieveOpenLeagues  : function(component, event, helper) {
    let action = component.get('c.getLeagues');
    component.set('v.showSpinner', true);
    action.setCallback(this, function(response){
        let state = response.getState();
        if(state === 'SUCCESS' || state === 'DRAFT') {
            component.set('v.leaguesList', response.getReturnValue());
        } else if(state === 'ERROR') {
            helper.handleError(component, response, helper);
        }
        component.set('v.showSpinner', false);
    });
    $A.enqueueAction(action);
    },

    onOpenModal : function(component, event, helper) {
        let selectedItem = event.currentTarget;
        let elementId = selectedItem.dataset.id;
        let joinComponent = component.find('joinComponent');
        joinComponent.getTeams(elementId);
        component.set('v.selectedLeagueId', component.get('v.leaguesList')[parseInt(elementId)].Id);
        document.getElementById('backdrop').classList.add("slds-backdrop_open");
        document.getElementById('modal').classList.add("slds-slide-down-cancel");
    },

    onCloseModal : function(component, event, helper) {
        document.getElementById('backdrop').classList.remove("slds-backdrop_open");
        document.getElementById('modal').classList.remove("slds-slide-down-cancel");
    },
})