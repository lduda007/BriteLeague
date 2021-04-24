public without sharing class BL_MatchService {

    public static void generateMatches(String competitionId) {
        List<BL_Competitor__c> competitors = new BL_DAO_Competitor().getCompetitorsByCompetitionId(competitionId);
        BL_Competition__c league = new BL_DAO_Competition().getCompetitionById(competitionId);

        if (competitors.size() >= 2) {
            BL_MatchGenerator matchGenerator;
            if (league.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE) {
                matchGenerator = new BL_BattleRoyaleMatchGenerator();
            } else {
                matchGenerator = new BL_ClassicMatchGenerator();
            }

            List<Id> competitorsIds = new List<Id>();
            List<BL_Match__c> generatedMatches = new List<BL_Match__c>();
            competitorsIds.addAll(new Map<Id, BL_Competitor__c>(competitors).keySet());

            generatedMatches = matchGenerator.generateMatches(
                    competitorsIds,
                    (Id) competitionId,
                    (Integer) league.Match_No__c
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