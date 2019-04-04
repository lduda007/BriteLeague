({
    onInit : function(component, event, helper) {
        helper.doInit(component);
    },

    onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
        helper.handleOnDrop(component, event);
    }
});