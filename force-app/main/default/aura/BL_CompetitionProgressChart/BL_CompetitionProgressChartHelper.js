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
            let errors = response.getError();

            if(state === "SUCCESS") {
                component.set("v.isError", false);
                component.set("v.isCompetitionStarted", result.isCompetitionStarted);
                if(result.isCompetitionStarted) {
                    component.set("v.labels", result.labels);
                    component.set("v.dataSets", result.dataSets);
                    this.generateChart(component);
                }
            } else if(state === "ERROR") {
                component.set("v.isError", true);
                this.getUtils(component).handleError(errors);
            }
        });
        $A.enqueueAction(action);
    },

    generateChart: function(component) {
        let lineChartData = {};
        lineChartData.labels = component.get("v.labels");
        lineChartData.datasets = component.get("v.dataSets");
        this.prepareWinComboPointStyles(lineChartData.datasets);
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
                        },
                        onClick: function(e, legendItem) {
                            let ci = this.chart;
                            let dataSet = ci.data.datasets[legendItem.datasetIndex];
                            dataSet.hidden = !dataSet.hidden;
                            ci.options.scales.yAxes[0].ticks.suggestedMax = ci.options.getSuggestedYAxisMax(ci.data.datasets);
                            ci.update();
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
                                suggestedMax: this.getSuggestedYAxisMax(lineChartData.datasets)
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
                                let dataset = data.datasets[tooltipItems[0].datasetIndex];
                                let point = dataset.data[tooltipItems[0].index];
                                let result = "";

                                if(dataset.label !== point.teamName) {
                                    result += point.teamName + " (" + dataset.label + ")";
                                } else {
                                    result += dataset.label;
                                }

                                result += ": " + point.y + " (+" + point.matchPoints + ")"

                                return result;
                            },
                            label: function(tooltipItem, data) {
                                let dataset = data.datasets[tooltipItem.datasetIndex];
                                let point = dataset.data[tooltipItem.index];
                                let result = "";

                                result += "vs " + point.enemyName;

                                if(point.enemyName !== point.enemyDataSetLabel) {
                                    result += " (" + point.enemyDataSetLabel + ")";
                                }

                                return result;
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
                    },
                    getSuggestedYAxisMax: this.getSuggestedYAxisMax
                }
            });
        } else {
            component.lineChart.data = lineChartData;
            component.lineChart.update();
        }
    },

    prepareWinComboPointStyles: function(dataSets) {
        for(let ds = 0; ds < dataSets.length; ds++) {
            let dataSet = dataSets[ds];
            let winCombo = 0;
            dataSet.pointStyle = [];
            dataSet.radius = [];
            dataSet.pointHoverRadius = [];
            dataSet.fill = true;
            dataSet.pointBackgroundColor = [];

            for(let i = 0; i < dataSet.data.length; i++) {
                if(dataSet.data[i].matchPoints === 3) {
                    winCombo++;
                } else {
                    winCombo = 0;
                }

                if(dataSet.data.length === (i + 1) && winCombo >= 2) {
                    dataSet.pointStyle.push('rectRot');
                    dataSet.radius.push(8);
                    dataSet.pointHoverRadius.push(9);
                    dataSet.pointBackgroundColor.push(dataSet.backgroundColor.substring(0, 7));
                } else {
                    dataSet.pointStyle.push('circle');
                    dataSet.radius.push(3);
                    dataSet.pointHoverRadius.push(4);
                    dataSet.pointBackgroundColor.push(dataSet.backgroundColor);
                }
            }
        }
    },

    getSuggestedYAxisMax: function(dataSets) {
        let maxPoints = 1;
        for(let ds = 0; ds < dataSets.length; ds++) {
            let dataSet = dataSets[ds];
            if((dataSet.hidden === undefined || dataSet.hidden === false) && dataSet.data.length > 0 && maxPoints < dataSet.data[dataSet.data.length - 1].y) {
                maxPoints = dataSet.data[dataSet.data.length - 1].y;
            }
        }
        let yAxisMax = maxPoints * 1.2 + 5 - (maxPoints * 1.2 % 5);
        return yAxisMax - 5 > maxPoints
                ? yAxisMax - 5
                : yAxisMax;
    },

    showSpinner: function(component) {
        component.set("v.isSpinner", true);
    },

    hideSpinner: function(component) {
        component.set("v.isSpinner", false);
    },

    getUtils: function(component) {
        return component.find("utils");
    }
});