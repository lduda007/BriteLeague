({
    handleError : function(component, response, helper) {
        console.log(response.getError()[0].message);
        let errorData = JSON.parse(response.getError()[0].message);
        console.log(errorData.name +" (code "+ errorData.code +"): "+ errorData.message);
        let errToast = $A.get("e.force:showToast");
        errToast.setParams({
            "message": errorData.name +" (code "+ errorData.code +"): "+ errorData.message,
            "type": 'error'
        });
        errToast.fire();
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

        let reader = new FileReader();

        let helper = this;
        reader.onload = function() {
            let fileContents = reader.result;
            let base64Mark = 'base64,';
            let dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);

            helper.upload(component, file, fileContents);
        };

        reader.readAsDataURL(file);
    },

    upload: function(component, file, fileContents) {
        if(!file) return;
        if(!file.type.match(/(image.*)/)) {
            return alert('Image file not supported');
        }

        if(file.size > 4500000) {
            alert('File size cannot exceed 4 500 000 bytes.\n' +
                'Selected file size: ' + file.size);
            return;
        }
        let reader = new FileReader();

        let helper = this;
        reader.onload = function() {
            let fileContents = reader.result;
            let base64Mark = 'base64,';
            let dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);

            helper.upload(component, file, fileContents);
        };

        let fromPos = 0;
        let toPos = Math.min(fileContents.length, fromPos + 750000);
        this.uploadChunk(component, file, fileContents, fromPos, toPos, '');
    },

    uploadChunk: function(component, file, fileContents, fromPos, toPos, attachId) {
        component.set("v.showSpinner", true);
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
                fromPos = toPos;fromPos = toPos;
                toPos = Math.min(fileContents.length, fromPos + 750000);
                if(fromPos < toPos) {
                    self.uploadChunk(component, file, fileContents, fromPos, toPos, attachId);
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
    }
});