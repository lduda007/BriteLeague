/**
 * @author Mateusz Przywara
 * @date   2016-07-12
 * @description DAO class - Data Access Object for AsyncApexJob
*/
public class BTN_DAO_AsyncApexJob extends BTN_DAO {

  /**
     * @author Mateusz Przywara
     * @date   2016-07-12
     * @description Constructor
    */
    public BTN_DAO_AsyncApexJob() {
        currentFields.add('ApexClass.Name');
    }

    public override Schema.SObjectType getSObjectType() {
        return AsyncApexJob.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFields() {
        return new List<Schema.SObjectField>{
                AsyncApexJob.Id,
                AsyncApexJob.ApexClassId,
                AsyncApexJob.NumberOfErrors,
                AsyncApexJob.JobItemsProcessed,
                AsyncApexJob.TotalJobItems,
                AsyncApexJob.Status
        };
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-07-12
         * @description find AsyncApexJobs
         * @param  statusSet - Set of Statuses
         * @return     List<AsyncApexJob>       - found AsyncApexJobs
        */
    public List<AsyncApexJob> findAsyncApexJobsByStatus(Set<String> statusSet) {
        return findSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('Status', 'IN', statusSet)
                }
        );
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-09
         * @description  selectCountOfAsyncJobsForStatusAndJobType
         * @param  jobType - JobType value
         * @param  statusSet - Set of Statuses
         * @return     Integer
        */
    public Integer selectCountOfAsyncJobsForStatusAndJobType(String jobType, Set<String> jobStatusList) {
        return countSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('JobType', '=', jobType),
                        new SearchCondition('AND Status', 'IN', jobStatusList)
                }
        );
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-09
         * @description  selectCountOfRunningAsyncJobs
         * @param  jobName - ApexClass.Name determinated ScheduledJob
         * @return     Integer
        */
    public Integer selectCountOfRunningAsyncJobs(String jobName) {
        return countSObjectsBy(
                new List<SearchCondition>{
                        new SearchCondition('NumberOfErrors', '=', 0),
                        new SearchCondition('AND Status', 'IN', new Set<String>{'Processing', 'Queued'}),
                        new SearchCondition('AND ApexClass.Name', '=', jobName)
                }
        );
    }

        /**
         * @author Mateusz Przywara
         * @date   2016-08-09
         * @description  selectAsyncJobForId
         * @param  jobId - Id of AsyncApexJob
         * @return     AsyncApexJob Found AsyncApexJob
        */
    public AsyncApexJob selectAsyncJobForId(Id jobId) {
        return (AsyncApexJob) findSObjectById(jobId);
    }
}