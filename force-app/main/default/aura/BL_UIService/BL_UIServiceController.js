({
    /** Checks if current context is community builder */
    checkIsBuilderContext: function(component, event, helper) {
        let urlToCheck = window.location.hostname.toLowerCase();
        return urlToCheck.indexOf('sitepreview') >= 0 || urlToCheck.indexOf('livepreview') >= 0;
    },

    /** Checks if current device is mobile */
    checkMobileBrowser: function(component, event, helper) {
        return $A.get('$Browser.formFactor') !== 'DESKTOP';
    },

    showSpinner: function(component, event, helper) {
        component.getEvent('overlayCmpEvent').setParams({
            spinnerActive: true
        }).fire();
    },

    hideSpinner: function(component, event, helper) {
        component.getEvent('overlayCmpEvent').setParams({
            spinnerActive: false
        }).fire();
    },

    showGlobalSpinner: function(component, event, helper) {
        component.set("v.spinnerVisible", true);
    },

    hideGlobalSpinner: function(component, event, helper) {
        component.set("v.spinnerVisible", false);
    }
})