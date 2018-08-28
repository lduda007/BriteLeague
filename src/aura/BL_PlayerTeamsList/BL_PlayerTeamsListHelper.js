({
    fetchRecords : function(component){
    	var action = component.get('c.getPlayerTeams');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                component.set('v.teamsList', response.getReturnValue());
                console.log('teams: '+JSON.stringify(component.get('v.teamsList')));
            } else if(state === 'ERROR') {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Error.',
                    type: 'error',
                    message : response.getError()[0].message
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);    
    },

    fetchReceivedInvitations : function(component){
        var action = component.get('c.getReceivedTeamInvitations');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                component.set('v.receivedInvitations', response.getReturnValue());
            } else if(state === 'ERROR') {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Error.',
                    type: 'error',
                    message : response.getError()[0].message
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);
    },

    fetchSentInvitations : function(component){
        var action = component.get('c.getSentTeamInvitations');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                component.set('v.sentInvitations', response.getReturnValue());
            } else if(state === 'ERROR') {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Error.',
                    type: 'error',
                    message : response.getError()[0].message
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
	saveRecord : function(component,event) {
        var self = this;
    	var selectedPlayer = component.get("v.selectedPlayer");
        var action = component.get("c.saveTeam");
        action.setParams({
            'team': component.get("v.team"),
            'player' : selectedPlayer
        });

        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                self.fetchRecords(component);
                document.getElementById("newTeamModal").style.display = "none" ;
		        $A.util.removeClass(component.find("modal-dialog-background"), "slds-backdrop_open");
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Team saved.',
                    type: 'success',
                    message : 'Approval request was send to ' + selectedPlayer.Name
                });
                showToast.fire();
                this.fetchSentInvitations(component);
            }else if(state === 'ERROR') {
				var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Error.',
                    type: 'error',
                    message : response.getError()[0].message
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);

    },

    confirmInvitation : function(component,event,isConfirm){
        var self = this;
        var recordToConfirm = event.getSource().get("v.name");

        var action = component.get("c.confirmInvitation");
        action.setParams({
            'recordId': recordToConfirm,
            'isConfirmed' : isConfirm
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var showToast = $A.get("e.force:showToast");
                if (isConfirm === true){
                    showToast.setParams({
                        title : 'Invitation confirmed.',
                        type: 'success',
                        message : 'Invitation was confirmed. You can play on this team!'
                    });
                } else {
                    showToast.setParams({
                        title : 'Invitation rected.',
                        type: 'success',
                        message : 'Invitation was rejected. Team was deleted :('
                    });
                }
                showToast.fire();
                self.fetchReceivedInvitations(component);
                self.fetchRecords(component);
            }else if(state === 'ERROR') {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Error.',
                    type: 'error',
                    message : "Unexpected error ocoured"
                });
                showToast.fire();
                self.fetchReceivedInvitations(component);
                self.fetchRecords(component);
            }
        });
        $A.enqueueAction(action);
    },

    deleteTeam : function(component,event){
        var self = this;
        var recordToDelete = event.getSource().get("v.name");

        var action = component.get("c.deleteTeams");
        action.setParams({
            'recordId': recordToDelete
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                self.fetchRecords(component,event);

                var showToast = $A.get("e.force:showToast");

                showToast.setParams({
                    title : 'Team deleted.',
                    type: 'success',
                    message : 'Team deleted!'
                });

                showToast.fire();
                this.fetchSentInvitations(component);
            }else if(state === 'ERROR') {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title : 'Error.',
                    type: 'error',
                    message : response.getError()[0].message
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);
    },

    goToTeam : function(component,event){
        var recordId = event.currentTarget.dataset.recordid;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/bl-team/"+recordId
        });
        urlEvent.fire();
    },

    getCurrentUser : function(component){
        let action = component.get('c.getCurrentUser');
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS")
            {
                let user = response.getReturnValue();
                component.set("v.user", user);
                this.checkIsCurrentUserAlreadyInCompetition(component, user, component.get("v.league"));
            }
        });
        $A.enqueueAction(action);
    }
})