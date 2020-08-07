({
    onInit : function(component, event, helper) {
        helper.getCompetitionMatches(component, null);
        helper.getCurrentUser(component);
    },

    goToTeamPage: function(component, event, helper) {
        let recordId = event.currentTarget.dataset.recordid;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },

    goToMatchPage: function(component, event, helper) {
        let recordId = event.currentTarget.dataset.recordid;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },

    goToLeaguePage: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },

    openScoreViewModal: function(component, event, helper) {
        component.set("v.selectedMatchId", event.currentTarget.dataset.recordid);
        let scoreModal = component.find("scoreModal");
        component.set("v.editMode", false);
        let matches = component.get('v.matches');
        let matchIndex = event.currentTarget.dataset.recordindex;
        let teamSize = matches[matchIndex].League__r.TeamSize__c;
        component.set("v.teamSize", teamSize);
        component.set('v.selectedMatchObject', matches[matchIndex]);
        if(teamSize === 'Single Player') {
            scoreModal.set("v.size", 'small');
        } else {
            scoreModal.set("v.size", 'large');
        }
        component.set("v.modalVisible", false);
        component.set("v.modalVisible", true);
        scoreModal.show();
    },

    openScoreProviderModal: function(component, event, helper) {
        let scoreModal = component.find("scoreModal");
        let matches = component.get('v.matches');
        let matchIndex = event.getSource().get("v.value");
        let match = matches[matchIndex];
        let teamSize = match.Competition__r.TeamSize__c;
        component.set("v.teamSize", teamSize);
        component.set("v.selectedMatchId", match.Id);
        component.set("v.editMode", true);
        if(teamSize === 'Single Player') {
            scoreModal.set("v.size", 'small');
        } else {
            scoreModal.set("v.size", 'large');
        }
        component.set("v.modalVisible", false);
        component.set("v.modalVisible", true);
        scoreModal.show();
    },

    handleScoreSelected: function(component, event, helper) {
        let scoreModal = component.find("scoreModal");
        scoreModal.hide();
    },

    onSinglePlayerMatchScoreSaved: function(component, event) {
        let scoreModal = component.find("scoreModal");
        scoreModal.hide();
    },

    onAllMatchesChange: function(component, event, helper) {
        let allMatches = component.get("v.allMatches");
        component.set("v.matches", allMatches);
    },

    onHandleTeamSelectedEvent: function(component, event, helper) {
        component.set("v.isSpinner", true);

        let selectedTeamId = event.getParam("teamId");
        let selectedTeamName = event.getParam("teamName");
        let currentlySelectedTeamId = component.get("v.selectedTeamId");
        let allMatches = component.get("v.allMatches");
        let matches = [];

        if(!currentlySelectedTeamId || selectedTeamId !== currentlySelectedTeamId) {
            matches = helper.getMatchesForTeam(allMatches, selectedTeamId);
            currentlySelectedTeamId = selectedTeamId;
        } else {
            Array.prototype.push.apply(matches, allMatches);
            currentlySelectedTeamId = null;
            selectedTeamName = null;
        }

        component.set("v.matches", matches);
        component.set("v.selectedTeamId", currentlySelectedTeamId);
        component.set("v.selectedTeamName", selectedTeamName);

        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.isSpinner", false);
            }),
            2000
        );
    }
});