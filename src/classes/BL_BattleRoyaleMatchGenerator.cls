public with sharing class BL_BattleRoyaleMatchGenerator implements BL_MatchGenerator {

    public List<BL_Match__c> generateMatches(List<Id> competitorsIds, Id leagueId, Integer rounds) {

        // TODO: Less queries

        // get competitors for parent teams
        List<BL_Competitor__c> battleRoyaleCompetitors = [SELECT Team__r.Id FROM BL_Competitor__c WHERE Id IN :competitorsIds AND Team__r.RecordType.DeveloperName = :BL_Constants.TEAM_RT_BATTLE_ROYALE];
        Map<Id, Id> teamToParentComp = new Map<Id, Id>();
        for (BL_Competitor__c comp : battleRoyaleCompetitors) {
            teamToParentComp.put(comp.Team__r.Id, comp.Id);
        }

        // get competitors for classic teams
        List<BL_Competitor__c> memberCompetitors = [SELECT Id, Team__r.Name FROM BL_Competitor__c WHERE Competition__c = :leagueId AND Team__c IN (SELECT Member__c FROM BL_TeamMember__c WHERE Team__r.Id In :teamToParentComp.keySet())];
        Map<Id, Id> teamToMemberComp = new Map<Id, Id>();
        for (BL_Competitor__c comp : memberCompetitors) {
            teamToMemberComp.put(comp.Team__r.Id, comp.Id);
        }

        List<BL_TeamMember__c> teamMembers = [select id, Team__r.Id, Member__c from bl_teammember__c where Member__r.Id IN :teamToMemberComp.keyset() AND Team__c IN :teamToParentComp.keySet()];
        Map<Id, List<Id>> parentToMembersIds = new Map<Id, List<Id>>();
        for (BL_TeamMember__c tm : teamMembers) {
            if (parentToMembersIds.get(tm.Team__c) == null) {
                parentToMembersIds.put(tm.Team__c, new List<Id>());
            }
            parentToMembersIds.get(tm.Team__r.Id).add(teamToMemberComp.get(tm.Member__c));
        }

        List<BL_Match__c> generatedMatches = new List<BL_Match__c>();

        // TODO: Less loops
        List<List<Id>> teamsCompetitors = parentToMembersIds.values();
        Integer parentTeamsCount = teamsCompetitors.size();
        for (Integer parentTeamIndex = 0; parentTeamIndex < parentTeamsCount - 1; parentTeamIndex++) {
            for (Integer memberTeamIndex = 0; memberTeamIndex < teamsCompetitors[parentTeamIndex].size(); memberTeamIndex++) {
                for (Integer opponentParentTeamIndex = parentTeamIndex + 1; opponentParentTeamIndex < parentTeamsCount; opponentParentTeamIndex++) {
                    for (Integer opponentTeamMemberIndex = 0; opponentTeamMemberIndex < teamsCompetitors[opponentParentTeamIndex].size(); opponentTeamMemberIndex++) {
                        for (Integer round = 1; round <= rounds; round++) {
                            generatedMatches.add(new BL_MatchBuilder()
                                    .setCompetition(leagueId)
                                    .setRound(round)
                                    .setTeam1(Math.mod(round, 2) == 0 ? teamsCompetitors[parentTeamIndex][memberTeamIndex] : teamsCompetitors[opponentParentTeamIndex][opponentTeamMemberIndex])
                                    .setTeam2(Math.mod(round, 2) == 0 ? teamsCompetitors[opponentParentTeamIndex][opponentTeamMemberIndex] : teamsCompetitors[parentTeamIndex][memberTeamIndex])
                                    .build());
                        }
                    }
                }
            }
        }
        return generatedMatches;
    }
}