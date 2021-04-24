/**
 * @author Mateusz Przywara
 * @date   2016-09-02
 * @description BTN_BAT_BaseBatch_Test Test class for Batch Base
 */
@isTest
private class BTN_BAT_BaseBatch_Test {
    private static final Integer N_RECORDS = 20;
    private static final String SUCCESS_MSG = 'Success';
    private static final String SUCCESS_MSG_EXTENSION = 'SuccessExt';
    private static final String CLASS_NAME = 'BTN_BAT_BaseBatch_Test';

    /**
     * @author Mateusz Przywara
     * @date   2016-07-15
     * @description Prepare data for tests
     *  Be careful with adding data assiociated with workflows, flows etc.
     *  It may cause CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
     */
    @testSetup static void createDataStructure() {
        Test.startTest();
        BTN_TestDataFactory.getBriteNetAccount();
        Test.stopTest();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-02
     * @description testBaseBatchConstructorWithLimitRecords Constructs Base Batch
     */
    @isTest static void testBaseBatchConstructorWithLimitRecords() {
        BTN_BAT_BaseBatch baseBatchObj = new BTN_BAT_BaseBatch(N_RECORDS);
        System.assertEquals(N_RECORDS, baseBatchObj.limitRecords);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-02
     * @description testBaseBatchConstructor Constructs Base Batch
     */
    @isTest static void testBaseBatchConstructor() {
        BTN_BAT_BaseBatch baseBatchObj = new BTN_BAT_BaseBatch();
        System.assertEquals(10000000, baseBatchObj.limitRecords);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-02
     * @description testStartVirtualMethod Test Empty Start Method
     */
    @isTest static void testStartVirtualMethod() {
        BTN_BAT_BaseBatch baseBatchObj = new BTN_BAT_BaseBatch();
        System.assertEquals(null, baseBatchObj.start(null));
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-02
     * @description testAddingUpdateToStats
     */
    @isTest static void testAddingUpdateToStats() {
        BTN_BAT_BaseBatch baseBatchObj = new BTN_BAT_BaseBatch(N_RECORDS);
        baseBatchObj.addUpdates();
        baseBatchObj.addNewValues();
        baseBatchObj.addFailed();
        baseBatchObj.addNumberOfRecords();
        baseBatchObj.setSuccessMessage(SUCCESS_MSG);
        baseBatchObj.setErrorMessageExtension(SUCCESS_MSG_EXTENSION);

        Id objectId = new BTN_DAO_Account().findAccountByName(BTN_ConstantRepo.BRITENET_ACCOUNT_NAME).Id;
        baseBatchObj.addErrorObjectId(objectId);
        baseBatchObj.addErrorObjectIdWithMessage(objectId, SUCCESS_MSG);

        baseBatchObj.clearUpdates();
        baseBatchObj.clearNumberOfRecords();

        baseBatchObj.emailMessage = baseBatchObj.buildEmailMessage(CLASS_NAME, new AsyncApexJob());
        baseBatchObj.sendEmailToAdmin(CLASS_NAME);

        //System.assertEquals(1, baseBatchObj.updates);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-05
     * @description testExecution
     */
    @isTest static void testExecution() {
        Test.startTest();
        Database.executeBatch(new BTN_BAT_Assignment());
        Test.stopTest();
    }
}