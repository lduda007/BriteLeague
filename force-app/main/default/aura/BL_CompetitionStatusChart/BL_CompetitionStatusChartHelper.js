({
    doInit: function(component) {
        this.showSpinner(component);

        let action = component.get("c.getInitDataWrapper");
        action.setParams({
            "competitionId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            this.hideSpinner(component);

            let state = response.getState();
            let result = response.getReturnValue();

            if(state === "SUCCESS") {
                component.set("v.initDataWrapper", result);
                component.set("v.isCompetitionStarted", result.isCompetitionStarted);
                if(result.isCompetitionStarted) {
                    let progressDoughnutChart = component.find("progressDoughnutChart");
                    progressDoughnutChart.setIsDataLoaded();
                }
            } else if(state === "ERROR") {
                let errors = response.getError();
                let message = 'Unknown error';
                if(errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.error(message);
            }
        });
        $A.enqueueAction(action);
    },

     showSpinner: function(component) {
         component.set("v.isSpinner", true);
     },

     hideSpinner: function(component) {
         component.set("v.isSpinner", false);
     }
});