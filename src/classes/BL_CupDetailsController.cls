
public with sharing class BL_CupDetailsController {
    @AuraEnabled
    public static BL_League__c loadCupDetails(String cupId) {
        List<BL_League__c> cup = [
                SELECT Id, Name, Start_Date__c, End_Date__c, Match_No__c, Max_Teams__c,Teams_Joined__c, isPrivate__c, CreatedBy.Name, isStarted__c, OwnerId
                FROM BL_League__c
                WHERE Id =: cupId
        ];
        return cup.size() > 0 ? cup[0] : new BL_League__c();
    }

    @AuraEnabled
    public static Map<Decimal, List<BL_Match__c>> loadCupRoundToMatchesMap(String cupId) {
        List<BL_Match__c> cupMatches = [
                SELECT Id, Name, Team1__r.Team__c, Team2__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__r.Name, CupStage__c, Team1_Score__c, Team2_Score__c
                FROM BL_Match__c
                WHERE League__c =: cupId
        ];
        Map<Decimal, List<BL_Match__c>> roundToMatchMap = new Map<Decimal, List<BL_Match__c>>();
        for(BL_Match__c match : cupMatches){
            if(roundToMatchMap.keySet().contains(match.CupStage__c)){
                roundToMatchMap.get(match.CupStage__c).add(match);
            }else{
                List<BL_Match__c> roundMatchesList = new List<BL_Match__c>();
                roundMatchesList.add(match);
                roundToMatchMap.put(match.CupStage__c, roundMatchesList);
            }
        }
        return roundToMatchMap;
    }

    @AuraEnabled
    public static BL_League__c startCupNow(String cupId) {
        BL_League__c cup = loadCupDetails(cupId);
        System.debug(cup);

        if(cup == null || cup.isStarted__c){
            throw new AuraHandledException('Cup already started');
        }
        try{
            cup.Start_Date__c = Date.today();
            cup.isStarted__c = true;
            update cup;
            BL_CupMatchesService.generateMatchesAfterCupStarted(cupId);
            return cup;
        }catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug(e.getDmlMessage(i));
            }
            throw new AuraHandledException('Cannot start cup');
        }
    }

    @AuraEnabled
    public static String getCurrentUserId() {
        return UserInfo.getUserId();
    }
}