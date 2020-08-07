({
    onInit: function(component, event, helper) {
        helper.doInit(component);
    },

    onCompetitionRecordTypeChange: function(component, event, helper) {
        helper.clearForm(component);
    },

    onSave: function(component, event, helper) {
        if(helper.validateForm(component)) {
            helper.doSave(component);
        } else {
            helper.showToast('ERROR', 'Form is not valid!');
        }
    }
});