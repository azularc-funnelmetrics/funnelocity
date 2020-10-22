/*
    Author:  Carine DMello
    Created On: 11/3/2017
    This trigger updates fields on the Sales rep profile object associated with an opportunity
    It is triggered each time an opportunity is inserted or updated
    Copyright: Funnel Metrics LLC
*/

trigger FunnelOpportunityTrigger on Opportunity (after insert, after update) {
    
     system.debug('Start of trigger'+Limits.getCpuTime());   
    
    //Set to store the sales rep id's that are associated with the inserted/updated opportunities
    Set<Id> salesProfIds = new Set<Id>();        
    
    New_Data_load_setting__mdt[] mtDt = [SELECT Bypass__c FROM New_Data_load_setting__mdt LIMIT 1];
    Fiscal_Year_Setting__c fy = Fiscal_Year_Setting__c.getValues('Current_Year');
    
    if((test.isRunningTest() && fy != null   ) || (fy != null  && mtDt != null && mtDt.size() > 0 &&  !mtDt[0].Bypass__c ) || (mtDt == NULL && fy != null ) ){
    
    //if(mtDt == NULL || (mtDt != null && mtDt.size() == 0) || test.isRunningTest() || (mtDt != null && mtDt.size() > 0 && !mtDt[0].Bypass__c)){
    
        system.debug(' inside oppty trigger ');
    
        try{
            //Increment/Decrement the counter fields on sales profile
            //Close rate monthly/quarterly/ytd opp count/amount
            if(trigger.isupdate){
                system.debug('Inside Update');
                FunnelTriggerBatchHelper.updateSalesProfsCounter(Trigger.newMap,Trigger.oldMap,Trigger.new);
              } 
         }
         catch(Exception ex){
            System.debug('FunnelOpportunityTrigger Exception occured: '+ ex+' Line number: '+ex.getLineNumber());
            FunnelTriggerBatchHelper.sendErrorMail(ex.getMessage()+' '+ex.getStackTraceString()); 
         } 
         
         system.debug('Checkpoint 1 trigger'+Limits.getCpuTime());
         
         try{
            //increment a counter if a QO opp is created
            if(trigger.isinsert){
                system.debug(' insert scenario ');
                FunnelTriggerBatchHelper.updateSalesProfsCounterQO(Trigger.newMap,Trigger.new);
            }
         }
         catch(Exception ex){
            System.debug('FunnelOpportunityTrigger Exception occured: '+ ex+' Line number: '+ex.getLineNumber());
            FunnelTriggerBatchHelper.sendErrorMail(ex.getMessage()+' '+ex.getStackTraceString()); 
         }
         
         try{        
            //Fetch all the sales profiles that are associated with the updated opportunities    
            salesProfIds = FunnelTriggerBatchHelper.fetchRelatedOwners(Trigger.new, Trigger.old);
            
            system.debug(' salesProfIds '+salesProfIds);
                
            //Map to store the sales profiles to be updated
            Map<id, Sales_Rep_Profile__c> profMap = new Map<id, Sales_Rep_Profile__c>();    
        
            //If there are any sales profiles associated to the inserted/updated opportunities
            //The corresponding YTD fields and correct active opportunities fields are updated
            if(salesProfIds != null){       
                profMap =  FunnelTriggerBatchHelper.fetchSalesProfileUpdatedMapFromOwners(salesProfIds,null);           
            }    
            
            system.debug('Checkpoint 2 trigger'+Limits.getCpuTime());
            
            //system.debug(' profMap.values() '+profMap.values());
            
            //If a sales profile was previously associated with an opportunity and is not associated with any opportunity now
            //Current active opportunities field should be updated to 0     
            if(salesProfIds != null && salesProfIds.size() > 0 && salesProfIds.size() != profMap.values().size()){        
                FunnelTriggerBatchHelper.updateSalesProfsNotAssociatedWithAnyOpptyUsingOwner(salesProfIds,profMap);
            }
            
            //system.debug(' profMap.values() '+profMap.values());
            
            List<Sales_Rep_Profile__c> profValues = profMap.values();
            
            //Update all the sales representative profiles that have been updated
            if(profMap != null && profMap.size() > 0){
                update profMap.values();
            }
            
            system.debug('Checkpoint 3 trigger'+Limits.getCpuTime());
            
            //system.debug(' profValues are '+profValues);
         }
         catch(Exception ex){
            System.debug('FunnelOpportunityTrigger Exception occured: '+ ex+' Line number: '+ex.getLineNumber());
            FunnelTriggerBatchHelper.sendErrorMail(ex.getMessage()+' '+ex.getStackTraceString()); 
         }
    }
    system.debug('End of trigger'+Limits.getCpuTime());   
}