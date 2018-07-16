({
    doInit: function(component, event, helper) {
        helper.initializeNewLeagueRecord(component);
    },

    handleSaveLeague: function(component, event, helper) {
        if(helper.validateLeagueForm(component)) {
            if(component.find("unlimitedTeamsCheckbox").get("v.checked") == true){
                component.set("v.simpleNewLeague.Max_Teams__c", 0 )
            }
            component.find("leagueRecordCreator").saveRecord(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // record is saved successfully
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "success",
                        "message": "The league was created."
                    });
                    resultsToast.fire();
                    helper.initializeNewLeagueRecord(component);

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
        component.set("v.simpleNewLeague.Max_Teams__c", event.getSource().get("v.value"));
        console.log(JSON.stringify(component.get("v.simpleNewLeague")));
    },
    handleUnlimitedChanged: function(component, event, helper){
        component.set("v.isFormVisible", false);
        component.set("v.isFormVisible", true);
    },
})