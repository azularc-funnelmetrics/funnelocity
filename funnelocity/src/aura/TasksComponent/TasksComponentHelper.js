/* Name: TasksComponentHelper.js
 * Last Modified: 09-23-2017
 * Modified By: FB
 * Description: 
 * This is a javascript helper library for Task Component controller. This is used wigth TasksComponent.
 */


/*************************** getTaskList() function ***************************
 * Parameter Definition: component,filterType,page, recordToDisply pass from controller as parameter refrence
 * Purpose: this method return the task list with given filter and properties set by components it call from different methods of controller.js with different properties
 **************************************************************************/    
({
    getTaskList : function(component,filterType,page, recordToDisply) {
        
        var sortBy = component.get("v.SortBy"); 
        var isNullFirst = component.get("v.isNullFirst");     
        var action = component.get("c.TaskList");      
        
        console.log('result ----# fltr' + filterType + ' pagenu'+page+' recr'+recordToDisply);
        action.setParams({
            "fltr": filterType,
            "pageNumber": page,
            "recordToDisply": recordToDisply,
            "sortBy" :  sortBy,
            "isNullFirst" : isNullFirst,
        });
        action.setCallback(this, function(a) {
            // store the response return value (wrapper class insatance)  
            var result = a.getReturnValue();
            console.log('result ---->' + JSON.stringify(result));
            // set the component attributes value with wrapper class properties.
            component.set("v.Tasks", result.tasks);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.ceil(result.total / recordToDisply));
        });
        $A.enqueueAction(action);
    },
 
 /*************************** changeTasksFilter() function ***************************
 * Parameter Definition: component,event,filterType,page, recordToDisply pass from controller as parameter refrence
 * Purpose: this method return task list with selected filter pass from controller it also keep the different properties
 **************************************************************************/    
    changeTasksFilter :function(component,event,filterType,page, recordToDisply) {
        var sortBy = component.get("v.SortBy"); 
        var isNullFirst = component.get("v.isNullFirst"); 
        
        var action = component.get("c.TaskList");
        
        action.setParams({
            "fltr": filterType,         
            "pageNumber": page,
            "recordToDisply": recordToDisply,
            "sortBy" :  sortBy,
            "isNullFirst" : isNullFirst,
            
        });
        action.setCallback(this, function(a) {
            // store the response return value (wrapper class insatance)  
            var result = a.getReturnValue();
            console.log('result ---->' + JSON.stringify(result));
            // set the component attributes value with wrapper class properties.
            
            
            component.set("v.Tasks", result.tasks);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.ceil(result.total / recordToDisply));
            
        });
        $A.enqueueAction(action);
        
    },
    
/*************************** updateTask() function ***************************
 * Parameter Definition: component,event  pass from controller as parameter refrence
 * Purpose: this method update the selected task status to close or open by checkbox action it calls from controller to perfrom the action
 **************************************************************************/    
    updateTask: function (component,event){
        console.log("helper Fire");
        var id =  event.getSource().get("v.text");
        var statusValue=event.getSource().get("v.value");
        //var id = event.source.get("v.text");
        //var statusValue= event.source.get("v.value");
        console.log("Task Id  ="+id+" and status="+statusValue);
        var messageStatus = statusValue > 0 ? "Closed" : "In Progress";
        console.log("Task Id  ="+id+" and status="+statusValue);
        var action = component.get("c.closeTask");
        action.setParams({
            "taskId": id,
            "status":statusValue
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            // Display toast message to indicate load status
            var toastEvent = $A.get("e.force:showToast");
            if(action.getState() ==='SUCCESS'){
                toastEvent.setParams({
                    "title": "Success!",
                    "message": " Your Task Status have been updated to "+messageStatus+" successfully."
                });
                
            }
            else{
                toastEvent.setParams({
                    "title": "Error!",
                    "message": " Something has gone wrong."
                });
            }
            toastEvent.fire();
        });
        $A.enqueueAction(action);
        
        
        
    },    

/*************************** getOverDue() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method return total number of over due task and assign the value into "overDue" varible for component use
 **************************************************************************/    
    getOverDue : function(component){
        var action = component.get("c.getOverDue");
        action.setCallback(this, function(a) {    
            console.log('overDue Total Tasks Value = '+a.getReturnValue());
            component.set("v.overDue", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
  /*************************** getRecordTypes() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method return total number of record type if exist and assign the value into "totalRecordType" varible for component logic use
 **************************************************************************/    
 
    getRecordTypes : function(component){
                
        var action = component.get("c.getTaskTotalRecordTypes");
        action.setCallback(this, function(a) {    
            console.log('TotalRecordTypes Tasks Value = '+a.getReturnValue());
            component.set("v.totalRecordType", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },    
   
/*************************** getToday() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method return total number of today task and assign the value into "Today" varible for component use
 **************************************************************************/    
    getToday : function(component){
        var action = component.get("c.getToday");
        action.setCallback(this, function(a) {    
            console.log('Today Total Tasks Value = '+a.getReturnValue());
            component.set("v.Today", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
/*************************** getThisMonth() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method return total number of this month task and assign the value into "thisMonth" varible for component use
 **************************************************************************/    
     getThisMonth : function(component){
        var action = component.get("c.getThisMonth");
        action.setCallback(this, function(a) {    
            console.log('This Month Total Tasks Value = '+a.getReturnValue());
            component.set("v.thisMonth", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
/***************************  getAllOpen() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method return total number of All open task and assign the value into "allOpen" varible for component use
 **************************************************************************/    
    getAllOpen : function(component){
        var action = component.get("c.getAllOpen");
        action.setCallback(this, function(a) {    
            console.log('This All Open Total Tasks Value = '+a.getReturnValue());
            component.set("v.allOpen", a.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },

/*************************** customRedirect() function ***************************
 * Parameter Definition: component,event pass from controller as parameter refrence
 * Purpose: this method is used to navigate the record its  fire $A.get("e.force:navigateToSObject"); and navigate to the selected record
 **************************************************************************/        
    customRedirect : function (component, event){
        
        var selectedItem = event.currentTarget;
        var selectedId = selectedItem.dataset.taskid;
        
        console.log("selected ID = "+selectedId);	
        
        
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            
            "recordId": selectedId,
            
            "slideDevName": "detail"
            
        });
        
        navEvt.fire(); 
        
    },

/***************************  getlastDate() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method is used to get the last date of the year and assign the value into "yearLastDate" variable for component use
 **************************************************************************/        
     getlastDate : function(component) {
        
        var action = component.get("c.LastDate");
        action.setCallback(this, function(a) {
            console.log(a.getReturnValue());
            component.set("v.yearLastDate", a.getReturnValue());
        });
        $A.enqueueAction(action);
        
    },

/***************************  getcurrentDate() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method is used to get the current date and assign the value into "currentDate" variable for component use
 **************************************************************************/        
       getcurrentDate : function(component) {
        
        var action = component.get("c.currentDate");
        action.setCallback(this, function(a) {
            console.log(a.getReturnValue());
            component.set("v.currentDate", a.getReturnValue());
        });
        $A.enqueueAction(action);
        
    },

/***************************  clearActive() function ***************************
 * Parameter Definition: component pass from controller as parameter refrence
 * Purpose: this method is used to clear the current selected action and revert the setting to default
 **************************************************************************/        
     clearActive : function(component,event) {
        
        var cmpTarget = component.find('Overdue');
        $A.util.removeClass(cmpTarget, 'metro-active');
        
        var cmpTarget1 = component.find('Today');
        $A.util.removeClass(cmpTarget1, 'metro-active');
        
        var cmpTarget2 = component.find('ThisMonth');
        $A.util.removeClass(cmpTarget2, 'metro-active');
        
        var cmpTarget3 = component.find('AllOpen');
        $A.util.removeClass(cmpTarget3, 'metro-active');
        
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