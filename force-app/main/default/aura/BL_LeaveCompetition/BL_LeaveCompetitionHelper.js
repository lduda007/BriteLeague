({
    leaveCompetition: function(component, user, competition) {
        let action = component.get('c.removeCompetitorFromCompetition');
        let playerId = component.get("v.playerId");
        let leagueId = component.get("v.competitionId");

        action.setParams({
            playerId: playerId,
            leagueId: leagueId
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let errors = response.getError();

            if(state === "SUCCESS") {
                this.getUtils(component).showSuccessToast($A.get("$Label.c.BL_You_ve_left_the_competition"));
                this.closeLeaveCompetitionModal(component);
                component.getEvent('BL_CompetitorLeftCompetition').fire();
                $A.get('e.force:refreshView').fire();
            } else {
                this.getUtils(component).handleError(errors);
            }
        });
        $A.enqueueAction(action);
    },

    closeLeaveCompetitionModal: function(component) {
        $A.util.removeClass(component.find('backdrop'), "slds-backdrop_open");
        $A.util.removeClass(component.find('leaveCompetitionModal'), "slds-slide-down-cancel");
    },

    getUtils: function(component) {
        return component.find("utils");
    }
});