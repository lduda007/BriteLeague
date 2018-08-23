({
    doInit : function(component, event, helper){
        helper.fetchLastMatches(component, event);
        helper.fetchNextMatches(component, event);
//        var action = component.get('c.getCondition');
//        action.setCallback(this, function(response){
//            var state = response.getState();
//            if(state === 'SUCCESS' || state === 'DRAFT') {
//                component.set('v.chartData', response.getReturnValue());
//            }
//        });
//        $A.enqueueAction(action);
    },

    generateChart : function(component, event, helper) {
        // line
        var action = component.get('c.getCondition');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                console.log(response.getReturnValue().name);
                console.log(response.getReturnValue().xLabels);
                console.log(response.getReturnValue().xValues);
                var chartdata2 = {
                    labels: response.getReturnValue().xLabels,
                    datasets: [
                        {
                            label:response.getReturnValue().name,
                            data: response.getReturnValue().xValues,
                            borderColor:'rgba(62, 159, 222, 1)',
                            fill: false,
                            pointBackgroundColor: "#FFFFFF",
                            pointBorderWidth: 4,
                            pointHoverRadius: 5,
                            pointRadius: 3,
                            bezierCurve: true,
                            pointHitRadius: 10
                        }
                    ]
                }
                //Get the context of the canvas element we want to select
                var ctx = component.find("condition").getElement();
                var lineChart2 = new Chart(ctx ,{
                    type: 'line',
                    data: chartdata2,
                    options: {
                        legend: {
                            position: 'false',
                            padding: 10,
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
            } else if(state === 'ERROR') {
                console.log('ERROR: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);

    },
    
})