public class BL_DTO_BattleRoyaleTeam {

    @AuraEnabled
    public BL_DTO_Team mainTeam;
    @AuraEnabled
    public List<BL_DTO_Team> subTeams = new List<BL_DTO_Team>();
}