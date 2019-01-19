({
    onFeedItemClick: function(component, event, helper) {
        let feedItem = component.get("v.feedItem");

        if(feedItem.eventType === "match") {
            let scoreModal = component.find("scoreModal");
            component.set("v.modalVisible", false);
            component.set("v.modalVisible", true);
            scoreModal.show();
        }
    }
});