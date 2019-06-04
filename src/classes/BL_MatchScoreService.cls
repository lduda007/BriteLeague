public without sharing class BL_MatchScoreService {
    public void setScoresForTeams(BL_Competitor__c competitor1, BL_Competitor__c competitor2, Decimal competitor1Score, Decimal competitor2Score, List<Decimal> team1GoalsInRound, List<Decimal> team2GoalsInRound) {
        Decimal team1TotalGoalsScored = 0;
        Decimal team2TotalGoalsScored = 0;

        for (Integer round = 0; round < team1GoalsInRound.size(); round++) {
            team1TotalGoalsScored += team1GoalsInRound[round];
            team2TotalGoalsScored += team2GoalsInRound[round];
        }

        if (competitor1Score > competitor2Score) {
            competitor1.GamesWon__c += 1;
            competitor2.GamesLost__c += 1;
        } else if (competitor1Score < competitor2Score) {
            competitor2.GamesWon__c += 1;
            competitor1.GamesLost__c += 1;
        } else if (competitor1Score == competitor2Score) {
            competitor2.GamesDrawn__c += 1;
            competitor1.GamesDrawn__c += 1;
        }

        competitor1.GoalsFor__c += team1TotalGoalsScored;
        competitor1.GoalsAgainst__c += team2TotalGoalsScored;
        competitor2.GoalsFor__c += team2TotalGoalsScored;
        competitor2.GoalsAgainst__c += team1TotalGoalsScored;
        competitor1.RoundsWon__c += competitor1Score;
        competitor1.RoundsLost__c += competitor2Score;
        competitor2.RoundsWon__c += competitor2Score;
        competitor2.RoundsLost__c += competitor1Score;
    }
}