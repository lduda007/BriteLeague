({
    doInit: function(component, event, helper) {

    },

    handleMatchScoreModalOpen: function(component, event, helper) {
        component.find("newScoreModal").show();
    },

    recordUpdated: function(component, event, helper) {
//        var eventParams = event.getParams();
//        component.set("v.team1Score", component.get("v.simpleMatchRecord.Team1_Score__c"));
//        component.set("v.team2Score", component.get("v.simpleMatchRecord.Team2_Score__c"));
//        if(component.get("v.simpleMatchRecord.isResolved__c") == true){
//            component.set("v.isReadOnly", true);
//            console.log("resolved true");
//        }else{
//            component.set("v.isReadOnly", false);
//            console.log("resolved false");
//        }
//        component.find("newScoreModal").hide();
//        helper.updateLeagueStatistics(component, event);
    },

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