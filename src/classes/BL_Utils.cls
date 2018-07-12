public with sharing class BL_Utils {
    public static String getBLCommunitySettings(String field){
        BL_CommunitySettings__c communitySettings = BL_CommunitySettings__c.getInstance('BriteLeagueSettings');
        return (String)communitySettings.get(field);
    }
}