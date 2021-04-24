public class BL_DAO_Competitor {

    public List<BL_Competitor__c> getCompetitorsByCompetitionId(Id competitionId) {
        return [
                SELECT
                        Id,
                        CreatedDate,
                        GamesWon__c,
                        GamesDrawn__c,
                        GamesLost__c,
                        GoalsFor__c,
                        GoalsAgainst__c,
                        GoalsDraw__c,
                        Is_Direct_Competitor__c,
                        MatchesPlayed__c,
                        Points__c,
                        Team__c,
                        Team__r.Name,
                        Team__r.Player1__c,
                        Team__r.Player2__c,
                        Team__r.RecordType.DeveloperName
                FROM BL_Competitor__c
                WHERE Competition__c = :competitionId
                ORDER BY Team__r.Name ASC
        ];
    }

    public BL_Competitor__c getCompetitorByPlayerIdAndCompetitionId(Id playerId, Id competitionId) {
        return [
                SELECT
                        Id,
                        GamesWon__c,
                        GamesDrawn__c,
                        GamesLost__c,
                        GoalsFor__c,
                        GoalsAgainst__c,
                        GoalsDraw__c,
                        Is_Direct_Competitor__c,
                        MatchesPlayed__c,
                        Points__c,
                        Team__r.Name,
                        Team__r.Player1__c,
                        Team__r.Player2__c,
                        Team__r.RecordType.DeveloperName
                FROM BL_Competitor__c
                WHERE Competition__c = :competitionId
                AND (
                        Team__r.Player1__c = :playerId
                        OR Team__r.Player2__c = :playerId
                )
                LIMIT 1
        ];
    }

    public BL_Competitor__c getCompetitorByPlayerIdAndCompetitionIdAndTeamRecordTypeDevName(Id playerId, Id competitionId, String teamRecordType) {
        return [
                SELECT
                        Id,
                        GamesWon__c,
                        GamesDrawn__c,
                        GamesLost__c,
                        GoalsFor__c,
                        GoalsAgainst__c,
                        GoalsDraw__c,
                        Is_Direct_Competitor__c,
                        MatchesPlayed__c,
                        Points__c,
                        Team__r.Name,
                        Team__r.Player1__c,
                        Team__r.Player2__c,
                        Team__r.RecordType.DeveloperName
                FROM BL_Competitor__c
                WHERE Competition__c = :competitionId
                AND (
                        Team__r.Player1__c = :playerId
                        OR Team__r.Player2__c = :playerId
                )
                AND Team__r.RecordType.DeveloperName = :teamRecordType
                LIMIT 1
        ];
    }

    public List<BL_Competitor__c> getCompetitorsByCompetitionIdAndParentTeamId(Id competitionId, Id parentTeamId) {
        return [
                SELECT
                        Id,
                        GamesWon__c,
                        GamesDrawn__c,
                        GamesLost__c,
                        GoalsFor__c,
                        GoalsAgainst__c,
                        GoalsDraw__c,
                        Is_Direct_Competitor__c,
                        MatchesPlayed__c,
                        Points__c,
                        Team__r.Name,
                        Team__r.Player1__c,
                        Team__r.Player2__c,
                        Team__r.RecordType.DeveloperName
                FROM BL_Competitor__c
                WHERE Competition__c = :competitionId
                AND Team__c IN (
                        SELECT Member__c
                        FROM BL_TeamMember__c
                        WHERE Team__c = :parentTeamId
                )
        ];
    }

    public BL_Competitor__c getParentCompetitorByMemberTeamIdAndCompetitionId(Id memberTeamId, Id competitionId) {
        List<BL_Competitor__c> competitor = [
                SELECT Id, GamesLost__c, GamesWon__c, GamesDrawn__c, RoundsWon__c, RoundsLost__c, GoalsAgainst__c, GoalsFor__c, GoalsDraw__c
                FROM BL_Competitor__c
                WHERE Competition__c = :competitionId
                AND Team__c IN (
                        SELECT Team__c
                        FROM BL_TeamMember__c
                        WHERE Member__c = :memberTeamId
                )
                LIMIT 1
        ];
        return competitor.isEmpty() ? null : competitor[0];
    }

    public Map<Id, BL_Competitor__c> getCompetitorsMapByIds(List<Id> ids) {
        return new Map<Id, BL_Competitor__c>([
                SELECT
                        Id,
                        Team__c,
                        GamesLost__c,
                        GamesDrawn__c,
                        GamesWon__c,
                        GoalsAgainst__c,
                        GoalsFor__c,
                        RoundsWon__c,
                        RoundsLost__c
                FROM BL_Competitor__c
                WHERE Id IN :ids
        ]);
    }
}