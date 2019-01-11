public class BL_CompetitionStatusChartController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper(Id competitionId) {
        InitDataWrapper initDataWrapper;
        try {
            initDataWrapper = new InitDataWrapper();

            BL_League__c league = [
                    SELECT Id, TeamSize__c, Teams_Joined__c, Start_Date__c, End_Date__c, (
                            SELECT Id, isResolved__c, Team1__r.Team__r.Player1__c, Team1__r.Team__r.Player2__c,
                                    Team2__r.Team__r.Player1__c, Team2__r.Team__r.Player2__c
                            FROM Matches__r
                    )
                    FROM BL_League__c
                    WHERE Id = :competitionId
                    LIMIT 1
            ];

            initDataWrapper.competitionTimeProgressDataSet = getCompetitionTimeProgressDataSet(league);
            initDataWrapper.competitionMatchesProgressDataSet = getCompetitionMatchesProgressDataSet(league.Matches__r);
            initDataWrapper.teamMatchesProgressDataSet = getTeamMatchesProgressDataSet(league.Matches__r);

            populateStatusFields(initDataWrapper);
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization of Competition Status Chart component: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }
        return initDataWrapper;
    }

    private static BL_ChartJS.DataSet getCompetitionTimeProgressDataSet(BL_League__c league) {
        BL_ChartJS.DataSet dataSet = new BL_ChartJS.DataSet();

        Date today = System.today();
        Integer fromStartDays = league.Start_Date__c.date().daysBetween(today);
        if(fromStartDays < 0) {
            fromStartDays = 0;
        }
        Integer toEndDays = today.daysBetween(league.End_Date__c.date());
        if(toEndDays < 0) {
            fromStartDays = league.Start_Date__c.date().daysBetween(league.End_Date__c.date());
            toEndDays = 0;
        }

        dataSet.data.add(fromStartDays);
        dataSet.data.add(toEndDays);

        String backgroundColor = '#00BCD4FF';
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

        String backgroundColor = '#2196F3FF';
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

        String backgroundColor = '#3F51B5FF';
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