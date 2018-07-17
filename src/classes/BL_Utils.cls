public with sharing class BL_Utils {
    private static User CURRENT_USER = getCurrentUser();

    public static User getCurrentUser() {
        if(CURRENT_USER == null || CURRENT_USER.Id != UserInfo.getUserId()){
            CURRENT_USER = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        }
        return CURRENT_USER;
    }

    public static String getBLCommunitySettings(String field){
        BL_CommunitySettings__c communitySettings = BL_CommunitySettings__c.getInstance('BriteLeagueSettings');
        return (String)communitySettings.get(field);
    }

    public static List<BL_Competitor__c> getLeagueCompetitors(String leagueId){
        List<BL_Competitor__c> competitors = [
            SELECT Id, Team__c, Team__r.Player1__c, Team__r.Player2__c
            FROM BL_Competitor__c
            WHERE League__c =: leagueId
        ];
        return competitors;
    }
}