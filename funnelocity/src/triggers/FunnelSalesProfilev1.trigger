/*
    Author:  Carine DMello
    Created On: 11/6/2017
    This trigger updates fields on the Sales rep profile object
    It is triggered every time a Sales profile is inserted/updated
*/

trigger FunnelSalesProfilev1 on Sales_Rep_Profile__c (after insert, after update) {    
    
    //List to store the ids of sales mangers of the sales representative profile that is inserted or updated
    List<Id> salesMgrs = new List<Id>();
    
    for(Sales_Rep_Profile__c sp: Trigger.new){
        
        //If the quota amount is updated/the sales manager is updated
        //store the ids of the sales manager in a list
        if(trigger.isInsert || 
              (  
                trigger.isUpdate 
                  && 
                (
                  (System.Trigger.oldMap.get(sp.Id).Annual_Quota_Amount__c != sp.Annual_Quota_Amount__c)  
                  ||
                  (System.Trigger.oldMap.get(sp.Id).Sales_Manager__c != sp.Sales_Manager__c)
                  ||
                  (System.Trigger.oldMap.get(sp.Id).Current_Active_Opportunities__c != sp.Current_Active_Opportunities__c)
                  ||
                  (System.Trigger.oldMap.get(sp.Id).Aggregated_current_active_opptys__c != sp.Aggregated_current_active_opptys__c)
                  ||
                  (System.Trigger.oldMap.get(sp.Id).Aggregated_Annual_Quota__c != sp.Aggregated_Annual_Quota__c)
                )                 
              )
          )
          {
               if(sp.Sales_Manager__c != null){
                   salesMgrs.add(sp.Sales_Manager__c); 
               }
          }
          
          //If the sales manager on a sales profile is updated, add it to the sales profile list to be updated as the quota amounts will change
          if(  trigger.isUpdate                   
                  &&                   
               (System.Trigger.oldMap.get(sp.Id).Sales_Manager__c != sp.Sales_Manager__c)                  
                  &&                                 
                (System.Trigger.oldMap.get(sp.Id).Sales_Manager__c != null)                           
            ){
              salesMgrs.add(System.Trigger.oldMap.get(sp.Id).Sales_Manager__c);
          }
    }
    
    //Fetch all the sales profile records that are associated with the managers
    //List<Sales_Rep_Profile__c> salesRepRecords = [SELECT Id, Month_1_Quota_Amount__c, Month_2_Quota_Amount__c, Month_3_Quota_Amount__c, Month_4_Quota_Amount__c, Month_5_Quota_Amount__c, Month_6_Quota_Amount__c, Month_7_Quota_Amount__c, Month_8_Quota_Amount__c, Month_9_Quota_Amount__c, Month_10_Quota_Amount__c, Month_11_Quota_Amount__c, Month_12_Quota_Amount__c,Sales_Manager__c FROM Sales_Rep_Profile__c WHERE Sales_Manager__c IN :salesMgrs];
    
    Map<Id, Sales_Rep_Profile__c> salesMgrProfMap = new Map<Id, Sales_Rep_Profile__c>([SELECT Id, Annual_Quota_Amount__c, Current_Active_Opportunities__c, Sales_Manager__c FROM Sales_Rep_Profile__c WHERE Id IN :salesMgrs]);
    
    
    //List to store the manger ids to be updated
    List<Sales_Rep_Profile__c> mgrsToUpdate = new List<Sales_Rep_Profile__c>();
    
    List<AggregateResult> salesRepRecordsAggr = [SELECT SUM(Annual_Quota_Amount__c) s, SUM(Current_Active_Opportunities__c ) c, Sales_Manager__c sm FROM Sales_Rep_Profile__c WHERE Sales_Manager__c IN :salesMgrs GROUP BY Sales_Manager__c];
    
    for(AggregateResult ar: salesRepRecordsAggr){
        Sales_Rep_Profile__c mgr = new Sales_Rep_Profile__c();
        mgr.id = (Id)ar.get('sm');
        mgr.Aggregated_current_active_opptys__c = salesMgrProfMap.get(mgr.id).Current_Active_Opportunities__c + (Decimal)ar.get('c');   
        mgr.Aggregated_Annual_Quota__c = salesMgrProfMap.get(mgr.id).Annual_Quota_Amount__c + (Decimal)ar.get('s');
        
        mgrsToUpdate.add(mgr);  
    }
    
    /*
    //Map to store the sales manager id and the sales profiles that are under the manager
    Map<Id, List<Sales_Rep_Profile__c>> salesProfMap = new Map<Id, List<Sales_Rep_Profile__c>>();
    
    //List to store the sales reps under a manager
    List<Sales_Rep_Profile__c> salesReps = new List<Sales_Rep_Profile__c>();
    
    for(Sales_Rep_Profile__c s: salesRepRecords){
        
        //If the map already contains the sales manger record, add it to the already added sales profiles list
        if(salesProfMap != null && salesProfMap.containsKey(s.Sales_Manager__c)){                                            
            salesProfMap.get(s.Sales_Manager__c).add(s);
        }
        //If the map does not contain the manager record, add it to the list
        else if(salesProfMap != null && !salesProfMap.containsKey(s.Sales_Manager__c)){            
            salesReps = new List<Sales_Rep_Profile__c>();
            salesReps.add(s);
            salesProfMap.put(s.Sales_Manager__c,salesReps);        
        }
    }
    
    system.debug(' salesProfMap '+salesProfMap);
    
    //Add the quotas of all sales reps under each manager
    for(Id i: salesProfMap.keySet()){
    
        Sales_Rep_Profile__c mgr = new Sales_Rep_Profile__c();
        mgr.id = i; 
        
        Integer m1=0;
        Integer m2=0;
        Integer m3=0;
        Integer m4=0;
        Integer m5=0;
        Integer m6=0;
        Integer m7=0;
        Integer m8=0;
        Integer m9=0;
        Integer m10=0;
        Integer m11=0;
        Integer m12=0;
       
        for(Sales_Rep_Profile__c rep: salesProfMap.get(i)){
        
            m1 = m1 + (Integer)rep.Month_1_Quota_Amount__c;
            m2 = m2 + (Integer)rep.Month_2_Quota_Amount__c;  
            m3 = m3 + (Integer)rep.Month_3_Quota_Amount__c;
            m4 = m4 + (Integer)rep.Month_4_Quota_Amount__c;
            m5 = m5 + (Integer)rep.Month_5_Quota_Amount__c;
            m6 = m6 + (Integer)rep.Month_6_Quota_Amount__c;
            m7 = m7 + (Integer)rep.Month_7_Quota_Amount__c;
            m8 = m8 + (Integer)rep.Month_8_Quota_Amount__c;
            m9 = m9 + (Integer)rep.Month_9_Quota_Amount__c;
            m10 = m10 + (Integer)rep.Month_10_Quota_Amount__c;
            m11 = m11 + (Integer)rep.Month_11_Quota_Amount__c;
            m12 = m12 + (Integer)rep.Month_12_Quota_Amount__c;  
        
        }
        
        mgr.Month_1_Quota_Amount__c = m1;
        mgr.Month_2_Quota_Amount__c = m2;
        mgr.Month_3_Quota_Amount__c = m3;        
        mgr.Month_4_Quota_Amount__c = m4; 
        mgr.Month_5_Quota_Amount__c = m5;        
        mgr.Month_6_Quota_Amount__c = m6;        
        mgr.Month_7_Quota_Amount__c = m7;        
        mgr.Month_8_Quota_Amount__c = m8;        
        mgr.Month_9_Quota_Amount__c = m9;
        mgr.Month_10_Quota_Amount__c = m10;            
        mgr.Month_11_Quota_Amount__c = m11;    
        mgr.Month_12_Quota_Amount__c = m12; 
        
        mgrsToUpdate.add(mgr);  
        
    }*/
    
    //update the manager records with the updated quotas
    update mgrsToUpdate;
       
}