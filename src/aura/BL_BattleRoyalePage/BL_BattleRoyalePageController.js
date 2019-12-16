({
    onInit: function (component, event, helper) {
        helper.doInit(component);
    },

    refresh: function (component, event, helper) {
        let leagueTable = component.find("leagueTable");
        leagueTable.refresh();
        let competitionFeed = component.find("feed");
        competitionFeed.refresh();
    }
});