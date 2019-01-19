({
    handleRoundScoreSaved: function(component, event, helper) {
        // tt - team ( 1 or 2 )
        for(let tt = 1; tt < 3; tt++) {
            component.set("v.simpleMatchRecord.Team" + tt + "_Score__c", event.getParam("team" + tt + "score"));
            // rr - round ( 1 or 2 or 3 )
            for(let rr = 1; rr < 4; rr++) {
                component.set("v.simpleMatchRecord.Team" + tt + "Round" + rr + "Goals__c", helper.loadTeamGoalsByRound(component, event, tt, rr));
            }
        }
        helper.updateMatchFinalScore(component, event);
    },

    handleRecordIdChanged: function(component, event, helper) {
        if(component.get("v.isReadOnly") == false) {
            component.find("scoreProviderTile").clearScores();
        }
        component.find("matchRecordEditor").reloadRecord(false);
    }
});