({
    onInit: function(component, event, helper) {
        helper.doInit(component);
    },

    onImageLoad: function(component) {
        component.set("v.showSpinner", false);
    },

    onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
        if(component.get("v.isEditable")) {
            helper.handleDrop(component, event);
        } else {
            event.preventDefault();
        }
    }
});