public class BL_ImageController {

    @AuraEnabled
    public static String getImageLink(Id parentId, String fileName) {
        List<Attachment> attachments = [
                SELECT Id
                FROM Attachment
                WHERE ParentId = :ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif')
                AND Name = :fileName
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ];

        return attachments.isEmpty()
                ? BL_BriteLeagueSettings__c.getOrgDefaults().Default_Image_URL__c
                : '/servlet/servlet.FileDownload?file=' + attachments[0].Id;
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