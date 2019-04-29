public interface BL_MatchGenerator {
    List<BL_Match__c> generateMatches(List<Id> competitorsIds, Id leagueId, Integer rounds);
}