({
    showToast: function(component, event, helper) {
        let params = event.getParam("arguments");
        helper.showToast(component, params.title, params.message, params.type);
    },

    handleError: function(component, event, helper) {
        let params = event.getParam("arguments");
        let errors = params.errors;
        let message;

        if(errors && Array.isArray(errors) && errors.length > 0) {
            message = errors[0].message;
        } else {
            message = "Unknown error";
        }

        helper.showToast(component, $A.get("$Label.c.BL_Error"), message, "ERROR");
    }
});