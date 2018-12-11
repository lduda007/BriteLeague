({
    generateCharts: function(component) {
        let dataSet1 = component.get("v.dataSet1");
        let dataSet2 = component.get("v.dataSet2");
        let dataSet3 = component.get("v.dataSet3");
        if(dataSet1) {
            this.generateChart(component, "chart1", dataSet1);
        }
        if(dataSet2) {
            this.generateChart(component, "chart2", dataSet2);
        }
        if(dataSet3) {
            this.generateChart(component, "chart3", dataSet3);
        }
    },

    generateChart: function(component, id, dataSet) {
        let doughnutChart = component[id];

        if(!doughnutChart) {
            let ctx = component.find(id).getElement();
            component[id] = new Chart(ctx, {
                type: "doughnut",
                data: {
                    datasets: [dataSet]
                },
                options: {
                    cutoutPercentage: 75,
                    hover: {
                        mode: null
                    },
                    tooltips: {
                        enabled: false
                    }
                }
            });
        } else {
            doughnutChart.data.datasets = [dataSet];
            doughnutChart.update();
        }
    }
});