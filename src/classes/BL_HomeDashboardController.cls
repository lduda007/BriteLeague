public with sharing class BL_HomeDashboardController {

    public static final Map<String, Integer> PERIOD_TO_DAYS = new Map<String, Integer> {
            'LAST_WEEK' => 7,
            'LAST_MONTH' => 30,
            'LAST_6_MONTHS' => 180,
            'LAST_YEAR' => 365
    };

    @AuraEnabled
    public static List<BL_Match__c> getLastMatches() {
        try {
            Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
            Map<Id, BL_Team__c> playerTeams = new Map<Id, BL_Team__c>([
                    SELECT Id
                    FROM BL_Team__c
                    WHERE Player1__c = :currentPlayer
                    OR Player2__c = :currentPlayer
            ]);
            List<BL_Match__c> matches = [
                    SELECT Id, isResolved__c, CupStage__c, Round__c, DrawRound__c, Team1_Score__c, Team2_Score__c,
                            Team1__r.Name, Team1__r.Team__r.Name, Team1__r.Team__r.Player1__r.Name, Team1__r.Team__r.Player2__r.Name,
                            Team2__r.Name, Team2__r.Team__r.Name, Team2__r.Team__r.Player1__r.Name, Team2__r.Team__r.Player2__r.Name,
                            Team1Round1Goals__c, Team1Round2Goals__c, Team1Round3Goals__c,
                            Team2Round1Goals__c, Team2Round2Goals__c, Team2Round3Goals__c,
                            League__r.Name, League__r.isCup__c, CreatedDate, League__r.TeamSize__c
                    FROM BL_Match__c
                    WHERE isResolved__c = true
                    AND (
                            Team1__r.Team__c IN :playerTeams.keySet()
                            OR Team2__r.Team__c IN :playerTeams.keySet()
                    )
                    ORDER BY LastModifiedDate DESC, DrawRound__c, Round__c
                    LIMIT 20
            ];
            return matches;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }

    @AuraEnabled
    public static List<BL_Match__c> getNextMatches() {
        Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
        List<BL_Team__c> playerTeams = [
                SELECT Id
                FROM BL_Team__c
                WHERE Player1__c = :currentPlayer
                OR Player2__c = :currentPlayer
        ];
        List<BL_Match__c> matches = [
                SELECT Id, Team1__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__c, Team2__r.Team__r.Name, League__c,
                        League__r.Name, CreatedDate, Team1_Score__c, Team2_Score__c, League__r.isCup__c, CupStage__c,
                        League__r.TeamSize__c, Round__c, DrawRound__c
                FROM BL_Match__c
                WHERE (
                        (
                                Team1_Score__c = null
                                OR Team1_Score__c = 0
                        ) AND (
                                Team2_Score__c = null
                                OR Team2_Score__c = 0
                        )
                ) AND (
                        Team1__r.Team__c IN :playerTeams
                        OR Team2__r.Team__c IN :playerTeams
                ) AND (
                        Team1__c != null
                        AND Team2__c != null
                )
                ORDER BY LastModifiedDate DESC, DrawRound__c, Round__c
                LIMIT 20
        ];

        return matches;
    }

    @AuraEnabled
    public static BL_ChartJS.Dataset getCondition(String period) {
        BL_ChartJS.Dataset dataset = new BL_ChartJS.Dataset();
        try {
            dataset.label = 'Performance';
            dataset.setPrimaryColor('#FF8C13FF');
            dataset.setSecondaryColorBasedOnPrimaryColor();
            dataset.fill();

            User currentUser = BL_Utils.getCurrentUser();
            Id currentPlayerId = currentUser.ContactId;
            Datetime dateFrom;

            if(period == 'ALL_TIME') {
                dateFrom = currentUser.CreatedDate;
            } else {
                Integer days = PERIOD_TO_DAYS.get(period);
                dateFrom = Date.today().addDays(-days);
            }

            Map<Date, Decimal> scorePerDate = new Map<Date, Decimal>();
            Map<Date, Integer> matchPerDate = new Map<Date, Integer>();
            Map<Id, BL_Team__c> playerTeams = new Map<Id, BL_Team__c>([
                    SELECT Id
                    FROM BL_Team__c
                    WHERE Player1__c = :currentPlayerId
                    OR Player2__c = :currentPlayerId
            ]);
            List<BL_Match__c> matches = [
                    SELECT Id, LastModifiedDate, Team1__r.Team__c, Team2__r.Team__c,
                            Team1Round1Goals__c, Team1Round2Goals__c, Team1Round3Goals__c,
                            Team2Round1Goals__c, Team2Round2Goals__c, Team2Round3Goals__c
                    FROM BL_Match__c
                    WHERE LastModifiedDate >= :dateFrom
                    AND (Team1_Score__c != 0 OR Team2_Score__c != 0)
                    AND (Team1Round1Goals__c != null AND Team2Round1Goals__c != null)
                    AND (
                            Team1__r.Team__c IN :playerTeams.keySet()
                            OR Team2__r.Team__c IN :playerTeams.keySet()
                    )
                    ORDER BY LastModifiedDate ASC
            ];

            for(BL_Match__c match : matches) {
                Date matchDate = Date.newInstance(match.LastModifiedDate.year(), match.LastModifiedDate.month(), match.LastModifiedDate.day());
                if(!scorePerDate.containsKey(matchDate)) {
                    scorePerDate.put(matchDate, 0);
                    matchPerDate.put(matchDate, 0);
                }
                Decimal score = scorePerDate.get(matchDate);
                Integer count = matchPerDate.get(matchDate);
                if(playerTeams.containsKey(match.Team1__r.Team__c)) {
                    score += (match.Team1Round1Goals__c - match.Team2Round1Goals__c + 10) / 2;
                    score += (match.Team1Round2Goals__c - match.Team2Round2Goals__c + 10) / 2;
                    count += 2;
                    if(match.Team1Round3Goals__c != null && match.Team1Round3Goals__c != 0 && match.Team2Round3Goals__c != null && match.Team2Round3Goals__c != 0) {
                        score += (match.Team1Round3Goals__c - match.Team2Round3Goals__c + 10) / 2;
                        count += 1;
                    }
                } else {
                    score += (match.Team2Round1Goals__c - match.Team1Round1Goals__c + 10) / 2;
                    score += (match.Team2Round2Goals__c - match.Team1Round2Goals__c + 10) / 2;
                    count += 2;
                    if(match.Team1Round3Goals__c != null && match.Team1Round3Goals__c != 0 && match.Team2Round3Goals__c != null && match.Team2Round3Goals__c != 0) {
                        score += (match.Team2Round3Goals__c - match.Team1Round3Goals__c + 10) / 2;
                        count += 1;
                    }
                }
                scorePerDate.put(matchDate, score);
                matchPerDate.put(matchDate, count);
            }

            for(Date matchDate : matchPerDate.keySet()) {
                dataset.labels.add(matchDate.format());
                dataset.data.add(getConditionAvg(scorePerDate.get(matchDate), matchPerDate.get(matchDate)));
            }
        } catch(Exception ex) {
            String uiMessage = 'An error occurred during loading of Performance Chart!';
            BL_Utils.throwAuraHandledException(uiMessage + ' - ' + ex.getStackTraceString(), uiMessage + ' - ' + ex.getStackTraceString());
        }

        return dataset;
    }

    private static Decimal getConditionAvg(Decimal score, Integer matches) {
        return (score / matches * 10.0).setScale(2);
    }
}