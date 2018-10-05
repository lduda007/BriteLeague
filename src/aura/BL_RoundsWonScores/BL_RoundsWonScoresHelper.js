({

    initializeChart: function(component) {
        let canvas = component.find('chart').getElement();
        component.roundsWonScoresChart = new Chart(canvas, {
            type: 'bar',
            data: {
                labels: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
                datasets: []
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                title: {
                    display: false
                },
                legend: {
                    position: 'bottom'
                },
                scales: {
                    yAxes: [{
                        stacked: true,
                        scaleLabel: {
                            display: true,
                            labelString: $A.get('$Label.c.BL_Matches'),
                            fontFamily: 'Salesforce Sans'
                        },
                        ticks: {
                            beginAtZero: true,
                            min: 0
                        }
                    }],
                    xAxes: [{
                        stacked: true,
                        scaleLabel: {
                            display: true,
                            labelString: $A.get('$Label.c.BL_Points'),
                            fontFamily: 'Salesforce Sans'
                        },
                        ticks: {
                            beginAtZero: true,
                            min: 0
                        }
                    }]
                },
                tooltips: {
                    mode: 'index',
                    intersect: false
                }
            }
        });
    },

    getChartData: function(component) {
        let action = component.get('c.getChartData');
        action.setParams({
            teamId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
                let data = response.getReturnValue();
                component.set('v.teamName', data.teamName);
                this.updateChartDataSets(component, data.dataSets);
                component.find('card').find('spinner').hideSpinner();
            } else if(response.getState() === 'ERROR'){
                component.find('card').find('spinner').hideSpinner();
            }
        });
        component.find('card').find('spinner').showSpinner();
        $A.enqueueAction(action);
    },

    updateChartDataSets: function(component, dataSets) {
        component.roundsWonScoresChart.data.datasets = dataSets;
        component.roundsWonScoresChart.update();
    }

})