({

    onInit: function(component, event, helper) {
        helper.initializeChart(component);
        helper.getChartData(component);
    },

    onMatchScoreSaved: function(component, event, helper) {
        helper.getChartData(component);
    }

})