/**
 * @author Dariusz Chmiela
 * @date 2016-08-18
 * @description BTN_OpportunityBuilderHelper test
*/
@isTest
public with sharing class BTN_OpportunityBuilderHelper_Test {
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description test saving Opportunity
    */
    @isTest
    private static void saveOportunityTest(){
        // given
        Opportunity opportunity = BTN_OpportunityBuilderHelper.buildWithTimeMaterialRecordType().get();
        // when
        Test.startTest();
        insert opportunity;
        Test.stopTest();
        // then
    }
    /**
     * @author Dariusz Chmiela
     * @date 2016-08-12
     * @description test saving BTN_ResourceRequest__c with given fields
    */
    @isTest
    private static void saveOpportunityWithGivenFieldsTest(){
        // given
        String name = 'Opportunity ' + System.currentTimeMillis(); // required
        Date closeDate = Date.today().addMonths(1); // required
        String stageName = Opportunity.StageName.getDescribe().getPicklistValues().get(0).value;
        Opportunity opp = BTN_OpportunityBuilderHelper.buildWithTimeMaterialRecordType()
                .withName(name)
                .withStageName(stageName)
                .withCloseDate(closeDate)
                .get();
        Test.startTest();
        insert opp;
        Test.stopTest();
        // then
        System.assertEquals(1, [SELECT
                Id
        FROM Opportunity
        WHERE Name = :name AND StageName = :stageName AND CloseDate = :closeDate LIMIT 3].size());
    }
}