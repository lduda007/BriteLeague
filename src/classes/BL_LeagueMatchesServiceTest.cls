@isTest
private class BL_LeagueMatchesServiceTest {
    @isTest
    static void testMatchGenerationForClassicLeagueEvenNumberOfTeams() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.insertLeague(BL_Constants.LEAGUE_RT_CLASSIC, 1);
        setupData.insertClassicTeamsForLeague(setupData.testLeague.Id, 4);

        Test.startTest();
        BL_LeagueMatchesService.generateMatchesAfterLeagueStarted(setupData.testLeague.Id);
        Test.stopTest();

        List<BL_Match__c> matches = [SELECT Id FROM BL_Match__c];

        System.assertEquals(6, matches.size());
    }

    @isTest
    static void testMatchGenerationForClassicLeagueOddNumberOfTeams() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.insertLeague(BL_Constants.LEAGUE_RT_CLASSIC, 1);
        setupData.insertClassicTeamsForLeague(setupData.testLeague.Id, 5);

        Test.startTest();
        BL_LeagueMatchesService.generateMatchesAfterLeagueStarted(setupData.testLeague.Id);
        Test.stopTest();

        List<BL_Match__c> matches = [SELECT Id FROM BL_Match__c];

        System.assertEquals(10, matches.size());
    }

    @isTest
    static void testMatchGenerationForBattleRoyaleLeague() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.insertLeague(BL_Constants.LEAGUE_RT_BATTLE_ROYALE, 2);

        setupData.insertBattleRoyaleTeamsForLeague(setupData.testLeague.Id, 3, 2);

        Test.startTest();
        BL_LeagueMatchesService.generateMatchesAfterLeagueStarted(setupData.testLeague.Id);
        Test.stopTest();

        List<BL_Match__c> generatedMatches = [SELECT Id, Round__c, Team1__r.Name, Team2__r.Name FROM BL_Match__c];
        System.assertEquals(24, generatedMatches.size());

        Integer roundOneMatches = 0;
        Integer roundTwoMatches = 0;
        for (BL_Match__c match : generatedMatches) {
            if (match.Round__c == 1) {
                roundOneMatches++;
            } else if (match.Round__c == 2) {
                roundTwoMatches++;
            }
        }
        System.assertEquals(12, roundOneMatches);
        System.assertEquals(12, roundTwoMatches);
    }

    class SetupDataClass {
        public BL_League__c testLeague;

        public void insertLeague(String recordTypeDevName, Integer rounds) {
            testLeague = new BL_League__c(
                    RecordTypeId = BL_Utils.getRecordTypeIdByDeveloperName('BL_League__c', recordTypeDevName),
                    Match_No__c = rounds
            );
            insert testLeague;
        }

        public void insertClassicTeamsForLeague(Id leagueId, Integer numberOfTeams) {
            List<BL_Team__c> teams = new List<BL_Team__c>();
            List<BL_Competitor__c> competitors = new List<BL_Competitor__c>();

            for (Integer i = 0; i < numberOfTeams; i++) {
                BL_Team__c team = new BL_Team__c(Name = 'test team ' + i);
                teams.add(new BL_Team__c(Name = 'test team ' + i));
            }
            insert teams;
            for (Integer i = 0; i < numberOfTeams; i++) {
                BL_Competitor__c competitor = new BL_Competitor__c(League__c = leagueId, Team__c = teams[i].Id);
                competitors.add(new BL_Competitor__c(League__c = leagueId, Team__c = teams[i].Id));
            }
            insert competitors;
        }

        public void insertBattleRoyaleTeamsForLeague(Id leagueId, Integer parentTeams, Integer memberTeams) {
            List<BL_Team__c> teams = new List<BL_Team__c>();
            List<BL_TeamMember__c> teamMembers = new List<BL_TeamMember__c>();
            List<BL_Competitor__c> competitors = new List<BL_Competitor__c>();
            Id battleRoyaleTeamRTId = BL_Utils.getRecordTypeIdByDeveloperName('BL_Team__c', BL_Constants.TEAM_RT_BATTLE_ROYALE);

            for (Integer i = 0; i < parentTeams; i++) {
                teams.add(new BL_Team__c(Name = 'test Battle Royale team ' + i, RecordTypeId = battleRoyaleTeamRTId));
            }
            for (Integer j = 0; j < memberTeams*parentTeams; j++) {
                teams.add(new BL_Team__c(Name = 'test team ' + j));
            }

            insert teams;

            System.debug(teams.size());
            for (Integer i = 0; i < parentTeams; i++) {
                for (Integer j = parentTeams + memberTeams * i ; j < parentTeams + memberTeams * (i+1); j++) {
                    teamMembers.add(new BL_TeamMember__c(Team__c = teams[i].Id, Member__c = teams[j].Id));
                }
            }
            insert teamMembers;

            for (Integer i = 0; i < teams.size(); i++) {
                competitors.add(new BL_Competitor__c(League__c = leagueId, Team__c = teams[i].Id));
            }
            insert competitors;
        }
    }
}