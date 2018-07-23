public with sharing class BL_MatchScoreProviderController {

    @AuraEnabled
    public static void updateMatchScore(String matchId){

    }
    @AuraEnabled
    public static void updateCompetitorStatistics(String matchId, String changedFields){
        ValuesMap nazwa = (ValuesMap)JSON.deserialize(changedFields, ValuesMap.class);
        system.debug(nazwa);
        system.debug('match Id: '+matchId);
        Integer team1goalsFor;
        Integer team1goalsAgainst;
        Integer team1gamesWon;
        Integer team1gamesLost;
        Integer team1draws;
//        Integer team2goalsFor;
        Integer team2goalsAgainst;
        Integer team2gamesWon;
        Integer team2gamesLost;
        Integer team2draws;
        system.debug('changed fields string: '+changedFields);
        List<BL_Match__c> match = [SELECT id, Team1__c, Team2__c,
                                    Team1__r.GoalsFor__c,Team1__r.GoalsAgainst__c,Team1__r.GamesWon__c,Team1__r.GamesLost__c,Team1__r.GamesDrawn__c,
                                    Team2__r.GoalsFor__c,Team2__r.GoalsAgainst__c,Team2__r.GamesWon__c,Team2__r.GamesLost__c,Team2__r.GamesDrawn__c
                                    FROM BL_Match__c WHERE id=:matchId];

        system.debug(match[0].Team2__r.GoalsFor__c);

//        system.debug('given changedFields: '+changedFields.Team1Round1Goals__c);
//        Map<String, Object> changedFieldsMap = (Map<String, Object>)JSON.deserializeUntyped(changedFields);
//        system.debug('keyset: '+changedFieldsMap.keySet());
//
//        Map<String, Object> team1goalsForMap = (Map<String,Object>)changedFieldsMap.get('Team1TotalGoalsScored__c');
//        Map<String, Object> team2GoalsFor = (Map<String,Object>)changedFieldsMap.get('Team2TotalGoalsScored__c');
//        system.debug('old value for team2 goals for: '+ team2GoalsFor.get('oldValue'));

//        Map<String, Object> m2 = (Map<String,Object>)changedFieldsMap.get('Team1Round1Goals__c');
//        system.debug(m2);
//        system.debug(m2.get('oldValue'));





    }
    public class Values{
        Integer oldValue;
        Integer value;
    }
    public class ValuesMap{
        Map<String, Values> valuesmap;
    }

}