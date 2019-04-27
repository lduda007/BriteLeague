public with sharing class BL_LeagueMatchesService {
    public static void generateMatchesAfterLeagueStarted(String leagueId) {
        List<BL_Competitor__c> competitors = BL_Utils.getLeagueCompetitors(leagueId);
        List<BL_League__c> league = [SELECT Match_No__c, RecordType.DeveloperName FROM BL_League__c WHERE Id = :leagueId];
        if (competitors.size() >= 2 && league.size() > 0) {
            BL_MatchGenerator matchGenerator;
            if (league[0].RecordType.DeveloperName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE) {
                matchGenerator = new BL_BattleRoyaleMatchGenerator();
            } else {
                matchGenerator = new BL_ClassicMatchGenerator();
            }

            List<Id> competitorsIds = new List<Id>();
            List<BL_Match__c> generatedMatches = new List<BL_Match__c>();
            competitorsIds.addAll(new Map<Id, BL_Competitor__c>(competitors).keySet());

            generatedMatches = matchGenerator.generateMatches(
                    competitorsIds,
                    (Id) leagueId,
                    (Integer) league[0].Match_No__c
            );

            insertGeneratedMatches(generatedMatches);
        }
    }

    private static void insertGeneratedMatches(List<BL_Match__c> generatedMatches) {
        try {
            insert generatedMatches;
        } catch (DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
        }
    }
}