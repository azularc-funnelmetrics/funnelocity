trigger FunnelLevelJunctionTrigger on Sales_Profile_Company_Level_Junction__c (after insert, before delete) {
    
    String prefix = 'FunnelMetrics__';
    
    Set<String> levelsSet = new Set<String>();
    
    Map<String, Schema.DescribeFieldResult> labelFieldsMap = new Map<String, Schema.DescribeFieldResult> ();

    Map<String, Schema.SObjectField> accountFieldMap = Schema.getGlobalDescribe().get(prefix+'Sales_Rep_Profile__c').getDescribe().fields.getMap();                
        
    for (String fieldName : accountFieldMap.keySet()){
        
        Schema.SobjectField theField = accountFieldMap.get(fieldName);
        
        if(theField.getDescribe().getName().contains('Level_picklist')){
            levelsSet.add(theField.getDescribe().getLabel());
            labelFieldsMap.put(theField.getDescribe().getLabel(),theField.getDescribe());
        }
    }    
    
    system.debug(' fields map '+labelFieldsMap);
    
    List<Sales_Rep_Profile__c> sreps = new List<Sales_Rep_Profile__c>();
    
    Map<id,Sales_Rep_Profile__c> srepMap = new Map<id,Sales_Rep_Profile__c>();
    
    Map<id,Sales_Profile_Company_Level_Junction__c> idJunRecMap = new Map<id,Sales_Profile_Company_Level_Junction__c>();
    
    List<id> juncRecs = new List<id>();
    
    if(trigger.isInsert){ 
        for(Sales_Profile_Company_Level_Junction__c j : Trigger.new){                 
            
            if(trigger.isInsert){ 
                juncRecs.add(j.id);
            }    
                    
        }
    }
    List<Sales_Profile_Company_Level_Junction__c> junRecs = [SELECT id, Company_Level__r.Level_Value__c, Company_Level__r.Level_Name__c FROM Sales_Profile_Company_Level_Junction__c WHERE id IN :juncRecs];
    
    for(Sales_Profile_Company_Level_Junction__c s: junRecs){
        idJunRecMap.put(s.id,s);    
    }
    
    List<Id> srIdList = new List<Id>();   
    List<Sales_Rep_Profile__c> srList = new List<Sales_Rep_Profile__c>();
    
    if(trigger.isInsert){ 
        for(Sales_Profile_Company_Level_Junction__c j : Trigger.new){                 
            if(trigger.isInsert){ 
                srIdList.add(j.Sales_Rep_Profile__c);
            }
        }
    }
    srList = [SELECT id FROM Sales_Rep_Profile__c WHERE id IN :srIdList];
    
    for(Sales_Rep_Profile__c s: srList){
        srepMap.put(s.id,s);
    }
    
    if(trigger.isInsert){ 
        for(Sales_Profile_Company_Level_Junction__c j : Trigger.new){                 
            
            if(trigger.isInsert){ 
            
                if(labelFieldsMap != null && labelFieldsMap.size() > 0 && idJunRecMap.get(j.id) != null && labelFieldsMap.get(idJunRecMap.get(j.id).Company_Level__r.Level_Name__c) != null){
                
                    system.debug(j.Company_Level__r.Level_Name__c);                 
                          
                    String fieldAPIName = labelFieldsMap.get(idJunRecMap.get(j.id).Company_Level__r.Level_Name__c).getName();    
                    
                    srepMap.get(j.Sales_Rep_Profile__c).put(fieldAPIName,idJunRecMap.get(j.id).Company_Level__r.Level_Value__c);
                    
                    system.debug(' srepMap '+srepMap); 
                }
            } 
        } 
     }
        
    if(trigger.isDelete){ 
        
        List<Sales_Profile_Company_Level_Junction__c> srJunList = new List<Sales_Profile_Company_Level_Junction__c>();
        List<id> junIds = new List<id>();
        
        for(Sales_Profile_Company_Level_Junction__c j : Trigger.old){                 
            srJunList.add(j);   
            junIds.add(j.id);         
        }
        
        Map<id,Sales_Profile_Company_Level_Junction__c> juncMap = new Map<id,Sales_Profile_Company_Level_Junction__c>();
        
        srJunList = [SELECT id,Sales_Rep_Profile__c, Company_Level__r.Level_Name__c FROM Sales_Profile_Company_Level_Junction__c WHERE id IN :srJunList];
    
        for(Sales_Profile_Company_Level_Junction__c s: srJunList){
            srIdList.add(s.Sales_Rep_Profile__c );
            juncMap.put(s.id,s);
        }
        
        List<Sales_Rep_Profile__c> srList = [SELECT id FROM Sales_Rep_Profile__c WHERE id IN :srIdList];
    
        for(Sales_Rep_Profile__c s: srList){
            srepMap.put(s.id,s);
        }
    
        for(Sales_Profile_Company_Level_Junction__c j : Trigger.old){   
            
            if(labelFieldsMap != null && labelFieldsMap.size() > 0 && idJunRecMap.get(j.id) != null && labelFieldsMap.get(idJunRecMap.get(j.id).Company_Level__r.Level_Name__c) != null){
            
                //system.debug(j.Company_Level__r.Level_Name__c);                 
                //String levelName = [SELECT Company_Level__r.Level_Name__c FROM Sales_Profile_Company_Level_Junction__c  WHERE id = :j.id].Company_Level__r.Level_Name__c;
                //Id srepID = [SELECT Sales_Rep_Profile__c FROM Sales_Profile_Company_Level_Junction__c  WHERE id = :j.id].Sales_Rep_Profile__c;
                system.debug(' labelFieldsMap '+labelFieldsMap);
                system.debug(' juncMap.get(j.id) '+juncMap.get(j.id));
                system.debug(' juncMap.get(j.id).Company_Level__r.Level_Name__c '+juncMap.get(j.id).Company_Level__r.Level_Name__c);
                String fieldAPIName = labelFieldsMap.get(juncMap.get(j.id).Company_Level__r.Level_Name__c).getName();    
                //Sales_Rep_Profile__c s = [SELECT id FROM Sales_Rep_Profile__c WHERE id = :srepID];                                
                
                if(srepMap.containsKey(juncMap.get(j.id).Sales_Rep_Profile__c)){
                    srepMap.get(juncMap.get(j.id).Sales_Rep_Profile__c).put(fieldAPIName,null);
                }
                
                system.debug(' srepMap '+srepMap); 
            }
        }
    }                       
    
    FunnelTriggerBatchHelper.doNotCallSPTrigger = true;
    
    system.debug(' srepMap.values() '+srepMap.values());
    update srepMap.values();  
    FunnelTriggerBatchHelper.doNotCallSPTrigger = false;
}