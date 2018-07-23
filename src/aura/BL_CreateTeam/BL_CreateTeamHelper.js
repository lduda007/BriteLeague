({
    saveRecord : function(component,event) {
    	var selectedPlayer = component.get("v.selectedPlayer");
        var action = component.get("c.saveTeam");
        action.setParams({
            'team': component.get("v.team"),
            'player' : selectedPlayer
        });

        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Team saved.',
                    type: 'success',
                    message : 'Approval request was send to ' + selectedPlayer.Name
                });
                showToast.fire();
            } else if(state === 'ERROR') {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Error.',
                    type: 'error',
                    message : response.getError()[0]
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);

    },
    clear : function(component,event){
        component.set("v.selectedPlayer", {});
        component.set("v.team.Name", '');

        var compEvent = $A.get("e.c:BL_CustomLookupClearEvent");
        compEvent.setParams({"parentName" : 'BL_CreateTeam' });
        compEvent.fire();
    }
})