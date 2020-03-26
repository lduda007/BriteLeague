@isTest
private class BL_MatchServiceTest {

    @isTest
    static void testMatchGenerationForClassicCompetitionEvenNumberOfTeams() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.testCompetition = setupData.insertCompetition(BL_Constants.LEAGUE_RT_CLASSIC, 1);
        setupData.insertClassicTeamsForLeague(setupData.testCompetition.Id, 4);

        Test.startTest();
        BL_MatchService.generateMatches(setupData.testCompetition.Id);
        Test.stopTest();

        List<BL_Match__c> matches = [SELECT Id FROM BL_Match__c];

        System.assertEquals(6, matches.size());
    }

    @isTest
    static void testMatchGenerationForClassicCompetitionOddNumberOfTeams() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.testCompetition = setupData.insertCompetition(BL_Constants.LEAGUE_RT_CLASSIC, 1);
        setupData.insertClassicTeamsForLeague(setupData.testCompetition.Id, 5);

        Test.startTest();
        BL_MatchService.generateMatches(setupData.testCompetition.Id);
        Test.stopTest();

        List<BL_Match__c> matches = [SELECT Id FROM BL_Match__c];

        System.assertEquals(10, matches.size());
    }

    @isTest
    static void testClassicGenerationForMultipleRounds() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.testCompetition = setupData.insertCompetition(BL_Constants.LEAGUE_RT_CLASSIC, 5);
        setupData.insertClassicTeamsForLeague(setupData.testCompetition.Id, 2);

        Test.startTest();
        BL_MatchService.generateMatches(setupData.testCompetition.Id);
        Test.stopTest();

        List<BL_Match__c> matches = [SELECT Id, Team1__c, Team2__c FROM BL_Match__c ORDER BY Round__c];

        System.assertEquals(5, matches.size());

        Id team1Id = matches[0].Team1__c;
        Id team2Id = matches[0].Team2__c;

        System.assertEquals(team2Id, matches[1].Team1__c);
        System.assertEquals(team1Id, matches[2].Team1__c);
        System.assertEquals(team2Id, matches[3].Team1__c);
        System.assertEquals(team1Id, matches[4].Team1__c);
    }

    @isTest
    static void testBattleRoyaleGenerationForMultipleRounds() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.testCompetition = setupData.insertCompetition(BL_Constants.LEAGUE_RT_BATTLE_ROYALE, 5);
        setupData.insertBattleRoyaleTeamsForLeague(setupData.testCompetition.Id, 2, 1);

        Test.startTest();
        BL_MatchService.generateMatches(setupData.testCompetition.Id);
        Test.stopTest();

        List<BL_Match__c> matches = [SELECT Id, Team1__c, Team2__c FROM BL_Match__c ORDER BY Round__c];

        System.assertEquals(5, matches.size());

        Id team1Id = matches[0].Team1__c;
        Id team2Id = matches[0].Team2__c;

        System.assertEquals(team2Id, matches[1].Team1__c);
        System.assertEquals(team1Id, matches[2].Team1__c);
        System.assertEquals(team2Id, matches[3].Team1__c);
        System.assertEquals(team1Id, matches[4].Team1__c);
    }

    @isTest
    static void testMatchGenerationForBattleRoyaleLeague() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.testCompetition = setupData.insertCompetition(BL_Constants.LEAGUE_RT_BATTLE_ROYALE, 2);

        setupData.insertBattleRoyaleTeamsForLeague(setupData.testCompetition.Id, 3, 2);

        Test.startTest();
        BL_MatchService.generateMatches(setupData.testCompetition.Id);
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

    @isTest
    static void testMatchGenerationForBattleRoyaleLeagueWhenTeamIsInAnotherLeagueInAnotherBRTeam() {
        SetupDataClass setupData = new SetupDataClass();
        setupData.testCompetition = setupData.insertCompetition(BL_Constants.LEAGUE_RT_BATTLE_ROYALE, 1);
        setupData.insertBattleRoyaleTeamsForLeague(setupData.testCompetition.Id, 3, 5);

        BL_Competition__c anotherLeague = setupData.insertCompetition(BL_Constants.LEAGUE_RT_BATTLE_ROYALE, 1);
        BL_Team__c anotherBRTeam = new BL_Team__c(RecordTypeId = BL_Utils.getRecordTypeIdByDeveloperName('BL_Team__c', BL_Constants.TEAM_RT_BATTLE_ROYALE));
        insert anotherBRTeam;
        BL_Team__c chosenTeam = [SELECT Id FROM BL_Team__c WHERE RecordType.Name = :BL_Constants.TEAM_RT_CLASSIC LIMIT 1];
        insert new BL_TeamMember__c(Team__c = anotherBRTeam.Id, Member__c = chosenTeam.Id);
        insert new BL_Competitor__c(Team__c = anotherBRTeam.Id, League__c = anotherLeague.Id);
        insert new BL_Competitor__c(Team__c = chosenTeam.Id, League__c = anotherLeague.Id);


        Test.startTest();
        BL_MatchService.generateMatches(setupData.testCompetition.Id);
        Test.stopTest();

        List<BL_Match__c> generatedMatches = [SELECT Id, Round__c, Team1__r.Name, Team2__r.Name FROM BL_Match__c];
        System.assertEquals(75, generatedMatches.size());

        Integer roundOneMatches = 0;
        Integer roundTwoMatches = 0;
        for (BL_Match__c match : generatedMatches) {
            if (match.Round__c == 1) {
                roundOneMatches++;
            } else if (match.Round__c == 2) {
                roundTwoMatches++;
            }
        }
        System.assertEquals(75, roundOneMatches);
        System.assertEquals(0, roundTwoMatches);
    }

    class SetupDataClass {
        public BL_Competition__c testCompetition;

        public BL_Competition__c insertCompetition(String recordTypeDevName, Integer rounds) {
            BL_Competition__c competition = new BL_Competition__c(
                    RecordTypeId = BL_Utils.getRecordTypeIdByDeveloperName(BL_Competition__c.SObjectType.getDescribe().getName(), recordTypeDevName),
                    Match_No__c = rounds
            );
            insert competition;
            return competition;
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