({
    doInit: function(component, event, helper) {
        helper.loadCurrentDate(component);
        helper.initializeNewLeagueRecord(component);
        console.log("start date: "+component.get("v.simpleNewLeague.Start_Date__c"));

    },

    handleSaveCompetition: function(component, event, helper) {
        var competitionName = (component.get("v.competitionType") == 'league' ? 'league' : 'cup');
        if(helper.validateLeagueForm(component, event)) {
            if(component.get("v.competitionType") == 'cup'){
                component.set("v.simpleNewLeague.isCup__c", true);
                component.set("v.simpleNewLeague.Match_No__c", 1);
            }
            let teamSize = component.get("v.teamSize");
            component.set("v.simpleNewLeague.TeamSize__c", teamSize);
            component.find("leagueRecordCreator").saveRecord(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // record is saved successfully
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "success",
                        "message": "The "+competitionName+" was created."
                    });
                    resultsToast.fire();
                    helper.initializeNewLeagueRecord(component);
                    let appEvent = $A.get("e.c:BL_CompetitionCreatedEvent");
                    appEvent.fire();
                } else if (saveResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    // handle the error state
                    console.log('Problem saving league, error: ' + JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            });
        }else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "error",
                "message": "Please provide valid data"
            }).fire();
        }
    },

    handleVisibilityChange: function(component, event, helper){
        let visibility = event.getSource().get("v.value");
        if(visibility == 'public'){
            component.set("v.simpleNewLeague.isPrivate__c", false);
        }else{
            component.set("v.simpleNewLeague.isPrivate__c", true);
        }
    },

    handleMaxTeamsChange: function(component, event, helper){
        console.log("input: "+component.get("v.simpleNewLeague.Max_Teams__c"));
        let validity = component.find("leagueField");
        for(let ii=0 ; ii < validity.length ; ii++){
            let validation = validity[ii].get("v.validity");
            console.log(validation.valid);
        }
//        component.set("v.simpleNewLeague.Max_Teams__c", event.getSource().get("v.value"));
//        component.set("v.simpleNewLeague.Max_Teams__c", component.get("v.simpleNewLeague.Max_Teams__c"));
        component.set("v.simpleNewLeague.Match_No__c", null);
//        helper.calculateTotalMatches(component);
        helper.fetchLeagueRoundsList(component);
    },

    handleStartDateChange: function(component, event, helper){

        helper.calculateMaxEndDate(component);
    },

    handleUnlimitedChanged: function(component, event, helper){
        component.set("v.isFormVisible", false);
        component.set("v.isFormVisible", true);
    },

    handleNoOfRoundsOrTeamsChange: function(component, event, helper){
        helper.calculateTotalMatches(component);
    },

    handleClear: function(component, event, helper){
        helper.clearForm(component);
    },

    handleCompetitionTypeChange: function(component, event, helper){
        helper.clearForm(component);
    },

    onKeyDown: function(component, evnt, helper){
//        let elem = evnt.getSource();
//        console.log('log: '+elem);
//        window.addEventListener("keydown", function(event) {
////          console.log("key: " + event.key + " , code: " + event.code);
//          console.log( " , code: " + event.code);
//          if(event.code == 'Comma' || event.code == 'Period' || event.code == 'KeyE' || event.code == 'Minus' || event.code =='NumpadSubtract' || event.code == 'NumpadAdd'){
//              event.preventDefault();
////              event.returnValue = false;
////              return false;
//           }
//        }, false);
    },
})