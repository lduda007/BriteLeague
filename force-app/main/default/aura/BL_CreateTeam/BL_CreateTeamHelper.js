({
    saveRecord : function(component,event) {
        if(this.isFormValid(component, 'createTeamForm')){
            var selectedPlayer = component.get("v.selectedPlayer");
            var isBattleRoyale = component.get("v.isBattleRoyale");

            var action = component.get("c.saveTeam");
            action.setParam('team', component.get("v.team"));
            if (isBattleRoyale) {
                action.setParam('isBattleRoyale', isBattleRoyale);
                action.setParam('player', null);
            } else {
                action.setParam('player', selectedPlayer);
            }

            action.setCallback(this, function(response) {
                $A.util.removeClass(component.find("mySpinner"), "slds-show");
                var state = response.getState();
                if (state === "SUCCESS") {
                    var showToast = $A.get("e.force:showToast");
                    let toastMessage = null;
                    if (component.get("v.isBattleRoyale") == false) {
                        toastMessage = 'Approval request was send to ' + selectedPlayer.Name;
                    } else {
                        toastMessage = 'Battle Royale team was successfully created'
                    }
                    showToast.setParams({
                        title : 'Team saved.',
                        type: 'success',
                        message : toastMessage
                    });
                    showToast.fire();
                    this.clear(component);
                    let evt = component.getEvent('BL_TeamCreatedEvent');
                    evt.fire();
                } else if(state === 'ERROR') {
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        title : 'Error.',
                        type: 'error',
                        message : response.getError()[0].message
                    });
                    showToast.fire();
                }
            });
            $A.enqueueAction(action);
        }else{
            var showToast = $A.get("e.force:showToast");
            showToast.setParams({
                title : 'Error.',
                type: 'error',
                message : "Review form errors and try again"
            });
            showToast.fire();
        }
    },
    clear : function(component){
        component.set("v.selectedPlayer", {});
        component.set("v.team.Name", '');
        var compEvent = $A.get("e.c:BL_CustomLookupClearEvent");
        compEvent.setParams({"parentName" : 'BL_CreateTeam' });
        compEvent.fire();
    },
    isFormValid : function(component, formId){
        var formInputs = component.find(formId);
        formInputs.showHelpMessageIfInvalid();
        let validity = formInputs.get("v.validity");
        return validity.valid;
    }
})