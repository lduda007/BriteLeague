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
                        Owner.Name,
                        RecordType.DeveloperName,
                        RecordType.Name,
                        Start_Date__c,
                        Status__c,
                        Teams_Joined__c,
                        TeamSize__c,
                (
                        SELECT
                                Id,
                                isResolved__c,
                                Team1__r.Team__r.Player1__c,
                                Team1__r.Team__r.Player2__c,
                                Team2__r.Team__r.Player1__c,
                                Team2__r.Team__r.Player2__c
                        FROM Matches__r
                )
                FROM BL_Competition__c
                WHERE Id = :competitionId
                LIMIT 1
        ];
    }
}