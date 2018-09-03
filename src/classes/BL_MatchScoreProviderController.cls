public with sharing class BL_MatchScoreProviderController {

    @AuraEnabled
    public static String updateMatchScore(String matchId, Decimal team1Score, Decimal team2Score, List<Decimal> team1GoalsInRound, List<Decimal> team2GoalsInRound, String matchDateString){
        system.debug('date param: '+matchDateString);
        Decimal[] team1GoalsInAllRounds = new Decimal[3];
        Decimal[] team2GoalsInAllRounds = new Decimal[3];
        List<String> competitors = new List<String>();
        Integer roundsPlayed = 3;
        Date matchDate = Date.valueOf(matchDateString);

        List<BL_Match__c> match = [SELECT id,isResolved__c,MatchDate__c, League__r.isCup__c, Team1__c, Team2__c, Team1_Score__c,Team2_Score__c, Team1TotalGoalsScored__c, Team2TotalGoalsScored__c,
                Team1__r.GoalsFor__c,Team1__r.GoalsAgainst__c,Team1__r.GamesWon__c,Team1__r.GamesLost__c,Team1__r.GamesDrawn__c,
                Team2__r.GoalsFor__c,Team2__r.GoalsAgainst__c,Team2__r.GamesWon__c,Team2__r.GamesLost__c,Team2__r.GamesDrawn__c, Team1Round1Goals__c,
                Team1Round2Goals__c, Team1Round3Goals__c, Team2Round1Goals__c,Team2Round2Goals__c,Team2Round3Goals__c
                FROM BL_Match__c WHERE id=:matchId];

        if(!match.isEmpty() && match[0].isResolved__c){
            throw new AuraHandledException('This match score was already set by other player');
        }

        match[0].Team1_Score__c = team1Score;
        match[0].Team2_Score__c = team2Score;
        match[0].MatchDate__c = matchDate;
        competitors.add(match[0].Team1__c);
        competitors.add(match[0].Team2__c);
        system.debug('date record: '+match[0].MatchDate__c);

        for (Integer ii=0 ; ii<team1GoalsInRound.size() ; ii++) {
            team1GoalsInAllRounds[ii]=team1GoalsInRound[ii];
            team2GoalsInAllRounds[ii]=team2GoalsInRound[ii];
        }

        for (Decimal goalsCount : team1GoalsInAllRounds) {
            if (goalsCount == null) {
                roundsPlayed -= 1;
            }
        }

        match[0].Team1Round1Goals__c = team1GoalsInAllRounds[0];
        match[0].Team1Round2Goals__c = team1GoalsInAllRounds[1];
        match[0].Team1Round3Goals__c = team1GoalsInAllRounds[2];

        match[0].Team2Round1Goals__c = team2GoalsInAllRounds[0];
        match[0].Team2Round2Goals__c = team2GoalsInAllRounds[1];
        match[0].Team2Round3Goals__c = team2GoalsInAllRounds[2];

        Decimal team1WinsOld = match[0].Team1__r.GamesWon__c;
        Decimal team2WinsOld = match[0].Team2__r.GamesWon__c;

        if (!match[0].League__r.isCup__c && roundsPlayed == 2) {
            match[0].isResolved__c = true;
            updateCompetitorStatistics(match[0], competitors, team1Score, team2Score, team1GoalsInRound, team2GoalsInRound);
        }else if (match[0].League__r.isCup__c && roundsPlayed >= 2 && match[0].Team1_Score__c != match[0].Team2_Score__c) {
            match[0].isResolved__c = true;
            updateCompetitorStatistics(match[0], competitors, team1Score, team2Score, team1GoalsInRound, team2GoalsInRound);
        }

        try{
            Database.upsert(match);
            return 'SUCCESS';
        }catch (DmlException e){
            System.debug('exception has occurred: ' + e.getMessage());
            throw new AuraHandledException('Error. Cannot save match score.');
        }
    }

    private static void updateCompetitorStatistics(BL_Match__c match, List<String> competitors, Decimal competitor1Score, Decimal competitor2Score, List<Decimal> team1GoalsInRound, List<Decimal> team2GoalsInRound){
        system.debug('goals: '+team1GoalsInRound+ ' | '+team2GoalsInRound);
        Decimal team1TotalGoalsScored = 0;
        Decimal team2TotalGoalsScored = 0;
        List<BL_Competitor__c> competitorsTeams = new List<BL_Competitor__c>();
        List<BL_Competitor__c> competitor1 = [
                SELECT id, GamesLost__c,GamesDrawn__c,GamesWon__c,GoalsAgainst__c,GoalsFor__c, RoundsWon__c, RoundsLost__c
                FROM BL_Competitor__c
                WHERE id=:competitors[0]
        ];
        List<BL_Competitor__c> competitor2 = [
                SELECT id, GamesLost__c,GamesDrawn__c,GamesWon__c,GoalsAgainst__c,GoalsFor__c, RoundsWon__c, RoundsLost__c
                FROM BL_Competitor__c
                WHERE id=:competitors[1]
        ];
        competitorsTeams.add(competitor1[0]);
        competitorsTeams.add(competitor2[0]);
        system.debug(competitorsTeams);
        system.debug(competitorsTeams.size());

        for (Integer ii=0;ii<team1GoalsInRound.size();ii++) {
            team1TotalGoalsScored += team1GoalsInRound[ii];
            team2TotalGoalsScored += team2GoalsInRound[ii];
        }

        if(competitor1Score > competitor2Score){
            competitorsTeams[0].GamesWon__c += 1;
            competitorsTeams[1].GamesLost__c += 1;
        }else if (competitor1Score < competitor2Score) {
            competitorsTeams[1].GamesWon__c += 1;
            competitorsTeams[0].GamesLost__c += 1;
        }else if (competitor1Score == competitor2Score) {
            competitorsTeams[1].GamesDrawn__c += 1;
            competitorsTeams[0].GamesDrawn__c += 1;
        }
        competitorsTeams[0].GoalsFor__c += team1TotalGoalsScored;
        competitorsTeams[0].GoalsAgainst__c += team2TotalGoalsScored;
        competitorsTeams[1].GoalsFor__c += team2TotalGoalsScored;
        competitorsTeams[1].GoalsAgainst__c += team1TotalGoalsScored;
        competitorsTeams[0].RoundsWon__c += match.Team1_Score__c;
        competitorsTeams[0].RoundsLost__c += match.Team2_Score__c;
        competitorsTeams[1].RoundsWon__c += match.Team2_Score__c;
        competitorsTeams[1].RoundsLost__c += match.Team1_Score__c;

        try{
            Database.upsert(competitorsTeams);
        }catch (DmlException e){
            System.debug('exception has occurred: ' + e.getMessage());
        }

    }
    private static List<BL_Match__c> getPlayerAllMatches(String playerId){
        List<BL_Match__c> playerMatches = [
                SELECT id
                FROM BL_Match__c
                WHERE Team1__r.Team__r.Player1__r.Id=:playerId
                OR Team1__r.Team__r.Player2__r.Id=:playerId
                OR Team2__r.Team__r.Player1__r.Id=:playerId
                OR Team2__r.Team__r.Player2__r.Id=:playerId
        ];
        return playerMatches;
    }

    private static void updateTeamStatistics(){

    }

}