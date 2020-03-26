public class BL_Settings {

    @AuraEnabled
    public Id userId;
    @AuraEnabled
    public Id playerId;
    @AuraEnabled
    public Id competitionId;
    @AuraEnabled
    public String competitionRecordTypeDevName;
    @AuraEnabled
    public Integer numberOfCompetitors = 0;
    @AuraEnabled
    public Boolean isCompetitionOwner = false;
    @AuraEnabled
    public Boolean isCompetitor = false;
    @AuraEnabled
    public Boolean isCaptainOfBattleRoyaleTeam = false;

    private BL_Competition__c competition;
    private List<BL_Competitor__c> competitors;

    public BL_Settings() {
        this.userId = UserInfo.getUserId();
        populatePlayerId();
    }

    public BL_Settings populateSettingsForCompetition(Id competitionId) {
        this.competitionId = competitionId;

        BL_DAO_Competition daoCompetition = new BL_DAO_Competition();
        this.competition = daoCompetition.getCompetitionById(competitionId);
        populateCompetitionSettings();

        BL_DAO_Competitor daoCompetitor = new BL_DAO_Competitor();
        this.competitors = daoCompetitor.getCompetitorsByCompetitionId(competitionId);
        populateCompetitorSettings();

        return this;
    }

    public BL_Competition__c getCompetition() {
        return this.competition;
    }

    public List<BL_Competitor__c> getCompetitors() {
        return this.competitors;
    }

    private void populatePlayerId() {
        User user = BL_Utils.getCurrentUser();
        this.playerId = user.ContactId;
    }

    private void populateCompetitionSettings() {
        this.competitionRecordTypeDevName = this.competition.RecordType.DeveloperName;
        this.isCompetitionOwner = this.competition.OwnerId == this.userId;
    }

    private void populateCompetitorSettings() {
        this.numberOfCompetitors = 0;

        for(BL_Competitor__c competitor : this.competitors) {
            if(competitor.Team__r.Player1__c == playerId || competitor.Team__r.Player2__c == playerId) {
                if(competitionRecordTypeDevName == BL_Constants.LEAGUE_RT_BATTLE_ROYALE) {
                    if(competitor.Team__r.RecordType.DeveloperName == BL_Constants.TEAM_RT_BATTLE_ROYALE) {
                        this.isCaptainOfBattleRoyaleTeam = true;
                    } else if(competitor.Team__r.RecordType.DeveloperName == BL_Constants.TEAM_RT_CLASSIC) {
                        this.isCompetitor = true;
                    }
                } else {
                    this.isCompetitor = true;
                }
            }

            if(competitor.Is_Direct_Competitor__c) {
                numberOfCompetitors++;
            }
        }
    }
}