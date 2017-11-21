/* Name: EventsComponentHelper.js
 * Last Modified: 09-23-2017
 * Modified By: FB
 * Description: 
 * This is a javascript helper library for Events Component controller.
 */


/*************************** getEventList() function ***************************
 * Parameter Definition: component,filterType,page, recordToDisply pass from controller as parameter refrence
 * Purpose: this method return the Event list with given filter and properties set by components it call from different methods of controller.js with different properties
 **************************************************************************/    

({
    
    getEventList : function(component,filterType,page, recordToDisply ){
        
        var sortBy = component.get("v.SortBy"); 
        
        if(filterType=='dateEvent'){
            
            var selectedDate = component.get("v.myDate");
            console.log("Selected Date is: ", selectedDate);
            var action = component.get("c.eventByDate");       
            action.setParams({
                "selectedDate": selectedDate,
                "pageNumber": page,
                "recordToDisply": recordToDisply,
                "sortBy" : sortBy, 
                
            });
            
        }else {
            var action = component.get("c.eventByFilter");
            
            
            
            action.setParams({
                "fltr": filterType,
                "pageNumber": page,
                "recordToDisply": recordToDisply,
                "sortBy" : sortBy,
            });
            
        } 
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            console.log('result ---->' + JSON.stringify(result));
            // set the component attributes value with wrapper class properties.
            
            
            component.set("v.events", result.events);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.ceil(result.total / recordToDisply));
            
            
        });
        
        $A.enqueueAction(action);
        
        
    },
 /***************************  clearActive() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method is used to clear the current selected action and revert the setting to default
 **************************************************************************/        
     clearActive: function(component,event){
        
        var cmpTarget = component.find('upcoming');
        $A.util.removeClass(cmpTarget, 'metro-active');
        
        var cmpTarget1 = component.find('today');
        $A.util.removeClass(cmpTarget1, 'metro-active');
        
        var cmpTarget2 = component.find('thisWeek');
        $A.util.removeClass(cmpTarget2, 'metro-active');
        
        var cmpTarget3 = component.find('thisMonth');
        $A.util.removeClass(cmpTarget3, 'metro-active');
        
        // component.set("v.date"," ");
    },
    
 /*************************** getFilterByDate() function ***************************
 * Parameter Definition: component,page,recordToDisply pass from controller as parameter refrence
 * Purpose: this method return Event list with selected filter pass from controller it also keep the different properties
 **************************************************************************/    
       getFilterByDate: function(component,page,recordToDisply){
        
        var sortBy = component.get("v.SortBy"); 
        console.log("dateChange Event fire");
        var selectedDate = component.get("v.myDate")+'';
        console.log("Selected Date is: ", selectedDate);
        var action = component.get("c.eventByDate");
        
        //alert(selectedDate+" and "+ page+" and "+recordToDisply+" and "+sortBy);
        
        action.setParams({
            "selectedDate": selectedDate,
            "pageNumber": page,
            "recordToDisply": recordToDisply,
            "sortBy" : sortBy,
            
        });
        action.setCallback(this, function(a) {
            
            var result = a.getReturnValue();
            console.log('result ---->' + JSON.stringify(result));
            // set the component attributes value with wrapper class properties.
            
            
            component.set("v.events", result.events);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.ceil(result.total / recordToDisply));
            
            
            
            
        });
        
        $A.enqueueAction(action);
        
    },
 /*************************** getUpcoming() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method return total number of up coming Events and assign the value into "upComing" varible for component use
 **************************************************************************/    
   
    getUpcoming : function(component){
        var action = component.get("c.getUpcoming");
        action.setCallback(this, function(a) {    
            console.log('The UpComing Event(s)= '+a.getReturnValue());
            component.set("v.upComing", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
  /*************************** getToday() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method return total number of today Events and assign the value into "today" varible for component use
 **************************************************************************/    
       getToday : function(component){
        var action = component.get("c.getToday");
        action.setCallback(this, function(a) {    
            console.log('Today Event(s)= '+a.getReturnValue());
            component.set("v.today", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
 /*************************** getThisWeek() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method return total number of this week Events and assign the value into "thisWeek" varible for component use
 **************************************************************************/    
     getThisWeek : function(component){
        var action = component.get("c.getThisWeek");
        action.setCallback(this, function(a) {    
            console.log('This Week Event(s)= '+a.getReturnValue());
            component.set("v.thisWeek", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
  /*************************** getThisMonth() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method return total number of this Month Events and assign the value into "thisMonth" varible for component use
 **************************************************************************/    
    
     getThisMonth : function(component){
        var action = component.get("c.getThisMonth");
        action.setCallback(this, function(a) {    
            console.log('This Month Event(s)= '+a.getReturnValue());
            component.set("v.thisMonth", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
 /*************************** getRecordTypes() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method return total number of record type if exist and assign the value into "totalRecordType" varible for component logic use
 **************************************************************************/    
 
    getRecordTypes : function(component){
        var action = component.get("c.getTotalRecordTypes");
        action.setCallback(this, function(a) {    
            console.log('TotalRecordTypes Event Value = '+a.getReturnValue());
            component.set("v.totalRecordType", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },  
    
    /*************************** customRedirect() function ***************************
 * Parameter Definition: component,event pass from controller as parameter refrence
 * Purpose: this method is used to navigate the record its  fire $A.get("e.force:navigateToSObject"); and navigate to the selected record
 **************************************************************************/        
 
   
    customRedirect : function(component, event){
        var selectedItem = event.currentTarget;
        var selectedId = selectedItem.dataset.eventid;
        console.log("selected ID = "+selectedId);	
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            
            "recordId": selectedId,            
            "slideDevName": "detail"
            
        });
        
        navEvt.fire();
    },
    /***************************  callToServer() function ***************************
 * Parameter Definition:component, method, callback and params pass from controller as parameter refrence
 * Purpose: this method is used to get the record type list
 **************************************************************************/        
  
    callToServer : function(component, method, callback, params) {
        //alert('Calling helper callToServer function');
        var action = component.get(method);
        if(params){
            action.setParams(params);
        }
        //alert(JSON.stringify(params));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('Processed successfully at server');
                callback.call(this,response.getReturnValue());
            }else if(state === "ERROR"){
                alert('Problem with connection. Please try again.');
            }
        });
        $A.enqueueAction(action);
    }
    
    
})