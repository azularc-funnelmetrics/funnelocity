/*
    Author:  Carine DMello
    Created On: 11/19/2017
    This trigger updates fields on the Sales rep profile object
    It is triggered every time a Sales profile is inserted/updated
*/

trigger FunnelSalesProfile on Sales_Rep_Profile__c (after insert, after update) {    
    
    //List to store the ids of sales mangers of the sales representative profiles that are inserted or updated
    List<Id> salesMgrs = new List<Id>();
    
    //Fetch the manager record ids of the sales profiles that have been updated        
    salesMgrs = FunnelTriggerBatchHelper.fetchMgrIdsForSalesRep(Trigger.new,Trigger.oldMap);
    
    system.debug(' salesMgrs '+salesMgrs);
    
    //List to store the manger ids to be updated
    List<Sales_Rep_Profile__c> mgrsToUpdate = new List<Sales_Rep_Profile__c>();
    
    //Using the manager ids, fetch the manager records with the new values calculated for aggregated active opptys and aggregated quota             
    mgrsToUpdate = FunnelTriggerBatchHelper.fetchMgrRecordsToUpdate(salesMgrs);
    
    //update the manager records with the updated quotas
    update mgrsToUpdate;
       
}