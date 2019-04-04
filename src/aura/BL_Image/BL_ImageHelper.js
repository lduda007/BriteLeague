({
    doInit: function(component) {
        component.set("v.showSpinner", false);
    },

    handleOnDrop: function(component, event) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        let files = event.dataTransfer.files;
        if(files.length > 1) {
            return alert("You can only upload one profile picture");
        }
        this.save(component, files[0]);
    }
});