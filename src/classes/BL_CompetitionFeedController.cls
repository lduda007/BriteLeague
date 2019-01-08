public class BL_CompetitionFeedController {

    public final static String FEED_ITEM_TYPE_EVENT = 'event';

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper(Id competitionId) {
        InitDataWrapper initDataWrapper;
        try {
            initDataWrapper = new InitDataWrapper();

            BL_League__c league = [
                    SELECT Id, CreatedDate, TeamSize__c, Teams_Joined__c, Status__c, Start_Date__c, End_Date__c
                    FROM BL_League__c
                    WHERE Id = :competitionId
                    LIMIT 1
            ];
            initDataWrapper.addFeedItem(
                    FEED_ITEM_TYPE_EVENT,
                    'League created',
                    'custom:custom44',
                    league.CreatedDate
            );

            if(BL_Constants.LEAGUE_STARTED_STATUSES.contains(league.Status__c)) {
                initDataWrapper.addFeedItem(
                        FEED_ITEM_TYPE_EVENT,
                        'League started',
                        'custom:custom20',
                        league.Start_Date__c
                );

                for(BL_Competitor__c competitor : [
                        SELECT Id, Team__r.Name, CreatedDate
                        FROM BL_Competitor__c
                        WHERE League__c = :competitionId
                        ORDER BY Team__r.Name ASC
                ]) {
                    initDataWrapper.addFeedItem(
                            FEED_ITEM_TYPE_EVENT,
                            competitor.Team__r.Name + ' joined',
                            'custom:custom83',
                            competitor.CreatedDate
                    );
                }

                for(BL_Match__c match : [
                        SELECT Id, Team1__c, Team2__c, Team1_Score__c, Team2_Score__c, Winner__c, Team1__r.Team__r.Name,
                                Team2__r.Team__r.Name, MatchDate__c
                        FROM BL_Match__c
                        WHERE League__c = :competitionId
                        AND isResolved__c = true
                        ORDER BY MatchDate__c ASC, LastModifiedDate ASC
                ]) {
                    initDataWrapper.addFeedItem(
                            FEED_ITEM_TYPE_EVENT,
                            match.Team1__r.Team__r.Name + ' vs ' + match.Team2__r.Team__r.Name + ' (' + match.Team1_Score__c + ':' + match.Team2_Score__c + ')',
                            'custom:custom82',
                            match.MatchDate__c
                    );
                }
            }

            if(league.Status__c == BL_Constants.LEAGUE_STATUS_FINISHED) {
                initDataWrapper.addFeedItem(
                        FEED_ITEM_TYPE_EVENT,
                        'League finished',
                        'custom:custom95',
                        league.End_Date__c
                );
            }

            initDataWrapper.sortFeedItems();
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization of BL_CompetitionFeed component: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }

        return initDataWrapper;
    }

    public class InitDataWrapper {
        @AuraEnabled
        public List<FeedItemWrapper> feedItems = new List<FeedItemWrapper>();

        public void addFeedItem(String type, String message, String iconName, Datetime dt) {
            FeedItemWrapper feedItemWrapper = new FeedItemWrapper();
            feedItemWrapper.type = type;
            feedItemWrapper.message = message;
            feedItemWrapper.iconName = iconName;
            feedItemWrapper.dt = dt;
            feedItems.add(feedItemWrapper);
        }

        public void sortFeedItems() {
            feedItems.sort();
        }
    }

    public class FeedItemWrapper implements Comparable {
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String iconName;
        @AuraEnabled
        public Datetime dt;

        public Integer compareTo(Object compareTo) {
            Long thisMillis = dt.getTime();
            Long compareToMillis = ((FeedItemWrapper)compareTo).dt.getTime();

            if(thisMillis == compareToMillis) {
                return 0;
            } else if(thisMillis < compareToMillis) {
                return 1;
            } else {
                return -1;
            }
        }
    }
}