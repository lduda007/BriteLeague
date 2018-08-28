({
    drawMatchesChart : function(component, event, helper) {
        let related = event.getParam('related');
        let values = [related.matchesWon.length, related.matchesLost.length, related.draws.length];
        component.set('v.remisy', related.draws.length);
        let ctx = component.find("matchesPie").getElement();
        let lineChart = new Chart(ctx ,{
            type: 'pie',
            data: {
               labels: ['Won', 'Lost', 'Draws'],
               datasets: [
                   {
                       label: 'Matches',
                       data: values,
                       borderColor:'rgba(192,192,192)',
                       backgroundColor: [
                                            'rgba( 7,166,157,1)',
                                            'rgba(194,57,52,1)',
                                            'rgba(216,216,216,1)'
                                         ],
                       fill: true,
                       pointBackgroundColor: "#FFFFFF",
                       pointBorderWidth: 4,
                       pointHoverRadius: 5,
                       pointRadius: 3,
                       bezierCurve: true,
                       pointHitRadius: 10
                   }
               ]
           },
            options: {
                legend: {
                    position: 'bottom',
                    padding: 10,
                    display: true
                },
                responsive: true,
                title: {
                    display: true,
                    position: 'top',
                    text: 'Matches'
                }
            }
        });
    },
    drawGoalsChart : function(component, event, helper) {
        let related = event.getParam('related');
        let values = [related.goalsFor, related.goalsLost];
        let ctx = component.find("goalsPie").getElement();
        let lineChart = new Chart(ctx ,{
            type: 'pie',
            data: {
               labels: ['Goals Scored', 'Goals Lost'],
               datasets: [
                   {
                       label: 'Goals',
                       data: values,
                       borderColor:'rgba(192,192,192)',
                       backgroundColor: [
                                           'rgba( 7,166,157,1)',
                                           'rgba(194,57,52, 1)',
                                        ],
                       fill: true,
                       pointBackgroundColor: "#FFFFFF",
                       pointBorderWidth: 4,
                       pointHoverRadius: 5,
                       pointRadius: 3,
                       bezierCurve: true,
                       pointHitRadius: 10
                   }
               ]
           },
            options: {
                legend: {
                    position: 'bottom',
                    padding: 10,
                    display: true
                },
                responsive: true,
                title: {
                    display: true,
                    position: 'top',
                    text: 'Goals'
                }
            }
        });
    }
})