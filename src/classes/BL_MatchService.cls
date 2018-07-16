public with sharing class BL_MatchService {
    public static void generateMatchesAfterLeagueStarted(String leagueId){
        List<BL_Competitor__c> competitors = BL_Utils.getLeagueCompetitors(leagueId);

        if(competitors.size() >= 2){
            List<String> competitorsIds = new List<String>();
            List<BL_Match__c> generatedMatches = new List<BL_Match__c>();
            competitorsIds.addAll(new Map<String,BL_Competitor__c>(competitors).keySet());
            Integer numberOfTeams = competitorsIds.size();
            Boolean isNumberOfTeamsEven = Math.mod(competitorsIds.size(),2) == 0;
            List<String> competitorIdsForDraw = competitorsIds.clone();

            if(isNumberOfTeamsEven){
                generatedMatches = generateMatchesForEvenNumberOfTeams(numberOfTeams, competitorIdsForDraw, leagueId);
            }else{
                generatedMatches = generateMatchesForNotEvenNumberOfTeams(numberOfTeams, competitorIdsForDraw, leagueId);
            }
            insertGeneratedMatches(generatedMatches);
        }
    }

    private static List<BL_Match__c> generateMatchesForNotEvenNumberOfTeams(Integer numberOfTeams, List<String> competitorIdsForDraw, String leagueId){
        List<BL_Match__c> generatedMatches = new List<BL_Match__c>();

        for(Integer ii=0; ii < numberOfTeams; ii++){
            for(Integer jj=0; jj < numberOfTeams/2; jj++){
                BL_Match__c newMatch = new BL_Match__c();
                newMatch.Team1__c = competitorIdsForDraw[jj];
                newMatch.Team2__c = competitorIdsForDraw[numberOfTeams-jj-2];
                newMatch.League__c = leagueId;
                generatedMatches.add(newMatch);
            }
            competitorIdsForDraw.add(competitorIdsForDraw[0]);
            competitorIdsForDraw.remove(0);
        }
        return generatedMatches;
    }

    private static List<BL_Match__c> generateMatchesForEvenNumberOfTeams(Integer numberOfTeams, List<String> competitorIdsForDraw, String leagueId){
        List<BL_Match__c> generatedMatches = new List<BL_Match__c>();
        String lastTeamOnTheList = competitorIdsForDraw[numberOfTeams-1];

        for(Integer ii=0; ii < numberOfTeams-1; ii++){
            for(Integer jj=0; jj < numberOfTeams/2; jj++){
                BL_Match__c newMatch = new BL_Match__c();
                newMatch.Team1__c = competitorIdsForDraw[jj];
                newMatch.Team2__c = competitorIdsForDraw[numberOfTeams-jj-1];
                newMatch.League__c = leagueId;
                generatedMatches.add(newMatch);
            }
            competitorIdsForDraw.remove(numberOfTeams-1);
            competitorIdsForDraw.add(competitorIdsForDraw[0]);
            competitorIdsForDraw.remove(0);
            competitorIdsForDraw.add(lastTeamOnTheList);
        }
        return generatedMatches;
    }

    private static void insertGeneratedMatches(List<BL_Match__c> generatedMatches){
        try{
            insert generatedMatches;
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
        }
    }
}