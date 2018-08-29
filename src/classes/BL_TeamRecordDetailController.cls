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
                WHERE Id =: teamId
        ];
        return teamStatistics.isEmpty() ? new BL_Team__c() : teamStatistics[0];
    }

    @AuraEnabled
    public static List<BL_League__c> getTeamCompetitions(String teamId) {
        List<String> compsIds = new List<String>();
        for (BL_Competitor__c comp : [SELECT Id, League__c FROM BL_Competitor__c WHERE Team__c = :teamId]) {
            compsIds.add(comp.League__c);
        }
        return [SELECT isCup__c, Start_Date__c, End_Date__c, Name FROM BL_League__c WHERE Id IN :compsIds];
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
    public static void savePicture(Id parentId, String fileName, String base64Data, String contentType) {
        List<Attachment> oldAttachments = [SELECT Id FROM Attachment WHERE ParentId=:parentId];
        delete oldAttachments;
        Attachment attachment = new Attachment();
        attachment.parentId = parentId;
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
        attachment.contentType = contentType;
        insert attachment;
    }
}