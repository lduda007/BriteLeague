public class BL_BattleRoyaleTableController {

    @AuraEnabled
    public static DataWrapper getDataWrapper(Id leagueId) {
        DataWrapper wrapper;
        try {
            wrapper = new DataWrapper();
            wrapper.populateBattleRoyaleTeams(leagueId);
        } catch(Exception e) {
            String uiMessage = 'An error occurred during initialization of "Battle Royale Table" component';
            BL_Utils.throwAuraHandledException(uiMessage, e);
        }

        return wrapper;
    }

    public class DataWrapper {
        @AuraEnabled
        public List<BL_DTO_BattleRoyaleTeam> battleRoyaleTeams;

        public void populateBattleRoyaleTeams(Id leagueId) {
            BL_DAO_Team daoTeam = new BL_DAO_Team();


            Map<Id, BL_DTO_BattleRoyaleTeam> battleRoyaleTeamsMap = new Map<Id, BL_DTO_BattleRoyaleTeam>();
            List<BL_Team__c> classicTeams = new List<BL_Team__c>();

            for(BL_Team__c team : daoTeam.getTeamsWithMembersByLeagueId(leagueId)) {
                if(team.RecordType.DeveloperName == BL_Constants.TEAM_RT_BATTLE_ROYALE) {
                    BL_DTO_Team dtoTeam = new BL_DTO_Team();
                    dtoTeam.setTeam(team);

                    BL_DTO_BattleRoyaleTeam battleRoyaleTeam = new BL_DTO_BattleRoyaleTeam();
                    battleRoyaleTeam.mainTeam = dtoTeam;

                    battleRoyaleTeamsMap.put(team.Id, battleRoyaleTeam);
                } else {
                    classicTeams.add(team);
                }
            }

            for(BL_Team__c team : classicTeams) {
                BL_DTO_BattleRoyaleTeam battleRoyaleTeam;

                for(BL_TeamMember__c teamMember : team.Members__r) {
                    if(battleRoyaleTeamsMap.containsKey(teamMember.Team__c)) {
                        battleRoyaleTeam = battleRoyaleTeamsMap.get(teamMember.Team__c);
                    }
                }

                if(battleRoyaleTeam != null) {
                    BL_DTO_Team dtoTeam = new BL_DTO_Team();
                    dtoTeam.setTeam(team);

                    battleRoyaleTeam.subTeams.add(dtoTeam);
                } else {
                    BL_Utils.throwAuraHandledException('Battle Royale Team not found for ' + team.Name);
                }
            }

            Map<Id, BL_Competitor__c> teamIdToCompetitorMap = new Map<Id, BL_Competitor__c>();

            BL_DAO_Competitor daoCompetitor = new BL_DAO_Competitor();

            for(BL_Competitor__c competitor : daoCompetitor.getCompetitorsByLeagueId(leagueId)) {
                teamIdToCompetitorMap.put(competitor.Team__c, competitor);
            }

            for(BL_DTO_BattleRoyaleTeam battleRoyaleTeam : battleRoyaleTeamsMap.values()) {
                BL_Competitor__c battleRoyaleTeamCompetitor = teamIdToCompetitorMap.get(battleRoyaleTeam.mainTeam.teamId);
                battleRoyaleTeam.mainTeam.setCompetitor(battleRoyaleTeamCompetitor);

                for(BL_DTO_Team team : battleRoyaleTeam.subTeams) {
                    BL_Competitor__c competitor = teamIdToCompetitorMap.get(team.teamId);
                    team.setCompetitor(competitor);
                }
            }

            this.battleRoyaleTeams = battleRoyaleTeamsMap.values();
        }
    }
}