({
    doInit : function(component, event, helper){
        helper.loadLeagueWithCompetitors(component);
        helper.loadLeagueMatches(component, null);
        helper.initializeTodayDate(component);
    },
    rowClicked: function(component, event, helper){
        let index = event.currentTarget.dataset.index;
        let selectedRowIndex = component.get("v.selectedRowIndex");
        if(!$A.util.isUndefinedOrNull(selectedRowIndex)){
            helper.removeHighlightFromAllRows(component);
        }
        if(index !== selectedRowIndex){
            let rows = component.find("competitorRow");
            let competitorId = event.currentTarget.dataset.competitorid;
            $A.util.addClass(rows[index], "row-highlighted");
            component.set("v.selectedRowIndex", index);
            helper.loadLeagueMatches(component, competitorId);
        }else{
            component.set("v.selectedRowIndex", null);
            helper.loadLeagueMatches(component, null);
        }
    },
    goToTeamPage: function (component, event, helper) {
        let recordId = event.currentTarget.dataset.recordid;
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/bl-team/"+recordId
        });
        urlEvent.fire();
    },
    startLeagueNowAction: function (component, event, helper) {
        helper.startLeagueNow(component);
    },
})