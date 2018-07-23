({
    setTeamPanelStyle: function(component){
        let team1score = component.get("v.team1Score");
        let team2score = component.get("v.team2Score");
        let scoreSum = parseInt(team1score) + parseInt(team2score);
        if(parseInt(team1score) == parseInt(team2score) && scoreSum == 2){
            component.set("v.team1FinalScoreColorStyle", "draw");
            component.set("v.team2FinalScoreColorStyle", "draw");
        }else if(parseInt(team1score) > parseInt(team2score) && scoreSum >= 2){
            component.set("v.team1FinalScoreColorStyle", "winner");
            component.set("v.team2FinalScoreColorStyle", "loser");
        }else if(parseInt(team1score) < parseInt(team2score) && scoreSum >= 2){
            component.set("v.team1FinalScoreColorStyle", "loser");
            component.set("v.team2FinalScoreColorStyle", "winner");
        }
    },
})