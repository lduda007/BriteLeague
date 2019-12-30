({
    /** Handles component overlay configuration event and routes it to perform required action */
    handleEvent: function(component, event) {
        let params = event.getParams(),
            config = component.get('v.config') || {};

        for (let param in params) {
            config[param] = this.handleParamAction(component, params[param])[param]();
        }

        component.set('v.config', config);
    },

    /** Performs action from component overlay configuration event */
    handleParamAction: function(component, value) {
        return {
            'spinnerActive': () => {return value;}
        };
    },
})