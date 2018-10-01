({
    doInit: function(component) {
        this.showSpinner(component);

        let action = component.get("c.getInitDataWrapper");
        action.setParams({
            'competitionId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                this.generateChart(component);
            } else if(state === 'ERROR') {

            }

            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    generateChart: function(component) {
        let lineChartData = {};
        lineChartData.labels = [];
        lineChartData.datasets = [];

        for(let line = 0; line < 2; line++) {
            let y = [];
            let dataset = {};
            dataset.borderColor = '#' + Math.floor(Math.random() * 16777215).toString(16);
            dataset.fill = false;

            for(let x = 0; x < 10; x++) {
                y.push(Math.floor((Math.random() * 10) + 1));
                if(line === 0) {
                    lineChartData.labels.push(x);
                }
            }
            dataset.data = y;

            lineChartData.datasets.push(dataset);
        }

        let ctx = component.find("chart").getElement();
        let lineChart = new Chart(ctx, {
            type: 'line',
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