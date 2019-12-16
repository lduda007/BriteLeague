({
    doInit: function(component, event, helper) {
        helper.fetchLastMatches(component, event);
        helper.fetchNextMatches(component, event);
    },

    generateChart: function(component, event, helper) {
        let action = component.get('c.getCondition');
        action.setParams({
            period: component.get("v.performancePeriod")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();

            if(state === 'SUCCESS' || state === 'DRAFT') {
                try {
                    let lineChartData = {
                        labels: result.labels,
                        datasets: [result]
                    };

                    if(!component.lineChart) {
                        let ctx = component.find("performanceChart").getElement();
                        component.lineChart = new Chart(ctx, {
                            type: 'line',
                            data: lineChartData,
                            options: {
                                legend: {
                                    display: false
                                },
                                responsive: true,
                                scales: {
                                    yAxes: [{
                                        ticks: {
                                            min: 0,
                                            max: 100,
                                            callback: function(value) {
                                                return value + "%"
                                            }
                                        },
                                        scaleLabel: {
                                            display: true,
                                            labelString: "Percentage"
                                        }
                                    }]
                                }
                            }
                        });
                    } else {
                        component.lineChart.data = lineChartData;
                        component.lineChart.update();
                    }
                }catch(e) {
                    console.error(e);
                }
            } else if(state === 'ERROR') {
                console.error('ERROR: ' + response.getError()[0].message);
            }
        });

        $A.enqueueAction(action);
    },

    onSinglePlayerMatchScoreSaved: function(component, event, helper) {
        helper.fetchLastMatches(component, event);
        helper.fetchNextMatches(component, event);
    }
});