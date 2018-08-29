({
    drawMatchesChart : function(component, matchesStats) {
        let ctx = component.find("matchesPie").getElement();
        let lineChart = new Chart(ctx ,{
            type: 'pie',
            data: {
               labels: ['Won', 'Lost', 'Draws'],
               datasets: [
                   {
                       label: 'Matches',
                       data: matchesStats,
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
    drawGoalsChart : function(component, goalsStats) {
        let ctx = component.find("goalsPie").getElement();
        let lineChart = new Chart(ctx ,{
            type: 'pie',
            data: {
               labels: ['Goals Scored', 'Goals Lost'],
               datasets: [
                   {
                       label: 'Goals',
                       data: goalsStats,
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
    },
    loadStatistics: function(component) {
        let action = component.get("c.loadTeamStatistics");
        action.setParams({
            teamId: component.get("v.recordId")
        });
        var self = this;
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS'){
                let stats = response.getReturnValue();
                let matchesStats = [stats.Total_Games_Won__c, stats.Total_Games_Lost__c, stats.Total_Games_Drawn__c];
                let goalsStats = [stats.Total_Goals_Scored__c, stats.Total_Goals_Lost__c];
                self.drawMatchesChart(component, matchesStats);
                self.drawGoalsChart(component, goalsStats);
            } else if (state === 'ERROR') {
                alert('error');
            }
        });
        $A.enqueueAction(action);
    }
})