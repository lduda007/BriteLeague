({
    doInit : function(component, event, helper) {
        helper.getCurrentContactId(component);
        helper.getPicture(component);
    },

    onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
        helper.handleOnDrop(component, event);
    },

    handleRecordUpdated: function(component, event, helper) {
        component.set("v.showSpinnerInit", false);
    }
});