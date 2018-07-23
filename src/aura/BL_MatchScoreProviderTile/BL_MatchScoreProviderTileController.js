({
    handleRoundScoreSelected: function(component, event, helper){
        let round = parseInt(event.getParam("round"));
        let givenTeam1Goals = parseInt(event.getParam("team1score"));
        let givenTeam2Goals = parseInt(event.getParam("team2score"));
        let team1TotalGoals = component.get("v.team1Goals");
        let team2TotalGoals = component.get("v.team2Goals");
        team1TotalGoals[round-1] = givenTeam1Goals;
        team2TotalGoals[round-1] = givenTeam2Goals;
        component.set("v.team1Goals", team1TotalGoals);
        component.set("v.team2Goals", team2TotalGoals);
        console.log("team1goals: "+component.get("v.team1Goals"));
        console.log("team2goals: "+component.get("v.team2Goals"));
    },
    handleTeamGoalsChange: function(component, event, helper){
        let teamNumber = event.getParam("expression").substring(6,7);
        let teamGoalsByRound = event.getParam("value");
        let teamScore = parseInt(0);
        for(let ii=0 ; ii < teamGoalsByRound.length ; ii++){
            if(teamGoalsByRound[ii] == 10){
                teamScore += parseInt(1);
            }
        }
        component.set("v.team"+teamNumber+"Score",teamScore);
        if(parseInt(component.get("v.team1Score")) == 1 && parseInt(component.get("v.team2Score")) == 1){
            component.set("v.isMatchWithExtraTimeRound", true);
        }
    },
    handleSaveScore: function(component, event, helper){
        let team1score = component.get("v.team1Score");
        let team2score = component.get("v.team2Score");
        component.getEvent("scoreSaved").setParams({
            "team1score" : team1score,
            "team2score" : team2score,
            "team1Goals" : component.get("v.team1Goals"),
            "team2Goals" : component.get("v.team2Goals")
        }).fire();
        helper.setTeamPanelStyle(component);
    },
    handleTeamScoreChange: function(component, event, helper){
        console.log("provider tile team score changed");
        console.log("tema1 score: "+component.get("v.team1Score"));
        console.log("tema2 score: "+component.get("v.team2Score"));
        helper.setTeamPanelStyle(component);
    },

})