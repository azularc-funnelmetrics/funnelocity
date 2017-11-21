/*
    Author:  Carine DMello
    Created On: 11/3/2017
    This trigger updates fields on the Sales rep profile object associated with an opportunity
    It is triggered each time an opportunity is inserted or updated
*/

trigger FunnelOpportunity on Opportunity (after insert, after update) {
    
    //Set to store the sales rep id's that are associated with the inserted/updated opportunities
    Set<Id> salesProfIds = new Set<Id>();        
    
    //Fetch all the sales profiles that are associated with the updated opportunities
    salesProfIds = FunnelTriggerBatchHelper.fetchRelatedSalesProfiles(Trigger.new, Trigger.old);        
    
    //Map to store the sales profiles to be updated
    Map<id, Sales_Rep_Profile__c> profMap = new Map<id, Sales_Rep_Profile__c>();
    
    //If there are any sales profiles associated to the inserted/updated opportunities
    //The corresponding YTD fields and correct active opportunities fields are updated
    if(salesProfIds != null){       
        profMap =  FunnelTriggerBatchHelper.fetchSalesProfileUpdatedMap(salesProfIds);           
    }    
    
    //If a sales profile was previously associated with an opportunity and is not associated with any opportunity now
    //Current active opportunities field should be updated to 0     
    if(salesProfIds != null && salesProfIds.size() > 0 && salesProfIds.size() != profMap.values().size()){        
        FunnelTriggerBatchHelper.updateSalesProfsNotAssociatedWithAnyOppty(salesProfIds,profMap);
    }
    
    system.debug(' profMap.values() '+profMap.values());
    
    //Update all the sales representative profiles that have been updated
    if(profMap != null && profMap.size() > 0){
        update profMap.values();
    }
}