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
                    'title' : 'Team saved.',
                    'message' : 'Approval request was send to ' + selectedPlayer.Name
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);

    }
})