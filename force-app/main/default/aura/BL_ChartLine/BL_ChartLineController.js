({
    generateChart : function(component, event, helper) {
        var labels = component.get('v.labels');
        var values = component.get('v.values');
        var name = component.get('v.name');
        var legend = component.get('v.legend');

        var chartdata = {
            labels: labels,
            datasets: [
                {
                    label: name,
                    data: values,
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
        var ctx = component.find("chart").getElement();
        var lineChart = new Chart(ctx ,{
            type: 'line',
            data: chartdata,
            options: {
                legend: {
                    position: legend,
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
    }
})