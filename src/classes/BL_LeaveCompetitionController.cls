public with sharing class BL_LeaveCompetitionController {

    @AuraEnabled
    public static void removeCompetitorFromCompetition(Id playerId, Id leagueId) {
        try {
            List<BL_Competitor__c> competitorsToDelete = new List<BL_Competitor__c>();

            BL_Competition__c league = new BL_DAO_Competition().getCompetitionById(leagueId);

            BL_DAO_Competitor daoCompetitor = new BL_DAO_Competitor();

            if(league.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE) {
                BL_Competitor__c battleRoyaleCompetitor = daoCompetitor.getCompetitorByPlayerIdAndLeagueIdAndTeamRecordTypeDevName(
                        playerId, leagueId, BL_Constants.TEAM_RT_BATTLE_ROYALE
                );

                competitorsToDelete.add(battleRoyaleCompetitor);

                List<BL_Competitor__c> classicCompetitors = daoCompetitor.getCompetitorsByLeagueIdAndParentTeamId(
                        leagueId, battleRoyaleCompetitor.Team__c
                );

                competitorsToDelete.addAll(classicCompetitors);
            } else {
                BL_Competitor__c competitor = daoCompetitor.getCompetitorByPlayerIdAndLeagueId(
                        playerId, leagueId
                );
                competitorsToDelete.add(competitor);
            }

            delete competitorsToDelete;
        } catch(Exception e) {
            BL_Utils.throwAuraHandledException(Label.BL_Error_When_Leaving_Competition, e);
        }
    }
}