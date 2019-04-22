public class BL_DAO_Competitor {

    public List<BL_Competitor__c> getCompetitorsByLeagueId(Id leagueId) {
        return [
                SELECT
                        Id,
                        Team__r.Player1__c,
                        Team__r.Player2__c
                FROM BL_Competitor__c
                WHERE League__c = :leagueId
        ];
    }
}