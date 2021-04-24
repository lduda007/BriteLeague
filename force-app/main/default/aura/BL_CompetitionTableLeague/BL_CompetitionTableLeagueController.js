({
    doInit : function(component, event, helper){
        helper.loadCompetitionWithCompetitors(component);
        helper.loadCompetitionMatches(component, null);
        helper.getCurrentUser(component);
    },

    rowClicked: function(component, event, helper){
        let index = event.currentTarget.dataset.index;
        let selectedRowIndex = component.get("v.selectedRowIndex");
        if(!$A.util.isUndefinedOrNull(selectedRowIndex)) {
            helper.removeHighlightFromAllRows(component);
        }

        if(index !== selectedRowIndex) {
            let rows = component.find("competitorRow");
            let competitorId = event.currentTarget.dataset.competitorid;
            $A.util.addClass(rows[index], "row-highlighted");
            component.set("v.selectedRowIndex", index);
            helper.loadCompetitionMatches(component, competitorId);
        } else {
            component.set("v.selectedRowIndex", null);
            helper.loadCompetitionMatches(component, null);
        }
    },

    goToTeamPage: function (component, event, helper) {
        let recordId = event.currentTarget.dataset.recordid;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },

    startLeagueNowAction: function (component, event, helper) {
        helper.startLeagueNow(component);
    },

    onScoreSubmitted: function (component, event, helper) {
        helper.loadCompetitionWithCompetitors(component);
        helper.loadCompetitionMatches(component, null);
    },

    handleCompetitorLeftCompetition : function(component, event, helper) {
        helper.loadCompetitionWithCompetitors(component);
    },

    onSinglePlayerMatchScoreSaved : function(component, event, helper) {
        helper.loadCompetitionWithCompetitors(component);
        helper.loadCompetitionMatches(component, null);
    }
});