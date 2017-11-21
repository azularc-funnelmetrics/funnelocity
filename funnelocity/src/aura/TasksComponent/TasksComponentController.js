/* Name: TasksComponentContrller.js
 * Last Modified: 09-23-2017
 * Modified By: FB
 * Description: 
 * This is a javascript controller for Task Component. This is used wigth TasksComponent.
 * controll the db operation between component and helper class call different actions
 * 
 */

/********************* doInit() function *********************/
/* This function is called first when component is loaded. This handles 
* get the record types, get the values of all action display on the component
*/ 
({
    doInit : function(component,event,helper) {
        
        //document.getElementById('style-5').style.setProperty('height', '10px');
        helper.clearActive(component,event);
        
        //component.set("v.url", window.location.origin);
        
        //Call Total recordtype method from helper
        helper.getRecordTypes(component); 
        
        
        //if record type then open record type modal window
        //if(total){    
        //  console.log('total');
        
        //call the record type list from the helper        
        helper.callToServer(
            component,
            "c.findRecordTypes",
            function(response) {
                if(response){
                    //alert(JSON.parse(response));
                    var jsonObject=JSON.parse(response);
                    
                    component.set('v.recordTypeList',jsonObject);  
                    component.set('v.task_selectedRecordType',jsonObject[0].recordTypeId); 
                }
            }, 
            {objName: 'Task'}
        ); 
        
        
        // }
        //ValidateYear('2017-08-22');
        
        //Call current date from helper     
        helper.getcurrentDate(component);       
        
        //Call last date from helper      
        helper.getlastDate(component);  
        
        //Call totalover due method from helper
        helper.getOverDue(component);
        
        //Call total Today method from helper
        helper.getToday(component);
        
        //Call total This Month method from helper
        helper.getThisMonth(component);
        
        //Call total All method from helper
        helper.getAllOpen(component);
        
        // this function call on the component load first time    
        // get the page Number if it's not define, take 1 as default
        var page =  1;
        // get the select option (drop-down) values.  
        
        var recordToDisply = component.get("v.maxLim")+''; 
        
        
        //Call Task List method from helper
        helper.getTaskList(component,'AllOpen',page, recordToDisply);
        
        var targetElement = component.find('AllOpen');        
        $A.util.addClass(targetElement,"metro-active");
        component.find("listViewSelection").set("v.value", 'AllOpen');
        component.find("selection").set("v.value", 'AllOpen');
        
        
    },
    
    /********************* switchStatics() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from action button, it updates the list according to the active action button
 * This actually call the selection button and call changeTasksFilter function of the helper class using the reference and pass parameters
 ****************************************************************/
    
    
    switchStatics : function(component,event,helper){
        
        
        helper.clearActive(component,event);
        //helper.resetPagination(component,event);
        
        
        var selectedItem = event.currentTarget;
        var selectVal = selectedItem.dataset.operationid;
        
        var targetElement = component.find(selectVal);        
        $A.util.addClass(targetElement,"metro-active");
        
        
        $A.util.addClass(targetElement,"metro-active");
        
        component.set("v.filterType", selectVal);
        
        var filterType = component.get("v.filterType"); 
        
        var page = 1
        var recordToDisply = component.get("v.maxLim")+'';                       
        
        //Call Task Change Filter method from helper
        helper.changeTasksFilter(component,event, filterType,page, recordToDisply);
    },
    
    /********************* changeFilter() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from avaliable top left , it updates the list according to the selected filter by default "My Tasks"
 * This actually call the top left filter  and call changeTasksFilter function of the helper class using the reference and pass parameters
 ****************************************************************/
    
    changeFilter:function(component,event,helper){
        
        helper.clearActive(component,event);
        
        var selectCmp = component.find("selection");
        var selectVal = selectCmp.get("v.value");
        
        var newValue="AllOpen";
        if(selectVal =='Today'){
            newValue = "Today";
            var targetElement = component.find("Today");
            
            $A.util.addClass(targetElement,"metro-active");
            //$('[data-operationid="Today"]').addClass('metro-active');               
            
            component.find("listViewSelection").set("v.value", newValue);
        }else {
            var targetElement = component.find(selectVal);
            
            $A.util.addClass(targetElement,"metro-active");
            
            component.find("listViewSelection").set("v.value", "AllOpen");
            
        }
        
        component.set("v.filterType", selectVal);            
        var filterType = component.get("v.filterType"); 
        
        var page = 1
        var recordToDisply = component.get("v.maxLim")+''; 
        //'.customlistView').val(newValue);
        //Call Task Change Filter method from helper
        helper.changeTasksFilter(component,event, filterType,page, recordToDisply);           
    },
    
    /********************* changeListView() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from avaliable list view filters , it updates the list according to the selected filter by default "All Open"
 * This actually call the list view filter  and call changeTasksFilter function of the helper class using the reference and pass parameters
 ****************************************************************/
    
    
    changeListView:function(component,event,helper){
        
        helper.clearActive(component,event);
        var selectCmp = component.find("listViewSelection");
        var selectVal = selectCmp.get("v.value");
        
        if(selectVal =='Today'){
            var targetElement = component.find("Today");
            $A.util.addClass(targetElement,"metro-active");
            //$('[data-operationid="Today"]').addClass('metro-active');
        }
        
        component.set("v.filterType", selectVal);
        
        var filterType = component.get("v.filterType"); 
        
        var page = 1
        var recordToDisply = component.get("v.maxLim")+''; 
        console.log("select Value"+selectVal);
        //Call Task Change Filter method from helper
        helper.changeTasksFilter(component,event, filterType,page, recordToDisply);
        
        
    },
    
    
    /********************* UpdateTask() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the taks, mostly when you are closing it or mark the task complete.
 * This actually call the updatedTask function of the helper class using the reference and pass parameters
 ****************************************************************/
    updateTask: function(component,event,helper){     
        //Call updateTask method from helper
        helper.updateTask(component,event);   
    }, 
    
    /* newTask() function
 * This function takes the component name and the event action  reference
 * This is called from new Task button
 */
    
    newTask : function(component, event) {            
        
        var total =component.get('v.totalRecordType');
        
        //if record type then open record type modal window
        if(total>1){                
            document.getElementById("record_type_dialogbackdrop").style.display = "block";
            document.getElementById("record_type_dialog").style.display = "block"
            // used for later use and will be removed after package **
                       
        } else {
            
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName":  "Task"
            });
            createRecordEvent.fire();
            
            
        }
        
    },
    /********************* Redirect() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to navigate to the selected record when you click or tap any record it call the helper method.
 * This actually call the customRedirect function of the helper class using the reference and pass parameters
 ****************************************************************/
    Redirect :function(component,event,helper){
        
        helper.customRedirect(component,event);    
        
    },
    
    /********************* showModal() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to show the ltc about modal window when click on the bottom image
 * This actually use javascript getElementById for refrence and update the property to display : Block  
 ****************************************************************/
    showModal : function(component, event, helper) {
        document.getElementById("modaldialog").style.display = "block";
        document.getElementById("dialogbackdrop").style.display = "block";
    },
    /********************* hideModal() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to Hide the ltc about modal window when click on the bottom image
 * This actually use javascript getElementById for refrence and update the property to display : none  
 ****************************************************************/
    
    hideModal : function(component,event, helper){
        document.getElementById("modaldialog").style.display = "none" ;
        document.getElementById("dialogbackdrop").style.display = "none" ;
    },
    
    /********************* previousPage() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from pagination , it updates the list according to the selected page
 * This actually call from the pagination and get preivouspage  and call getTaskList function of the helper class using the reference and pass parameters
 ****************************************************************/
    
    previousPage: function(component, event, helper) {
        
        var page = component.get("v.page") || 1;
        
        var direction = event.getSource().get("v.alternativeText");
        
        var recordToDisply = component.get("v.maxLim")+''; 
        
        page = direction === "Previous Page" ? (page - 1) : (page + 1);
        
        var filterType = component.get("v.filterType"); 
        
        //Call Task List method from helper
        helper.getTaskList(component,filterType,page, recordToDisply);
        
    },
    
    /*********************  nextPage() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from pagination , it updates the list according to the selected page
 * This actually call from the pagination and get  nextPage  and call getTaskList function of the helper class using the reference and pass parameters
 ****************************************************************/
    
    nextPage: function(component, event, helper) {
        
        var page = component.get("v.page") || 1;
        
        var direction = event.getSource().get("v.alternativeText");
        
        var recordToDisply = component.get("v.maxLim")+''; 
        page = direction === "Previous Page" ? (page - 1) : (page + 1);
        
        var filterType = component.get("v.filterType"); 
        
        //Call Task List method from helper
        helper.getTaskList(component,filterType,page, recordToDisply);
        
    },
    
    /*********************  firstPage() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from pagination , it updates the list according to the selected page
 * This actually call from the pagination and get  firstPage  and call getTaskList function of the helper class using the reference and pass parameters
 ****************************************************************/
    firstPage: function(component, event, helper) {
        
        var page =  1;
        
        //var direction = event.getSource().get("v.alternativeText");
        
        var recordToDisply = component.get("v.maxLim")+''; 
        
        //page = direction === "Previous Page" ? (page - 1) : (page + 1);
        
        var filterType = component.get("v.filterType"); 
        
        //Call Task List method from helper
        helper.getTaskList(component,filterType,page, recordToDisply);
        
    },
    
    /*********************  lastPage() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from pagination , it updates the list according to the selected page
 * This actually call from the pagination and get  lastPage  and call getTaskList function of the helper class using the reference and pass parameters
 ****************************************************************/
    
    lastPage: function(component, event, helper) {
        
        var page =   component.get("v.pages")
        
        //var direction = event.getSource().get("v.alternativeText");
        
        var recordToDisply = component.get("v.maxLim")+''; 
        
        //page = direction === "Previous Page" ? (page - 1) : (page + 1);
        
        var filterType = component.get("v.filterType"); 
        
        //Call Task List method from helper
        helper.getTaskList(component,filterType,page, recordToDisply);
        
    },
    
    /********************* onconfirm() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to navigate to the selected record type if records type exist when you click or tap on next button in record type modal window it fire lightning Create Event.
 * This actually call the $A.get("e.force:createRecord"); with selected record type 
 ****************************************************************/
    onconfirm : function(component, event, helper){
        //alert('confirm get called');
        var objName ='Task';
        //alert(objName);
        var selectedRecType=component.get('v.task_selectedRecordType');
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName":  objName,
            "recordTypeId": selectedRecType
        });
        createRecordEvent.fire();
        //close the record type modal when new even fire
        document.getElementById("record_type_dialogbackdrop").style.display = "none" ;
        document.getElementById("record_type_dialog").style.display = "none" ;
        
        
    },
    
    /********************* onChange() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to updated selected record type if records type exist when you click or tap on Record type list in record type modal window it assign the selected value into variable.
 * This actually set the selected record type value to the variable "task_selectedRecordType"
 ****************************************************************/
    onChange : function(component, event, helper) {
        var value = event.getSource().get("v.text");
        component.set('v.task_selectedRecordType', value);
    },
    
    /********************* defaultCloseAction() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to close the record type modal window when click on the cancel button
 * This actually use javascript getElementById for refrence and update the property to display : none  
 ****************************************************************/
    
    defaultCloseAction : function(component, event, helper) {
        document.getElementById("record_type_dialogbackdrop").style.display = "none" ;
        document.getElementById("record_type_dialog").style.display = "none" ;
        
    }
    
    
})