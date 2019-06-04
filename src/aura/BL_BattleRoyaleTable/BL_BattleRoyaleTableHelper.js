({
    getDataWrapper: function(component) {
        this.showSpinner(component);

        let action = component.get("c.getDataWrapper");
        action.setParams({
            "leagueId": component.get("v.leagueId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();

            if(state === "SUCCESS") {
                component.set("v.battleRoyaleTeams", result.battleRoyaleTeams);
            } else if(state === "ERROR") {
                let errors = response.getError();
                let message = 'Unknown error';
                if(errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.error(message);
            }

            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    setColumns: function(component) {
        let columns = [];
        let isPhone = $A.get("$Browser.isPhone");

        columns.push({
            label: "Name",
            type: "button",
            typeAttributes: {
                label: {
                    fieldName: "name"
                },
                name: "goToRecord",
                variant: "base"
            },
            cellAttributes: {
                iconName: {
                    fieldName: "teamIcon"
                },
                iconPosition: "left"
            }
        });

        if(!isPhone) {
            columns.push({
                label: "Captain",
                fieldName: "player1Name",
                type: "text"
            });
        }

        columns.push({
            label: "M",
            fieldName: "matchesPlayed",
            type: "number",
            initialWidth: "50",
            cellAttributes: {
                alignment: "left"
            }
        });

        if(!isPhone) {
            Array.prototype.push.apply(columns, [
                {
                    label: "W",
                    fieldName: "gamesWon",
                    type: "number",
                    initialWidth: "50",
                    cellAttributes: {
                        alignment: "left"
                    }
                },
                {
                    label: "D",
                    fieldName: "gamesDrawn",
                    type: "number",
                    initialWidth: "50",
                    cellAttributes: {
                        alignment: "left"
                    }
                },
                {
                    label: "L",
                    fieldName: "gamesLost",
                    type: "number",
                    initialWidth: "50",
                    cellAttributes: {
                        alignment: "left"
                    }
                },
                {
                    label: "B",
                    fieldName: "goalsDraw",
                    type: "number",
                    initialWidth: "50",
                    cellAttributes: {
                        alignment: "left"
                    }
                }
            ]);
        }

        columns.push({
            label: "P",
            fieldName: "points",
            type: "number",
            initialWidth: "50",
            cellAttributes: {
                alignment: "left"
            }
        });

        component.set("v.columns", columns);
    },

    showSpinner: function(component) {
        component.set("v.isSpinner", true);
    },

    hideSpinner: function(component) {
        component.set("v.isSpinner", false);
    },

    getUtils: function(component) {
        return component.find("utils");
    }
});