({
	doInit : function(component) {
		var action = component.get("c.getsaleprof");
         action.setParams({
			"accountId": component.get("v.recordId")
         });

        action.setCallback(this, function(response){
            var state = response.getState();
        	$A.log(response);
        	if(state == "SUCCESS"){
            	component.set("v.sales", response.getReturnValue());
        }
        });
           $A.enqueueAction(action);                
	}
})