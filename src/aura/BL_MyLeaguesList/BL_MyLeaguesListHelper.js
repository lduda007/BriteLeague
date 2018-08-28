({
    handleError : function(component, response, helper) {
        console.log(response.getError()[0].message);
        let errorData = JSON.parse(response.getError()[0].message);
        console.log(errorData.name +" (code "+ errorData.code +"): "+ errorData.message);
        let errToast = $A.get("e.force:showToast");
        errToast.setParams({
            "message": errorData.name +" (code "+ errorData.code +"): "+ errorData.message,
            "type": 'error'
        });
        errToast.fire();
    },
})