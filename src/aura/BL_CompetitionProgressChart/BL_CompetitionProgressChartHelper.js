({
    doInit: function(component) {
        this.showSpinner(component);

        let action = component.get("c.getInitDataWrapper");
        action.setParams({
            "competitionId": component.get("v.competitionId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();

            if(state === "SUCCESS") {
                component.set("v.labels", result.labels);
                component.set("v.dataSets", result.dataSets);
                this.generateChart(component);
            } else if(state === "ERROR") {
                let errors = response.getError();
                let message = 'Unknown error';
                if(errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.error(message);
            }

            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    generateChart: function(component) {
        let lineChartData = {};
        lineChartData.labels = component.get("v.labels");
        lineChartData.datasets = component.get("v.dataSets");

        if(!component.lineChart) {
            let ctx = component.find("chart").getElement();
            component.lineChart = new Chart(ctx, {
                type: "line",
                data: lineChartData,
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    legend: {
                        display: true,
                        labels: {
                            fontColor: "#000",
                            fontFamily: "Salesforce Sans",
                            usePointStyle: true
                        }
                    },
                    scales: {
                        xAxes: [{
                            scaleLabel: {
                                display: true,
                                labelString: $A.get("$Label.c.BL_Matches"),
                                fontFamily: "Salesforce Sans"
                            }
                        }],
                        yAxes: [{
                            ticks: {
                                min: 0,
                                beginAtZero: true,
                                suggestedMax: 1
                            },
                            scaleLabel: {
                                display: true,
                                labelString: $A.get("$Label.c.BL_Points"),
                                fontFamily: "Salesforce Sans"
                            }
                        }]
                    },
                    tooltips: {
                        mode: "nearest",
                        displayColors: false,
                        bodyFontSize: 14,
                        bodyFontStyle: "bold",
                        callbacks: {
                            title: function(tooltipItems, data) {
                                let point = data.datasets[tooltipItems[0].datasetIndex].data[tooltipItems[0].index];
                                return $A.get("$Label.c.BL_Points") + ": " + point.y + " (+" + point.matchPoints + ")";
                            },
                            label: function(tooltipItem, data) {
                                let point = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                                return "vs " + point.enemyName || "";
                            },
                            labelTextColor: function(tooltipItem, chart) {
                                let dataset = chart.config.data.datasets[tooltipItem.datasetIndex];
                                let point = dataset.data[tooltipItem.index]
                                return point.enemyColor.substring(0, 7);
                            },
                            footer: function(tooltipItems, data) {
                                let point = data.datasets[tooltipItems[0].datasetIndex].data[tooltipItems[0].index];
                                return point.matchDate;
                            }
                        }
                    }
                }
            });
        } else {
            component.lineChart.data = lineChartData;
            component.lineChart.update();
        }
    },

    showSpinner: function(component) {
        component.set("v.isSpinner", true);
    },

    hideSpinner: function(component) {
        component.set("v.isSpinner", false);
    }
});