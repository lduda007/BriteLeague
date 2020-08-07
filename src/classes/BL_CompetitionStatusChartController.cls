public class BL_CompetitionStatusChartController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper(Id competitionId) {
        InitDataWrapper initDataWrapper;
        try {
            initDataWrapper = new InitDataWrapper();

            BL_Competition__c competition = new BL_DAO_Competition().getCompetitionById(competitionId);

            if(BL_Constants.LEAGUE_STARTED_STATUSES.contains(competition.Status__c)) {
                initDataWrapper.isCompetitionStarted = true;

                initDataWrapper.competitionTimeProgressDataSet = getCompetitionTimeProgressDataSet(competition);
                initDataWrapper.competitionMatchesProgressDataSet = getCompetitionMatchesProgressDataSet(competition.Matches__r);
                initDataWrapper.teamMatchesProgressDataSet = getTeamMatchesProgressDataSet(competition.Matches__r);

                populateStatusFields(initDataWrapper);
            } else {
                initDataWrapper.isCompetitionStarted = false;
            }
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization of "BL_CompetitionStatusChart" component: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, e);
        }
        return initDataWrapper;
    }

    private static BL_ChartJS.DataSet getCompetitionTimeProgressDataSet(BL_Competition__c competition) {
        BL_ChartJS.DataSet dataSet = new BL_ChartJS.DataSet();
        Date today = System.today();
        Date startDate = competition.Start_Date__c.date();
        Date endDate = competition.End_Date__c.date();
        Integer fromStartDays;
        Integer toEndDays;

        if(startDate.daysBetween(endDate) > 0) { // The competition lasts longer than 1 day
            fromStartDays = startDate.daysBetween(today);
            if(fromStartDays < 0) {
                fromStartDays = 0;
            }
            toEndDays = today.daysBetween(endDate);
            if(toEndDays < 0) {
                fromStartDays = startDate.daysBetween(endDate);
                toEndDays = 0;
            }
        } else { // One-day competition
            if(today <= startDate) {
                fromStartDays = 0;
                toEndDays = 1;
            } else {
                fromStartDays = 1;
                toEndDays = 0;
            }
        }

        dataSet.data.add(fromStartDays);
        dataSet.data.add(toEndDays);

        String backgroundColor = BL_ColorHelper.TEAL;
        dataSet.setSecondaryColor(new List<String>{
                backgroundColor, backgroundColor.removeEnd('FF') + '50'
        });

        return dataSet;
    }

    private static BL_ChartJS.DataSet getCompetitionMatchesProgressDataSet(List<BL_Match__c> matches) {
        BL_ChartJS.DataSet dataSet = new BL_ChartJS.DataSet();
        Integer resolvedMatches = 0;
        Integer unsolvedMatches = 0;

        for(BL_Match__c match : matches) {
            if(match.isResolved__c) {
                resolvedMatches++;
            } else {
                unsolvedMatches++;
            }
        }

        dataSet.data.add(resolvedMatches);
        dataSet.data.add(unsolvedMatches);

        String backgroundColor = BL_ColorHelper.BLUE;
        dataSet.setSecondaryColor(new List<String>{
                backgroundColor, backgroundColor.removeEnd('FF') + '50'
        });

        return dataSet;
    }

    private static BL_ChartJS.DataSet getTeamMatchesProgressDataSet(List<BL_Match__c> matches) {
        BL_ChartJS.DataSet dataSet = new BL_ChartJS.DataSet();

        User user = [
                SELECT Id, ContactId
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
        ];

        Integer userTeamResolvedMatches = 0;
        Integer userTeamUnsolvedMatches = 0;

        for(BL_Match__c match : matches) {
            if(isUserPlayerInOneOfTeamsOfMatch(match, user)) {
                if(match.isResolved__c) {
                    userTeamResolvedMatches++;
                } else {
                    userTeamUnsolvedMatches++;
                }
            }
        }

        dataSet.data.add(userTeamResolvedMatches);
        dataSet.data.add(userTeamUnsolvedMatches);

        String backgroundColor = BL_ColorHelper.INDIGO;
        dataSet.setSecondaryColor(new List<String>{
                backgroundColor, backgroundColor.removeEnd('FF') + '50'
        });

        return dataSet;
    }

    private static Boolean isUserPlayerInOneOfTeamsOfMatch(BL_Match__c match, User user) {
        return match.Team1__r.Team__r.Player1__c == user.ContactId
                || match.Team1__r.Team__r.Player2__c == user.ContactId
                || match.Team2__r.Team__r.Player1__c == user.ContactId
                || match.Team2__r.Team__r.Player2__c == user.ContactId;
    }

    private static void populateStatusFields(InitDataWrapper initDataWrapper) {
        initDataWrapper.competitionTimeStatus = getStatusValueForDataSet(initDataWrapper.competitionTimeProgressDataSet);
        initDataWrapper.competitionMatchesStatus = getStatusValueForDataSet(initDataWrapper.competitionMatchesProgressDataSet);
        initDataWrapper.teamMatchesStatus = getStatusValueForDataSet(initDataWrapper.teamMatchesProgressDataSet);
    }

    private static String getStatusValueForDataSet(BL_ChartJS.DataSet dataSet) {
        List<Integer> data = (List<Integer>) JSON.deserialize(JSON.serialize(dataSet.data), List<Integer>.class);
        return data[0] + '/' + (data[0] + data[1]);
    }

    public class InitDataWrapper {
        @AuraEnabled
        public Boolean isCompetitionStarted;
        @AuraEnabled
        public BL_ChartJS.DataSet competitionTimeProgressDataSet;
        @AuraEnabled
        public BL_ChartJS.DataSet competitionMatchesProgressDataSet;
        @AuraEnabled
        public BL_ChartJS.DataSet teamMatchesProgressDataSet;
        @AuraEnabled
        public String competitionTimeStatus;
        @AuraEnabled
        public String competitionMatchesStatus;
        @AuraEnabled
        public String teamMatchesStatus;
    }
}