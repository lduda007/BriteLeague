public class BL_DAO_League {

    public BL_League__c getLeagueById(Id leagueId) {
        return [
                SELECT
                        Id,
                        End_Date__c,
                        Max_Teams__c,
                        Name,
                        Owner.Name,
                        RecordType.DeveloperName,
                        RecordType.Name,
                        Start_Date__c,
                        Status__c,
                        Teams_Joined__c,
                        TeamSize__c
                FROM BL_League__c
                WHERE Id = :leagueId
                LIMIT 1
        ];
    }
}