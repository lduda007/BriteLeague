public class BL_DAO_Team {

    public List<BL_Team__c> getTeamsByLeagueId(Id leagueId) {
        return [
                SELECT Id
                FROM BL_Team__c
                WHERE Id IN (
                        SELECT Team__c
                        FROM BL_Competitor__c
                        WHERE League__c = :leagueId
                )
        ];
    }
}