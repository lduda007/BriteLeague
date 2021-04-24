/**
 * @author Mateusz Przywara
 * @date   2016-07-15
 * @description Class test Drag and Drop Component
*/
global class BTN_DragNDropComponentController {
    public string URLForPage{get; set;}
    private static BTN_DAO_Attachment attachmentDAOLayer{set;
        get {
            if (BTN_ValidationHandler.isNull(attachmentDAOLayer)) {
                attachmentDAOLayer = new BTN_DAO_Attachment();
                attachmentDAOLayer.addBodyField();
            }
            return attachmentDAOLayer;
        }
    }
    /**
     * @author Mateusz Przywara
     * @date   2016-06-17
     * @description Constructor sets URL of current Organization. JS will add sObject Id and use it to refresh page.
     */
    public BTN_DragNDropComponentController() {
        URLForPage = ApexPages.currentPage().getHeaders().get('Host');
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-17
     * @description Simple method uploads Attachment to provided sObject(ParrentId).
     * @param  parentId sObject Id supporting attachments
     * @param  attachmentId Id Id of attachment for update.
     * @param  fileName String
     * @param  contentType String Type of content ex. PDF / PNG etc.
     * @param  base64BlobValue String representing Blob. JS remoting does not support Blob.
     * @return              Id Id of Attachment that has been inserted / updated.
     */
    @RemoteAction
    global static String attachBlob(String parentId, String attachmentId, String fileName, String contentType, String
            base64BlobValue) {
        Id result;
        //If recordId is blank this is the first part of a multi piece upload
        if (attachmentId == '' || attachmentId == null){
            Attachment att = new Attachment(
                    ParentId = parentId,
                    Body = EncodingUtil.Base64Decode(base64BlobValue),
                    Name = fileName,
                    ContentType = contentType
            );
            insert att;

            //Return the new attachment Id
            result = att.Id;

        } else {
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
            update new Attachment(
                    Id = attachmentId,
                    Body = EncodingUtil.Base64Decode(
                            EncodingUtil.Base64Encode(
                                    attachmentDAOLayer.findAttachmentById(attachmentId).Body)+ base64BlobValue
                    )
            );
            //Return the Id of the attachment we are currently processing
            result = attachmentId;
        }
        return result;
    }
}