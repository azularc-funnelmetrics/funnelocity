trigger FunnelCompanyLevelTrigger on Company_Level__c (after insert) {
/*    
    List<Sales_Profile_Company_Level_Junction__c> junc = new List<Sales_Profile_Company_Level_Junction__c>();
    
    List<Sales_Rep_Profile__c> allProfs = [SELECT id, Sales_Manager__c FROM Sales_Rep_Profile__c LIMIT 2000];
                    
    for(Company_Level__c c:trigger.new){

        if(c.Sales_Rep_Profile__c != null){
        
            Map<Id,List<Id>> profMgrMap = new Map<Id,List<Id>>();
            
            for(Sales_Rep_Profile__c s:allProfs){
                if(s.Sales_Manager__c != null){
                    if(profMgrMap == null || (!profMgrMap.keySet().contains(s.Sales_Manager__c))){
                        List<Id> suborList = new List<Id>();
                        suborList.add(s.Id);
                        profMgrMap.put(s.Sales_Manager__c,suborList);
                    }
                    else if(profMgrMap.containsKey(s.Sales_Manager__c)){
                        profMgrMap.get(s.Sales_Manager__c).add(s.id);
                    }
                }
            }
            
            List<Id> mgrIds = new List<Id>();
            mgrIds.add(c.Sales_Rep_Profile__c);
            
            List<Id> junctsToBeCreated = new List<Id>();
            junctsToBeCreated.add(c.Sales_Rep_Profile__c);
            
            while(mgrIds != null && mgrIds.size()>0){
                List<Id> newMgrIds = new List<Id>();
                for(Id mgrId:mgrIds){
                    if(profMgrMap.get(mgrId) != null){
                        junctsToBeCreated.addAll(profMgrMap.get(mgrId)); 
                        newMgrIds.addAll(profMgrMap.get(mgrId));
                    }          
                }
                mgrIds = new List<Id>();
                mgrIds.addAll(newMgrIds);
            }
            
            system.debug(' junctsToBeCreated '+junctsToBeCreated);                              
    
            for(Id sp : junctsToBeCreated){    
                Sales_Profile_Company_Level_Junction__c j = new Sales_Profile_Company_Level_Junction__c();
                j.Company_Level__c = c.id;
                j.Sales_Rep_Profile__c = sp;
                junc.add(j);   
            }
            
        }        
    }
        
    insert junc;
*/    
}