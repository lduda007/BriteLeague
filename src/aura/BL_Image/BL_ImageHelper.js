({
    doInit: function(component) {
        let action = component.get('c.getImageLink');
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: component.get("v.fileName")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            let errors = response.getError();

            if(state === "SUCCESS") {
                component.set("v.fileSrc", result);
            } else {
                this.handleApexError(component, errors);
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    handleDrop: function(component, event) {
        component.set("v.showSpinner", true);
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        let files = event.dataTransfer.files;
        if(files.length > 1) {
            return alert("You can only upload one profile picture");
        }
        this.saveImage(component, files[0]);
    },

    saveImage: function(component, file) {
        if(!file) {
            component.set("v.showSpinner", false);
            return;
        } else if(!file.type.match(/(image.*)/)) {
            component.set("v.showSpinner", false);
            this.showToast(component, "error", "This file type is not supported");
            return;
        } else if(file.size > 4500000) {
            component.set("v.showSpinner", false);
            this.showToast(component, "error", "File size cannot exceed 4.5 MB.\n' Selected file size: " + (file.size / (1024 * 1024)).toPrecision(2) + " MB");
            return;
        } else {
            let reader = new FileReader();
            let helper = this;

            reader.onloadend = function() {
                let fileContents = reader.result;
                let base64Mark = "base64,";
                let dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                fileContents = fileContents.substring(dataStart);

                component.set("v.fileContentType", file.type);
                component.set("v.fileBody", fileContents);

                let fromPos = 0;
                let toPos = Math.min(fileContents.length, fromPos + 500000);
                helper.uploadChunk(component, file, fromPos, toPos, '');
            };

            reader.readAsDataURL(file);
        }
    },

    uploadChunk: function(component, file, fromPos, toPos, fileId) {
        let fileContents = component.get("v.fileBody");
        let chunk = fileContents.substring(fromPos, toPos);
        let helper = this;

        let action = component.get("c.saveTheChunk");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: component.get("v.fileName"),
            base64Data: encodeURIComponent(chunk),
            contentType: file.type,
            fileId: fileId
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            let errors = response.getError();

            if(state === "SUCCESS" || state === "DRAFT") {
                fileId = result;
                fromPos = toPos;
                fromPos = toPos;
                toPos = Math.min(fileContents.length, fromPos + 500000);

                if(fromPos < toPos) {
                    helper.uploadChunk(component, file, fromPos, toPos, fileId);
                } else {
                    helper.showToast(component, "success", "Image uploaded");
                    helper.doInit(component);
                }
            } else if(state === "ERROR") {
                helper.handleApexError(component, errors);
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
        component.find("uploadDiv").click();
    },

    showToast: function(component, type, message) {
        let toast = $A.get("e.force:showToast");
        if(toast) {
            toast.setParams({
                "message": message,
                "type": type
            }).fire();
        } else {
            alert(message);
        }
    },

    handleApexError: function(component, errors) {
        let errorMessage = '';
        for(let i = 0; i < errors.length; i++) {
            errorMessage += errors[i].message + ' ';
        }
        this.showToast(component, 'error', errorMessage);
    }
});