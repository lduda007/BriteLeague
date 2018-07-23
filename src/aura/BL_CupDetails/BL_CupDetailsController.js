({
    doInit : function(component, event, helper){
        helper.loadCupDetails(component, event);
        helper.loadCupMatches(component, event);
        helper.initializeTodayDate(component);
    },
    startCupNowAction: function (component, event, helper) {
        helper.startCupNow(component);
    },
})