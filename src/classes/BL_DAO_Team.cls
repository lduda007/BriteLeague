public class BL_DAO_Team {

    public List<BL_Team__c> getTeamsByLeagueId(Id leagueId) {
        return [
                SELECT
                        Id,
                        IsActive__c,
                        Name,
                        Player1__r.Name,
                        Player2__r.Name,
                        RecordType.DeveloperName
                FROM BL_Team__c
                WHERE Id IN (
                        SELECT Team__c
                        FROM BL_Competitor__c
                        WHERE League__c = :leagueId
                )
        ];
    }

    public List<BL_Team__c> getTeamsByPlayerId(Id playerId) {
        return [
                SELECT
                        Id,
                        IsActive__c,
                        Name,
                        Player1__r.Name,
                        Player2__r.Name,
                        RecordType.DeveloperName
                FROM BL_Team__c
                WHERE (
                        Player1__c = :playerId
                        OR Player2__c = :playerId
                )
        ];
    }
}