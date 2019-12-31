public with sharing class BL_MatchScoreProviderController {

    @AuraEnabled
    public static String updateMatchScore(String matchId, Decimal team1Score, Decimal team2Score, List<Decimal> team1GoalsInRound, List<Decimal> team2GoalsInRound, Datetime matchDate) {
        Decimal[] team1GoalsInAllRounds = new Decimal[3];
        Decimal[] team2GoalsInAllRounds = new Decimal[3];
        List<String> competitors = new List<String>();
        Integer roundsPlayed = 3;

        BL_DAO_Match daoMatch = new BL_DAO_Match();
        BL_Match__c match = daoMatch.getMatchById(matchId);

        if (match != null && match.isResolved__c) {
            throw new AuraHandledException('This match score was already set by other player');
        }

        match.Team1_Score__c = team1Score;
        match.Team2_Score__c = team2Score;
        match.MatchDate__c = matchDate;
        competitors.add(match.Team1__c);
        competitors.add(match.Team2__c);

        for (Integer ii = 0; ii < team1GoalsInRound.size(); ii++) {
            team1GoalsInAllRounds[ii] = team1GoalsInRound[ii];
            team2GoalsInAllRounds[ii] = team2GoalsInRound[ii];
        }

        for (Decimal goalsCount : team1GoalsInAllRounds) {
            if (goalsCount == null) {
                roundsPlayed -= 1;
            }
        }

        match.Team1Round1Goals__c = team1GoalsInAllRounds[0];
        match.Team1Round2Goals__c = team1GoalsInAllRounds[1];
        match.Team1Round3Goals__c = team1GoalsInAllRounds[2];

        match.Team2Round1Goals__c = team2GoalsInAllRounds[0];
        match.Team2Round2Goals__c = team2GoalsInAllRounds[1];
        match.Team2Round3Goals__c = team2GoalsInAllRounds[2];

        Decimal team1WinsOld = match.Team1__r.GamesWon__c;
        Decimal team2WinsOld = match.Team2__r.GamesWon__c;

        if (isMatchResolved(match, roundsPlayed)) {
            match.isResolved__c = true;
            updateCompetitorStatistics(
                    match,
                    competitors,
                    team1GoalsInRound,
                    team2GoalsInRound
            );
        }

        try {
            Database.upsert(match);
            return 'SUCCESS';
        } catch (DmlException e) {
            System.debug('exception has occurred: ' + e.getMessage());
            throw new AuraHandledException('Error. Cannot save match score.');
        }
    }

    private static void updateCompetitorStatistics(BL_Match__c match, List<String> competitors, List<Decimal> team1GoalsInRound, List<Decimal> team2GoalsInRound) {
        Decimal team1TotalGoalsScored = 0;
        Decimal team2TotalGoalsScored = 0;
        Boolean isBattleRoyale = match.League__r.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE;

        BL_DAO_Competitor daoCompetitor = new BL_DAO_Competitor();
        Map<Id, BL_Competitor__c> competitorsMap = daoCompetitor.getCompetitorsMapByIds(competitors);
        BL_Competitor__c competitor1 = competitorsMap.get(competitors[0]);
        BL_Competitor__c competitor2 = competitorsMap.get(competitors[1]);
        BL_Competitor__c parent1;
        BL_Competitor__c parent2;

        if (isBattleRoyale) {
            parent1 = daoCompetitor.getParentCompetitorByMemberTeamIdAndLeagueId(competitor1.Team__c, match.League__c);
            parent2 = daoCompetitor.getParentCompetitorByMemberTeamIdAndLeagueId(competitor2.Team__c, match.League__c);
        }

        BL_MatchScoreService scoreService = new BL_MatchScoreService();
        scoreService.setScoresForTeams(competitor1, competitor2, match.Team1_Score__c, match.Team2_Score__c, team1GoalsInRound, team2GoalsInRound);
        if (isBattleRoyale) {
            scoreService.setScoresForTeams(parent1, parent2, match.Team1_Score__c, match.Team2_Score__c, team1GoalsInRound, team2GoalsInRound);
        }

        List<BL_Competitor__c> competitorsToUpdate = new List<BL_Competitor__c>();
        competitorsToUpdate.add(competitor1);
        competitorsToUpdate.add(competitor2);
        if (isBattleRoyale) {
            competitorsToUpdate.add(parent1);
            competitorsToUpdate.add(parent2);
        }

        try {
            Database.upsert(competitorsToUpdate);
        } catch (DmlException e) {
            System.debug('exception has occurred: ' + e.getMessage());
        }
    }

    private static Boolean isMatchResolved(BL_Match__c match, Integer roundsPlayed) {
        Boolean result = false;
        if (match.League__r.RecordType.DeveloperName == BL_Constants.LEAGUE_RT_CUP) {
            if (roundsPlayed >= 2 && match.Team1_Score__c != match.Team2_Score__c) {
                result = true;
            }
        } else {
            if (roundsPlayed == 2) {
                result = true;
            }
        }

        return result;
    }
}