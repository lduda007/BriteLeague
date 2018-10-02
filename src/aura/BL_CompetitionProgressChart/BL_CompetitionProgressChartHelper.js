({
    doInit: function(component) {
        this.showSpinner(component);

        let action = component.get("c.getInitDataWrapper");
        action.setParams({
            "competitionId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();

            if(state === "SUCCESS") {
                component.set("v.labels", result.labels);
                component.set("v.dataSets", result.dataSets);
                this.generateChart(component);
            }

            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    generateChart: function(component) {
        let lineChartData = {};
        lineChartData.labels = component.get("v.labels");
        lineChartData.datasets = component.get("v.dataSets");

        let ctx = component.find("chart").getElement();
        let lineChart = new Chart(ctx, {
            type: "line",
            data: lineChartData,
        });
    },

    showSpinner: function(component) {
        component.set("v.isSpinner", true);
    },

    hideSpinner: function(component) {
        component.set("v.isSpinner", false);
    }
});