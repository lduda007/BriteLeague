({
    handleComponentEvent: function(component, event, helper) {
        helper.handleEvent(component, event);
        event.stopPropagation();
    },

    handleApplicationEvent: function(component, event, helper) {
        helper.handleEvent(component, event);
    },
})