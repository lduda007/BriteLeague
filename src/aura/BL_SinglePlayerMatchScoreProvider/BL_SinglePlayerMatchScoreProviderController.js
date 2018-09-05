({
    doInit : function(component, event, helper){
        if(!$A.util.isEmpty(component.get("v.matchId"))){
            helper.getMatchDetails(component);
        }
    },
    onSaveMatchScore : function(component, event, helper){
        helper.saveMatchScore(component);
    },
    onMatchIdChange : function(component, event, helper){
        helper.getMatchDetails(component);
    }
})