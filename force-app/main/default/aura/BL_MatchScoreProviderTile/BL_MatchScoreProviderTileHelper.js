({
    updateFinalScore: function(component, event) {
        let teamNumber = event.getParam("expression").substring(6, 7);
        let teamGoalsByRound = event.getParam("value");
        let teamScore = parseInt(0);
        for(let ii = 0; ii < teamGoalsByRound.length; ii++) {
            if(teamGoalsByRound[ii] == 10) {
                teamScore += parseInt(1);
            }
        }
        component.set("v.team" + teamNumber + "Score", teamScore);
    },

    updateFinalScoreFromTwoRounds: function(component) {
        let team1score = 0;
        let team2score = 0;
        let team1goals = component.get("v.team1Goals");
        let team2goals = component.get("v.team2Goals");
        for(let ii = 0; ii < team1goals.length - 1; ii++) {
            if(team1goals[ii] == 10) {
                team1score += parseInt(1);
            }
        }
        for(let jj = 0; jj < team2goals.length - 1; jj++) {
            if(team2goals[jj] == 10) {
                team2score += parseInt(1);
            }
        }
        team1goals[2] = null;
        team2goals[2] = null;
        component.set("v.team1Score", team1score);
        component.set("v.team2Score", team2score);
    },

    setTeamPanelStyle: function(component) {
        let team1score = component.get("v.team1Score");
        let team2score = component.get("v.team2Score");
        let scoreSum = parseInt(team1score) + parseInt(team2score);
        if(parseInt(team1score) == parseInt(team2score) && scoreSum == 2) {
            component.set("v.team1FinalScoreColorStyle", "draw");
            component.set("v.team2FinalScoreColorStyle", "draw");
        } else if(parseInt(team1score) > parseInt(team2score) && scoreSum >= 2) {
            component.set("v.team1FinalScoreColorStyle", "winner");
            component.set("v.team2FinalScoreColorStyle", "loser");
        } else if(parseInt(team1score) < parseInt(team2score) && scoreSum >= 2) {
            component.set("v.team1FinalScoreColorStyle", "loser");
            component.set("v.team2FinalScoreColorStyle", "winner");
        }
    },

    clearTeamRoundsScores: function(component) {
        let roundProvidersList = component.find("roundProviders");
        for(let ii = 0; ii < roundProvidersList.length; ii++) {
            roundProvidersList[ii].clearScores();
        }
    },

    clearTeamCardsColorsStyles: function(component) {
        component.set("v.team1FinalScoreColorStyle", null);
        component.set("v.team2FinalScoreColorStyle", null);
    },

    clearOldDataOnModal: function(component) {
        this.clearTeamCardsColorsStyles(component);
        component.set("v.team2Score", null);
        component.set("v.team1Score", null);
        component.set("v.team1Goals", []);
        component.set("v.team2Goals", []);
    },

    convertDateToString: function(component, dateValue) {
        let dateObject = new Date(Date.parse(dateValue));
        let dateObjectMonth = (dateObject.getMonth() + 1);
        let dateObjectDay = dateObject.getDate();

        if(parseInt(dateObjectMonth) < 10) {
            dateObjectMonth = '0' + dateObjectMonth;
        }

        if(parseInt(dateObjectDay) < 10) {
            dateObjectDay = '0' + dateObjectDay;
        }

        return dateObject.getFullYear()
            + '-' + dateObjectMonth
            + '-' + dateObjectDay
            + 'T' + dateObject.getHours()
            + ':' + dateObject.getMinutes()
            + ':' + dateObject.getSeconds()
            + '.' + dateObject.getMilliseconds() + 'Z';
    }
});