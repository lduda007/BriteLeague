({
    setColumns: function(component) {
        let columns = [
            {
                label: "Name",
                fieldName: "name",
                type: "text",
                minColumnWidth: "200"
            },
            {
                label: "P1",
                fieldName: "player1LastName",
                type: "text"
            },
            {
                label: "P2",
                fieldName: "player2LastName",
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
    }
});