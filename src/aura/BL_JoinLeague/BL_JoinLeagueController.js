({
    doInit : function(component, event, helper) {
         helper.getPlayerActiveTeams(component);
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
        let team = component.get('v.competitorToInsert').Team__c;
        if($A.util.isEmpty(team)){
            let toastEvt = $A.get('e.force:showToast');
            toastEvt.setParams({
                "message" : $A.get('$Label.c.BL_Select_Team_Error'),
                "type" : 'warning'
            });
            toastEvt.fire();
        } else {
            helper.handleSaveCompetitor(component, event, helper);
        }
    }
});