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
    getTeamRelatedRecords : function(component, event, helper) {
        component.set('v.showSpinnerInit', true);
        let action = component.get('c.getRelated');
        action.setParams({
            'teamId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                component.set('v.related', response.getReturnValue());
                let appEvent = $A.get('e.c:BL_TeamRelatedLoaded');
                appEvent.setParams({
                    "related": response.getReturnValue()
                });
                appEvent.fire();
            } else if(state === 'ERROR') {
                helper.handleError(component, response, helper);
            }
            component.set('v.showSpinnerInit', false);
        });
        $A.enqueueAction(action);
    },

    getPicture : function(component) {
        let action = component.get("c.getProfilePicture");
        action.setParams({
            parentId: component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            let attachment = response.getReturnValue();
            if (attachment && attachment.Id) {
                component.set('v.pictureSrc', '/servlet/servlet.FileDownload?file='
                                                  + attachment.Id);
            }
        });
        $A.enqueueAction(action);
    },
    readFile: function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
  			return alert('Image file not supported');
		}
        let reader = new FileReader();
        reader.onloadend = function() {
            let dataURL = reader.result;
            component.set("v.pictureSrc", dataURL);
            component.set('v.attachmentContentType', file.type);
            component.set('v.attachmentName', file.name);
            component.set('v.attachmentBody', dataURL.match(/,(.*)$/)[1]);
            helper.onOpenModal(component, event, helper);
        };
        reader.readAsDataURL(file);
	},

    upload: function(component, event, helper) {
        component.set('v.showSpinner', true);
        let action = component.get("c.savePicture");
        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: component.get('v.attachmentName'),
            base64Data: component.get('v.attachmentBody'),
            contentType: component.get('v.attachmentContentType')
        });
        component.set("v.message", "Uploading...");
        action.setCallback(this, function(response) {
            console.log('IN CALLBACK');
            let state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT'){
                component.set("v.message", "Image uploaded");
                component.set("v.showSpinner", false);
                let successToast = $A.get("e.force:showToast");
                successToast.setParams({
                    "message": 'Image uploaded',
                    "type": 'success'
                });
                successToast.fire();
            } else if (state === 'ERROR') {
                alert('error');
            }
        });
        $A.enqueueAction(action);
    },
    getCurrentContactId : function(component, event, helper) {
        console.log('get user');
        let action = component.get("c.getUserContactId");
        action.setCallback(this, function(response) {
            component.set('v.contactId', response.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    handleOnDrop : function(component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        let files = event.dataTransfer.files;
        if (files.length>1) {
            return alert("You can only upload one profile picture");
        }
        helper.readFile(component, helper, files[0]);
    },

        onOpenModal : function(component, event, helper) {
            document.getElementById('backdropOfConfirmTeamsProfilePicture').classList.add("slds-backdrop_open");
            document.getElementById('modalOfConfirmTeamsProfilePicture').classList.add("slds-slide-down-cancel");
        },

        onCloseModal : function(component, event, helper) {
            document.getElementById('backdropOfConfirmTeamsProfilePicture').classList.remove("slds-backdrop_open");
            document.getElementById('modalOfConfirmTeamsProfilePicture').classList.remove("slds-slide-down-cancel");
        },
})