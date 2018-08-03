({
    goToTeamPage: function (component, event, helper) {
        let recordId = event.currentTarget.dataset.recordid;
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/bl-team/"+recordId
        });
        urlEvent.fire();
    },
    goToMatchPage: function (component, event, helper) {
        let recordId = event.currentTarget.dataset.recordid;
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/bl-match/"+recordId
        });
        urlEvent.fire();
    },
    openScoreViewModal: function (component, event, helper){
        component.set("v.selectedMatchId", event.currentTarget.dataset.recordid);
        console.log('matchId: '+component.get("v.selectedMatchId"));
        component.find("newScoreModal").show();
    },
    openScoreProviderModal: function (component, event, helper){
        component.set("v.selectedMatchId", event.getSource().get("v.value"));
        console.log('matchId: '+component.get("v.selectedMatchId"));
        component.set('v.showModal', false);
        component.set('v.showModal', true);
        component.find("newScoreModal").show();
    },
    handleScoreSelected: function (component, event, helper){
        component.find("newScoreModal").hide();
    },
})