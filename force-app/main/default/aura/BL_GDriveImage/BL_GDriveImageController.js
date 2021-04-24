({
    doInit : function(component, event, helper) {

    },

    onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        if (files.length>1) {
            return alert("You can only upload one profile picture");
        }
        helper.readFile(component, helper, files[0]);
    },

    recordLoaded: function(component, event, helper) {
        if (!event.getParam("oldValue") && event.getParam("value")) {
            helper.loadExistingImage(component, event);
        }

    },

    imageLoaded: function(component, event, helper) {
        let spinner = component.find("spinner");
        $A.util.addClass(spinner, 'slds-hide');
    }
})