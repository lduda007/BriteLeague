({
    getTeamLogo: function(component) {
        let team = component.get("v.teamObject");

        let action = component.get("c.getProfilePicture");
        action.setParams({
            parentId: team.Id,
        });
        action.setCallback(this, function(response) {
            let attachment = response.getReturnValue();
            if(attachment && attachment.Id) {
                component.set("v.teamLogo", "/servlet/servlet.FileDownload?file=" + attachment.Id);
            } else {
                component.set("v.teamLogo", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdyq2y3f1IKjJEkyq7Dcx0oSQszq9VVm3lsiRbAR7BRCN0NCNG");
            }
        });
        $A.enqueueAction(action);
    }
});