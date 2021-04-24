({
    readFile: function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
            return alert('Image file not supported');
        }
        if (file.size > 3000000) {
            return alert('Image cannot exceed 3MB');
        }
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            component.set("v.pictureSrc", dataURL);
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
    },

    upload: function(component, file, data) {
        let uploadAction = component.get("c.uploadImage");
        uploadAction.setParams({
                imageData : data,
                fileType: file.type,
                recordId: component.get("v.recordId")
        });
        uploadAction.setCallback(this, (response) => {
            let state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.GDriveImageSrc', response.getReturnValue());
                this.showToast('success', 'Image Uploaded');
                console.log(response.getReturnValue());

            } else {
                console.error(response.getError()[0]);
            }
        });
        this.showToast('info', 'Uploading Image...');
        $A.enqueueAction(uploadAction);
    },

    loadExistingImage: function(component, event) {
        let imageId = component.get("v.record").Logo_Id__c;
        if (imageId) {
            let imageURL = "https://drive.google.com/uc?id=" + imageId + "&export=download";
            component.set("v.pictureSrc", imageURL);
            let spinner = component.find("spinner");
            $A.util.removeClass(spinner, 'slds-hide');
        }
    },

    showToast: function(type, message) {
        $A.get("e.force:showToast").setParams({
            "type": type,
            "message": message
        }).fire();
    }
})