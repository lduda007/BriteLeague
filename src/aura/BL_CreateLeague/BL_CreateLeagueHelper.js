({
     validateLeagueForm: function(component) {
        var validLeague = true;
         // Show error messages if required fields are blank
        var allValid = component.find('leagueField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            return(validLeague);
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
        var currentDate = new Date();
        var dateString = currentDate.getFullYear()+'-'+(currentDate.getMonth()+1)+'-'+currentDate.getDate();
        return dateString;
    },
    initializeNewLeagueRecord: function(component){
        var helper = this;
        var currentDate = new Date();
        component.find("leagueRecordCreator").getNewRecord(
            "BL_League__c", // sObject type (objectApiName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newLeague");
                var error = component.get("v.newLeagueError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
                component.set("v.currentDate", helper.loadCurrentDate(component));
            })
        );
    },
})