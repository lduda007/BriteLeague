public class BL_DTO_BattleRoyaleTeam extends BL_DTO_Team {
    @AuraEnabled
    public List<BL_DTO_Team> subTeams = new List<BL_DTO_Team>();

    public void addSubTeam(BL_DTO_Team subTeam) {
        subTeams.add(subTeam);
    }
}