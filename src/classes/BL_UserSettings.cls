public class BL_UserSettings {

    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public Id playerId;
    @AuraEnabled
    public Id leagueId;
    @AuraEnabled
    public Boolean isLeagueOwner;
    @AuraEnabled
    public Boolean isLeagueCompetitor;

    public BL_UserSettings() {
        this.userId = UserInfo.getUserId();
        populatePlayerId();
    }

    public BL_UserSettings populateSettingsForLeague(Id leagueId) {
        this.leagueId = leagueId;

        BL_DAO_League daoLeague = new BL_DAO_League();
        BL_League__c league = daoLeague.getLeagueById(leagueId);
        populateIsLeagueOwner(league);

        BL_DAO_Competitor daoCompetitor = new BL_DAO_Competitor();
        List<BL_Competitor__c> competitors = daoCompetitor.getCompetitorsByLeagueId(leagueId);
        populateIsLeagueCompetitor(competitors);

        return this;
    }

    private void populatePlayerId() {
        User user = BL_Utils.getCurrentUser();
        this.playerId = user.ContactId;
    }

    private void populateIsLeagueOwner(BL_League__c league) {
        this.isLeagueOwner = league.OwnerId == this.userId;
    }

    private void populateIsLeagueCompetitor(List<BL_Competitor__c> competitors) {
        Boolean result = false;

        for(BL_Competitor__c competitor : competitors) {
            if(competitor.Team__r.Player1__c == playerId || competitor.Team__r.Player2__c == playerId) {
                result = true;
                break;
            }
        }

        this.isLeagueCompetitor = result;
    }
}