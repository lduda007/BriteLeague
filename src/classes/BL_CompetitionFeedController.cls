public class BL_CompetitionFeedController {

    public static MatchStatementsManager matchStatementsManager = new MatchStatementsManager();

    private static final String EVENT_TYPE_LEAGUE_CREATED = 'league_created';
    private static final String EVENT_TYPE_LEAGUE_STARTED = 'league_started';
    private static final String EVENT_TYPE_LEAGUE_FINISHED = 'league_finished';
    private static final String EVENT_TYPE_TEAM_JOINED = 'team_joined';
    private static final String EVENT_TYPE_MATCH = 'match';

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper(Id competitionId) {
        InitDataWrapper initDataWrapper;

        try {
            initDataWrapper = new InitDataWrapper();

            BL_League__c league = [
                    SELECT Id, CreatedDate, CreatedBy.Name, Status__c, Start_Date__c, End_Date__c
                    FROM BL_League__c
                    WHERE Id = :competitionId
                    LIMIT 1
            ];

            initDataWrapper.addFeedItem(
                    new FeedItemWrapperBuilder()
                            .setAsLeagueCreated(league.CreatedDate, league.CreatedBy.Name)
                            .build()
            );

            if(BL_Constants.LEAGUE_STARTED_STATUSES.contains(league.Status__c)) {
                initDataWrapper.addFeedItem(
                        new FeedItemWrapperBuilder()
                                .setAsLeagueStarted(league.Start_Date__c)
                                .build()
                );

                for(BL_Competitor__c competitor : [
                        SELECT Id, Team__r.Name, CreatedDate
                        FROM BL_Competitor__c
                        WHERE League__c = :competitionId
                        ORDER BY Team__r.Name ASC
                ]) {
                    initDataWrapper.addFeedItem(
                            new FeedItemWrapperBuilder()
                                    .setAsTeamJoined(competitor.Team__r.Name, competitor.CreatedDate)
                                    .build()
                    );
                }

                for(BL_Match__c match : [
                        SELECT Id, Team1_Score__c, Team2_Score__c, Team1TotalGoalsScored__c, Team2TotalGoalsScored__c,
                                Team1__r.Team__r.Name, Team2__r.Team__r.Name, MatchDate__c
                        FROM BL_Match__c
                        WHERE League__c = :competitionId
                        AND isResolved__c = true
                        ORDER BY MatchDate__c ASC, LastModifiedDate ASC
                ]) {
                    initDataWrapper.addFeedItem(
                            new FeedItemWrapperBuilder()
                                    .setAsMatch(match)
                                    .build()
                    );
                }
            }

            if(league.Status__c == BL_Constants.LEAGUE_STATUS_FINISHED) {
                initDataWrapper.addFeedItem(
                        new FeedItemWrapperBuilder()
                                .setAsLeagueFinished(league.End_Date__c)
                                .build()
                );
            }

            initDataWrapper.sortFeedItems();
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization of BL_CompetitionFeed component: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage + ' ' + e.getStackTraceString());
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
        public String iconName;
        @AuraEnabled
        public Datetime dt;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean isToday {
            get {
                return dt.isSameDay(System.now());
            }
        }
        @AuraEnabled
        public String eventType;
        @AuraEnabled
        public Id eventRecordId;

        public Integer compareTo(Object compareTo) {
            Long thisMillis = dt.getTime();
            Long compareToMillis = ((FeedItemWrapper) compareTo).dt.getTime();

            if(thisMillis == compareToMillis) {
                return 0;
            } else if(thisMillis < compareToMillis) {
                return 1;
            } else {
                return -1;
            }
        }
    }

    public class FeedItemWrapperBuilder {

        private FeedItemWrapper record;

        public FeedItemWrapperBuilder() {
            record = new FeedItemWrapper();
        }

        public FeedItemWrapperBuilder setAsLeagueCreated(Datetime createdDatetime, String createdBy) {
            record.eventType = EVENT_TYPE_LEAGUE_CREATED;
            record.iconName = 'custom:custom44';
            record.dt = createdDatetime;
            record.message = String.format(Label.BL_League_Created_Statement, new List<String>{
                    makeTextBold(createdBy)
            });

            return this;
        }

        public FeedItemWrapperBuilder setAsLeagueStarted(Datetime startDatetime) {
            record.eventType = EVENT_TYPE_LEAGUE_STARTED;
            record.iconName = 'custom:custom20';
            record.dt = startDatetime;
            record.message = Label.BL_League_Started_Statement;

            return this;
        }

        public FeedItemWrapperBuilder setAsLeagueFinished(Datetime endDatetime) {
            record.eventType = EVENT_TYPE_LEAGUE_FINISHED;
            record.iconName = 'custom:custom95';
            record.dt = endDatetime;
            record.message = Label.BL_League_Finished_Statement;

            return this;
        }

        public FeedItemWrapperBuilder setAsTeamJoined(String teamName, Datetime joinDatetime) {
            record.eventType = EVENT_TYPE_TEAM_JOINED;
            record.iconName = 'custom:custom83';
            record.dt = joinDatetime;
            record.message = String.format(Label.BL_Team_Joined_Statement, new List<String>{
                    makeTextBold(teamName)
            });

            return this;
        }

        public FeedItemWrapperBuilder setAsMatch(BL_Match__c match) {
            record.eventType = EVENT_TYPE_MATCH;
            record.iconName = 'custom:custom82';
            record.dt = match.MatchDate__c;
            record.eventRecordId = match.Id;

            String statement;

            if(match.Team1_Score__c > match.Team2_Score__c) {
                if(match.Team1TotalGoalsScored__c - match.Team2TotalGoalsScored__c > 10) {
                    statement = matchStatementsManager.getHardWinStatement();
                } else {
                    statement = matchStatementsManager.getSoftWinStatement();
                }
            } else if(match.Team1_Score__c < match.Team2_Score__c) {
                if(match.Team2TotalGoalsScored__c - match.Team1TotalGoalsScored__c > 10) {
                    statement = matchStatementsManager.getHardLossStatement();
                } else {
                    statement = matchStatementsManager.getSoftLossStatement();
                }
            } else {
                statement = matchStatementsManager.getDrawStatement();
            }

            record.message = String.format(statement, new List<String>{
                    makeTextBold(match.Team1__r.Team__r.Name),
                    makeTextBold(match.Team2__r.Team__r.Name)
            }) + ' ' + '(' + match.Team1_Score__c + ':' + match.Team2_Score__c + ')';

            return this;
        }

        public FeedItemWrapper build() {
            return record;
        }

        private String makeTextBold(String text) {
            return '<b>' + text + '</b>';
        }
    }

    public class MatchStatementsManager {

        private Map<String, Integer> hardWinStatementsToUsage;
        private Map<String, Integer> softWinStatementsToUsage;
        private Map<String, Integer> hardLossStatementsToUsage;
        private Map<String, Integer> softLossStatementsToUsage;
        private Map<String, Integer> drawStatementsToUsage;

        public MatchStatementsManager() {
            populateHardWinStatementsToUsage();
            populateSoftWinStatementsToUsage();
            populateHardLossStatementsToUsage();
            populateSoftLossStatementsToUsage();
            populateDrawStatementsToUsage();
        }

        public String getHardWinStatement() {
            String statement = getRandomStatementWithLowestUsage(hardWinStatementsToUsage);

            incrementStatementUsage(hardWinStatementsToUsage, statement);

            return statement;
        }

        public String getSoftWinStatement() {
            String statement = getRandomStatementWithLowestUsage(softWinStatementsToUsage);

            incrementStatementUsage(softWinStatementsToUsage, statement);

            return statement;
        }

        public String getHardLossStatement() {
            String statement = getRandomStatementWithLowestUsage(hardLossStatementsToUsage);

            incrementStatementUsage(hardLossStatementsToUsage, statement);

            return statement;
        }

        public String getSoftLossStatement() {
            String statement = getRandomStatementWithLowestUsage(softLossStatementsToUsage);

            incrementStatementUsage(softLossStatementsToUsage, statement);

            return statement;
        }

        public String getDrawStatement() {
            String statement = getRandomStatementWithLowestUsage(drawStatementsToUsage);

            incrementStatementUsage(drawStatementsToUsage, statement);

            return statement;
        }

        private String getRandomStatementWithLowestUsage(Map<String, Integer> usageMap) {
            List<String> statementsWithLowestUsage = new List<String>();
            Integer lowestUsage = usageMap.values()[0];

            for(String statement : usageMap.keySet()) {
                Integer usage = usageMap.get(statement);


                if(usage < lowestUsage) {
                    statementsWithLowestUsage = new List<String>{
                            statement
                    };
                    lowestUsage = usage;
                } else if(usage == lowestUsage) {
                    statementsWithLowestUsage.add(statement);
                }
            }

            Integer randomIndex = Integer.valueOf(Math.floor(Math.random() * statementsWithLowestUsage.size()));

            return statementsWithLowestUsage[randomIndex];
        }

        private void incrementStatementUsage(Map<String, Integer> usageMap, String statement) {
            Integer usage = usageMap.get(statement);
            usage++;
            usageMap.put(statement, usage);
        }

        private void populateHardWinStatementsToUsage() {
            hardWinStatementsToUsage = getNewUsageMapForStatements(Label.BL_Hard_Win_Statements.split(';'));
        }

        private void populateSoftWinStatementsToUsage() {
            softWinStatementsToUsage = getNewUsageMapForStatements(Label.BL_Soft_Win_Statements.split(';'));
        }

        private void populateHardLossStatementsToUsage() {
            hardLossStatementsToUsage = getNewUsageMapForStatements(Label.BL_Hard_Loss_Statements.split(';'));
        }

        private void populateSoftLossStatementsToUsage() {
            softLossStatementsToUsage = getNewUsageMapForStatements(Label.BL_Soft_Loss_Statements.split(';'));
        }

        private void populateDrawStatementsToUsage() {
            drawStatementsToUsage = getNewUsageMapForStatements(Label.BL_Draw_Statements.split(';'));
        }

        private Map<String, Integer> getNewUsageMapForStatements(List<String> statements) {
            Map<String, Integer> usageMap = new Map<String, Integer>();

            for(String s : statements) {
                usageMap.put(s, 0);
            }

            return usageMap;
        }
    }
}