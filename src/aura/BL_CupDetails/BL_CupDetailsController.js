({
    doInit : function(component, event, helper){
        helper.loadCupDetails(component);
        helper.loadCupMatches(component);
        helper.getCurrentUser(component);
    },
    startCupNowAction: function (component, event, helper) {
        helper.startCupNow(component);
    },
    onScoreSubmitted: function (component, event, helper) {
        helper.loadCupMatches(component);
    },
})