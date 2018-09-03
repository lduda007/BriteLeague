
public with sharing class BL_CreateTeamLookupController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%' + searchKeyWord + '%';
        Id playerId = BL_Utils.getCurrentUser().ContactId;
        List < sObject > returnList = new List < sObject > ();

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery =  'SELECT Id, Name from ' +ObjectName + ' WHERE Name LIKE: searchKey AND Id !=  \'' + playerId + '\' ORDER BY CreatedDate DESC LIMIT 5';
        system.debug(sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}