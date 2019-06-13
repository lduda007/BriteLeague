({
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
            Array.prototype.push.apply(columns, [
                {
                    label: "Players",
                    fieldName: "players",
                    type: "text"
                },
                {
                    label: "M",
                    fieldName: "matchesPlayed",
                    type: "number",
                    initialWidth: "50",
                    cellAttributes: {
                        alignment: "left"
                    }
                },
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

        if(!isPhone) {
            columns.push({
                type: "button-icon",
                typeAttributes: {
                    name: "selectTeam",
                    variant: "base",
                    iconName: "utility:check",
                    class: "button-icon-size-small"
                },
                initialWidth: "50"
            });
        }

        component.set("v.columns", columns);
    },

    getUtils: function(component) {
        return component.find("utils");
    }
});