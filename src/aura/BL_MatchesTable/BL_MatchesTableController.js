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
//    openScoreViewModal: function (component, event, helper){
//        component.set('v.showModal', false);
//        component.set("v.selectedMatchId", event.currentTarget.dataset.recordid);
//        console.log('matchId: '+component.get("v.selectedMatchId"));
//        component.set('v.showModal', true);
//        component.find("newScoreModal").show();
//    },
    openScoreViewModal: function (component, event, helper){
        component.set('v.showScoreViewModal', false);
        component.set("v.selectedMatchId", event.currentTarget.dataset.recordid);
        let matches = component.get('v.matches');
        for(let ii=0; ii < matches.length ; ii++){
            if(matches[ii].Id == component.get('v.selectedMatchId')){
//                console.log('list ID: '+matches[ii].Id+ ' | selected Id: '+component.get('v.selectedMatchId'));
                component.set('v.selectedMatchObject', matches[ii]);
                break;
            }
        }


        let backdrop = component.find('backdrop');
        let scoreViewModal = component.find('scoreViewModal');
        $A.util.addClass(backdrop, 'slds-backdrop_open');
        $A.util.addClass(scoreViewModal, 'slds-slide-down-cancel');
        component.set('v.showScoreViewModal', true);

    },
    openScoreProviderModal: function (component, event, helper){
        component.set('v.showModal', false);
        component.set("v.selectedMatchId", event.getSource().get("v.value"));
        console.log('matchId: '+component.get("v.selectedMatchId"));
        component.set('v.showModal', true);
        component.find("newScoreModal").show();
    },
    handleScoreSelected: function (component, event, helper){
        component.set('v.showModal', false);
        component.set('v.showModal', true);
        component.find("newScoreModal").hide();
    },
    closeModal : function(component, event, helper) {
        let backdrop = component.find('backdrop');
        let scoreViewModal = component.find('scoreViewModal');
        component.set('v.selectedMatchId', null);
        $A.util.removeClass(backdrop, 'slds-backdrop_open');
        $A.util.removeClass(scoreViewModal, 'slds-slide-down-cancel');
    },
})