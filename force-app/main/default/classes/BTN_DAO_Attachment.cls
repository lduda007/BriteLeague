/**
 * @author Mateusz Przywara
 * @date   2016-07-12
 * @description DAO class - Data Access Object for Attachment
*/
public class BTN_DAO_Attachment extends BTN_DAO {
   /**
     * @author Mateusz Przywara
     * @date   2016-07-12
     * @description Constructor
    */
    public BTN_DAO_Attachment() {
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-07-12
     * @description Constructor setting custom List of fields
    */
    public BTN_DAO_Attachment(List<Schema.SObjectField> customFields) {
        setCustomFields(customFields);
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description find Attachment
         * @param  attachmentName - Name of Attachment to search for
         * @return     Attachment       - found Attachment
         */
    public Attachment findAttachmentById(Id attachmentId) {
        return (Attachment) findSObjectById(attachmentId);
    }


        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description find Attachments to provided Parent Id
         * @param find Attachments to provided Parent Id
         * @return List<Attachment> found Attachments
        */
    public List<Attachment> findAttachmentsByParentId(Id parentId) {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('ParentId', '=', parentId)
                }
        );
    }

    public override Schema.SObjectType getSObjectType() {
        return Attachment.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                Attachment.Id,
                Attachment.ParentId,
                Attachment.Name
        };
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description add Body field to Query
         * @return void
        */
    public void addBodyField() {
        currentFields.add('Body');
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description add Parent Name to Query
         * @return void
        */
    public void addParentNameField() {
        currentFields.add('Parent.Name');
    }
    
        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description find Attachments to provided list of sObjects
         * @param find Attachments to provided list of sObjects
         * @return List<Attachment> - found Attachments
        */
    public List<Attachment> findAttachmentsByParents(Set<Id> setOfSObjectIds) {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('ParentId', 'IN', setOfSObjectIds)
                }
        );
    }

}