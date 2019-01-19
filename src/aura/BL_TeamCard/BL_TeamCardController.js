({
    onInit : function(component, event, helper) {
        let team = component.get("v.teamObject");
        let teamLogo = component.get("v.teamLogo");
        if(team && !teamLogo) {
            helper.getTeamLogo(component);
        }
    }
});