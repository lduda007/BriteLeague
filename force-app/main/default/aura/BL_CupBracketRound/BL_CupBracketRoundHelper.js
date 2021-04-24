({
    generateMatchups: function(component){
        let matches = component.get("v.matches");
        let matchesCoupled = [];
        let matchesCouple = [];

        if(matches.length === 1){
            matchesCouple.push(matches[0]);
            matchesCoupled.push(matchesCouple);
        }else{
            for(let ii=0; ii<matches.length/2; ii++){
                matchesCouple = [];
                matchesCouple.push(matches[ii*2]);
                matchesCouple.push(matches[ii*2+1]);
                matchesCoupled.push(matchesCouple);
            }
        }
        component.set("v.matchesCoupled", matchesCoupled);
    }
})