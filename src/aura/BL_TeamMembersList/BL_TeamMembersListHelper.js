({
    loadTeamMembers : function(component) {
        let getTeamMembersAction = component.get("c.getTeamMembers");
        getTeamMembersAction.setParam('teamId', component.get("v.recordId"));
        getTeamMembersAction.setCallback(this, response => {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.teamMembers", response.getReturnValue());
            } else {
                this.showToast(
                    component,
                    $A.get("$Label.c.BL_Error_When_Loading_Team_Details"),
                    "error",
                    $A.get("$Label.c.BL_Error")
                );
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(getTeamMembersAction);
    },

    getCurrentPlayer : function(component) {
        let getPlayerAction = component.get("c.getUserContactId");
        getPlayerAction.setCallback(this, response => {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentPlayerId", response.getReturnValue());
            } else {
                this.showToast(
                    component,
                    $A.get("$Label.c.BL_Error_When_Loading_Team_Details"),
                    "error",
                    $A.get("$Label.c.BL_Error")
                );
            }
        });
        $A.enqueueAction(getPlayerAction);
    },

    tryToSelectTeam : function(component) {
        if(component.get("v.selectedTeam").Name) {
            let selectedTeams = component.get("v.selectedTeams");
            let selectedTeam = component.get("v.selectedTeam");
            let currentMembers = component.get("v.teamMembers");
            let existingElementIndex = selectedTeams.findIndex(t => t.Id == selectedTeam.Id);
            if (existingElementIndex == -1) {
                selectedTeams.push(selectedTeam);
                selectedTeams.sort((a, b) => {
                    return a.Name >= b.Name ? 1 : -1;
                });
                component.set("v.selectedTeams", selectedTeams);
            } else {
                selectedTeams[existingElementIndex].isHighlighted = true;
                component.set("v.selectedTeams", selectedTeams);
                setTimeout(() => {
                    selectedTeams[existingElementIndex].isHighlighted = false;
                    component.set("v.selectedTeams", selectedTeams);
                }, 2000);
            }

            var compEvent = $A.get("e.c:BL_CustomLookupClearEvent");
            compEvent.setParams({"parentName" : 'BL_TeamMembersList' });
            compEvent.fire();
        }
    },

    addSelectedTeams : function(component) {
        let membersIds = component.get("v.selectedTeams").map(team => team.Id);

        let saveMembersAction = component.get("c.addTeamMembers");
        saveMembersAction.setParams({
            "parentTeamId": component.get("v.recordId"),
            "memberTeamsIds": membersIds
        });
        saveMembersAction.setCallback(this, response => {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.selectedTeams", []);
                component.set("v.showSpinner", true);
                this.loadTeamMembers(component);
                this.showToast(
                    component,
                    $A.get("$Label.c.BL_Success"),
                    "success"
                );
            } else {
                this.showToast(
                    component,
                    $A.get("$Label.c.BL_Error_when_adding_teams"),
                    "error",
                    $A.get("$Label.c.BL_Error")
                );
            }
        });
        $A.enqueueAction(saveMembersAction);
    },

    removeTeam : function(component, teamMemberId) {
        let removeMemberAction = component.get("c.removeTeamMember");
        removeMemberAction.setParams({
            "parentTeamId": component.get("v.recordId"),
            "teamMemberId": teamMemberId
        });
        removeMemberAction.setCallback(this, response => {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.selectedTeams", []);
                component.set("v.showSpinner", true);
                this.loadTeamMembers(component);
                this.showToast(
                    component,
                    $A.get("$Label.c.BL_Team_Removed")
                );
            } else {
                this.showToast(
                    component,
                    $A.get("$Label.c.BL_Error_when_removing_team"),
                    "error",
                    $A.get("$Label.c.BL_Error")
                );
            }
        });
        $A.enqueueAction(removeMemberAction);
    },

    showToast : function(component, message, type, title) {
        let resultsToast = $A.get("e.force:showToast");
        if ($A.util.isUndefined(resultsToast)){
            alert(message);
        } else {
            resultsToast.setParams({
                "title": title,
                "message": message,
                "type": type
            });
            resultsToast.fire();
        }
    }
})