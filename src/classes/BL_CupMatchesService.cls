
public with sharing class BL_CupMatchesService {
    public static void generateMatchesAfterCupStarted(String leagueId){
        List<BL_Competitor__c> competitors = BL_Utils.getLeagueCompetitors(leagueId);
        List<BL_League__c> league = [SELECT Match_No__c FROM BL_League__c WHERE Id =: leagueId];

        if(competitors.size() >= 2 && league.size() > 0){
            List<String> competitorsIds = new List<String>();
            List<BL_Match__c> allGeneratedMatches = new List<BL_Match__c>();
            List<BL_Match__c> firstRoundMatches = new List<BL_Match__c>();
            competitorsIds.addAll(new Map<String,BL_Competitor__c>(competitors).keySet());
            Integer numberOfTeams = competitorsIds.size();
            List<String> competitorIdsForDraw = competitorsIds.clone();

            allGeneratedMatches = generateMatchesForFirstCupStage(numberOfTeams, competitorIdsForDraw, leagueId, numberOfTeams/2);
            firstRoundMatches.addAll(allGeneratedMatches);
            allGeneratedMatches.clear();
            allGeneratedMatches.addAll(relateMatchesForAllCupStages(firstRoundMatches, leagueId, competitorsIds.size()));
            upsertGeneratedMatches(allGeneratedMatches);
        }
    }

    private static List<BL_Match__c> generateMatchesForFirstCupStage(Integer numberOfTeams, List<String> competitorIdsForDraw, String leagueId, Integer cupStage){
        List<BL_Match__c> generatedMatches = new List<BL_Match__c>();
        for(Integer jj=0; jj < numberOfTeams/2; jj++){
            BL_Match__c newMatch = new BL_Match__c();
            newMatch.Team1__c = competitorIdsForDraw[jj];
            newMatch.Team2__c = competitorIdsForDraw[numberOfTeams-jj-1];
            newMatch.League__c = leagueId;
            newMatch.CupStage__c = cupStage;
            generatedMatches.add(newMatch);
        }
        return generatedMatches;
    }

    private static List<BL_Match__c> generateMatchesForNextCupStages(Integer numberOfTeamsAtCurrentStage, String leaguId){
        List<BL_Match__c> nextRoundsMatches = new List<BL_Match__c>();
        while(numberOfTeamsAtCurrentStage/2 > 1){
            numberOfTeamsAtCurrentStage /= 2;
            for(Integer ii=0; ii < numberOfTeamsAtCurrentStage/2; ii++){
                nextRoundsMatches.add(new BL_Match__c(Team1_Score__c=9, League__c=leaguId));
            }
        }
        //3rd place match
//        nextRoundsMatches.add(new BL_Match__c(Team1_Score__c=9, League__c=leaguId));
        try{
            insert nextRoundsMatches;
            return nextRoundsMatches;
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
            return null;
        }
    }

    private static List<BL_Match__c> relateMatchesForAllCupStages(List<BL_Match__c> stageMatches, String leagueId, Integer numberOfTeamsAtCurrentStage){
        List<BL_Match__c> nextRoundsMatches = generateMatchesForNextCupStages(numberOfTeamsAtCurrentStage, leagueId);
        List<BL_Match__c> nextStageMatches = new List<BL_Match__c>();
        List<BL_Match__c> allGeneratedMatches = new List<BL_Match__c>();

        while(stageMatches.size() > 1){
            for(Integer ii=0; ii < stageMatches.size(); ii+=2){
                stageMatches[ii].NextRoundMatch__c = nextRoundsMatches[0].Id;
                stageMatches[ii+1].NextRoundMatch__c = nextRoundsMatches[0].Id;
                stageMatches[ii].CupStage__c = stageMatches.size();
                stageMatches[ii+1].CupStage__c = stageMatches.size();
                nextStageMatches.add(nextRoundsMatches[0]);
                nextRoundsMatches.remove(0);
            }
            allGeneratedMatches.addAll(stageMatches);
            stageMatches.clear();
            stageMatches.addAll(nextStageMatches);
            nextStageMatches.clear();
        }
        //final and 3rd place matches
        stageMatches[0].CupStage__c = 1;
        allGeneratedMatches.add(stageMatches[0]);
        for(BL_Match__c match : allGeneratedMatches){
            match.Team1_Score__c = 9;
            system.debug(match);
        }
        return allGeneratedMatches;
    }

    private static void upsertGeneratedMatches(List<BL_Match__c> generatedMatches){
        try{
            upsert generatedMatches;
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
        }
    }
}