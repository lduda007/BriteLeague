public class BL_DTO_Team {

    @AuraEnabled
    public Id teamId;
    @AuraEnabled
    public Id competitorId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public Id player1Id;
    @AuraEnabled
    public Id player2Id;
    @AuraEnabled
    public String player1ImageUrl;
    @AuraEnabled
    public String player2ImageUrl;
    @AuraEnabled
    public String player1Name;
    @AuraEnabled
    public String player2Name;
    @AuraEnabled
    public String player1FirstName;
    @AuraEnabled
    public String player2FirstName;
    @AuraEnabled
    public String player1LastName;
    @AuraEnabled
    public String player2LastName;
    @AuraEnabled
    public Integer gamesWon;
    @AuraEnabled
    public Integer gamesDrawn;
    @AuraEnabled
    public Integer gamesLost;
    @AuraEnabled
    public Integer goalsFor;
    @AuraEnabled
    public Integer goalsAgainst;
    @AuraEnabled
    public Integer goalsDrawn;
    @AuraEnabled
    public Integer points;

    private BL_Team__c team;
    private BL_Competitor__c competitor;

    public void setTeam(BL_Team__c team) {
        this.team = team;

        this.teamId = team.Id;
        this.name = team.Name;
        this.player1Id = team.Player1__c;
        this.player2Id = team.Player2__c;
        this.player1Name = team.Player1__r.Name;
        this.player2Name = team.Player2__r.Name;
        this.player1FirstName = team.Player1__r.FirstName;
        this.player2FirstName = team.Player2__r.FirstName;
        this.player1LastName = team.Player1__r.LastName;
        this.player2LastName = team.Player2__r.LastName;
        this.player1ImageUrl = team.Player1__r.ImageUrl__c;
        this.player2ImageUrl = team.Player2__r.ImageUrl__c;
    }

    public void setCompetitor(BL_Competitor__c competitor) {
        this.competitor = competitor;

        this.gamesWon = Integer.valueOf(competitor.GamesWon__c);
        this.gamesDrawn = Integer.valueOf(competitor.GamesDrawn__c);
        this.gamesLost = Integer.valueOf(competitor.GamesLost__c);
        this.goalsFor = Integer.valueOf(competitor.GoalsFor__c);
        this.goalsAgainst = Integer.valueOf(competitor.GoalsAgainst__c);
        this.goalsDrawn = Integer.valueOf(competitor.GamesDrawn__c);
        this.points = Integer.valueOf(competitor.Points__c);
    }
}