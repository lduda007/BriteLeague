public with sharing class BL_LeaveCompetitionController {
    @AuraEnabled
    public static String removeCompetitorFromCompetition(String playerId, String competitionId) {
        List<BL_Competitor__c> competitor = [
            SELECT Id
            FROM BL_Competitor__c
            WHERE League__c =: competitionId AND (Team__r.Player1__c =: playerId OR Team__r.Player2__c =: playerId)
        ];
        try{
            delete competitor;
            return Label.BL_Success;
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
            throw new AuraHandledException(Label.BL_Error_When_Leaving_Competition);
        }
    }
}