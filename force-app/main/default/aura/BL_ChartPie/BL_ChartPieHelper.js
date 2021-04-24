({
    getDefaultColors : function(component, event, count) {
        var defaultColors = [
            'rgba(74, 255, 49, 1)',
            'rgba(255, 68, 53, 1)',
            'rgba(74, 255, 49, 1)',
            'rgba(255, 68, 53, 1)',
            'rgba(74, 255, 49, 1)',
            'rgba(255, 68, 53, 1)',
            'rgba(74, 255, 49, 1)',
            'rgba(255, 68, 53, 1)',
            'rgba(74, 255, 49, 1)',
            'rgba(255, 68, 53, 1)',
            'rgba(74, 255, 49, 1)',
            'rgba(255, 68, 53, 1)',
            'rgba(74, 255, 49, 1)',
            'rgba(255, 68, 53, 1)',
            'rgba(74, 255, 49, 1)',
            'rgba(255, 68, 53, 1)'];

        var colors = [];
        for (var i = 0; i < count; i++) {
            colors.push(defaultColors[i]);
        }

        return colors;
    }
})