public class BL_CompetitionProgressChartController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper(String competitionId) {
        InitDataWrapper wrapper = new InitDataWrapper();
        try {
            BL_League__c league = [
                    SELECT Id, TeamSize__c, Teams_Joined__c, Status__c
                    FROM BL_League__c
                    WHERE Id = :competitionId
                    LIMIT 1
            ];
            if(BL_Constants.LEAGUE_STARTED_STATUSES.contains(league.Status__c)) {
                wrapper.isCompetitionStarted = true;
                Map<String, BL_ChartJS.DataSet> teamIdToDataSet = new Map<String, BL_ChartJS.DataSet>();
                List<String> hexColors = BL_ColorHelper.getHexColors(Integer.valueOf(league.Teams_Joined__c));

                for(BL_Competitor__c competitor : [
                        SELECT Id, Team__r.Name
                        FROM BL_Competitor__c
                        WHERE League__c = :competitionId
                        ORDER BY Team__r.Name ASC
                ]) {
                    String teamColor = hexColors[teamIdToDataSet.size()];

                    BL_ChartJS.DataSet dataSet = new BL_ChartJS.DataSet();
                    dataSet.label = competitor.Team__r.Name;
                    dataSet.setPrimaryColor(teamColor);
                    dataSet.setSecondaryColorBasedOnPrimaryColor();
                    dataSet.fill();
                    dataSet.addPoint(new BL_ChartJS.Point(0, 0));
                    teamIdToDataSet.put(competitor.Id, dataSet);
                }

                for(BL_Match__c match : [
                        SELECT Id, Team1__c, Team2__c, Team1_Score__c, Team2_Score__c, Winner__c, Team1__r.Team__r.Name,
                                Team2__r.Team__r.Name, MatchDate__c
                        FROM BL_Match__c
                        WHERE League__c = :competitionId
                        AND isResolved__c = true
                        ORDER BY MatchDate__c ASC, LastModifiedDate ASC
                ]) {
                    BL_ChartJS.DataSet team1DataSet = teamIdToDataSet.get(match.Team1__c);
                    BL_ChartJS.DataSet team2DataSet = teamIdToDataSet.get(match.Team2__c);

                    Integer team1MatchPoints = getPointsForTeam(match.Team1__c, match.Winner__c);
                    Integer team2MatchPoints = getPointsForTeam(match.Team2__c, match.Winner__c);

                    Integer team1Points = Integer.valueOf(((BL_ChartJS.Point) team1DataSet.data[team1DataSet.data.size() - 1]).y) + team1MatchPoints;
                    Integer team2Points = Integer.valueOf(((BL_ChartJS.Point) team2DataSet.data[team2DataSet.data.size() - 1]).y) + team2MatchPoints;

                    BL_ChartJS.Point team1Point = new BL_ChartJS.Point(team1DataSet.data.size(), team1Points);
                    team1Point.matchPoints = team1MatchPoints;
                    team1Point.matchDate = match.MatchDate__c != null ? match.MatchDate__c.format() : null;
                    team1Point.enemyName = match.Team2__r.Team__r.Name;
                    team1Point.enemyColor = team2DataSet.borderColor;

                    BL_ChartJS.Point team2Point = new BL_ChartJS.Point(team2DataSet.data.size(), team2Points);
                    team2Point.matchPoints = team2MatchPoints;
                    team2Point.matchDate = match.MatchDate__c != null ? match.MatchDate__c.format() : null;
                    team2Point.enemyName = match.Team1__r.Team__r.Name;
                    team2Point.enemyColor = team1DataSet.borderColor;

                    team1DataSet.addPoint(team1Point);
                    team2DataSet.addPoint(team2Point);
                }

                wrapper.labels.addAll(prepareLabels(competitionId, new List<String>(teamIdToDataSet.keySet())[0]));
                wrapper.dataSets.addAll(teamIdToDataSet.values());
            } else {
                wrapper.isCompetitionStarted = false;
            }
        } catch(Exception e) {
            BL_Utils.throwAuraHandledException(e.getMessage(), e.getMessage() + ' ' + e.getStackTraceString());
        }
        return wrapper;
    }

    private static Integer getPointsForTeam(Id teamId, String winnerId) {
        if(teamId == winnerId) {
            return 3;
        } else if(winnerId == null) {
            return 1;
        } else {
            return 0;
        }
    }

    private static List<String> prepareLabels(String competitionId, String competitorId) {
        Integer numberOfMatches = [
                SELECT COUNT()
                FROM BL_Match__c
                WHERE League__c = :competitionId
                AND (
                        Team1__c = :competitorId
                        OR Team2__c = :competitorId
                )
        ];

        List<String> labels = new List<String>();
        for(Integer i = 0; i <= numberOfMatches; i++) {
            labels.add(String.valueOf(i));
        }

        return labels;
    }

    public class InitDataWrapper {
        @AuraEnabled
        public Boolean isCompetitionStarted;
        @AuraEnabled
        public List<String> labels = new List<String>();
        @AuraEnabled
        public List<BL_ChartJS.DataSet> dataSets = new List<BL_ChartJS.DataSet>();
    }
}