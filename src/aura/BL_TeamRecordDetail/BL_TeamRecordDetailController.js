({
    doInit : function(component, event, helper) {
        helper.getCurrentContactId(component, event, helper);
        helper.getPicture(component, event, helper);
    },
    onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
        helper.handleOnDrop(component, event, helper);
	},

	uploadProfilePicture: function(component, event, helper) {
	    helper.upload(component, event, helper);
	    helper.onCloseModal(component, event, helper);
    },

    closeModal: function(component, event, helper){
   	    helper.onCloseModal(component, event, helper);
        helper.getPicture(component, event, helper);
    },
    handleRecordUpdated: function(component, event, helper) {
        component.set("v.showSpinnerInit", false);
    }
})