Public class FunnelUpdateMetaData{
     
  /*    Public static void updatecr(Set<String> names){
          createRating(names ,UserInfo.getSessionId());
     }
     
     @future(callout=true)
     Public static void createRating(Set<String> names , String sessionId)
     {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
           // service.SessionHeader.sessionId = UserInfo.getSessionId();
            service.SessionHeader.sessionId = sessionId;
           
            
            MetadataService.GlobalValueSet  globalValueSet = new MetadataService.GlobalValueSet ();
            globalValueSet.masterLabel = 'Rating Names';
            globalValueSet.fullName ='FunnelMetrics__Rating_Names';
            
            List<MetadataService.customValue> mc = new list<MetadataService.customValue>();
            for(String s : names ){
                MetadataService.customValue c1 = new MetadataService.CustomValue();
                c1.default_x = false;
                c1.isActive = true;
                c1.fullName = s;
                mc.add(c1);
            }
        globalValueSet.customValue = mc;
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { globalValueSet });
        system.debug('results '+results );
     }
     
   @future(callout=true)
    Public static void createCompanyLevel(Set<String> names , Set<id> tn, Boolean createjun , String sessionId){
            //system.debug('names ---->'+names );
            //system.debug('tn ---->'+tn);
            //system.debug('createjun ---->'+createjun );
    
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            //service.SessionHeader.sessionId = UserInfo.getSessionId();
            service.SessionHeader.sessionId = sessionId;
            
            MetadataService.GlobalValueSet  globalValueSet = new MetadataService.GlobalValueSet ();
            globalValueSet.masterLabel = 'Company levels';
            globalValueSet.fullName ='Company_levels';
            
            List<MetadataService.customValue> mc = new list<MetadataService.customValue>();
            for(String s : names ){
                MetadataService.customValue c1 = new MetadataService.CustomValue();
                c1.default_x = false;
                c1.isActive = true;
                c1.fullName = s;
                mc.add(c1);
            }
        globalValueSet.customValue = mc;
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { globalValueSet });
        
        if(createjun){
            //system.debug('inside create juntion record');
            List<Company_Level__c> cm = [Select id,Sales_Rep_Profile__c,Level_Value__c From Company_Level__c where id IN :tn];
            //system.debug('cm ---->'+cm );
            List<Sales_Profile_Company_Level_Junction__c> junc = new List<Sales_Profile_Company_Level_Junction__c>();
    
            List<Sales_Rep_Profile__c> allProfs = [SELECT id, Sales_Manager__c FROM Sales_Rep_Profile__c LIMIT 2000];            
            
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
            
            Map<id,id> salesProfCertMap = new Map<id,id>();
            
            List<Certification__c> certRecords = [SELECT id,Sales_Rep_Profile__c FROM Certification__c LIMIT 5000];
            
            for(Certification__c c:certRecords){
                salesProfCertMap.put(c.Sales_Rep_Profile__c,c.id);       
            }
            
            for(Company_Level__c c:cm){
             
                if(c.Sales_Rep_Profile__c != null){
                                        
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
                    
                    //system.debug(' junctsToBeCreated '+junctsToBeCreated);                              
            
                    for(Id sp : junctsToBeCreated){    
                        Sales_Profile_Company_Level_Junction__c j = new Sales_Profile_Company_Level_Junction__c();
                        j.Company_Level__c = c.id;
                        j.Sales_Rep_Profile__c = sp;
                        j.Certification__c = salesProfCertMap.get(sp);
                       // j.Company_Level_Picklist__c = c.Level_Value__c;
                        junc.add(j);   
                    }            
                }
         
               
            }
            //system.debug('junc---->'+junc);
            if(junc != null && junc.size()>0){
                insert junc;
                //system.debug('insert junc---->'+junc);
            }
            
        }
    }*/

}