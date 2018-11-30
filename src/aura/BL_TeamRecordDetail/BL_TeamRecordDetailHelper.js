({
    handleError : function(component, response, helper) {
        console.log(response.getError()[0].message);
        let errorData = JSON.parse(response.getError()[0].message);
        console.log(errorData.name +" (code "+ errorData.code +"): "+ errorData.message);
        this.showToast(component, 'error', errorData.name + " (code " + errorData.code + "): " + errorData.message);

    },

    getPicture : function(component) {
        let action = component.get("c.getProfilePicture");
        action.setParams({
            parentId: component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            let attachment = response.getReturnValue();
            if (attachment && attachment.Id) {
                component.set('v.pictureSrc', '/servlet/servlet.FileDownload?file=' + attachment.Id);
            }
        });
        $A.enqueueAction(action);
    },

    save: function(component, file) {
        if(!file) {
            return;
        } else if(!file.type.match(/(image.*)/)) {
            this.showToast(component, 'error', 'This file type is not supported');
            return;
        } else if(file.size > 4500000) {
            this.showToast(component, 'error', 'File size cannot exceed 4.5 MB.\n' + 'Selected file size: ' + (file.size / (1024*1024)).toPrecision(2) + ' MB');
            return;
        } else {
            let reader = new FileReader();
            let helper = this;

            reader.onloadend = function() {
                let fileContents = reader.result;
                let base64Mark = 'base64,';
                let dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                fileContents = fileContents.substring(dataStart);

                component.set("v.pictureSrc", fileContents);
                component.set('v.attachmentContentType', file.type);
                component.set('v.attachmentName', file.name);
                component.set('v.attachmentBody', fileContents);

                let fromPos = 0;
                let toPos = Math.min(fileContents.length, fromPos + 500000);
                helper.uploadChunk(component, file, fromPos, toPos, '');
            };

            reader.readAsDataURL(file);
        }
    },

    uploadChunk: function(component, file, fromPos, toPos, attachId) {
        component.set("v.showSpinner", true);
        let fileContents = component.get("v.attachmentBody");
        let chunk = fileContents.substring(fromPos, toPos);
        let self = this;
        let action = component.get("c.saveTheChunk");
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk),
            contentType: file.type,
            fileId: attachId
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                attachId = response.getReturnValue();
                fromPos = toPos;
                fromPos = toPos;
                toPos = Math.min(fileContents.length, fromPos + 500000);
                if(fromPos < toPos) {
                    self.uploadChunk(component, file, fromPos, toPos, attachId);
                } else {
                    component.set("v.message", "Image uploaded");
                    component.set("v.showSpinner", false);
                    $A.get("e.force:showToast").setParams({
                        "message": 'Image uploaded',
                        "type": 'success'
                    }).fire();
                    self.getPicture(component);
                }
            } else if(state === 'ERROR') {
                let errors = response.getError();
                let errorMessage = '';
                for(let i = 0; i < errors.length; i++) {
                    errorMessage += errors[i].message + ' ';
                }
                $A.get("e.force:showToast").setParams({
                    "message": errorMessage,
                    "type": 'error'
                }).fire();
            }
        });
        $A.enqueueAction(action);
        component.find('uploadDiv').click();
    },

    getCurrentContactId : function(component) {
        let action = component.get("c.getUserContactId");
        action.setCallback(this, function(response) {
            component.set('v.contactId', response.getReturnValue());
        });
        $A.enqueueAction(action);
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
    }
});