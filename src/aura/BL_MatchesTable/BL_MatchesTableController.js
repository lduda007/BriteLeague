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
    goToLeaguePage: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/bl-league/"+recordId
        });
        urlEvent.fire();
    },
    openScoreViewModal: function (component, event, helper){
        component.set("v.selectedMatchId", event.currentTarget.dataset.recordid);
        let scoreModal = component.find("scoreModal");
        component.set("v.editMode", false);
        let matches = component.get('v.matches');
        let matchIndex = event.currentTarget.dataset.recordindex;
        let teamSize = matches[matchIndex].League__r.TeamSize__c;
        component.set("v.teamSize", teamSize);
        component.set('v.selectedMatchObject', matches[matchIndex]);

        if(teamSize === 'Single Player'){
            scoreModal.set("v.size", 'small');
        }else{
            scoreModal.set("v.size", 'large');
        }
        component.set("v.modalVisible", false);
        component.set("v.modalVisible", true);
        scoreModal.show();
    },
    openScoreProviderModal: function (component, event, helper){
        let scoreModal = component.find("scoreModal");
        let matches = component.get('v.matches');
        let matchIndex = event.getSource().get("v.value");
        let match = matches[matchIndex];
        let teamSize = match.League__r.TeamSize__c;
        component.set("v.teamSize", teamSize);
        component.set("v.selectedMatchId", match.Id);
        component.set("v.editMode", true);
        if(teamSize === 'Single Player'){
            scoreModal.set("v.size", 'small');
        }else{
            scoreModal.set("v.size", 'large');
        }
        component.set("v.modalVisible", false);
        component.set("v.modalVisible", true);
        scoreModal.show();
    },
    handleScoreSelected: function (component, event, helper){
        let scoreModal = component.find("scoreModal");
        scoreModal.hide();
    },
    onSinglePlayerMatchScoreSaved : function(component, event) {
        let scoreModal = component.find("scoreModal");
        scoreModal.hide();
    }
})