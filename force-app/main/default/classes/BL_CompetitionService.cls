public class BL_CompetitionService {

    public static void startCompetition(Id competitionId) {
        BL_Competition__c competition = new BL_DAO_Competition().getCompetitionById(competitionId);

        if(competition == null || competition.Status__c == BL_Constants.LEAGUE_STATUS_STARTED) {
            throw new AuraHandledException(Label.BL_League_already_started);
        }

        competition.Start_Date__c = System.now();
        competition.Status__c = BL_Constants.LEAGUE_STATUS_STARTED;
        update competition;

        BL_MatchService.generateMatches(competitionId);
    }
}