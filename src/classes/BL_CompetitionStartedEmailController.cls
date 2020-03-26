
public with sharing class BL_CompetitionStartedEmailController {
    public Id recordId {get; set {initializeCompetitorDetails(value);}}
    public String competitionUrl {get; set;}
    public BL_Competitor__c competitor {get; set;}

    private void initializeCompetitorDetails(String competitorId){
        List<BL_Competitor__c> competitors = [
                SELECT Id, Team__r.Name, GoalsFor__c, GoalsAgainst__c, Points__c, Competition__r.Name, Competition__c,
                        Competition__r.End_Date__c, Competition__r.RecordType.DeveloperName, Competition__r.TeamSize__c
                FROM BL_Competitor__c
                WHERE Id =: competitorId
        ];
        if(!competitors.isEmpty()){
            competitor = competitors[0];
            competitionUrl = BL_Utils.getBLCommunityUrl('League Page');
        }
    }
}