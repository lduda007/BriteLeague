({
    doInit: function(component) {
        let action = component.get("c.getInitDataWrapper");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            let errors = response.getError();

            if(state === "SUCCESS") {
                let newCompetitionWrapper = result.competitionWrapper;
                newCompetitionWrapper.startDate = this.convertDateToString(component, new Date());
                component.set("v.newCompetitionWrapper", newCompetitionWrapper);
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
            newCompetitionWrapperJson: JSON.stringify(component.get("v.newCompetitionWrapper"))
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
        return component.find('newCompetitionForm').reduce(function (isValidSoFar, input) {
            return isValidSoFar && input.get('v.validity').valid;
        }, true);
    },

    clearForm: function(component) {
        let newCompetitionWrapper = component.get("v.newCompetitionWrapper");
        newCompetitionWrapper.teamsLimit = null;
        newCompetitionWrapper.rounds = null;
        component.set("v.newCompetitionWrapper", newCompetitionWrapper);
    },

    showToast: function(type, message) {
        $A.get("e.force:showToast").setParams({
            "type": type,
            "message": message
        }).fire();
    }
});