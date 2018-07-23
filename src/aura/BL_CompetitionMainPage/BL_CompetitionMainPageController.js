({
    recordUpdated: function(component, event, helper) {
        let changeType = event.getParams().changeType;
        if(changeType === "LOADED") {
            let competition = component.get("v.competitionFields");
            if(competition.isCup__c == false){
                component.set("v.competitionType", 'league');
            }else{
                component.set("v.competitionType", 'cup')
            }
        }
    }
})