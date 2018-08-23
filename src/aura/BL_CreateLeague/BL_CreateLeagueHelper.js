({
//     validateLeagueForm: function(component) {
//        var validLeague = true;
//         // Show error messages if required fields are blank
//        var allValid = component.find('leagueField').reduce(function (validFields, inputCmp) {
//            inputCmp.showHelpMessageIfInvalid();
//            return validFields && inputCmp.get('v.validity').valid;
//        }, true);
//        if (allValid) {
//            return(validLeague);
//        }
//    },
    validateLeagueForm: function(component, event) {
        var allValid = component.find('leagueField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            return true
        } else {
            return false
        }

    },
    fetchMaxTeamsPickListVal: function(component){
        var action = component.get("c.getLeagueFieldPicklistValues");
        action.setParams({
            "fieldName": "Max_Team_No__c"
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.maxTeamsOptions", allValues);
            }
        });
        $A.enqueueAction(action);
    },
    loadCurrentDate: function(component){
        let currentDate = new Date();
        let currentDateMonth = (currentDate.getMonth()+1);
        let currentDateDays = currentDate.getDate();
        if(parseInt(currentDateMonth) < 10 ){
            currentDateMonth = '0'+currentDateMonth;
        }
        if(parseInt(currentDateDays) < 10 ){
                    currentDateDays = '0'+currentDateDays;
        }
        let dateString = currentDate.getFullYear()+'-'+currentDateMonth+'-'+currentDateDays;
//        let dateString = currentDate.getFullYear()+'-'+(currentDate.getMonth()+1)+'-'+currentDate.getDate();
        let yearLater = currentDate;
        yearLater.setDate(yearLater.getDate() + 365);
        let yearLaterString = yearLater.getFullYear()+'-'+(yearLater.getMonth()+1)+'-'+yearLater.getDate();
        component.set("v.yearLaterDate", yearLaterString);
        component.set("v.currentDate", dateString);
        return dateString;
    },
    calculateMaxEndDate: function(component){
        //add 365 days (31536000000 milliseconds)
        let maxEndDate = new Date((Date.parse(component.get("v.simpleNewLeague.Start_Date__c"))) + 31536000000);
        console.log("max date : " + new Date(maxEndDate));
        let maxEndDateMonth = (maxEndDate.getMonth()+1);
        let maxEndDateDays = maxEndDate.getDate();
        if(parseInt(maxEndDateMonth) < 10 ){
            maxEndDateMonth = '0'+maxEndDateMonth;
        }
        if(parseInt(maxEndDateDays) < 10 ){
                    maxEndDateDays = '0'+maxEndDateDays;
        }
        let maxEndDateString = maxEndDate.getFullYear()+'-'+maxEndDateMonth+'-'+maxEndDateDays;
        component.set("v.maxEndDate", maxEndDateString);
        component.set("v.simpleNewLeague.End_Date__c", null);
        component.set("v.endDateInputVisible", false);
        component.set("v.endDateInputVisible", true);
        console.log("start date min: "+component.find('leagueField')[1].get("v.min"));
    },
    loadMaxStartDate: function(component){

    },
    initializeNewLeagueRecord: function(component){
        console.log("init record");
        var helper = this;
        var currentDate = new Date();
        component.find("leagueRecordCreator").getNewRecord(
            "BL_League__c", // sObject type (objectApiName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newLeague");
                var error = component.get("v.newLeagueError");
//                console.log("record: "+JSON.stringify(component.get("v.simpleNewLeague")))
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
//                component.set("v.currentDate", helper.loadCurrentDate(component));
//                component.set("v.maxStartDate", helper.loadMaxStartDate(component));
//                component.set("v.simpleNewLeague.Match_No__c", 2);
            })
        );
    },
    calculateTotalMatches: function(component){
        let totalTeams = component.get("v.simpleNewLeague.Max_Teams__c");
        let totalRounds = component.get("v.simpleNewLeague.Match_No__c");
        component.set("v.totalMatches", totalRounds*(totalTeams/2)*(totalTeams-1));
    },

    fetchLeagueRoundsList: function(component){
        let totalTeams = component.get("v.simpleNewLeague.Max_Teams__c");
        let matchesInSingleRound = totalTeams - 1;
        let totalMatchesLimit = component.get("v.totalMatchesLimit");
        console.log('totalTeams: '+totalTeams+' matchesInSingleRound: '+matchesInSingleRound+' totalMatchesLimit: '+totalMatchesLimit);
        console.log()
        let roundsLimit = Math.floor(totalMatchesLimit/((totalTeams/2)*matchesInSingleRound));
        if(roundsLimit > component.get("v.totalRoundsLimit")){
            roundsLimit = component.get("v.totalRoundsLimit");
        }
        console.log('Max rounds: '+roundsLimit);
        var leagueRoundsList = [];
        for(let ii=1 ; ii<=roundsLimit ; ii++){
            leagueRoundsList.push(ii);
        }
        console.log(leagueRoundsList);
        component.set("v.leagueRoundsNumber", leagueRoundsList);
    },
    clearForm: function(component){
        component.set("v.simpleNewLeague.Name", null); 
        component.set("v.simpleNewLeague.Max_Teams__c", null);
        component.set("v.simpleNewLeague.Match_No__c", null);
        component.set("v.simpleNewLeague.Start_Date__c", null);
        component.set("v.simpleNewLeague.End_Date__c", null);
        component.set("v.isFormVisible", false);
        component.set("v.isFormVisible", true);
    },

})