({
    goToTeamPage: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
    goToLeaguePage: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
//    openScoreProviderModal: function (component, event, helper){
//        component.set("v.selectedMatchId", event.currentTarget.dataset.recordid);
//        console.log('matchId: '+component.get("v.selectedMatchId"));
//        component.find("newScoreModal").show();
//    },

    openScoreProviderModal: function (component, event, helper){
        component.set("v.showModal", false);
        component.set("v.selectedMatchId", event.getSource().get("v.value"));
        console.log('matchId: '+component.get("v.selectedMatchId"));
        component.set("v.showModal", true);
        component.find("newScoreModal").show();
    },
    handleScoreSelected: function (component, event, helper){
        component.find("newScoreModal").hide();
    },
})