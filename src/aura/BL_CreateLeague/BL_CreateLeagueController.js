({
    onInit: function(component, event, helper) {
        helper.doInit(component);
    },

    onSave: function(component, event, helper) {
        if(helper.validateLeagueForm(component, event)) {
            let competitionType = component.get("v.competitionType");
            let initDataWrapper = component.get("v.initDataWrapper");
            component.set("v.simpleNewLeague.RecordTypeId", initDataWrapper.leagueRecordTypeDeveloperNameToId[competitionType]);

            if(competitionType === "Cup") {
                component.set("v.simpleNewLeague.Match_No__c", 1);
            }
            let teamSize = component.get("v.teamSize");
            component.set("v.simpleNewLeague.TeamSize__c", teamSize);
            component.find("leagueRecordCreator").saveRecord(function(saveResult) {
                if(saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // record is saved successfully
                    let resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "success",
                        "message": "The competition was created."
                    });
                    resultsToast.fire();
                    helper.initializeNewLeagueRecord(component);
                    let appEvent = $A.get("e.c:BL_CompetitionCreatedEvent");
                    appEvent.fire();
                } else if(saveResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                } else if(saveResult.state === "ERROR") {
                    // handle the error state
                    console.log('Problem saving league, error: ' + JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            });
        } else {
            let resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "message": "Please provide valid data"
            }).fire();
        }
    },

    handleVisibilityChange: function(component, event, helper) {
        let visibility = event.getSource().get("v.value");
        if(visibility == 'public') {
            component.set("v.simpleNewLeague.isPrivate__c", false);
        } else {
            component.set("v.simpleNewLeague.isPrivate__c", true);
        }
    },

    handleMaxTeamsChange: function(component, event, helper) {
        let validity = component.find("leagueField");
        for(let ii = 0; ii < validity.length; ii++) {
            let validation = validity[ii].get("v.validity");
        }
        component.set("v.simpleNewLeague.Match_No__c", null);
        helper.fetchLeagueRoundsList(component);
    },

    handleStartDateChange: function(component, event, helper) {
        helper.calculateMaxEndDate(component);
    },

    handleUnlimitedChanged: function(component, event, helper) {
        component.set("v.isFormVisible", false);
        component.set("v.isFormVisible", true);
    },

    handleNoOfRoundsOrTeamsChange: function(component, event, helper) {
        helper.calculateTotalMatches(component);
    },

    handleClear: function(component, event, helper) {
        helper.clearForm(component);
    },

    onLeagueRecordTypeChange: function(component, event, helper) {
        helper.clearForm(component);
    }
});