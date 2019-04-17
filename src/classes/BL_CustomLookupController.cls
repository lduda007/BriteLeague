public with sharing class BL_CustomLookupController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String additionalFilters) {

        String searchKey = '%' + searchKeyWord + '%';
        Id playerId = BL_Utils.getCurrentUser().ContactId;
        List < sObject > returnList = new List < sObject > ();

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String queryFilters = 'Name LIKE :searchKey ';
        if (String.isEmpty(additionalFilters) == false) {
            queryFilters += ' AND ' + additionalFilters;
        }
        String sQuery = 'SELECT Id, Name from ' + ObjectName + ' WHERE ' + queryFilters + ' ORDER BY CreatedDate DESC LIMIT 5';

        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}