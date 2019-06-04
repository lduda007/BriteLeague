public with sharing class BL_ClassicMatchGenerator implements BL_MatchGenerator {

    public List<BL_Match__c> generateMatches(List<Id> competitorsIds, Id leagueId, Integer rounds) {
        if (Math.mod(competitorsIds.size(), 2) == 0) {
            return generateMatchesForEvenNumberOfTeams(competitorsIds, leagueId, rounds);
        } else {
            return generateMatchesForOddNumberOfTeams(competitorsIds, leagueId, rounds);
        }
    }

    private List<BL_Match__c> generateMatchesForEvenNumberOfTeams(List<Id> competitorsIds, Id leagueId, Integer rounds) {
        List<BL_Match__c> generatedMatches = new List<BL_Match__c>();
        Integer numberOfTeams = competitorsIds.size();
        Id lastTeamOnTheListId = competitorsIds[numberOfTeams - 1];

        for (Integer i = 0; i < numberOfTeams - 1; i++) {
            for (Integer j = 0; j < numberOfTeams / 2; j++) {
                for (Integer currentRound = 0; currentRound < rounds; currentRound++) {
                    generatedMatches.add(
                            new BL_MatchBuilder()
                                    .setTeam1(Math.mod(currentRound + 1, 2) == 0 ? competitorsIds[j] : competitorsIds[numberOfTeams - j - 1])
                                    .setTeam2(Math.mod(currentRound + 1, 2) == 0 ? competitorsIds[numberOfTeams - j - 1] : competitorsIds[j])
                                    .setLeague(leagueId)
                                    .setRound(currentRound + 1)
                                    .build()
                    );
                }
            }
            competitorsIds.remove(numberOfTeams - 1);
            competitorsIds.add(competitorsIds[0]);
            competitorsIds.remove(0);
            competitorsIds.add(lastTeamOnTheListId);
        }
        return generatedMatches;
    }

    private List<BL_Match__c> generateMatchesForOddNumberOfTeams(List<Id> competitorsIds, Id leagueId, Integer rounds) {
        List<BL_Match__c> generatedMatches = new List<BL_Match__c>();
        Integer numberOfTeams = competitorsIds.size();

        for (Integer i = 0; i < numberOfTeams; i++) {
            for (Integer j = 0; j < numberOfTeams / 2; j++) {
                for (Integer currentRound = 0; currentRound < rounds; currentRound++) {
                    generatedMatches.add(
                            new BL_MatchBuilder()
                                    .setTeam1(competitorsIds[j])
                                    .setTeam2(competitorsIds[numberOfTeams - j - 2])
                                    .setLeague(leagueId)
                                    .setRound(currentRound + 1)
                                    .build()
                    );
                }
            }
            competitorsIds.add(competitorsIds[0]);
            competitorsIds.remove(0);
        }
        return generatedMatches;
    }
}