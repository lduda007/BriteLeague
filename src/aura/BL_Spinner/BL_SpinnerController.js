({

    showSpinner: function(component, event, helper) {
        component.set('v.show', true);
    },

    hideSpinner: function(component, event, helper) {
        component.set('v.show', false);
    }

})