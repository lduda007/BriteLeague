public class BL_DAO_Team {

    public BL_Team__c getTeamById(Id teamId) {
        return [
                SELECT
                        Id,
                        IsActive__c,
                        Name,
                        Player1__r.Name,
                        Player2__r.Name,
                        RecordType.DeveloperName
                FROM BL_Team__c
                WHERE Id = :teamId
                LIMIT 1
        ];
    }

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

    public List<BL_Team__c> getTeamsWithMembersByLeagueId(Id leagueId) {
        return [
                SELECT
                        Id,
                        IsActive__c,
                        Name,
                        Player1__r.Name,
                        Player2__r.Name,
                        Player1__r.FirstName,
                        Player2__r.FirstName,
                        Player1__r.LastName,
                        Player2__r.LastName,
                        Player1__r.ImageUrl__c,
                        Player2__r.ImageUrl__c,
                        RecordType.DeveloperName,
                (
                        SELECT
                                Id,
                                Team__c
                        FROM Members__r
                )
                FROM BL_Team__c
                WHERE Id IN (
                        SELECT Team__c
                        FROM BL_Competitor__c
                        WHERE League__c = :leagueId
                )
                ORDER BY Name ASC
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

    public List<BL_Team__c> getTeamsByParentTeamId(Id parentTeamId) {
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
                        SELECT Member__c
                        FROM BL_TeamMember__c
                        WHERE Team__c = :parentTeamId
                )
        ];
    }
}