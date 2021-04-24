/**
 * @author Mateusz Przywara
 * @date   2016-09-02
 * @description BTN_JOB_BaseJob_Test Test Class for Job Base
*/
@isTest
private class BTN_JOB_BaseJob_Test {
    private static final String JOB_NAME = 'TestJob';
    private static final Set<String> JOB_STATUS = new Set<String>{'Completed', 'Queued'};
    private static final String HOUR = String.valueOf(Datetime.now().hour());
    private static final String MIN = String.valueOf(Datetime.now().minute());
    private static final String SEK = String.valueOf(Datetime.now().second());
    private static final String CRON_FIRE_TIME = SEK + ' ' + MIN + ' ' + HOUR + ' * * ?';
    private static final String EXCEPTION_MSG = 'Error has been done';

    /**
     * @author Mateusz Przywara
     * @date   2016-09-05
     * @description testTidyUpMethod
    */
    @isTest static void testTidyUpMethod() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_JOB_BaseJob baseJobInstance = new BTN_JOB_BaseJob();
            baseJobInstance.repeatJob = true;
            Test.startTest();
            System.schedule(
                    'Job Started At ' + String.valueOf(Datetime.now()),
                    CRON_FIRE_TIME,
                    baseJobInstance
            );
            System.schedule(
                    'Job 2 Started At ' + String.valueOf(Datetime.now()),
                    CRON_FIRE_TIME,
                    baseJobInstance
            );
            Test.stopTest();

            System.assertEquals(2, new BTN_DAO_AsyncApexJob().findAsyncApexJobsByStatus(JOB_STATUS).size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-05
     * @description testRepeatMethod
    */
    @isTest static void testRepeatMethod() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_JOB_BaseJob baseJobInstance = new BTN_JOB_BaseJob();
            Test.startTest();
            System.schedule(
                    'Job Started At ' + String.valueOf(Datetime.now()),
                    CRON_FIRE_TIME,
                    baseJobInstance
            );
            Test.stopTest();
            baseJobInstance.repeatJob();
            System.assertEquals(2, new BTN_DAO_AsyncApexJob().findAsyncApexJobsByStatus(JOB_STATUS).size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-05
     * @description testTidyUpMethod
    */
    @isTest static void testScheduleMethod() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_JOB_BaseJob baseJobInstance = new BTN_JOB_BaseJob();
            baseJobInstance.scheduleJob(JOB_NAME, 15);
            System.assertEquals(1, new BTN_DAO_AsyncApexJob().findAsyncApexJobsByStatus(JOB_STATUS).size());
        }
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-05
     * @description testSendEmailToAdminMethod Tests send email methods
    */
    @isTest static void testSendEmailToAdminMethod() {
        System.RunAs(BTN_Utils.getCurrentUser()) {
            BTN_JOB_BaseJob baseJobInstance = new BTN_JOB_BaseJob();
            baseJobInstance.sendExceptionEmailToAdmin(EXCEPTION_MSG);
            baseJobInstance.sendWarningEmailToAdminAndRescheduleJob();
            // Job has been scheduled due to Warning
            System.assertEquals(1, new BTN_DAO_AsyncApexJob().findAsyncApexJobsByStatus(JOB_STATUS).size());
        }
    }
}