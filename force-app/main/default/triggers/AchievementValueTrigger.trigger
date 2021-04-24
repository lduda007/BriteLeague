trigger AchievementValueTrigger on Achievement_Value__c (before insert, before update) {
    if (Trigger.isBefore) {
        Map<Id, Achievement__c> achievements = new Map<Id, Achievement__c>(AchievementService.getAllAchievements(true));
        for (Achievement_Value__c av : Trigger.new) {
           av.IndexOfValue__c = Math.ceil((Math.log10(av.Value__c)/Math.log10(2)));
           av.ExternalId__c = achievements.get(av.Achievement__c).ExternalID__c+'#'+av.Name;
        }
    }
}