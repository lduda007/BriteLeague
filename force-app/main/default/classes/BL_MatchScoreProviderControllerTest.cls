@IsTest
private class BL_MatchScoreProviderControllerTest {

    @IsTest
    static void testClassicLeagueMatchScore() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.insertCompetition(BL_Constants.LEAGUE_RT_LEAGUE);
        setupData.insertClassicTeams();
        setupData.insertCompetitors();
        setupData.insertMatch();

        Test.startTest();
        BL_MatchScoreProviderController.updateMatchScore(
                setupData.testMatch.Id,
                2,
                0,
                new List<Decimal> {10, 10},
                new List<Decimal> {3, 3},
                Datetime.now()
        );
        Test.stopTest();

        setupData.requeryData();

        System.assertEquals(true, setupData.testMatch.isResolved__c);
        System.assertEquals(20, setupData.testCompetitors[0].GoalsFor__c);
        System.assertEquals(6, setupData.testCompetitors[0].GoalsAgainst__c);
        System.assertEquals(2, setupData.testCompetitors[0].RoundsWon__c);
        System.assertEquals(0, setupData.testCompetitors[0].RoundsLost__c);
        System.assertEquals(1, setupData.testCompetitors[0].GamesWon__c);
        System.assertEquals(1, setupData.testCompetitors[1].GamesLost__c);
    }

    @IsTest
    static void testCupMatchScore() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.insertCompetition(BL_Constants.LEAGUE_RT_CUP);
        setupData.insertClassicTeams();
        setupData.insertCompetitors();
        setupData.insertMatch();

        Test.startTest();
        BL_MatchScoreProviderController.updateMatchScore(
                setupData.testMatch.Id,
                2,
                1,
                new List<Decimal> {10, 3, 10},
                new List<Decimal> {3, 10, 3},
                Datetime.now()
        );
        Test.stopTest();

        setupData.requeryData();

        System.assertEquals(true, setupData.testMatch.isResolved__c);
        System.assertEquals(23, setupData.testCompetitors[0].GoalsFor__c);
        System.assertEquals(16, setupData.testCompetitors[0].GoalsAgainst__c);
        System.assertEquals(2, setupData.testCompetitors[0].RoundsWon__c);
        System.assertEquals(1, setupData.testCompetitors[0].RoundsLost__c);
        System.assertEquals(1, setupData.testCompetitors[0].GamesWon__c);
        System.assertEquals(1, setupData.testCompetitors[1].GamesLost__c);
    }

    @IsTest
    static void testBattleRoyaleLeagueMatchScore() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.insertCompetition(BL_Constants.LEAGUE_RT_BATTLE_ROYALE);
        setupData.insertBattleRoyaleAndMemberTeams();
        setupData.insertCompetitors();
        setupData.insertMatch();

        Test.startTest();
        BL_MatchScoreProviderController.updateMatchScore(
                setupData.testMatch.Id,
                2,
                0,
                new List<Decimal> {10, 10},
                new List<Decimal> {3, 3},
                Datetime.now()
        );
        Test.stopTest();

        setupData.requeryData();

        System.assertEquals(true, setupData.testMatch.isResolved__c);
        System.assertEquals(20, setupData.testCompetitors[2].GoalsFor__c);
        System.assertEquals(6, setupData.testCompetitors[2].GoalsAgainst__c);
        System.assertEquals(2, setupData.testCompetitors[2].RoundsWon__c);
        System.assertEquals(0, setupData.testCompetitors[2].RoundsLost__c);
        System.assertEquals(1, setupData.testCompetitors[2].GamesWon__c);
        System.assertEquals(1, setupData.testCompetitors[3].GamesLost__c);
    }

    class SetupDataClass {
        BL_Competition__c testLeague;
        List<BL_Team__c> testTeams = new List<BL_Team__c>();
        List<BL_Competitor__c> testCompetitors = new List<BL_Competitor__c>();
        BL_Match__c testMatch;

        public void insertCompetition(String recordTypeName) {
            testLeague = new BL_Competition__c(
                    Match_No__c = 1,
                    RecordTypeId = BL_Utils.getRecordTypeIdByDeveloperName('BL_Competition__c', recordTypeName)
            );
            insert testLeague;
        }

        public void insertClassicTeams() {
            for(Integer i = 0; i < 2; i++) {
                testTeams.add(new BL_Team__c(
                        Name = 'Test Team ' + i
                ));
            }
            insert testTeams;
        }

        public void insertBattleRoyaleAndMemberTeams() {
            List<BL_TeamMember__c> teamMembers = new List<BL_TeamMember__c>();
            for(Integer i = 0; i < 2; i++) {
                testTeams.add(new BL_Team__c(
                        Name = 'Test Team ' + i
                ));
            }
            for(Integer BRCount = 0; BRCount < 2; BRCount++) {
                testTeams.add(new BL_Team__c(
                        Name = 'Test Team ' + (2 + BRCount),
                        RecordTypeId = BL_Utils.getRecordTypeIdByDeveloperName('BL_Team__c', BL_Constants.TEAM_RT_BATTLE_ROYALE)
                ));
            }
            insert testTeams;
            for(Integer i = 0; i < 2; i++) {
                teamMembers.add(new BL_TeamMember__c(
                        Member__c = testTeams[i].Id,
                        Team__c = testTeams[i + 2].Id
                ));
            }
            insert teamMembers;
        }

        public void insertCompetitors() {
            for(Integer i = 0; i < testTeams.size(); i++) {
                testCompetitors.add(new BL_Competitor__c(
                        Competition__c = testLeague.Id,
                        Team__c = testTeams[i].Id
                ));
            }
            insert testCompetitors;
        }

        public void insertMatch() {
            testMatch = new BL_MatchBuilder()
                    .setCompetition(testLeague.Id)
                    .setTeam1(testCompetitors[0].Id)
                    .setTeam2(testCompetitors[1].Id)
                    .build();
            insert testMatch;
        }

        public void requeryData() {
            testCompetitors = [SELECT Id, GoalsFor__c, GoalsAgainst__c, RoundsLost__c, RoundsWon__c, GamesWon__c, GamesLost__c FROM BL_Competitor__c ORDER BY Team__r.Name ASC];
            testMatch = [SELECT isResolved__c FROM BL_Match__c WHERE Id = :testMatch.Id LIMIT 1];
        }
    }
}