({
    generateChart : function(component, event, helper) {
        var labels = component.get('v.labels');
        var values = component.get('v.values');
        var name = component.get('v.name');
        var colors = component.get('v.colors');
        var legend = component.get('v.legend');

        if (colors.length == 0) {
            colors = helper.getDefaultColors(component, event, values.length);
        }

        var chartdata = {
            labels: labels,
            datasets: [
                {
                    label: name,
                    data: values,
                    borderColor:'rgba(62, 159, 222, 1)',
                    backgroundColor: colors,
                    fill: true,
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
            type: 'pie',
            data: chartdata,
            options: {
                legend: {
                    position: legend,
                    padding: 10,
                },
                responsive: true
            }
        });
    }
})