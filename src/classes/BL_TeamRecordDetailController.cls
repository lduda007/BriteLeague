public with sharing class BL_TeamRecordDetailController {
    @AuraEnabled
    public static String getUserContactId() {
        return BL_Utils.getCurrentUser().ContactId;
    }

    @AuraEnabled
    public static BL_Team__c loadTeamStatistics(String teamId) {
        List<BL_Team__c> teamStatistics = [
                SELECT Id, Total_Games_Won__c, Total_Games_Drawn__c, Total_Games_Lost__c, Total_Goals_Scored__c, Total_Goals_Lost__c, TotalRoundsWon__c, TotalRoundsLost__c
                FROM BL_Team__c
                WHERE Id = :teamId
        ];
        return teamStatistics.isEmpty() ? new BL_Team__c() : teamStatistics[0];
    }

    @AuraEnabled
    public static List<BL_League__c> getTeamCompetitions(String teamId) {
        List<String> compsIds = new List<String>();
        for (BL_Competitor__c comp : [SELECT Id, League__c FROM BL_Competitor__c WHERE Team__c = :teamId]) {
            compsIds.add(comp.League__c);
        }
        return [
                SELECT RecordType.DeveloperName, Start_Date__c, End_Date__c, Name
                FROM BL_League__c
                WHERE Id IN :compsIds
        ];
    }

    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {
        List<Attachment> att = [
                SELECT Id, Name, LastModifiedDate, ContentType
                FROM Attachment
                WHERE parentid = :ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif')
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ];
        if(att.size() > 0) {
            return att[0];
        } else return new Attachment();
    }

    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        try {
            if(String.isBlank(fileId)) {
                fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            } else {
                appendToFile(fileId, base64Data);
            }
        } catch(Exception e) {
            String uiMessage = 'An error occurred during saving the file: ' + e.getMessage();
            BL_Utils.throwAuraHandledException(uiMessage, uiMessage + ' ' + e.getStackTraceString());
        }
        return Id.valueOf(fileId);
    }

    private static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        delete [SELECT Id FROM Attachment WHERE ParentId = :parentId];

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment a = new Attachment(
                ParentId = parentId,
                Name = fileName,
                Body = EncodingUtil.base64Decode(base64Data),
                ContentType = contentType
        );
        insert a;
        return a.Id;
    }

    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment a = [
                SELECT Id, Body
                FROM Attachment
                WHERE Id = :fileId
        ];

        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        update a;
    }
}