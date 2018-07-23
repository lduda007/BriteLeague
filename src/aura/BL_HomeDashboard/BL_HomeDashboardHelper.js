({
    fetchLastMatches : function(component,event){
        var action = component.get('c.getLastMatches');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                component.set('v.lastMatches', response.getReturnValue());
            } else if(state === 'ERROR') {

            }
        });
        $A.enqueueAction(action);
    },

    fetchNextMatches : function(component,event){
        var action = component.get('c.getNextMatches');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' || state === 'DRAFT') {
                component.set('v.nextMatches', response.getReturnValue());
            } else if(state === 'ERROR') {

            }
        });
        $A.enqueueAction(action);
    },
})