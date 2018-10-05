public with sharing class BL_RoundsWonScores {

    @AuraEnabled
    public static DataWrapper getChartData(Id teamId){
        DataWrapper dataWrapper = new DataWrapper();
        try {
            populateTeamName(dataWrapper, teamId);
            populateRoundsWonScores(dataWrapper, teamId);
        } catch(Exception e){
            AuraHandledException ae = new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
            ae.setMessage(e.getMessage() + ' ' + e.getStackTraceString());
            throw ae;
        }
        return dataWrapper;
    }

    private static void populateTeamName(DataWrapper dataWrapper, Id teamId){
        dataWrapper.teamName = [SELECT Name FROM BL_Team__c WHERE Id = :teamId].Name;
    }

    private static void populateRoundsWonScores(DataWrapper dataWrapper, Id teamId){
        Map<Id, BL_ChartJS.DataSet> resultsByTeamId = new Map<Id, BL_ChartJS.DataSet>();
        for(List<BL_Match__c> matches : [
            SELECT Team1__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__c, Team2__r.Team__r.Name,
                Team1Round1Goals__c, Team1Round2Goals__c, Team1Round3Goals__c,
                Team2Round1Goals__c, Team2Round2Goals__c, Team2Round3Goals__c
            FROM BL_Match__c
            WHERE (Team1__r.Team__c = :teamId OR Team2__r.Team__c = :teamId) AND isResolved__c = true
        ]){
            for(BL_Match__c match : matches){
                BL_Team__c opponentTeam = getOpponentTeam(teamId, match);
                BL_ChartJS.DataSet dataSet = getOpponentDataSet(resultsByTeamId, opponentTeam);
                populateDataSetWithMatchResults(dataSet, opponentTeam, match);
            }
        }
        dataWrapper.dataSets = resultsByTeamId.values();
        populateDataSetWithColour(dataWrapper);
    }

    private static BL_Team__c getOpponentTeam(Id teamId, BL_Match__c match){
        if(match.Team1__r.Team__c == teamId){
            return match.Team2__r.Team__r;
        }
        return match.Team1__r.Team__r;
    }

    private static BL_ChartJS.DataSet getOpponentDataSet(Map<Id, BL_ChartJS.DataSet> resultsByTeamId, BL_Team__c opponentTeam){
        BL_ChartJS.DataSet dataSet = resultsByTeamId.get(opponentTeam.Id);
        if(dataSet == null){
            dataSet = new BL_ChartJS.DataSet();
            dataSet.label = opponentTeam.Name;
            dataSet.data = new List<Integer>();
            for(Integer i = 0; i < 10; i++){
                dataSet.data.add(0);
            }
            resultsByTeamId.put(opponentTeam.Id, dataSet);
        }
        return dataSet;
    }

    private static void populateDataSetWithMatchResults(BL_ChartJS.DataSet dataSet, BL_Team__c team, BL_Match__c match){
        // 1st round
        if(match.Team1__r.Team__c == team.Id && match.Team1Round1Goals__c < match.Team2Round1Goals__c){
            Integer goals = match.Team1Round1Goals__c.intValue();
            dataSet.data.set(goals, ((Integer) dataSet.data.get(goals)) + 1);
        } else if(match.Team2__r.Team__c == team.Id && match.Team1Round1Goals__c > match.Team2Round1Goals__c){
            Integer goals = match.Team2Round1Goals__c.intValue();
            dataSet.data.set(goals, ((Integer) dataSet.data.get(goals)) + 1);
        }
        // 2nd round
        if(match.Team1__r.Team__c == team.Id && match.Team1Round2Goals__c < match.Team2Round2Goals__c){
            Integer goals = match.Team1Round2Goals__c.intValue();
            dataSet.data.set(goals, ((Integer) dataSet.data.get(goals)) + 1);
        } else if(match.Team2__r.Team__c == team.Id && match.Team1Round2Goals__c > match.Team2Round2Goals__c){
            Integer goals = match.Team2Round2Goals__c.intValue();
            dataSet.data.set(goals, ((Integer) dataSet.data.get(goals)) + 1);
        }
        // 3rd round
        if(match.Team1__r.Team__c == team.Id && match.Team1Round3Goals__c < match.Team2Round3Goals__c){
            Integer goals = match.Team1Round3Goals__c.intValue();
            dataSet.data.set(goals, ((Integer) dataSet.data.get(goals)) + 1);
        } else if(match.Team2__r.Team__c == team.Id && match.Team1Round3Goals__c > match.Team2Round3Goals__c){
            Integer goals = match.Team2Round3Goals__c.intValue();
            dataSet.data.set(goals, ((Integer) dataSet.data.get(goals)) + 1);
        }
    }

    private static void populateDataSetWithColour(DataWrapper dataWrapper){
        for(Integer i = 0; i < dataWrapper.dataSets.size(); i++){
            String color = BL_ColorHelper.getHexColorOnIndex(i);
            BL_ChartJS.DataSet dataSet = dataWrapper.dataSets.get(i);
            dataSet.setPrimaryColor(color);
            dataSet.setSecondaryColor(color.removeEnd('FF'));
            dataSet.fill();
        }
    }

    public class DataWrapper {
        @AuraEnabled
        public String teamName;
        @AuraEnabled
        public List<BL_ChartJS.DataSet> dataSets;
    }

}