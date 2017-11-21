/* Name: EventsComponentContrller.js
 * Last Modified: 09-27-2017
 * Modified By: FB
 * Description: 
 * This is a javascript controller for Event Component. 
 * controll the db operation between component and helper class call different actions
 * 
 */

/********************* doInit() function *********************/
/* This function is called first when component is loaded. This handles 
* get the record types, get the values of all action display on the component
*/ 
({
    doInit : function(component,event,helper) {
        component.set("v.myDate", "");
        //Call getEventList method from helper
        helper.clearActive(component,event);
        
        //Call Total recordtype method from helper
        helper.getRecordTypes(component);       
        //call the record type list from the helper      
         
            helper.callToServer(
                component,
                "c.findRecordTypes",
                function(response) {
                    if(response){
                    //alert(JSON.parse(response));
                    var jsonObject=JSON.parse(response);
                    component.set('v.recordTypeList',jsonObject);  
                    component.set('v.e_selectedRecordType',jsonObject[0].recordTypeId); 
                    }
                    }, 
                {objName: 'Event'}
            ); 
        
        
        var page =  1;
        // get the select option (drop-down) values.  
        
        var recordToDisply = component.get("v.maxLim")+''; 
        
        component.set("v.filterType", 'upcoming');
        
        helper.getEventList(component,'upcoming',page, recordToDisply);
        
        //Call getUpcoming method from helper
        helper.getUpcoming(component);
        
        //Call getToday method from helper
        helper.getToday(component);
        
        //Call getThisWeek method from helper
        helper.getThisWeek(component);
        
        //Call getThisMonth method from helper
        helper.getThisMonth(component);        
        var targetElement = component.find("upcoming");        
        $A.util.addClass(targetElement,"metro-active"); 
        
        
    },
    /********************* Redirect() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to navigate to the selected record when you click or tap any record it call the helper method.
 * This actually call the customRedirect function of the helper class using the reference and pass parameters
 ****************************************************************/
    Redirect :function(component,event,helper){
        
        //Call customRedirect method from helper
        helper.customRedirect(component,event);
        
    },  
    /********************* dateChange() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to keep the selected date value from date picker 
 * This actually call when click or tap on date picker and this function update the event list according to the selected date
 ****************************************************************/
    
    dateChange: function(component, event, helper) {
        
        var dateval = component.get("v.myDate");
        console.log('#dateval'+dateval)
        if(dateval !=''){
            //Call getFilterByDate method from helper
            //helper.clearActive(component,event);
            helper.clearActive(component,event);
            
            component.set("v.filterType", 'dateEvent');
            var page =  1;
            // get the select option (drop-down) values.  
            
            var recordToDisply = component.get("v.maxLim")+''; 
            console.log('ssss');
            
            helper.getFilterByDate(component,page,recordToDisply);
            
        }
        
        
    },
    
    /********************* switchEvent() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from the selected action button , it updates the list according to the selected action default "Upcoming"
 * This actually call when tap or click on the actions button and call getEventList function of the helper class using the reference and pass parameters
 ****************************************************************/
    switchEvent : function(component,event,helper){
        
        // used for later use and will be removed after package **
        /*      var arr = [];
    arr = component.find("main").getElement().childNodes;
    console.log(event.target+'idby');
    for(var cmp in component.find("main").getElement().childNodes) {
        
        $A.util.removeClass(arr[cmp], "metro-active");
            //$A.util.toggleClass(arr[cmp], "metro-active");
    }
    
        console.log('elements'+arr); */
        
        helper.clearActive(component,event);
        
        //var dateField = component.find("dateValue");
        //dateField.set("v.value",'');
        
        component.set("v.myDate", "");
        
        
        
        
        var selectedItem = event.currentTarget;
        var eventId = selectedItem.dataset.operationid;
        var targetElement = component.find(eventId);
        
        $A.util.addClass(targetElement,"metro-active");  
        
        
        component.set("v.filterType", eventId);
        
        var filterType = component.get("v.filterType"); 
        
        // used for later use and will be removed after package **
        // $A.util.addClass(targetElement,"metro-active");        
        /*
        $('div.col3').removeClass('metro-active');	
        $('div.col3').on("click", function(e) {
            console.log("Fire");
            e.preventDefault();
            $(this).addClass('metro-active');
            
        });
        */
        
        var page = 1;
        var recordToDisply = component.get("v.maxLim")+'';  
        
        //Call EventList Filter method from helper
        helper.getEventList(component,filterType,page, recordToDisply);
        
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
    
    
    /* newEvent() function
 * This function takes the component name and the event action  reference
 * This is called from new Event button
 */
    newEvent : function(component, event,helper) {
        
        var total =component.get('v.totalRecordType');
        
        //if record type then open record type modal window
        if(total>1){
            
            document.getElementById("event_record_type_dialogbackdrop").style.display = "block";
            document.getElementById("event_record_type_dialog").style.display = "block"
            
          
        } else {
            
            
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName":  "Event"
            });
            createRecordEvent.fire();         
            
        }                
    },
    
    /********************* previousPage() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from pagination , it updates the list according to the selected page
 * This actually call from the pagination and get preivouspage  and call getEventList function of the helper class using the reference and pass parameters
 ****************************************************************/
    
    previousPage: function(component, event, helper) {
        
        var page = component.get("v.page") || 1;
        
        var direction = event.getSource().get("v.alternativeText");
        
        var recordToDisply = component.get("v.maxLim")+''; 
        
        page = direction === "Previous Page" ? (page - 1) : (page + 1);
        
        var filterType = component.get("v.filterType"); 
        
        //Call Task List method from helper
        helper.getEventList(component,filterType,page, recordToDisply);
        
    },
    
    /*********************  nextPage() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from pagination , it updates the list according to the selected page
 * This actually call from the pagination and get  nextPage  and call getEventList function of the helper class using the reference and pass parameters
 ****************************************************************/
    
    nextPage: function(component, event, helper) {
        
        var page = component.get("v.page") || 1;
        
        var direction = event.getSource().get("v.alternativeText");
        
        var recordToDisply = component.get("v.maxLim")+''; 
        page = direction === "Previous Page" ? (page - 1) : (page + 1);
        
        var filterType = component.get("v.filterType"); 
        
        //Call Task List method from helper
        helper.getEventList(component,filterType,page, recordToDisply);
        
    },
    
    /*********************  firstPage() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from pagination , it updates the list according to the selected page
 * This actually call from the pagination and get  firstPage  and call getEventList function of the helper class using the reference and pass parameters
 ****************************************************************/
    
    firstPage: function(component, event, helper) {
        
        var page =  1;
        
        //var direction = event.getSource().get("v.alternativeText");
        
        var recordToDisply = component.get("v.maxLim")+''; 
        
        //page = direction === "Previous Page" ? (page - 1) : (page + 1);
        
        var filterType = component.get("v.filterType"); 
        
        //Call Task List method from helper
        helper.getEventList(component,filterType,page, recordToDisply);
        
    },
    /*********************  lastPage() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to update the list from pagination , it updates the list according to the selected page
 * This actually call from the pagination and get  lastPage  and call getEventList function of the helper class using the reference and pass parameters
 ****************************************************************/
    
    lastPage: function(component, event, helper) {
        
        var page =   component.get("v.pages")
        
        //var direction = event.getSource().get("v.alternativeText");
        
        var recordToDisply = component.get("v.maxLim")+''; 
        
        //page = direction === "Previous Page" ? (page - 1) : (page + 1);
        
        var filterType = component.get("v.filterType"); 
        
        //Call Task List method from helper
        helper.getEventList(component,filterType,page, recordToDisply);
        
    },
    
    /********************* onconfirm() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to navigate to the selected record type if records type exist when you click or tap on next button in record type modal window it fire lightning Create Event.
 * This actually call the $A.get("e.force:createRecord"); with selected record type 
 ****************************************************************/
    
    onconfirm : function(component, event, helper){
        //alert('confirm get called');
        var objName ='Event';
        //alert(objName);
        var selectedRecType=component.get('v.e_selectedRecordType');
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName":  objName,
            "recordTypeId": selectedRecType
        });
        createRecordEvent.fire();
        //close the record type modal when new even fire
        document.getElementById("event_record_type_dialogbackdrop").style.display = "none" ;
        document.getElementById("event_record_type_dialog").style.display = "none" ;
        
        //  alert('selected recordtype:'+selectedRecType);
    },
    
    /********************* onChange() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to updated selected record type if records type exist when you click or tap on Record type list in record type modal window it assign the selected value into variable.
 * This actually set the selected record type value to the variable "selectedRecordType"
 ****************************************************************/
    onChange : function(component, event, helper) {
        var value = event.getSource().get("v.text");
        component.set('v.e_selectedRecordType', value);
    },
    /********************* defaultCloseAction() function *******************
 * This function takes the component name, the event action and helper class reference
 * This is used to close the record type modal window when click on the cancel button
 * This actually use javascript getElementById for refrence and update the property to display : none  
 ****************************************************************/
    defaultCloseAction : function(component, event, helper) {
        document.getElementById("event_record_type_dialogbackdrop").style.display = "none" ;
        document.getElementById("event_record_type_dialog").style.display = "none" ;
        
    }
    
    
})