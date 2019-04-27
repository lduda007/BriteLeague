public class BL_DAO_Competitor {

    public List<BL_Competitor__c> getCompetitorsByLeagueId(Id leagueId) {
        return [
                SELECT
                        Id,
                        Team__r.Player1__c,
                        Team__r.Player2__c,
                        Team__r.RecordType.DeveloperName
                FROM BL_Competitor__c
                WHERE League__c = :leagueId
        ];
    }

    public BL_Competitor__c getCompetitorByPlayerIdAndLeagueId(Id playerId, Id leagueId) {
        return [
                SELECT
                        Id,
                        Team__r.Player1__c,
                        Team__r.Player2__c,
                        Team__r.RecordType.DeveloperName
                FROM BL_Competitor__c
                WHERE League__c = :leagueId
                AND (
                        Team__r.Player1__c = :playerId
                        OR Team__r.Player2__c = :playerId
                )
                LIMIT 1
        ];
    }

    public BL_Competitor__c getCompetitorByPlayerIdAndLeagueIdAndTeamRecordTypeDevName(Id playerId, Id leagueId, String teamRecordType) {
        return [
                SELECT
                        Id,
                        Team__r.Player1__c,
                        Team__r.Player2__c,
                        Team__r.RecordType.DeveloperName
                FROM BL_Competitor__c
                WHERE League__c = :leagueId
                AND (
                        Team__r.Player1__c = :playerId
                        OR Team__r.Player2__c = :playerId
                )
                AND Team__r.RecordType.DeveloperName = :teamRecordType
                LIMIT 1
        ];
    }

    public List<BL_Competitor__c> getCompetitorsByLeagueIdAndParentTeamId(Id leagueId, Id parentTeamId) {
        return [
                SELECT
                        Id,
                        Team__r.Player1__c,
                        Team__r.Player2__c,
                        Team__r.RecordType.DeveloperName
                FROM BL_Competitor__c
                WHERE League__c = :leagueId
                AND Team__c IN (
                        SELECT Member__c
                        FROM BL_TeamMember__c
                        WHERE Team__c = :parentTeamId
                )
        ];
    }
}