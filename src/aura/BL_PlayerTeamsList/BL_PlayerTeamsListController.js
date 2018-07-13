({
    doInit : function(component, event, helper){
        helper.fetchRecords(component,event);
    },
    
    saveRecord : function(component, event, helper) {
        helper.saveRecord(component,event);
    },
    
    newTeam : function(component, event, helper) {
        document.getElementById("newTeamModal").style.display = "block";
        $A.util.addClass(component.find("modal-dialog-background"), "slds-backdrop_open");
    },

    hideModal : function(component,event, helper){
       document.getElementById("newTeamModal").style.display = "none" ;
       $A.util.removeClass(component.find("modal-dialog-background"), "slds-backdrop_open");
   }
})