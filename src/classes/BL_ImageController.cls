public class BL_ImageController {

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