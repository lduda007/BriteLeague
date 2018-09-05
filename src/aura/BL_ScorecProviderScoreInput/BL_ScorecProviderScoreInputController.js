({
    doInit: function(component, event, helper){
        var options = component.get("v.scoreOptions");
        var loserOptions = component.get("v.loserScoreOptions");
        for(let ii=0; ii<=10; ii++){
            options.push(ii);
            if(ii != 10){
                loserOptions.push(ii);
            }
        }
        component.set("v.scoreOptions", options);
        component.set("v.loserScoreOptions", loserOptions);
    },
    handleScoreChange: function(component, event, helper){
        let componentEvent = component.getEvent("scoreInputSelected");
        componentEvent.setParams({
            "score": event.getSource().get("v.value"),
            "roundNumber": component.get("v.roundNumber"),
            "teamNumber": component.get("v.teamNumber"),
        });
        componentEvent.fire();
    },
})