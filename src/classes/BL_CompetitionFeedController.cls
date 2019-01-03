public class BL_CompetitionFeedController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper(Id competitionId) {
        InitDataWrapper initDataWrapper;
        try {
            initDataWrapper = new InitDataWrapper();

            FeedItemWrapper feedItemWrapper = new FeedItemWrapper();
            feedItemWrapper.iconName = 'custom:custom95';
            initDataWrapper.feedItems.add(feedItemWrapper);

        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization of BL_CompetitionFeed component: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }
        return initDataWrapper;
    }

    public class InitDataWrapper {
        @AuraEnabled
        public List<FeedItemWrapper> feedItems = new List<FeedItemWrapper>();
    }

    public class FeedItemWrapper {
        @AuraEnabled
        public String iconName;
    }
}