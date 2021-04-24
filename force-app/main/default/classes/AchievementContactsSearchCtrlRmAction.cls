public with sharing class AchievementContactsSearchCtrlRmAction {

     @RemoteAction
     public static Map<String, List<AchievementContactsSearchController.Option>> getOptions() {
        return AchievementContactsSearchController.getOptions();
     }

     @RemoteAction
     public static List<Achievement_Set__c> search(AchievementContactsSearchController.SearchCriteria criteria) {
        return AchievementContactsSearchController.search(criteria);
     }
}