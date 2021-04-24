@isTest
private class BL_MatchScoreServiceTest {
    @isTest
    static void testSetScoresForTeams() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.createCompetitors();

        Test.startTest();
        BL_MatchScoreService scoreService = new BL_MatchScoreService();
        scoreService.setScoresForTeams(setupData.competitor1, setupData.competitor2, 2, 0, new List<Decimal>{10, 10}, new List<Decimal>{5, 3});
        Test.stopTest();

        System.assertEquals(2, setupData.competitor1.RoundsWon__c);
        System.assertEquals(2, setupData.competitor2.RoundsLost__c);
        System.assertEquals(1, setupData.competitor1.GamesWon__c);
        System.assertEquals(1, setupData.competitor2.GamesLost__c);
        System.assertEquals(20, setupData.competitor1.GoalsFor__c);
        System.assertEquals(20, setupData.competitor2.GoalsAgainst__c);
        System.assertEquals(8, setupData.competitor2.GoalsFor__c);
        System.assertEquals(8, setupData.competitor1.GoalsAgainst__c);
    }

    class SetupDataClass {
        public BL_Competitor__c competitor1;
        public BL_Competitor__c competitor2;

        public void createCompetitors() {
            competitor1 = new BL_Competitor__c(
                    GamesWon__c = 0,
                    GamesDrawn__c = 0,
                    GamesLost__c = 0,
                    GoalsAgainst__c = 0,
                    GoalsFor__c = 0,
                    RoundsLost__c = 0,
                    RoundsWon__c = 0
            );
            competitor2 = new BL_Competitor__c(
                    GamesWon__c = 0,
                    GamesDrawn__c = 0,
                    GamesLost__c = 0,
                    GoalsAgainst__c = 0,
                    GoalsFor__c = 0,
                    RoundsLost__c = 0,
                    RoundsWon__c = 0
            );
        }
    }
}