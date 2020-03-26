public without sharing class BL_MatchBuilder {
    private BL_Match__c record;

    public BL_MatchBuilder() {
        record = new BL_Match__c();
    }

    public BL_MatchBuilder setTeam1(Id teamId) {
        record.Team1__c = teamId;
        return this;
    }

    public BL_MatchBuilder setTeam2(Id teamId) {
        record.Team2__c = teamId;
        return this;
    }

    public BL_MatchBuilder setCompetition(Id competitionId) {
        record.Competition__c = competitionId;
        return this;
    }

    public BL_MatchBuilder setRound(Integer round) {
        record.Round__c = round;
        return this;
    }

    public BL_Match__c build() {
        return record;
    }
}