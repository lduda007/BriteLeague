({
    doInit : function(component, event, helper){
        helper.retrieveOpenLeagues(component, event, helper);
    },
    handleCompetitorCreated : function(component, event, helper) {
        component.find("tabset").set("v.selectedTabId",'myLeagues');
        component.find('myLeaguesComponent').retrieve();
    },
    handleCompetitionCreated : function(component, event, helper) {
        component.find("tabset").set("v.selectedTabId",'open');
    },
    goToRecord : function(component, event, helper) {
        let selectedItem = event.currentTarget;
        let elementId = selectedItem.dataset.id;
        let sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": elementId
        })
        sObjectEvent.fire();
    }
})