({
    doInit : function(component, event, helper){
        helper.retrieveOpenLeagues(component, event);
    },
    openModal : function(component, event, helper) {
        helper.onOpenModal(component, event);
    },
    closeModal : function(component, event, helper) {
        helper.onCloseModal(component, event);
    },
    handleCompetitorCreated : function(component, event, helper) {
        helper.retrieveOpenLeagues(component, event);
    },
    handleCompetitionCreated : function(component, event, helper) {
        helper.retrieveOpenLeagues(component, event);
    },
    goToRecord : function(component, event, helper) {
        let selectedItem = event.currentTarget;
        let elementId = selectedItem.dataset.id;
        let sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": elementId
        })
        sObjectEvent.fire();
    },
})