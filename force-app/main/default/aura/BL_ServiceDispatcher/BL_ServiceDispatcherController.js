({
    callService: function(component, event, helper) {
        let args = event.getParams().arguments;
        return helper.callService(component, args);
    }
})