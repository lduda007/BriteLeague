({
    /**
    Calls service method by given service and method name
    */
    callService: function(component, args) {
        this.activateService(component, args.serviceName);
        return component.find(args.serviceName)[args.methodName].apply(null, args.params);
    },
    /**
    Renders service component
    */
    activateService: function(component, serviceName) {
        const active = component.get('v.active') || {};
        active[serviceName] = true;
        component.set('v.active', active);
    }
})