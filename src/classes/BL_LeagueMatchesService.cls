public with sharing class BL_LeagueMatchesService {
    public static void generateMatchesAfterLeagueStarted(String leagueId){
        List<BL_Competitor__c> competitors = BL_Utils.getLeagueCompetitors(leagueId);
        List<BL_League__c> league = [SELECT Match_No__c FROM BL_League__c WHERE Id =: leagueId];

        if(competitors.size() >= 2 && league.size() > 0){
            List<String> competitorsIds = new List<String>();
            List<BL_Match__c> generatedMatches = new List<BL_Match__c>();
            competitorsIds.addAll(new Map<String,BL_Competitor__c>(competitors).keySet());
            Integer numberOfTeams = competitorsIds.size();
            Boolean isNumberOfTeamsEven = Math.mod(competitorsIds.size(),2) == 0;

            if(isNumberOfTeamsEven){
                generatedMatches = generateMatchesForEvenNumberOfTeams(numberOfTeams, competitorsIds, leagueId, league[0].Match_No__c);
            }else{
                generatedMatches = generateMatchesForNotEvenNumberOfTeams(numberOfTeams, competitorsIds, leagueId, league[0].Match_No__c);
            }
            insertGeneratedMatches(generatedMatches);
        }
    }

    private static List<BL_Match__c> generateMatchesForNotEvenNumberOfTeams(Integer numberOfTeams, List<String> competitorIdsForDraw, String leagueId, Decimal rounds){
        List<BL_Match__c> generatedMatches = new List<BL_Match__c>();

        for(Integer ii=0; ii < numberOfTeams; ii++){
            for(Integer jj=0; jj < numberOfTeams/2; jj++){
                for(Integer kk=0; kk < rounds; kk++){
                    BL_Match__c newMatch = new BL_Match__c();
                    newMatch.Team1__c = competitorIdsForDraw[jj];
                    newMatch.Team2__c = competitorIdsForDraw[numberOfTeams-jj-2];
                    newMatch.League__c = leagueId;
                    newMatch.Round__c = kk+1;
                    newMatch.DrawRound__c = ii+1;
                    generatedMatches.add(newMatch);
                }
            }
            competitorIdsForDraw.add(competitorIdsForDraw[0]);
            competitorIdsForDraw.remove(0);
        }
        return generatedMatches;
    }

    private static List<BL_Match__c> generateMatchesForEvenNumberOfTeams(Integer numberOfTeams, List<String> competitorIdsForDraw, String leagueId, Decimal rounds){
        List<BL_Match__c> generatedMatches = new List<BL_Match__c>();
        String lastTeamOnTheList = competitorIdsForDraw[numberOfTeams-1];

        for(Integer ii=0; ii < numberOfTeams-1; ii++){
            for(Integer jj=0; jj < numberOfTeams/2; jj++){
                for(Integer kk=0; kk < rounds; kk++){
                    BL_Match__c newMatch = new BL_Match__c();
                    newMatch.Team1__c = competitorIdsForDraw[jj];
                    newMatch.Team2__c = competitorIdsForDraw[numberOfTeams-jj-1];
                    newMatch.League__c = leagueId;
                    newMatch.Round__c = kk+1;
                    newMatch.DrawRound__c = ii+1;
                    generatedMatches.add(newMatch);
                }
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