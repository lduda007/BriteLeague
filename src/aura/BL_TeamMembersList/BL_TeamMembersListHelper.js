({
	loadTeamMembers : function(component) {
		let getTeamMembersAction = component.get("c.getTeamMembers");
		getTeamMembersAction.setParam('teamId', component.get("v.recordId"));
		getTeamMembersAction.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.teamMembers", response.getReturnValue());
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
        $A.enqueueAction(getTeamMembersAction);
	},
})