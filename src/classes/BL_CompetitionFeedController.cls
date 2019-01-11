public class BL_CompetitionFeedController {

    public final static String FEED_ITEM_TYPE_EVENT = 'event';
    public final static String FEED_ITEM_TYPE_MATCH = 'match';

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper(Id competitionId) {
        InitDataWrapper initDataWrapper;
        try {
            initDataWrapper = new InitDataWrapper();
            FeedItemWrapper feedItem;

            BL_League__c league = [
                    SELECT Id, CreatedDate, TeamSize__c, Teams_Joined__c, Status__c, Start_Date__c, End_Date__c
                    FROM BL_League__c
                    WHERE Id = :competitionId
                    LIMIT 1
            ];

            feedItem = new FeedItemWrapper();
            feedItem.type = FEED_ITEM_TYPE_EVENT;
            feedItem.message = 'League created';
            feedItem.iconName = 'custom:custom44';
            feedItem.dt = league.CreatedDate;
            initDataWrapper.addFeedItem(feedItem);

            if(BL_Constants.LEAGUE_STARTED_STATUSES.contains(league.Status__c)) {
                feedItem = new FeedItemWrapper();
                feedItem.type = FEED_ITEM_TYPE_EVENT;
                feedItem.message = 'League started';
                feedItem.iconName = 'custom:custom20';
                feedItem.dt = league.Start_Date__c;
                initDataWrapper.addFeedItem(feedItem);

                for(BL_Competitor__c competitor : [
                        SELECT Id, Team__r.Name, CreatedDate
                        FROM BL_Competitor__c
                        WHERE League__c = :competitionId
                        ORDER BY Team__r.Name ASC
                ]) {
                    feedItem = new FeedItemWrapper();
                    feedItem.type = FEED_ITEM_TYPE_EVENT;
                    feedItem.message = competitor.Team__r.Name + ' joined';
                    feedItem.iconName = 'custom:custom83';
                    feedItem.dt = competitor.CreatedDate;
                    initDataWrapper.addFeedItem(feedItem);
                }

                for(BL_Match__c match : [
                        SELECT Id, Team1__c, Team2__c, Team1_Score__c, Team2_Score__c, Winner__c, Team1__r.Team__r.Name,
                                Team2__r.Team__r.Name, MatchDate__c
                        FROM BL_Match__c
                        WHERE League__c = :competitionId
                        AND isResolved__c = true
                        ORDER BY MatchDate__c ASC, LastModifiedDate ASC
                ]) {
                    feedItem = new FeedItemWrapper();
                    feedItem.type = FEED_ITEM_TYPE_MATCH;
                    feedItem.message = '(' + match.Team1_Score__c + ':' + match.Team2_Score__c + ')';
                    feedItem.team1 = match.Team1__r.Team__r.Name;
                    feedItem.team2 = match.Team2__r.Team__r.Name;
                    feedItem.iconName = 'custom:custom82';
                    feedItem.dt = match.MatchDate__c;
                    initDataWrapper.addFeedItem(feedItem);
                }
            }

            if(league.Status__c == BL_Constants.LEAGUE_STATUS_FINISHED) {
                feedItem = new FeedItemWrapper();
                feedItem.type = FEED_ITEM_TYPE_EVENT;
                feedItem.message = 'League finished';
                feedItem.iconName = 'custom:custom95';
                feedItem.dt = league.End_Date__c;
                initDataWrapper.addFeedItem(feedItem);
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

        public void addFeedItem(FeedItemWrapper feedItem) {
            feedItems.add(feedItem);
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
        @AuraEnabled
        public String team1;
        @AuraEnabled
        public String team2;

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