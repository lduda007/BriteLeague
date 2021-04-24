/**
 * @author Mateusz Przywara
 * @date   2016-07-15
 * @description Class test Drag and Drop Component
*/
@isTest
private class BTN_DragNDropComponentController_Test {
    private static final String BLOB_PART_FIRST = 'This text re';
    private static final String BLOB_PART_SECOND = 'presents a dummy file';
    private static final String TEST_FILENAME = 'fileName';
    private static final String TEST_TEXT = 'text';

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description Prepare data for tests
     * Modified 2016-10-28 CPU time limit problems with createDataStructureForBriteRM()
    */
    @testSetup static void createDataStructure() {
        //BTN_TestDataFactory.createDataStructureForBriteRM();
        BTN_TestDataFactory.getBriteNetAccount();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-17
     * @description Test Attachment Upload to Private Account by RM.
    */
    static testMethod void testAttachmentUploadIsCorrect() {
        BTN_DAO_Attachment attachmentDAO = new BTN_DAO_Attachment();
        attachmentDAO.addBodyField();
        //Split string 'file' in to two chunks, first chunk must be divisible by 3 for base64 encode with no padding
        Blob part1 = Blob.valueOf(BLOB_PART_FIRST); //length is 12
        Blob part2 = Blob.valueOf(BLOB_PART_SECOND);

        String part1base64 = EncodingUtil.base64Encode(part1);
        String part2base64 = EncodingUtil.base64Encode(part2);

        //BTN_ResourceRequest__c rr = BTN_ResourceRequestBuilderHelper.buildWithManualRecordType().get();
        System.RunAs(BTN_TestDataFactory.USER_MAP_BY_PROFILE.get(BTN_ConstantRepo.RESOURCE_MANAGER_PROFILE_NAME)) {
            //Retrieve a test accound the 'file' can be attached to.

            Account acct = new Account(RecordTypeId = BTN_RecordTypeUtils.getRecordTypeAccountPrivateSector().Id, Name = 'Test');
            insert acct;

            //insert rr;
            //Start the test
            Test.startTest();
            //Send first part of the file to be uploaded
            String attachmentId = BTN_DragNDropComponentController.attachBlob(acct.Id, '', TEST_FILENAME, TEST_TEXT,
                    part1base64);

            //Send the second piece of the file to be uploaded
            BTN_DragNDropComponentController.attachBlob(acct.Id, attachmentId, TEST_FILENAME, TEST_TEXT, part2base64);
            Test.stopTest();

            //Assert one file has been attached to the test account
            List<Attachment> attachments = attachmentDAO.findAttachmentsByParentId(acct.Id);
            System.assertEquals(1, attachments.size());

            //Assert the contents of the split file were recontructed correctly
            System.assertEquals(BLOB_PART_FIRST + BLOB_PART_SECOND, attachments[0].Body.toString());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-06-17
     * @description Test Construction process of DragNDrop Controller.
    */
    static testMethod void testDragNDropComponentControllerContructor() {
        System.RunAs(BTN_TestDataFactory.USER_MAP_BY_PROFILE.get(BTN_ConstantRepo.RESOURCE_MANAGER_PROFILE_NAME)) {
            BTN_DragNDropComponentController controller = new BTN_DragNDropComponentController();
            System.assertEquals(
                    ApexPages.currentPage().getHeaders().get(
                            BTN_ConstantRepo.HOST_PARAMETER_NAME), controller.URLForPage);
        }
    }
}