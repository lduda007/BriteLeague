({
    doInit : function(component, event, helper) {
         component.find("competitorRecordCreator").getNewRecord(
             "BL_Competitor__c",
             null,
             false,
             $A.getCallback(function() {
                 let rec = component.get("v.newCompetitor");
                 let error = component.get("v.newCompetitorError");
                 if(error || (rec === null)) {
                     return;
                 }
             })
         );
    },
    saveCompetitor : function(component, event, helper) {
        helper.handleSaveCompetitor(component);
    }
})