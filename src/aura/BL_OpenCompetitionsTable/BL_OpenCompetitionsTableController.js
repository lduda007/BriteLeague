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
})