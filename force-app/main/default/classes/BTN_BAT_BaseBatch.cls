/**
 * @author Mateusz Przywara
 * @date   2016-08-09
 * @description BTN_BAT_BaseBatch Base Class for all Batches.
 *  Modified sObject - > Object
 *  Start now return Iterable<Object>
*/
global virtual class BTN_BAT_BaseBatch implements Database.Batchable<Object>, Database.Stateful {
    private Double updates { get; set; }
    private Double numberOfRecords { get; set; }
    private Double newValues { get; set; }
    private Double failed { get; set; }
    private String successMessage { get; set; }
    private String errorMessageExtension { get; set; }
    private Map<Id, String> errorIds;
    public List<string> batchErrors = new List<string>();
    public Integer limitRecords = 10000000;
    public String emailMessage;

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description GSD_BAT_BaseBatch constructor  - initialises variables
    */
    global BTN_BAT_BaseBatch() {
        updates = 0;
        failed = 0;
        numberOfRecords = 0;
        newValues = 0;
        successMessage = null;
        errorMessageExtension = null;
        errorIds = new Map<Id, String>();
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description GSD_BAT_BaseBatch constructor  - initialises variables
    * @param Integer nRecords - limits the number of records in the query used for testing
    */
    global BTN_BAT_BaseBatch(Integer nRecords) {
        limitRecords = nRecords;
        updates = 0;
        failed = 0;
        newValues = 0;
        numberOfRecords = 0;
        errorIds = new Map<Id, String>();
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description setFailedUpdates method  - increases number of failed updates
    */
    global void addUpdates() {
        updates++;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-09
     * @description addNewValues Adds 1 to Update from null to value Counter
    */
    global void addNewValues() {
        newValues++;
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-08-09
     * @description failed Adds 1 to failed Counter
    */
    global void addFailed() {
        failed++;
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description clearFailedUpdates method  - clears number of failed updates
    */
    global void clearUpdates() {
        updates = 0;
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description addNumberOfRecords method  - increases number of records
    */
    global void addNumberOfRecords() {
        numberOfRecords++;
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description clearNumberOfRecords method  - clears number of records
    */
    global void clearNumberOfRecords() {
        numberOfRecords = 0;
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description setSuccessMessage method  - set success message for printing in email
    * @param String msg - success message
    */
    global void setSuccessMessage(String msg) {
        successMessage = msg;
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description setErrorMessageExtension method  - set error message for printing in email
    * @param String msg - error message
    */
    global void setErrorMessageExtension(String msg) {
        errorMessageExtension = msg;
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description addErrorObjectId method  - save id of error record
    * @param Id objId - id of error object
    */
    global void addErrorObjectId(Id objId) {
        errorIds.put(objId, '');
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description addErrorObjectIdWithMessage method  - save id of error record with message
    * @param Id objId - id of error object
    * @param  String msg - additional message
    */
    global void addErrorObjectIdWithMessage(Id objId, String msg) {
        errorIds.put(objId, msg);
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description addError method - add database rror
    * @param Database.SaveResult dbError - database error
    */
    global void addError(Database.SaveResult dbError) {
        for (Database.error error: dbError.getErrors()) {
            errorIds.put(dbError.getId(), error.getMessage());
        }
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description start method  base method to allow other classes to override this - no functionality
    * @param Database.batchableContext bc
    * @return null
    */
 /*   global virtual Database.QueryLocator start(Database.batchableContext bc) {
        return null;
    } */


    /**
    * @author Mateusz Przywara
    * @date   2016-08-18
    * @description start
    * @param Database.batchableContext
    * @param System.Iterable<Object>
    */
    global virtual Iterable<Object> start(Database.batchableContext bc) {
        return null;
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description execute method  base method to allow other classes to override this -  no functionality
    * @param Database.BatchableContext BC
    * @param List<SObject> scope
    */
    global virtual void execute(Database.BatchableContext BC, List<Object> scope) {
    }

    /**
    * @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description finish method  base method - sends email on completion of batch on with errors and also information to internal log
    * @param Database.BatchableContext ctx
    */
    global virtual void finish(Database.BatchableContext ctx) {
        AsyncApexJob apexJob = new BTN_DAO_AsyncApexJob().selectAsyncJobForId(ctx.getJobId());
        ApexClass batchApexClass = apexJob.ApexClass;
        BTN_LogUtils logger = new BTN_LogUtils(batchApexClass.name);

        if (apexJob.NumberOfErrors > 0 || updates > 0) {

            emailMessage = buildEmailMessage(batchApexClass.name, apexJob);

            logger.info(emailMessage, apexJob.Id);

            if (batchErrors.size() > 0) {
                logger.warning('Warning', apexJob.id, batchErrors);
                emailMessage += 'The Errors were :\n';
            }
            for (String s: batchErrors) {
                emailMessage = emailMessage + s + '\n';
            }

            if (errorIds.size() > 0) {
                emailMessage += 'ID list of wrong objects:\n';

                for (Id objId : errorIds.keySet()) {
                    emailMessage += 'ID [' + objId + '] ' + errorIds.get(objId) + '\n';
                    logger.warning('Id of element caused error: ' + objId, apexJob.id);
                }
            }

            if (errorMessageExtension != null) {
                emailMessage += errorMessageExtension;
            }
            sendEmailToAdmin(batchApexClass.name);
        } else if (successMessage != null) {

        }

        logger.info('Base batch finished', apexJob.Id);
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-05
     * @description sendExceptionEmailToAdmin
    */
    global void sendEmailToAdmin(String className) {
        BTN_Email_Utils.sendWarningEmailToAdmin (
                String.format(
                        System.Label.EmailTemplateBatchSuccessSubject,
                        new String[]{ className }
                ),
                emailMessage
        );
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-05
     * @description buildEmailMessage
    */
    global String buildEmailMessage(String className, AsyncApexJob apexJob) {
        return String.format(
                System.Label.EmailTemplateBatchSuccessSubject,
                new String[] {
                        className,
                        String.valueOf(apexJob.TotalJobItems),
                        String.valueOf(apexJob.JobItemsProcessed),
                        String.valueOf(apexJob.NumberOfErrors),
                        String.valueOf(numberOfRecords),
                        String.valueOf(newValues),
                        String.valueOf(updates),
                        String.valueOf(failed)
                }
        );
    }}