({
    updateFinalScore: function(component, event){
        let teamNumber = event.getParam("expression").substring(6,7);
        let teamGoalsByRound = event.getParam("value");
        let teamScore = parseInt(0);
        for(let ii=0 ; ii < teamGoalsByRound.length ; ii++){
            if(teamGoalsByRound[ii] == 10){
                teamScore += parseInt(1);
            }
        }
        component.set("v.team"+teamNumber+"Score",teamScore);
    },

    updateFinalScoreFromTwoRounds: function(component){
        let team1score = 0;
        let team2score = 0;
        let team1goals = component.get("v.team1Goals");
        let team2goals = component.get("v.team2Goals");
        for(let ii=0 ; ii < team1goals.length - 1 ; ii++){
            if(team1goals[ii] == 10){
                team1score += parseInt(1); 
            }
        }
        for(let jj=0 ; jj < team2goals.length - 1 ; jj++){
            if(team2goals[jj] == 10){
                team2score += parseInt(1);
            }
        }
        team1goals[2] = null;
        team2goals[2] = null;
        component.set("v.team1Score",team1score);
        component.set("v.team2Score",team2score);
    },

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

    clearTeamRoundsScores: function(component){
        let roundProvidersList = component.find("roundProviders");
        for(let ii=0 ; ii < roundProvidersList.length ; ii++){
            roundProvidersList[ii].clearScores();
        }
    },

    clearTeamCardsColorsStyles: function(component){
        component.set("v.team1FinalScoreColorStyle",null);
        component.set("v.team2FinalScoreColorStyle",null);
    },

    clearOldDataOnModal: function(component){
        this.clearTeamScores(component);
        this.clearTeamCardsColorsStyles(component);
        component.set("v.team2Score", null);
        component.set("v.team1Score", null);
        component.set("v.team1Goals", []);
        component.set("v.team2Goals", []);
    },

    fetchMatchDateToCurrentDate: function(component){
        let currentDate = new Date();
        let currentDateMonth = (currentDate.getMonth()+1);
        let currentDateDays = currentDate.getDate();
        if(parseInt(currentDateMonth) < 10 ){
            currentDateMonth = '0'+currentDateMonth;
        }
        if(parseInt(currentDateDays) < 10 ){
            currentDateDays = '0'+currentDateDays;
        }
//        component.set("v.matchDate", currentDate.getFullYear()+'-'+currentDateMonth+'-'+currentDateDays);
        return currentDate.getFullYear()+'-'+currentDateMonth+'-'+currentDateDays;
    },
    matchMaxMinDateInit: function(component){
        let minDate = new Date(Date.parse(component.get("v.matchRecord.League__r.Start_Date__c")));
        let maxDate = new Date(Date.parse(component.get("v.matchRecord.League__r.End_Date__c")));
        let today = new Date();

        let minDateString = this.convertDateToString(component, minDate);
        let maxDateString = this.convertDateToString(component, maxDate);
        let todayString = this.convertDateToString(component, today);

        if(Date.parse(maxDateString) < Date.parse(todayString)){
            component.set('v.matchMaxDate', maxDateString);
            component.set('v.matchDate', maxDateString);
        }else{
            component.set('v.matchMaxDate', todayString);
            component.set('v.matchDate', todayString);
        }
    },

    convertDateToString: function(component, dateValue){
        let dateObject = new Date(Date.parse(dateValue));
        let dateObjectMonth = (dateObject.getMonth()+1);
        let dateObjectDay = dateObject.getDate();
        if(parseInt(dateObjectMonth) < 10){
            dateObjectMonth = '0'+dateObjectMonth;
        }
        if(parseInt(dateObjectDay) < 10){
            dateObjectDay = '0'+dateObjectDay;
        }
        return dateObject.getFullYear()+'-'+dateObjectMonth+'-'+dateObjectDay;
    },

    validateMaxMinMatchDate: function(component, selectedDate){
        let maxDate = component.get('v.matchRecord.League__r.End_Date__c');
        let minDate = component.get('v.matchRecord.League__r.Start_Date__c');
        let currentDate = this.convertDateToString(component, new Date());
        var inputCmp = component.find('inputDateCmp');

        if(Date.parse(currentDate) < Date.parse(maxDate)){
            maxDate = currentDate;
        }
        if( Date.parse(selectedDate) > Date.parse(maxDate) || Date.parse(selectedDate) < Date.parse(minDate) ){
            component.set('v.isSelectedMatchDateValid' , false);
            inputCmp.set('v.errors', [{message : 'Choose a date between '+minDate+' and '+maxDate}]);
        }else{
            component.set('v.isSelectedMatchDateValid' , true);
            inputCmp.set('v.errors', null);
        }
    },

})