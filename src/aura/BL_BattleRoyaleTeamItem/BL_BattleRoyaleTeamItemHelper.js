({
    setColumns: function(component) {
        let columns = [
            {
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
            },
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
            },
            {
                label: "P",
                fieldName: "points",
                type: "number",
                initialWidth: "50",
                cellAttributes: {
                    alignment: "left"
                }
            }
        ];

        component.set("v.columns", columns);
    },

    getUtils: function(component) {
        return component.find("utils");
    }
});