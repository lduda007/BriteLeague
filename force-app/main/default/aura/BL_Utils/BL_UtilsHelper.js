({
    showToast: function(component, title, message, type) {
        let toastEvent = $A.get("e.force:showToast");

        if(toastEvent) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type
            });
            toastEvent.fire();
        } else {
            console.error("Toasts are not available!");
        }
    }
});