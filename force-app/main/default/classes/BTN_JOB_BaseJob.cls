/**
 * @author Mateusz Przywara
 * @date   2016-08-09
 * @description BTN_JOB_BaseJob Base Class for all Jobs
*/
global virtual class BTN_JOB_BaseJob implements Schedulable {

    public static final Integer MAX_BATCH_JOBS = 5;    // the max number of concurrent jobs
    public static final String RETRY = '-Retry ';
    public static final String REPEAT = '-Repeat ';
    public String jobName;
    public String batchName;
    public Database.Batchable<Object> liveBatch;
    public String classname;
    public Boolean repeatJob = false;
    public Integer repeatIntervalMins = 10;
    public Integer rescheduleIntervalMins = 30;
    public Integer chunkSize = 200;
    public SchedulableContext sc;

	/**
	* @date 26/01/2016
    * @Author Arkadiusz Jezierski
	* @description CanBatchJobRun method - checks to see if there are less than 5 concurrent batch jobs running
	* @return - true - it can run - false it can not run
	*/
    global Boolean canBatchJobRun() {
        return new BTN_DAO_AsyncApexJob().selectCountOfAsyncJobsForStatusAndJobType(
                'BatchApex',
                new Set<String>{
                        'Processing', 'Preparing'
                }
        ) < MAX_BATCH_JOBS;
    }

    /**
	* @date 26/01/2016
    * @Author Arkadiusz Jezierski
	* @description isBatchJobNotAlreadyRunning method - checks if batch is not already running or is in queue
	* @return - true if batch is not running, false in otherwise
	*/
    global Boolean isBatchJobNotAlreadyRunning() {
        return new BTN_DAO_AsyncApexJob().selectCountOfRunningAsyncJobs(this.batchName) == 0;
    }

	/**
	* @date 26/01/2016
    * @Author Arkadiusz Jezierski
	* @description execute method - allows the inherited class override this method which has to be implemented as part of the
	* schedule interface
	* it implements the following logic
	* if the batch job is not already running
	* if the batch job can run ie there are currently less than MAX Jobs - 5 already running
	* execute the batch job
	* else reschedule the job to rerun in 30 mins time - notify the iHCP administrator user
	* finally if we are not rescheduled and repeatJob flag is set
	* repeat the job and abort the current job.
	* @param SchedulableContext sc
	*/
    global virtual void execute(SchedulableContext sc) {
        this.sc = sc;
        Boolean rescheduled = false;
        BTN_LogUtils logger = new BTN_LogUtils(className);
        try {
            if (isBatchJobNotAlreadyRunning()) {
                if (canBatchJobRun()) {
                    Database.executeBatch(liveBatch, chunkSize);
                } else {
                    sendWarningEmailToAdminAndRescheduleJob();
                    rescheduled = true;
                }
            }
            if (!rescheduled && repeatJob) {
                // repeat the job in 10 mins
                repeatJob();
                //abort this job
                tidyUp();
            }
        } catch (Exception e) {
            sendExceptionEmailToAdmin(e.getMessage());
        }
    }

	/**
	* @date 26/01/2016
    * @Author Arkadiusz Jezierski
	* @description rescheduleJob method
	* @param integer minutes
	*/
    global void rescheduleJob(Integer minutes) {
        rescheduleJob(this.jobname + RETRY, minutes);
    }

	/**
	* @date 26/01/2016
    * @Author Arkadiusz Jezierski
    * @description rescheduleJob method
    */
    global void rescheduleJob() {
        rescheduleJob(this.jobname + RETRY, this.rescheduleIntervalMins);
    }

	/**
	* @date 26/01/2016
    * @Author Arkadiusz Jezierski
     * @description rescheduleJob method -used to reschedule the job so that the batch will run later
     * @param string - classname - used to identify the rescheduled job
     * @param integer - Minutes - when the job should be rescheduled
     * @return - void
     */
    protected void rescheduleJob(String name, Integer minutes) {
        Datetime dt = Datetime.now().addminutes(minutes); //  mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        System.Schedule(name + dt.format(), timeForScheduler, this);
    }

	/**
	* @date 26/01/2016
    * @Author Arkadiusz Jezierski
	* @description RepeatJob method -used to reschedule the job so that the batch will run later
	*/
    global void repeatJob(Integer minutes) {
        scheduleJob(this.jobname + REPEAT, minutes);
    }

	/**
	* @date 26/01/2016
    * @Author Arkadiusz Jezierski
	* @description RepeatJob method -used to reschedule the job so that the batch will run later
	*/
    @testVisible
    protected void repeatJob() {
        scheduleJob(this.jobname + REPEAT, RepeatIntervalMins);
    }

	/**
	* @date 26/01/2016
    * @Author Arkadiusz Jezierski
	* @description RepeatJob method -used to reschedule the job so that the batch will run later
	* @param string - classname - used to identify the rescheduled job
	* @param integer - Minutes - when the job should be rescheduled
	*/
    @testVisible
    protected void scheduleJob(String name, Integer minutes) {
        Datetime now = System.Now().addMinutes(minutes);
        //Set a cron trigger expression for the next fire and schedule the class
        String timeForScheduler = '0 ' + now.minute() + ' * * * ?';
        System.schedule(name + now.format(), timeForScheduler, this);
    }

	/**
	* @date 26/01/2016
    * @Author Arkadiusz Jezierski
	* @description TidyUp method -used to abort the current job
	*/
    global void tidyUp() {
        //Get the of the current job and abort itself.
        System.abortJob(this.sc.getTriggerId());
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-05
     * @description sendWarningEmailToAdminAndRescheduleJob
    */
    global void sendWarningEmailToAdminAndRescheduleJob() {
        BTN_Email_Utils.sendWarningEmailToAdmin(
                String.format(
                        System.Label.EmailTemplateJobFailedAndReschedulesSubject,
                        new List<String>{ JobName }
                ),
                System.Label.EmailTemplateJobFailedAndReschedulesBody
        );
        rescheduleJob();
    }

    /**
     * @author Mateusz Przywara
     * @date   2016-09-05
     * @description sendExceptionEmailToAdmin
    */
    global void sendExceptionEmailToAdmin(String excMessage) {
        BTN_Email_Utils.sendWarningEmailToAdmin(
                String.format(
                        System.Label.EmailTemplateJobFailedSubject,
                        new String[]{classname}
                ),
                String.format(
                        System.Label.EmailTemplateJobFailedBody,
                        new String[]{classname, excMessage}
                )
        );
    }
}