({
    doInit: function(component) {
        component.set('v.showSpinner', true);

        let action = component.get('c.getAllLeagues');
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();

            if(state === 'SUCCESS' || state === 'DRAFT') {
                component.set('v.allLeagues', result);
            } else if(state === 'ERROR') {
                this.handleError(component, response);
            }

            component.set('v.showSpinner', false);
        });

        $A.enqueueAction(action);
    },

    setAllLeaguesColumns: function(component) {
        component.set("v.allLeaguesColumns", [
            {label: "Name", fieldName: "Name", type: "button", typeAttributes: { variant: 'base', name: 'view', label: {fieldName: 'Name'}}},
            {label: "Start Date", fieldName: 'Start_Date__c', type: "date"},
            {label: "End date", fieldName: "End_Date__c", type: "date"},
            {label: "Type", fieldName: "TeamSize__c", type: "text"},
            {label: "Status", fieldName: "Status__c", type: "text"}
        ]);
    },

    goToRecord: function(component, row) {
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": row.Id
        });
        navEvt.fire();
    },

    handleError: function(component, response) {
        let errorData = JSON.parse(response.getError()[0].message);
        let errorMessage = errorData.name + " (code " + errorData.code + "): " + errorData.message;
        let errToast = $A.get("e.force:showToast");
        if(errToast) {
            errToast.setParams({
                "message": errorMessage,
                "type": "error"
            });
            errToast.fire();
        } else {
            console.error(errorMessage);
        }
    }
});