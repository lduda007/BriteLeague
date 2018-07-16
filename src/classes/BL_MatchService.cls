public with sharing class BL_MatchService {
    public static void generateMatchesAfterLeagueStarted(String leagueId){
        List<BL_Competitor__c> competitors = [
                SELECT Id, Team__c
                FROM BL_Competitor__c
                WHERE League__c =: leagueId
        ];
        if(competitors.size() >= 2){
            List<Id> competitorsIds = new List<Id>();
            List<BL_Match__c> generatedMatches = new List<BL_Match__c>();
            competitorsIds.addAll(new Map<Id,BL_Competitor__c>(competitors).keySet());
            Integer numberOfTeams = competitorsIds.size();
            Boolean isNumberOfTeamsEven = Math.mod(competitorsIds.size(),2) == 0;
            List<Id> competitorIdsForDraw = competitorsIds.clone();

            if(isNumberOfTeamsEven){
                Id lastTeamOnTheList = competitorsIds[numberOfTeams-1];
                for(Integer ii=0; ii < competitors.size()-1; ii++){
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
            }else{
                for(Integer ii=0; ii < competitors.size(); ii++){
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
            }
            try{
                insert generatedMatches;
            }catch (DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug(e.getDmlMessage(i));
                }
            }
        }
    }
}