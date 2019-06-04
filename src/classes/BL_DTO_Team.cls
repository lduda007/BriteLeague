public virtual class BL_DTO_Team implements Comparable {

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
    public String players;
    @AuraEnabled
    public Integer matchesPlayed;
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
    public Integer goalsDraw;
    @AuraEnabled
    public Integer points;
    @AuraEnabled
    public String teamIcon;

    private BL_Team__c team;
    private BL_Competitor__c competitor;

    public void setTeam(BL_Team__c team) {
        this.team = team;

        this.teamId = team.Id;
        this.name = team.Name;
        this.player1Id = team.Player1__c;
        this.player1Name = team.Player1__r.Name;
        this.player1FirstName = team.Player1__r.FirstName;
        this.player1LastName = team.Player1__r.LastName;
        this.players = team.Player1__r.LastName;
        this.player1ImageUrl = team.Player1__r.ImageUrl__c;

        if(team.Player2__c != null) {
            this.player2Id = team.Player2__c;
            this.player2Name = team.Player2__r.Name;
            this.player2FirstName = team.Player2__r.FirstName;
            this.player2LastName = team.Player2__r.LastName;
            this.players += ' & ' + team.Player2__r.LastName;
            this.player2ImageUrl = team.Player2__r.ImageUrl__c;
        }

        if(team.RecordType.DeveloperName == BL_Constants.TEAM_RT_BATTLE_ROYALE) {
            this.teamIcon = BL_Constants.ICON_STANDARD_HOUSEHOLD;
        } else if(team.RecordType.DeveloperName == BL_Constants.TEAM_RT_CLASSIC) {
            if(team.Player2__c != null) {
                this.teamIcon = BL_Constants.ICON_STANDARD_CUSTOMERS;
            } else {
                this.teamIcon = BL_Constants.ICON_STANDARD_AVATAR;
            }
        }
    }

    public void setCompetitor(BL_Competitor__c competitor) {
        this.competitor = competitor;

        this.matchesPlayed = Integer.valueOf(competitor.MatchesPlayed__c);
        this.gamesWon = Integer.valueOf(competitor.GamesWon__c);
        this.gamesDrawn = Integer.valueOf(competitor.GamesDrawn__c);
        this.gamesLost = Integer.valueOf(competitor.GamesLost__c);
        this.goalsFor = Integer.valueOf(competitor.GoalsFor__c);
        this.goalsAgainst = Integer.valueOf(competitor.GoalsAgainst__c);
        this.goalsDraw = Integer.valueOf(competitor.GoalsDraw__c);
        this.points = Integer.valueOf(competitor.Points__c);
    }

    public Integer compareTo(Object toCompare) {
        BL_DTO_Team toCompareTeam = (BL_DTO_Team) toCompare;

        if(this.points > toCompareTeam.points) {
            return -1;
        } else if(this.points < toCompareTeam.points) {
            return 1;
        } else {
            return 0;
        }
    }
}