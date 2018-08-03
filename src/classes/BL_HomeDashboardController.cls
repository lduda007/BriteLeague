public with sharing class BL_HomeDashboardController {

	@AuraEnabled
	public static List<BL_Match__c> getLastMatches(){
		try {
			Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
			Map<Id, BL_Team__c> playerTeams = new Map<Id, BL_Team__c>([SELECT Id FROM BL_Team__c WHERE Player1__c = :currentPlayer OR Player2__c = :currentPlayer]);
			List<BL_Match__c> matches = [
					SELECT Id, Team1__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__c, Team2__r.Team__r.Name, Team1_Score__c, Team2_Score__c, CreatedDate
					FROM BL_Match__c
					WHERE
					isResolved__c = true
					AND (
							Team1__r.Team__c IN :playerTeams.keySet()
							OR Team2__r.Team__c IN :playerTeams.keySet()
					)
					ORDER BY LastModifiedDate DESC
					LIMIT 20
			];

			return matches;
		} catch (Exception ex) {
			throw new AuraHandledException(ex.getStackTraceString());
		}
	}

	@AuraEnabled
	public static List<BL_Match__c> getNextMatches(){
		Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
		Map<Id, BL_Team__c> playerTeams = new Map<Id, BL_Team__c>([SELECT Id FROM BL_Team__c WHERE Player1__c = :currentPlayer OR Player2__c = :currentPlayer]);
		List<BL_Match__c> matches = [
				SELECT Id, Team1__r.Team__c, Team1__r.Team__r.Name, Team2__r.Team__c, Team2__r.Team__r.Name, League__c, League__r.Name, CreatedDate, Team1_Score__c, Team2_Score__c
				FROM BL_Match__c
				WHERE
				((Team1_Score__c = null OR Team1_Score__c = 0) AND (Team2_Score__c = null OR Team2_Score__c = 0))
				AND (
						Team1__r.Team__c IN :playerTeams.keySet()
						OR Team2__r.Team__c IN :playerTeams.keySet()
				)
				ORDER BY LastModifiedDate DESC
				LIMIT 20
		];

		return matches;
	}

	@AuraEnabled
	public static DTO_Chart getCondition(){
		try {
			Id currentPlayer = BL_Utils.getCurrentUser().ContactId;
			Integer days = 7;
			Datetime dateFrom = Date.today().addDays(-days);
			Map<Date,Integer> scorePerDate = new Map<Date,Integer>();
			Map<Date,Integer> matchPerDate = new Map<Date,Integer>();
			Map<Id, BL_Team__c> playerTeams = new Map<Id, BL_Team__c>([SELECT Id FROM BL_Team__c WHERE Player1__c = :currentPlayer OR Player2__c = :currentPlayer]);
			List<BL_Match__c> matches = [
					SELECT Id, Team1__r.Team__c, Team2__r.Team__c, Team1Round1Goals__c, Team1Round2Goals__c, Team1Round3Goals__c, Team2Round1Goals__c, Team2Round2Goals__c, Team2Round3Goals__c, LastModifiedDate
					FROM BL_Match__c
					WHERE
					LastModifiedDate >= :dateFrom
					AND (Team1_Score__c != 0 OR Team2_Score__c != 0)
					AND (Team1Round1Goals__c != null AND Team2Round1Goals__c != null)
					AND (
							Team1__r.Team__c IN :playerTeams.keySet()
							OR Team2__r.Team__c IN :playerTeams.keySet()
					)
					ORDER BY LastModifiedDate ASC
			];

			for (BL_Match__c match : matches){
				Date matchDate = Date.newInstance(match.LastModifiedDate.year(), match.LastModifiedDate.month(), match.LastModifiedDate.day());
				if (!scorePerDate.containsKey(matchDate)){
					scorePerDate.put(matchDate, 0);
					matchPerDate.put(matchDate, 0);
				}
				Integer score = scorePerDate.get(matchDate);
				Integer count = matchPerDate.get(matchDate);
				if (playerTeams.containsKey(match.Team1__r.Team__c)){
					score += (Integer) (match.Team1Round1Goals__c - match.Team2Round1Goals__c + 10) / 2;
					score += (Integer) (match.Team1Round2Goals__c - match.Team2Round2Goals__c + 10) / 2;
					count += 2;
					if (match.Team1Round3Goals__c != null && match.Team1Round3Goals__c != 0 && match.Team2Round3Goals__c != null && match.Team2Round3Goals__c != 0){
						score += (Integer) (match.Team1Round3Goals__c - match.Team2Round3Goals__c + 10) / 2;
						count += 1;
					}
				} else {
					score += (Integer) (match.Team2Round1Goals__c - match.Team1Round1Goals__c + 10) / 2;
					score += (Integer) (match.Team2Round2Goals__c - match.Team1Round2Goals__c + 10) / 2;
					count += 2;
					if (match.Team1Round3Goals__c != null && match.Team1Round3Goals__c != 0 && match.Team2Round3Goals__c != null && match.Team2Round3Goals__c != 0){
						score += (Integer) (match.Team2Round3Goals__c - match.Team1Round3Goals__c + 10) / 2;
						count += 1;
					}
				}
				scorePerDate.put(matchDate, score);
				matchPerDate.put(matchDate, count);
			}

			DTO_Chart chart = new DTO_Chart();
			chart.name = 'Performance';
			chart.xValues = new List<Integer>();
			chart.xLabels = new List<String>();
			for (Date matchDate : matchPerDate.keySet()){
				chart.xLabels.add(matchDate.format());
				chart.xValues.add(getConditionAvg(scorePerDate.get(matchDate), matchPerDate.get(matchDate)));
			}
			//		chart = new DTO_Chart();
			//		chart.name = 'Condition';
			//		chart.xValues = new List<Integer>{55,80,85,80,95,70,80,30,80,85};
			//		chart.xLabels = new List<String>{'day 1','day 2','day 3','day 4','day 5','day 6','day 7','day 8','day 9','day 10'};
			return chart;
		} catch (Exception ex) {
			throw new AuraHandledException(ex.getStackTraceString());
		}

	}

	private static Integer getConditionAvg(Integer score, Integer matches){
		return score / matches * 10;
	}

	public class DTO_Chart{
		@AuraEnabled public String name {get;set;}
		@AuraEnabled public List<String> xLabels {get;set;}
		@AuraEnabled public List<Integer> xValues {get;set;}
	}
}