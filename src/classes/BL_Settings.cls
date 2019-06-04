public class BL_Settings {

    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public Id playerId;
    @AuraEnabled
    public Id leagueId;
    @AuraEnabled
    public String leagueRecordTypeDevName;
    @AuraEnabled
    public Integer numberOfDirectLeagueCompetitors = 0;
    @AuraEnabled
    public Boolean isLeagueOwner = false;
    @AuraEnabled
    public Boolean isLeagueCompetitor = false;
    @AuraEnabled
    public Boolean isCaptainOfBattleRoyaleTeam = false;

    private BL_League__c league;
    private List<BL_Competitor__c> competitors;

    public BL_Settings() {
        this.userId = UserInfo.getUserId();
        populatePlayerId();
    }

    public BL_Settings populateSettingsForLeague(Id leagueId) {
        this.leagueId = leagueId;

        BL_DAO_League daoLeague = new BL_DAO_League();
        this.league = daoLeague.getLeagueById(leagueId);
        populateLeagueSettings();

        BL_DAO_Competitor daoCompetitor = new BL_DAO_Competitor();
        this.competitors = daoCompetitor.getCompetitorsByLeagueId(leagueId);
        populateCompetitorSettings();

        return this;
    }

    public BL_League__c getLeague() {
        return this.league;
    }

    public List<BL_Competitor__c> getCompetitors() {
        return this.competitors;
    }

    private void populatePlayerId() {
        User user = BL_Utils.getCurrentUser();
        this.playerId = user.ContactId;
    }

    private void populateLeagueSettings() {
        this.leagueRecordTypeDevName = this.league.RecordType.DeveloperName;
        this.isLeagueOwner = this.league.OwnerId == this.userId;
    }

    private void populateCompetitorSettings() {
        this.numberOfDirectLeagueCompetitors = 0;

        for(BL_Competitor__c competitor : this.competitors) {
            if(competitor.Team__r.Player1__c == playerId || competitor.Team__r.Player2__c == playerId) {
                if(leagueRecordTypeDevName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE) {
                    if(competitor.Team__r.RecordType.DeveloperName == BL_Constants.TEAM_RT_BATTLE_ROYALE) {
                        this.isCaptainOfBattleRoyaleTeam = true;
                    } else if(competitor.Team__r.RecordType.DeveloperName == BL_Constants.TEAM_RT_CLASSIC) {
                        this.isLeagueCompetitor = true;
                    }
                } else {
                    this.isLeagueCompetitor = true;
                }
            }

            if(competitor.Is_Direct_Competitor__c) {
                numberOfDirectLeagueCompetitors++;
            }
        }
    }
}