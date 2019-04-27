public class BL_UserSettings {

    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public Id playerId;
    @AuraEnabled
    public Id leagueId;
    @AuraEnabled
    public String leagueRecordTypeDevName;
    @AuraEnabled
    public Boolean isLeagueOwner = false;
    @AuraEnabled
    public Boolean isLeagueCompetitor = false;
    @AuraEnabled
    public Boolean isCaptainOfBattleRoyaleTeam = false;

    public BL_UserSettings() {
        this.userId = UserInfo.getUserId();
        populatePlayerId();
    }

    public BL_UserSettings populateSettingsForLeague(Id leagueId) {
        this.leagueId = leagueId;

        BL_DAO_League daoLeague = new BL_DAO_League();
        BL_League__c league = daoLeague.getLeagueById(leagueId);
        populateLeagueSettings(league);

        BL_DAO_Competitor daoCompetitor = new BL_DAO_Competitor();
        List<BL_Competitor__c> competitors = daoCompetitor.getCompetitorsByLeagueId(leagueId);
        populateLeagueCompetitorSettings(competitors);

        return this;
    }

    private void populatePlayerId() {
        User user = BL_Utils.getCurrentUser();
        this.playerId = user.ContactId;
    }

    private void populateLeagueSettings(BL_League__c league) {
        this.leagueRecordTypeDevName = league.RecordType.DeveloperName;
        this.isLeagueOwner = league.OwnerId == this.userId;
    }

    private void populateLeagueCompetitorSettings(List<BL_Competitor__c> competitors) {

        for(BL_Competitor__c competitor : competitors) {
            if(competitor.Team__r.Player1__c == playerId || competitor.Team__r.Player2__c == playerId) {
                if(leagueRecordTypeDevName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE) {
                    if(competitor.Team__r.RecordType.DeveloperName == BL_Constants.TEAM_RT_BATTLE_ROYALE) {
                        this.isCaptainOfBattleRoyaleTeam = true;
                    } else if(competitor.Team__r.RecordType.DeveloperName == BL_Constants.TEAM_RT_CLASSIC) {
                        this.isLeagueCompetitor = true;
                    }
                } else {
                    this.isLeagueCompetitor = true;
                    break;
                }
            }
        }
    }
}