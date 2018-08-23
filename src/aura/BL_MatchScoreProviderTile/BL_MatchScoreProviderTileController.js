({
    doInit: function(component, event, helper){

    },

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

    },
    handleTeamGoalsChange: function(component, event, helper){
        helper.updateFinalScore(component, event);
    },
    handleSaveScore: function(component, event, helper){
        let team1score = component.get("v.team1Score");
        let team2score = component.get("v.team2Score");
        component.getEvent("scoreSaved").setParams({
            "team1score" : team1score,
            "team2score" : team2score,
            "team1Goals" : component.get("v.team1Goals"),
            "team2Goals" : component.get("v.team2Goals"),
            "matchDate" : new Date(component.get("v.matchDate")).toJSON()
        }).fire();

        helper.clearOldDataOnModal(component);
        helper.setTeamPanelStyle(component);

    },
    handleTeamScoreChange: function(component, event, helper){
        helper.setTeamPanelStyle(component);
        let team1score = component.get("v.team1Score");
        let team2score = component.get("v.team2Score");
        let team1goals = component.get("v.team1Goals");
        let team2goals = component.get("v.team2Goals");
        let scoreSum = parseInt(team1score) + parseInt(team2score);
        if(parseInt(team1score) == 1 && parseInt(team2score) == 1){
            component.set("v.isMatchWithExtraTimeRound", true);
        }else if(scoreSum == 3 && parseInt(team1score) != 3 && parseInt(team2score) != 3){
            component.set("v.isMatchWithExtraTimeRound", true);
            if( (parseInt(team1score) == 1 && parseInt(team1goals[2])==10) || (parseInt(team2score) == 1 && parseInt(team2goals[2])==10) ){
                helper.updateFinalScoreFromTwoRounds(component);
                component.set("v.isMatchWithExtraTimeRound", false);
            }
        }else if(parseInt(team1score)==3 || parseInt(team2score)==3){
            helper.updateFinalScoreFromTwoRounds(component);
            component.set("v.isMatchWithExtraTimeRound", false);
        }
    },
    clearData: function(component, event, helper){
        helper.clearTeamRoundsScores(component);
        helper.clearTeamCardsColorsStyles(component);
        helper.fetchMatchDateToCurrentDate(component);
        component.set("v.isMatchWithExtraTimeRound", false);
        if(component.get("v.team1Score") != null && component.get("v.team2Score") != null){
            component.set("v.team2Score", 0);
            component.set("v.team1Score", 0);
            component.set("v.team1Goals", []);
            component.set("v.team2Goals", []);
        }
    },
    handleMatchRecordChange: function(component, event, helper){
        component.set("v.dateInputVisible", false);
        component.set("v.dateInputVisible", true);
//        helper.fetchMatchDateToCurrentDate(component);
        helper.matchMaxMinDateInit(component);
    },

    matchDateChange: function(component, event, helper){
        let selectedDate = component.get('v.matchDate');
        helper.validateMaxMinMatchDate(component, selectedDate)
    },
    handleDateInputError: function(component, event, helper){
//        console.log('error handler: '+ JSON.stringify(event.getParam('errors')));
    },
    handleDateInputErrorClear: function(component, event, helper){
//        console.log('error cleared '+ JSON.stringify(event.getParams()));
    },

})