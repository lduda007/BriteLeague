public class BL_CompetitionProgressChartController {

    @AuraEnabled
    public static InitDataWrapper getInitDataWrapper(String competitionId) {
        InitDataWrapper wrapper = new InitDataWrapper();
        try {
            BL_Competition__c competition = new BL_DAO_Competition().getCompetitionById(competitionId);

            if(BL_Constants.LEAGUE_STARTED_STATUSES.contains(competition.Status__c)) {
                wrapper.isCompetitionStarted = true;
                List<BL_ChartJS.DataSet> dataSets = new List<BL_ChartJS.DataSet>();
                Map<Id, BL_ChartJS.DataSet> competitorIdToDataSet = new Map<Id, BL_ChartJS.DataSet>();
                Map<Id, BL_Competitor__c> teamIdToCompetitor = new Map<Id, BL_Competitor__c>();
                List<String> hexColors = BL_ColorHelper.getHexColors(Integer.valueOf(competition.Teams_Joined__c));
                Integer numberOfDirectCompetitors = 0;

                List<BL_Competitor__c> competitors = new BL_DAO_Competitor().getCompetitorsByCompetitionId(competitionId);

                for(BL_Competitor__c competitor : competitors) {
                    if(competitor.Is_Direct_Competitor__c) {
                        numberOfDirectCompetitors++;

                        String teamColor = hexColors[competitorIdToDataSet.size()];

                        BL_ChartJS.DataSet dataSet = new BL_ChartJS.DataSet();
                        dataSet.recordId = competitor.Id;
                        dataSet.label = competitor.Team__r.Name;
                        dataSet.setPrimaryColor(teamColor);
                        dataSet.setSecondaryColorBasedOnPrimaryColor();
                        dataSet.fill();
                        dataSet.addPoint(new BL_ChartJS.Point(0, 0));

                        dataSets.add(dataSet);
                        competitorIdToDataSet.put(competitor.Id, dataSet);
                    }

                    teamIdToCompetitor.put(competitor.Team__c, competitor);
                }

                if(competition.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE) {
                    for(BL_Team__c team : new BL_DAO_Team().getTeamsWithMembersByCompetitionId(competitionId)) {
                        if(team.RecordType.DeveloperName == BL_Constants.TEAM_RT_CLASSIC) {
                            for(BL_TeamMember__c teamMember : team.Members__r) {
                                if(teamIdToCompetitor.containsKey(teamMember.Team__c)) {
                                    BL_Competitor__c parentTeamCompetitor = teamIdToCompetitor.get(teamMember.Team__c);

                                    if(competitorIdToDataSet.containsKey(parentTeamCompetitor.Id)) {
                                        BL_ChartJS.DataSet parentTeamDataSet = competitorIdToDataSet.get(parentTeamCompetitor.Id);
                                        BL_Competitor__c competitor = teamIdToCompetitor.get(team.Id);
                                        competitorIdToDataSet.put(competitor.Id, parentTeamDataSet);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }

                for(BL_Match__c match : new BL_DAO_Match().getResolvedMatchesForCompetition(competitionId)) {
                    BL_ChartJS.DataSet team1DataSet = competitorIdToDataSet.get(match.Team1__c);
                    BL_ChartJS.DataSet team2DataSet = competitorIdToDataSet.get(match.Team2__c);

                    Integer team1MatchPoints = getPointsForCompetitor(match.Team1__c, match.Winner__c);
                    Integer team2MatchPoints = getPointsForCompetitor(match.Team2__c, match.Winner__c);

                    Integer team1Points = Integer.valueOf(((BL_ChartJS.Point) team1DataSet.data[team1DataSet.data.size() - 1]).y) + team1MatchPoints;
                    Integer team2Points = Integer.valueOf(((BL_ChartJS.Point) team2DataSet.data[team2DataSet.data.size() - 1]).y) + team2MatchPoints;

                    BL_ChartJS.Point team1Point = new BL_ChartJS.Point(team1DataSet.data.size(), team1Points);
                    team1Point.matchPoints = team1MatchPoints;
                    team1Point.matchDate = match.MatchDate__c != null ? match.MatchDate__c.format() : null;
                    team1Point.teamName = match.Team1__r.Team__r.Name;
                    team1Point.enemyName = match.Team2__r.Team__r.Name;
                    team1Point.enemyDataSetLabel = team2DataSet.label;
                    team1Point.enemyColor = team2DataSet.borderColor;

                    BL_ChartJS.Point team2Point = new BL_ChartJS.Point(team2DataSet.data.size(), team2Points);
                    team2Point.matchPoints = team2MatchPoints;
                    team2Point.matchDate = match.MatchDate__c != null ? match.MatchDate__c.format() : null;
                    team2Point.teamName = match.Team2__r.Team__r.Name;
                    team2Point.enemyName = match.Team1__r.Team__r.Name;
                    team2Point.enemyDataSetLabel = team1DataSet.label;
                    team2Point.enemyColor = team1DataSet.borderColor;

                    team1DataSet.addPoint(team1Point);
                    team2DataSet.addPoint(team2Point);
                }

                wrapper.labels.addAll(prepareLabels(competition, numberOfDirectCompetitors));
                wrapper.dataSets.addAll(dataSets);
            } else {
                wrapper.isCompetitionStarted = false;
            }
        } catch(Exception e) {
            String uiMessage = 'An error occurred during loading of "BL_CompetitionProgressChart" component';
            BL_Utils.throwAuraHandledException(uiMessage, e);
        }
        return wrapper;
    }

    private static Integer getPointsForCompetitor(Id competitorId, String winnerId) {
        if(competitorId == winnerId) {
            return 3;
        } else if(winnerId == null) {
            return 1;
        } else {
            return 0;
        }
    }

    private static List<String> prepareLabels(BL_Competition__c competition, Integer numberOfDirectCompetitors) {
        Integer numberOfMatchesPerTeam = 0;

        if(competition.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_CLASSIC) {
            numberOfMatchesPerTeam = Integer.valueOf(competition.Match_No__c * (competition.Teams_Joined__c - 1));
        } else if(competition.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE) {
            Integer numberOfSubTeamsPerBattleRoyaleTeam = Integer.valueOf(competition.Teams_Joined__c - numberOfDirectCompetitors) / numberOfDirectCompetitors;

            numberOfMatchesPerTeam = Integer.valueOf((numberOfDirectCompetitors - 1) * Math.pow(numberOfSubTeamsPerBattleRoyaleTeam, 2) * competition.Match_No__c);
        }

        List<String> labels = new List<String>();

        Integer labelsScale;

        if(numberOfMatchesPerTeam <= 25) {
            labelsScale = 1;
        } else if(numberOfMatchesPerTeam <= 50) {
            labelsScale = 2;
        } else if(numberOfMatchesPerTeam <= 100) {
            labelsScale = 4;
        } else {
            labelsScale = 10;
        }


        for(Integer i = 0; i <= numberOfMatchesPerTeam; i++) {
            if(Math.mod(i, labelsScale) == 0) {
                labels.add(String.valueOf(i));
            } else {
                labels.add('');
            }
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