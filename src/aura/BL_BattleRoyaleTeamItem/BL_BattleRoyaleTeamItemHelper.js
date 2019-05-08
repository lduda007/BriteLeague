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
                initialWidth: "50"
            },
            {
                label: "W",
                fieldName: "gamesWon",
                type: "number",
                initialWidth: "50"
            },
            {
                label: "D",
                fieldName: "gamesDrawn",
                type: "number",
                initialWidth: "50"
            },
            {
                label: "L",
                fieldName: "gamesLost",
                type: "number",
                initialWidth: "50"
            },
            {
                label: "P",
                fieldName: "points",
                type: "number",
                initialWidth: "50"
            }
        ];

        component.set("v.columns", columns);
    },

    getUtils: function(component) {
        return component.find("utils");
    }
});