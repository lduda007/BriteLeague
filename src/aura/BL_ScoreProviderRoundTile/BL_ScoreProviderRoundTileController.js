({
    handleScoreSelected: function(component,event,helper){
        let score = event.getParam("score");
        let round = event.getParam("roundNumber");
        let team = event.getParam("teamNumber");
        if(team == 1){
            component.set("v.team1Score", score);
            if(score != 10){
                component.set("v.team2Score", 10);
                component.set("v.team2wins", true);
            }else if(score == 10){
                component.set("v.team1wins", true);
            }
        }
        if(team == 2){
            component.set("v.team2Score", score);
            if(score != 10){
                component.set("v.team1Score", 10);
                component.set("v.team1wins", true);
            }else if(score == 10){
                component.set("v.team2wins", true);
            }
        }
    },
    handleRoundScoreChanged: function(component,event,helper){
        let team1score = parseInt(component.get("v.team1Score"));
        let team2score = parseInt(component.get("v.team2Score"));
        let scoreSum = parseInt(team1score) + parseInt(team2score);
        if(!$A.util.isEmpty(component.get("v.team1Score")) && !$A.util.isEmpty(component.get("v.team2Score"))){
            if(scoreSum == 20){
                component.set(event.getParam("expression") , event.getParam("oldValue"));
            }

        }

    },
    handleAcceptScoreClick: function(component,event,helper){
        let team1score = parseInt(component.get("v.team1Score"));
        let team2score = parseInt(component.get("v.team2Score"));
        component.getEvent("roundScoreSelected").setParams({
            "team1score" : team1score,
            "team2score" : team2score,
            "round" : component.get("v.roundNo")
        }).fire();
        component.set("v.isEditMode", false);
    },
    handleEditModeClick: function(component,event,helper){
        component.set("v.isEditMode", true);
    },
})