public class BL_DAO_Competition {

    public BL_Competition__c getCompetitionById(Id competitionId) {
        return [
                SELECT
                        Id,
                        CreatedBy.Name,
                        CreatedDate,
                        Date_League_Finished__c,
                        End_Date__c,
                        Match_No__c,
                        Matches_Scheduled__c,
                        Max_Teams__c,
                        Name,
                        OwnerId,
                        Owner.Name,
                        RecordType.DeveloperName,
                        RecordType.Name,
                        Start_Date__c,
                        Status__c,
                        Teams_Joined__c,
                        TeamSize__c, (
                        SELECT
                                Id,
                                isResolved__c,
                                Team1__r.Team__r.Player1__c,
                                Team1__r.Team__r.Player2__c,
                                Team2__r.Team__r.Player1__c,
                                Team2__r.Team__r.Player2__c
                        FROM Matches__r
                ), (
                        SELECT
                                Id,
                                Team__c,
                                Team__r.Player1__c, Team__r.Player2__c, Team__r.Name,
                                Team__r.Player1__r.LastName, Team__r.Player1__r.Name, Team__r.Player2__r.LastName,
                                Team__r.Player2__r.Name,
                                GamesWon__c, GamesLost__c, GamesDrawn__c, GoalsFor__c, GoalsAgainst__c, GoalsDraw__c, Points__c,
                                Team__r.Player1__r.ImageUrl__c, Team__r.Player2__r.ImageUrl__c
                        FROM Competitors__r
                        ORDER BY Points__c DESC, GoalsDraw__c DESC, GoalsFor__c DESC, GoalsAgainst__c ASC, Team__r.Name ASC
                )
                FROM BL_Competition__c
                WHERE Id = :competitionId
                LIMIT 1
        ];
    }
}