({
	loadParentTeams : function(component) {
		let getParentTeamsAction = component.get("c.getParentTeams");
		getParentTeamsAction.setParam('teamId', component.get("v.recordId"));
		getParentTeamsAction.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.parentTeams", response.getReturnValue());
            }else{
                let resultsToast = $A.get("e.force:showToast");
                if ($A.util.isUndefined(resultsToast)){
                    alert($A.get("$Label.c.BL_Error_When_Loading_Team_Details"));
                }else{
                    resultsToast.setParams({
                        "title": $A.get("$Label.c.BL_Error"),
                        "message": $A.get("$Label.c.BL_Error_When_Loading_Team_Details")
                    });
                    resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(getParentTeamsAction);
	},
})