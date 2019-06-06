({
    getMatchesForTeam: function(matches, teamId) {
        let teamMatches = [];

        for(let i = 0; i < matches.length; i++) {
            let match = matches[i];
            if(match.Team1__r.Team__c == teamId || match.Team2__r.Team__c == teamId) {
                teamMatches.push(match);
            }
        }

        return teamMatches;
    }
});