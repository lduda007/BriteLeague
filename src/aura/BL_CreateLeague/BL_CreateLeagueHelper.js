({
    doInit: function(component) {
        let action = component.get("c.getInitDataWrapper");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();

            if(state === "SUCCESS") {
                component.set("v.initDataWrapper", result);
            } else if(state === "ERROR") {
                let errors = response.getError();
                let message = 'Unknown error';
                if(errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.error(message);
            }
        });
        $A.enqueueAction(action);
    },

    validateLeagueForm: function(component, event) {
        var allValid = component.find('leagueField').reduce(function(validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if(allValid) {
            return true
        } else {
            return false
        }
    },

    fetchMaxTeamsPickListVal: function(component) {
        let action = component.get("c.getLeagueFieldPicklistValues");
        action.setParams({
            "fieldName": "Max_Team_No__c"
        });
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.maxTeamsOptions", allValues);
            }
        });
        $A.enqueueAction(action);
    },

    loadCurrentDate: function(component) {
        let currentDate = new Date();
        let currentDateMonth = (currentDate.getMonth() + 1);
        let currentDateDays = currentDate.getDate();
        if(parseInt(currentDateMonth) < 10) {
            currentDateMonth = '0' + currentDateMonth;
        }
        if(parseInt(currentDateDays) < 10) {
            currentDateDays = '0' + currentDateDays;
        }
        let dateString = currentDate.getFullYear() + '-' + currentDateMonth + '-' + currentDateDays;
//        let dateString = currentDate.getFullYear()+'-'+(currentDate.getMonth()+1)+'-'+currentDate.getDate();
        let yearLater = currentDate;
        yearLater.setDate(yearLater.getDate() + 365);
        let yearLaterString = yearLater.getFullYear() + '-' + (yearLater.getMonth() + 1) + '-' + yearLater.getDate();
        component.set("v.yearLaterDate", yearLaterString);
        component.set("v.currentDate", dateString);
        return dateString;
    },

    calculateMaxEndDate: function(component) {
        //add 365 days (31536000000 milliseconds)
        let maxEndDate = new Date((Date.parse(component.get("v.simpleNewLeague.Start_Date__c"))) + 31536000000);
        let maxEndDateMonth = (maxEndDate.getMonth() + 1);
        let maxEndDateDays = maxEndDate.getDate();
        if(parseInt(maxEndDateMonth) < 10) {
            maxEndDateMonth = '0' + maxEndDateMonth;
        }
        if(parseInt(maxEndDateDays) < 10) {
            maxEndDateDays = '0' + maxEndDateDays;
        }
        let maxEndDateString = maxEndDate.getFullYear() + '-' + maxEndDateMonth + '-' + maxEndDateDays;
        component.set("v.maxEndDate", maxEndDateString);
        component.set("v.simpleNewLeague.End_Date__c", null);
        component.set("v.endDateInputVisible", false);
        component.set("v.endDateInputVisible", true);
    },

    loadMaxStartDate: function(component) {

    },

    initializeNewLeagueRecord: function(component) {
        let helper = this;
        let currentDate = new Date();
        component.find("leagueRecordCreator").getNewRecord(
            "BL_League__c", // sObject type (objectApiName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                let rec = component.get("v.newLeague");
                let error = component.get("v.newLeagueError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
            })
        );
    },

    calculateTotalMatches: function(component) {
        let totalTeams = component.get("v.simpleNewLeague.Max_Teams__c");
        let totalRounds = component.get("v.simpleNewLeague.Match_No__c");
        component.set("v.totalMatches", totalRounds * (totalTeams / 2) * (totalTeams - 1));
    },

    fetchLeagueRoundsList: function(component) {
        let totalTeams = component.get("v.simpleNewLeague.Max_Teams__c");
        let matchesInSingleRound = totalTeams - 1;
        let totalMatchesLimit = component.get("v.totalMatchesLimit");
        let roundsLimit = Math.floor(totalMatchesLimit / ((totalTeams / 2) * matchesInSingleRound));
        if(roundsLimit > component.get("v.totalRoundsLimit")) {
            roundsLimit = component.get("v.totalRoundsLimit");
        }
        let leagueRoundsList = [];
        for(let ii = 1; ii <= roundsLimit; ii++) {
            leagueRoundsList.push(ii);
        }
        component.set("v.leagueRoundsNumber", leagueRoundsList);
    },

    clearForm: function(component) {
        component.set("v.simpleNewLeague.Name", null);
        component.set("v.simpleNewLeague.Max_Teams__c", null);
        component.set("v.simpleNewLeague.Match_No__c", null);
        component.set("v.simpleNewLeague.Start_Date__c", null);
        component.set("v.simpleNewLeague.End_Date__c", null);
        component.set("v.isFormVisible", false);
        component.set("v.isFormVisible", true);
    }
});