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

            BL_Competition__c competition = new BL_DAO_Competition().getCompetitionById(competitionId);

            initDataWrapper.addFeedItem(
                    new FeedItemWrapperBuilder()
                            .setAsCompetitionCreated(competition.CreatedDate, competition.CreatedBy.Name)
                            .build()
            );

            for(BL_Competitor__c competitor : new BL_DAO_Competitor().getCompetitorsByCompetitionId(competitionId)) {
                initDataWrapper.addFeedItem(
                        new FeedItemWrapperBuilder()
                                .setAsTeamJoined(competitor.Team__r.Name, competitor.CreatedDate)
                                .build()
                );
            }

            if(BL_Constants.LEAGUE_STARTED_STATUSES.contains(competition.Status__c)) {
                initDataWrapper.addFeedItem(
                        new FeedItemWrapperBuilder()
                                .setAsCompetitionStarted(competition.Start_Date__c)
                                .build()
                );

                for(BL_Match__c match : new BL_DAO_Match().getResolvedMatchesForCompetition(competitionId)) {
                    initDataWrapper.addFeedItem(
                            new FeedItemWrapperBuilder()
                                    .setAsMatch(match)
                                    .build()
                    );
                }
            }

            if(competition.Status__c == BL_Constants.LEAGUE_STATUS_FINISHED) {
                initDataWrapper.addFeedItem(
                        new FeedItemWrapperBuilder()
                                .setAsCompetitionFinished(competition.Date_League_Finished__c)
                                .build()
                );
            }

            initDataWrapper.sortFeedItems();
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization of BL_CompetitionFeed component';
            BL_Utils.throwAuraHandledException(uiMessage, e);
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

        public FeedItemWrapperBuilder setAsCompetitionCreated(Datetime createdDatetime, String createdBy) {
            record.eventType = EVENT_TYPE_LEAGUE_CREATED;
            record.iconName = 'custom:custom44';
            record.dt = createdDatetime;
            record.message = String.format(Label.BL_League_Created_Statement, new List<String>{
                    makeTextBold(createdBy)
            });

            return this;
        }

        public FeedItemWrapperBuilder setAsCompetitionStarted(Datetime startDatetime) {
            record.eventType = EVENT_TYPE_LEAGUE_STARTED;
            record.iconName = 'custom:custom20';
            record.dt = startDatetime;
            record.message = Label.BL_League_Started_Statement;

            return this;
        }

        public FeedItemWrapperBuilder setAsCompetitionFinished(Datetime endDatetime) {
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
                    statement = matchStatementsManager.getHardWinStatement(match.LastModifiedDate.second());
                } else {
                    statement = matchStatementsManager.getSoftWinStatement(match.LastModifiedDate.second());
                }
            } else if(match.Team1_Score__c < match.Team2_Score__c) {
                if(match.Team2TotalGoalsScored__c - match.Team1TotalGoalsScored__c > 10) {
                    statement = matchStatementsManager.getHardLossStatement(match.LastModifiedDate.second());
                } else {
                    statement = matchStatementsManager.getSoftLossStatement(match.LastModifiedDate.second());
                }
            } else {
                statement = matchStatementsManager.getDrawStatement(match.LastModifiedDate.second());
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

        private List<String> hardWinStatements;
        private List<String> softWinStatements;
        private List<String> hardLossStatements;
        private List<String> softLossStatements;
        private List<String> drawStatements;

        private List<String> hardWinRecentlyUsed = new List<String>();
        private List<String> softWinRecentlyUsed = new List<String>();
        private List<String> hardLossRecentlyUsed = new List<String>();
        private List<String> softLossRecentlyUsed = new List<String>();
        private List<String> drawRecentlyUsed = new List<String>();

        public MatchStatementsManager() {
            hardWinStatements = Label.BL_Hard_Win_Statements.split(';');
            softWinStatements = Label.BL_Soft_Win_Statements.split(';');
            hardLossStatements = Label.BL_Hard_Loss_Statements.split(';');
            softLossStatements = Label.BL_Soft_Loss_Statements.split(';');
            drawStatements = Label.BL_Draw_Statements.split(';');
        }

        public String getHardWinStatement(Integer seed) {
            return getRandomStatement(hardWinStatements, seed, hardWinRecentlyUsed);
        }

        public String getSoftWinStatement(Integer seed) {
            return getRandomStatement(softWinStatements, seed, softWinRecentlyUsed);
        }

        public String getHardLossStatement(Integer seed) {
            return getRandomStatement(hardLossStatements, seed, hardLossRecentlyUsed);
        }

        public String getSoftLossStatement(Integer seed) {
            return getRandomStatement(softLossStatements, seed, softLossRecentlyUsed);
        }

        public String getDrawStatement(Integer seed) {
            return getRandomStatement(drawStatements, seed, drawRecentlyUsed);
        }

        private String getRandomStatement(List<String> statements, Integer seed, List<String> recentlyUsed) {
            List<String> statementsToUse = statements.clone();
            Integer i = 0;
            while (i < statementsToUse.size()){
                if (recentlyUsed.contains(statementsToUse[i])) {
                    statementsToUse.remove(i);
                } else {
                    i++;
                }
            }
            Integer chosenStatementIndex = Math.mod(seed, statementsToUse.size());

            if (recentlyUsed.size() >= 3) {
                recentlyUsed.remove(0);
            }
            recentlyUsed.add(statementsToUse[chosenStatementIndex]);
            return statementsToUse[chosenStatementIndex];
        }
    }
}