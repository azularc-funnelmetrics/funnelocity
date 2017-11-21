/*
    Author:  Carine DMello
    Created On: 11/20/2017
    This class is a
*/

public with sharing class FunnelTriggerBatchHelper{

    public static List<Id> fetchMgrIdsForSalesRep(List<Sales_Rep_Profile__c> sReps, Map<Id, Sales_Rep_Profile__c> oldMap){
        
        List<Id> salesMgrs = new List<Id>();
        
        for(Sales_Rep_Profile__c sp: sReps){
    
            if(trigger.isInsert)
            {
                if(sp.Sales_Manager__c != null){
                    salesMgrs.add(sp.Sales_Manager__c); 
                }
            }
                            
            //If the quota amount is updated/the sales manager is updated
            //store the ids of the sales manager in a list
            if( 
                  (  
                    trigger.isUpdate 
                      && 
                    (
                      (oldMap.get(sp.Id).Annual_Quota_Amount__c != sp.Annual_Quota_Amount__c)  
                      ||
                      (oldMap.get(sp.Id).Sales_Manager__c != sp.Sales_Manager__c)
                      ||
                      (oldMap.get(sp.Id).Current_Active_Opportunities__c != sp.Current_Active_Opportunities__c)
                      ||
                      (oldMap.get(sp.Id).Aggregated_current_active_opptys__c != sp.Aggregated_current_active_opptys__c)
                      ||
                      (oldMap.get(sp.Id).Aggregated_Annual_Quota__c != sp.Aggregated_Annual_Quota__c)
                    )                 
                  )
              )
              {
                   if(sp.Sales_Manager__c != null){
                       
                       salesMgrs.add(sp.Sales_Manager__c); 
                       /*
                       if(System.Trigger.oldMap.get(sp.Id).Current_Active_Opportunities__c != sp.Current_Active_Opportunities__c){
                           
                           if(activeOppsUpdateMap != null && !activeOppsUpdateMap.containsKey(sp.Sales_Manager__c)){
                               if(System.Trigger.oldMap.get(sp.Id).Current_Active_Opportunities__c != null){
                                   activeOppsUpdateMap.put(sp.Sales_Manager__c,(Integer)(sp.Current_Active_Opportunities__c - System.Trigger.oldMap.get(sp.Id).Current_Active_Opportunities__c));                       
                               }
                           }
                           else if(activeOppsUpdateMap != null && activeOppsUpdateMap.containsKey(sp.Sales_Manager__c)){
                               
                               Integer newVal = activeOppsUpdateMap.get(sp.Sales_Manager__c) + (Integer)(sp.Current_Active_Opportunities__c - System.Trigger.oldMap.get(sp.Id).Current_Active_Opportunities__c);
                               
                               activeOppsUpdateMap.put(sp.Sales_Manager__c,newVal);                       
                           }
                       }*/
                       
                       if(oldMap.get(sp.Id).Sales_Manager__c != sp.Sales_Manager__c
                          &&                                 
                          (oldMap.get(sp.Id).Sales_Manager__c != null)){
                           
                           salesMgrs.add(oldMap.get(sp.Id).Sales_Manager__c);    
                           
                       }
                   }  
                   
                   if(
                          oldMap.get(sp.Id).Sales_Manager__c != sp.Sales_Manager__c
                          &&                                 
                          (oldMap.get(sp.Id).Sales_Manager__c != null)
                          &&
                          sp.Sales_Manager__c == null
                      )
                   {
                           
                       salesMgrs.add(oldMap.get(sp.Id).Sales_Manager__c);    
                       
                   }                            
              }
              
              //system.debug(' activeOppsUpdateMap '+activeOppsUpdateMap);
              
              
        } 
        
        return salesMgrs;   
    
    }
    
    public static List<Sales_Rep_Profile__c> fetchMgrRecordsToUpdate(List<Id> salesMgrsIds){
    
        //List to store the manger ids to be updated
        List<Sales_Rep_Profile__c> mgrsToUpdate = new List<Sales_Rep_Profile__c>();       
        
        //Fetch all the sales profile records that are associated with the managers
        //List<Sales_Rep_Profile__c> salesRepRecords = [SELECT Id, Month_1_Quota_Amount__c, Month_2_Quota_Amount__c, Month_3_Quota_Amount__c, Month_4_Quota_Amount__c, Month_5_Quota_Amount__c, Month_6_Quota_Amount__c, Month_7_Quota_Amount__c, Month_8_Quota_Amount__c, Month_9_Quota_Amount__c, Month_10_Quota_Amount__c, Month_11_Quota_Amount__c, Month_12_Quota_Amount__c,Sales_Manager__c FROM Sales_Rep_Profile__c WHERE Sales_Manager__c IN :salesMgrs];    
        Map<Id, Sales_Rep_Profile__c> salesMgrProfMap = new Map<Id, Sales_Rep_Profile__c>([SELECT Id, Annual_Quota_Amount__c, Current_Active_Opportunities__c, Sales_Manager__c FROM Sales_Rep_Profile__c WHERE Id IN :salesMgrsIds]);
        
        List<AggregateResult> salesRepRecordsAggr = [SELECT SUM(Annual_Quota_Amount__c) s, SUM(Current_Active_Opportunities__c ) c, Sales_Manager__c sm FROM Sales_Rep_Profile__c WHERE Sales_Manager__c IN :salesMgrsIds GROUP BY Sales_Manager__c];       
        
        system.debug(' salesMgrProfMap  '+salesMgrProfMap);
        
        system.debug(' salesRepRecordsAggr '+salesRepRecordsAggr);
        
        for(AggregateResult ar: salesRepRecordsAggr){
            
            Sales_Rep_Profile__c mgr = new Sales_Rep_Profile__c();
            mgr.id = (Id)ar.get('sm');
            
            if(salesMgrProfMap.get(mgr.id).Current_Active_Opportunities__c == null)
                salesMgrProfMap.get(mgr.id).Current_Active_Opportunities__c = 0;    
            
            mgr.Aggregated_current_active_opptys__c = (Decimal)ar.get('c');   
            mgr.Aggregated_Annual_Quota__c = (Decimal)ar.get('s');
            
            /*
            if(activeOppsUpdateMap.get(mgr.id) != null){
                mgr.Aggregated_current_active_opptys__c = mgr.Aggregated_current_active_opptys__c + activeOppsUpdateMap.get(mgr.id); 
            }
            */
            
            mgrsToUpdate.add(mgr);  
        }
        
        system.debug('mgrsToUpdate '+mgrsToUpdate);
        
        return mgrsToUpdate;
    }
    
    public Static Date getFiscalYearDate(String recName){
    
        Fiscal_Year_Setting__c fy = Fiscal_Year_Setting__c.getValues(recName);
        
        if(fy != null)
            return fy.Start_Date__c;
        else
            return null;
    }
    
    public Static Fiscal_Year_Setting__c getFiscalYearRecord(String recName){
    
        Fiscal_Year_Setting__c fy = Fiscal_Year_Setting__c.getValues(recName);
        
        return fy;
    }
    
    public Static Set<Id> fetchRelatedSalesProfiles(List<Opportunity> newVals, List<Opportunity> oldVals){
        
        Set<Id> salesProfIds = new Set<Id>();
        
        Date currentFiscalYear = getFiscalYearDate('Current_Year');
        
        //Fetch all the sales profiles associated with the opportunities (both the old and new values)
        for (Opportunity o : newVals){ 
            
            if(currentFiscalYear == null){
                o.addError('The fiscal year start date is not set');
            }
        
            if(o.Sales_Rep_Profile__c != null){ 
                 salesProfIds.add(o.Sales_Rep_Profile__c);
            }
                
        }
        
        //Fetch the sales profiles associated with the opportunities before the update
        if(trigger.isUpdate){
            for (Opportunity o : oldVals){ 
                system.debug(' old '+o);  
                if(o.Sales_Rep_Profile__c != null){ 
                     salesProfIds.add(o.Sales_Rep_Profile__c);
                }
            }
        }
        
        return salesProfIds;
        
    }
    
    public Static Map<Id,Sales_Rep_Profile__c> fetchSalesProfileUpdatedMap(Set<Id> salesProfIds){
            
        Date currentFiscalYear = getFiscalYearDate('Current_Year');
        
        //Map to store the sales profiles to be updated
        Map<id, Sales_Rep_Profile__c> profMap = new Map<id, Sales_Rep_Profile__c>();
        
        //Fetch the count of closed opportunities, sum of revenue, avg of days to close an opportunity for all the sales profiles
        List<AggregateResult> listRepsClosedOpps = [SELECT COUNT(id) c, SUM(Amount) s, AVG(Days_for_closure__c) av, Sales_Rep_Profile__c sr FROM Opportunity WHERE StageName = 'Closed Won' AND CloseDate >= :currentFiscalYear AND Sales_Rep_Profile__c IN :salesProfIds GROUP BY Sales_Rep_Profile__c];    
        
        //Fetch the count of open opportunities associated with every sales profile
        List<AggregateResult> listRepsOpenOpps = [SELECT COUNT(id) c, Sales_Rep_Profile__c sr FROM Opportunity WHERE (StageName != 'Closed Won' AND StageName != 'Closed Lost' AND StageName != NULL) AND Sales_Rep_Profile__c IN :salesProfIds GROUP BY Sales_Rep_Profile__c]; 
        
        for(AggregateResult ar: listRepsClosedOpps){
            
            //Populate the fields on the sales profile related to closed opportunities
            Sales_Rep_Profile__c s = new Sales_Rep_Profile__c(); 
            s.id = (Id)ar.get('sr');
            s.YTD_Opportunities_won__c = (Integer)ar.get('c'); 
            s.YTD_Revenue__c = (Decimal)ar.get('s');
            s.YTD_Average_Sales_Cycle__c = (Decimal)ar.get('av');
            
            //Variable to indicate whether there are any open opporunities associated with the sales profile we are updating 
            Boolean openOppsFound = false;
            
            //Iterate thorugh all the sales profiles associated with open opportunities and update current active opportunities field
            for(AggregateResult arO: listRepsOpenOpps){
                
                if(ar.get('sr') == arO.get('sr')){
                
                    s.Current_Active_Opportunities__c = (Integer)arO.get('c');
                    openOppsFound = true;
                    break;
                }    
            }
            
            //If no open opportunities are found, the current active opportunities field is set to 0
            if(!openOppsFound){
                s.Current_Active_Opportunities__c = 0;
            }
            
            profMap.put(s.id,s);          
        }
        
        for(AggregateResult arO: listRepsOpenOpps){
            //If a sales profile is associated only with open opportunities and not closed, the current active opptys field should be updated    
            if(!profMap.keySet().contains((Id)arO.get('sr'))){
                Sales_Rep_Profile__c s = new Sales_Rep_Profile__c();
                s.id = (Id)arO.get('sr');
                s.Current_Active_Opportunities__c = (Integer)arO.get('c');
                profMap.put((Id)arO.get('sr'),s);
            }    
        }
        
        return profMap;         
    
    }
    
    public Static void updateSalesProfsNotAssociatedWithAnyOppty(Set<Id> salesProfIds, Map<Id,Sales_Rep_Profile__c> profMap){
        
        //Remove the ids that have already been added to the map that is being updated
        salesProfIds.removeAll(profMap.keySet());
        
        //Verify if the remaining sales profile ids have no opportunities associated
        List<AggregateResult> ar = [SELECT COUNT(id) c, Sales_Rep_Profile__c sr FROM Opportunity WHERE Sales_Rep_Profile__c IN : salesProfIds AND StageName != NULL AND StageName != 'Closed Lost' AND StageName != 'Closed Won' GROUP BY Sales_Rep_Profile__c];
        
        //If there are no query results, the current active opportunities field should be updated to 0
        if(ar == null || (ar != null && ar.size() == 0)){
            system.debug(' no values in query ');
            for(Id i: salesProfIds){
                Sales_Rep_Profile__c s = new Sales_Rep_Profile__c();
                s.id = i;
                s.Current_Active_Opportunities__c = 0; 
                profMap.put(s.id,s);
            }
        }
    
    }
    
}