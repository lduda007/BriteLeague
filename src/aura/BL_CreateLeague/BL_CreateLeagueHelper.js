({
    doInit: function(component) {
        let action = component.get("c.getInitDataWrapper");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            let errors = response.getError();

            if(state === "SUCCESS") {
                let newLeagueWrapper = result.leagueWrapper;
                newLeagueWrapper.startDate = this.convertDateToString(component, new Date());
                component.set("v.newLeagueWrapper", newLeagueWrapper);
                component.set("v.initDataWrapper", result);
            } else if(state === "ERROR") {
                let message = 'Unknown error';
                if(errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.error(message);
            }
        });
        $A.enqueueAction(action);
    },

    doSave: function(component) {
        let action = component.get("c.saveCompetition");
        action.setParams({
            newLeagueWrapperJson: JSON.stringify(component.get("v.newLeagueWrapper"))
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            let errors = response.getError();

            if(state === "SUCCESS") {
                this.showToast('SUCCESS', 'Competition Created!');
                $A.get("e.force:navigateToSObject").setParams({
                      "recordId": result,
                      "slideDevName": "detail"
                      }).fire();
            } else if(state === "ERROR") {
                let message;
                if(errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                } else {
                    message = 'Unknown error!';
                }
                this.showToast('ERROR', message);
            }
        });
        $A.enqueueAction(action);
    },

    convertDateToString: function(component, dateValue) {
        let dateObject = new Date(Date.parse(dateValue));
        let dateObjectMonth = (dateObject.getMonth() + 1);
        let dateObjectDay = dateObject.getDate();

        if(parseInt(dateObjectMonth) < 10) {
            dateObjectMonth = '0' + dateObjectMonth;
        }

        if(parseInt(dateObjectDay) < 10) {
            dateObjectDay = '0' + dateObjectDay;
        }

        return dateObject.getFullYear()
            + '-' + dateObjectMonth
            + '-' + dateObjectDay
            + 'T' + dateObject.getHours()
            + ':' + dateObject.getMinutes()
            + ':' + dateObject.getSeconds()
            + '.' + dateObject.getMilliseconds() + 'Z';
    },

    validateForm: function(component) {
        return component.find('newLeagueForm').reduce(function (isValidSoFar, input) {
            return isValidSoFar && input.get('v.validity').valid;
            }, true);
    },

    clearForm: function(component) {
        let newLeagueWrapper = component.get("v.newLeagueWrapper");
        newLeagueWrapper.teamsLimit = null;
        newLeagueWrapper.rounds = null;
        component.set("v.newLeagueWrapper", newLeagueWrapper);
    },

    showToast: function(type, message) {
        $A.get("e.force:showToast").setParams({
            "type": type,
            "message": message
        }).fire();
    }
});