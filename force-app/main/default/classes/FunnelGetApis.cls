/*--++---------------------+++----------------++++-------------------
Author:    Irfan Shaikh                     
Date:      13th, March 2019
Desc:      This controller is for making the call out to Trifecta APIs 
           for receiving the FS, QS, Important flag, and coeffecient
           evaluated by the model.
           
Copyright: Funnel Metrics, LLC
++-------------------+++++-----------++++--------------------------*/
public class FunnelGetApis {
     
   
    public String token{get;set;}
   
    public String jsonData {get;set;}
    public String msg {get;set;}
    public String jbody {get;set;}
  
    public List<FM_API__mdt> lstApiParam {get; set;}
    public List<Organization> lstOrg {get;set;}
        
    public List<Sales_Rep_Profile__c> lstSRPS {get;set;}
    public list<Certification__c> lstCrtObj {get;set;}
    public Certification_Rating__c CerRatingObj{get;set;}
    public List<Certification_Rating__c> lstCerRatingObj {get;set;}

    public Map<String, Object> mapStats{get;set;}
      
    
    public FunnelGetApis() {
    
      // Retrieve the API param data from Custom Meta Data Types
      lstApiParam = new List<FM_API__mdt>();
      lstApiParam = [Select Client_Id__c,Client_secret__c,Password__c,Scopes__c,Token_url__c,Type__c,Username__c from FM_API__mdt LIMIT 5000];
    }

     public void getAccessToken() {
                   
          //jbody = 'grant_type='+lstApiParam[0].Type__c + '&scope='+lstApiParam[0].Scopes__c + '&username='+lstApiParam[0].Username__c +'&password='+ lstApiParam[0].Password__c;
       
                /* ANBLICK */
            JSONGenerator gen = JSON.createGenerator(true);
            clsJSON2 cjObj = new clsJSON2();
                gen.writeStartObject();
                            
                    
                    
                    /* cjObj.wsf(gen,'username',lstApiParam[0].Username__c);
                    cjObj.wsf(gen,'password',lstApiParam[0].Password__c); */
                
                cjObj.wsf(gen,'username','funnelmetrics');
                cjObj.wsf(gen,'password','F@u&n^n)e*l&P#r*o)d');
               // cjObj.wsf(gen,'password','F@u&n^n)e*l&D#e*v');
                     
                gen.writeEndObject();
                      
            String jbody = gen.getAsString(); 
            /* ANBLICK */
          system.debug(' jbody ' +jbody);
          
          // Parameters required for httpHandler() method : httpHandler(string method, string atoken, string endpoint, string jbody)
          
          if(!test.isRunningTest()){
              jsonData = httpHandler('POST', '', '/oauth/token', jbody );
              
              fromJSON j = (fromJSON)JSON.deserialize(jsonData, fromJSON.class);
              system.debug(' response ' +j);
              token = j.access_token;
              msg = token;
          }
    }
  
       
     public void getandUpdateFSQS(){
     
         boolean check = true;
         string jScorebody;
         string sfEmpIds;
         jsonData = '';
         
         lstOrg = new List<Organization>();
         lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
         
         lstSRPS  =  new List<Sales_Rep_Profile__c>([Select id from Sales_Rep_Profile__c where Annual_Quota_Amount__c > 0 ]);
         
             for(Sales_Rep_Profile__c s: lstSRPS){
               if(!check){
                   sfEmpIds +=',';
                   sfEmpIds += s.id;
                }
                else{
                   sfEmpIds += s.id;
                   check = false;
               }
             }
          
          if(sfEmpIds != null)   
              sfEmpIds = sfEmpIds.remove('null');
                        
           
          //sfEmpIds = 'a0D1U000000wm0jUAA,a0D1U000000wm0oUAA,a0D1U000000wm0sUAA,a0D1U000000wm0cUAA,a0D1U000000wm0wUAA,a0D1U000000wm0xUAA,a0D1U000000wm0yUAA,a0D1U000000wm0zUAA,a0D1U000000wm15UAA,a0D1U000000wm16UAA,a0D1U000000wm17UAA,a0D1U000000wm18UAA,a0D1U000000wm19UAA,a0D1U000000wm1AUAQ,a0D1U000000wm1BUAQ,a0D1U000000wm1CUAQ,a0D1U000000wm1DUAQ,a0D1U000000wm1EUAQ,a0D1U000000wm1FUAQ,a0D1U000000wm1GUAQ,a0D1U000000wm1HUAQ,a0D1U000000wm0uUAA,a0D1U000000wm0vUAA,a0D1U000000wm10UAA,a0D1U000000wm11UAA,a0D1U000000wm12UAA,a0D1U000000wm13UAA,a0D1U000000wm14UAA,a0D1U000000wm1KUAQ,a0D1U000000wm1IUAQ,a0D1U000000wm1LUAQ,a0D1U000000wm1MUAQ,a0D1U000000wm1NUAQ,a0D1U000000wm1OUAQ,a0D1U000000wm1PUAQ,a0D1U000000wm1QUAQ,a0D1U000000wm1RUAQ,a0D1U000000wm1SUAQ,a0D1U000000wm1JUAQ,a0D1U000000wm1TUAQ,a0D1U000000wm1UUAQ,a0D1U000000wm1VUAQ,a0D1U000000wm1WUAQ,a0D1U000000wm1XUAQ,a0D1U000000wm1YUAQ,a0D1U000000wm1ZUAQ,a0D1U000000wm1aUAA,a0D1U000000wm1bUAA,a0D1U000000wm1cUAA,a0D1U000000wm1dUAA,a0D1U000000wm1eUAA,a0D1U000000wm1fUAA,a0D1U000000wm1gUAA,a0D1U000000wm1hUAA,a0D1U000000wm1iUAA,a0D1U000000wm1jUAA,a0D1U000000wm1kUAA,a0D1U000000wm1lUAA,a0D1U000000wm1mUAA,a0D1U000000wm1nUAA,a0D1U000000wm1oUAA,a0D1U000000wm1pUAA,a0D1U000000wm1qUAA,a0D1U000000wm1rUAA,a0D1U000000wm1sUAA,a0D1U000000wm1tUAA,a0D1U000000wm1uUAA,a0D1U000000wm1vUAA';
            
          jScorebody= '?orgId='+lstOrg[0].Id+'&sfEmployeeIds='+sfEmpIds;          
          
          //jScorebody= '?orgId='+'00D1U000000ELJWUA4'+'&sfEmployeeIds='+sfEmpIds;
          
          system.debug(' jScorebody '+jScorebody);
          
          //Map<id,id> salesProfCertMap = new Map<id,id>();
          Map<id,Certification__c> salesprofCertMap = new Map<id, Certification__c> ();
          
          List<Certification__c> certList = [SELECT id,Sales_rep_profile__c FROM Certification__c WHERE (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];
          
          for(Certification__c c:certList){
              //salesProfCertMap.put(c.Sales_profile__c,c.id);
              salesprofCertMap.put(c.Sales_rep_profile__c,c);
          }
          
          //jsonData = '[{"id":1,"sfEmployeeId":"a0Cf200000d9kNEEAY","quantitativeScore":6,"funnelocityScore":9,"qualSnapshotId":694,"quantSnapshotId":2206,"createdAt":"2019-03-19T15:56:35.433205Z","updatedAt":"2019-03-19T15:56:35.433205Z","scoredAt":null},{"id":2,"sfEmployeeId":"a0Cf200000d9kOPEAY","quantitativeScore":4,"funnelocityScore":8,"qualSnapshotId":695,"quantSnapshotId":2218,"createdAt":"2019-03-19T15:57:13.314965Z","updatedAt":"2019-03-19T15:57:13.314965Z","scoredAt":null}]]';
          lstCrtObj = new List<Certification__c>();
                    
              system.debug(' jScorebody '+jScorebody);
              
              jsonData = httpHandler('GET', token, '/employees/latestScores'+jScorebody, '');
          
              List<fromJSON>  jsonObj = (List<fromJSON>)JSON.deserialize(jsonData,List<fromJSON>.class);
             
              for(fromJSON obj: jsonObj) {
                   
                   if(obj.QuantScore != null && obj.QuantScore >= 0){
                       salesprofCertMap.get(obj.sfEmployeeId).Overall_quantitative_Rating__c = obj.QuantScore;
                       salesprofCertMap.get(obj.sfEmployeeId).Overall_Rating__c = obj.QuantScore;                           
                       // quantitativeScore = FS : Need to replace when updated in the APIs
                       system.debug(' obj.sfEmployeeId '+obj.sfEmployeeId+' obj.quantitativeScore '+obj.QuantScore);
                   }
                   if(obj.QualScore != null && obj.QualScore>= 0){
                       salesprofCertMap.get(obj.sfEmployeeId).Individual_Qualitative_Rating__c = obj.QualScore;
                       salesprofCertMap.get(obj.sfEmployeeId).Overall_Qualitative_Rating__c = obj.QualScore;
                       // funnelocityScore = QS : Need to replace when updated in the APIs
                       system.debug(' obj.sfEmployeeId qual '+obj.sfEmployeeId+' obj.qualitativeScore '+obj.QualScore);
                   }
                   if(obj.QuantActual!= null && obj.QuantActual>= 0){
                       salesprofCertMap.get(obj.sfEmployeeId).Target_value__c = obj.QuantActual;
                        
                       system.debug(' obj.sfEmployeeId act '+obj.sfEmployeeId+' obj.QuantActual'+obj.QuantActual);
                   }
                   if(obj.QuantPredicted != null && obj.QuantPredicted >= 0){
                       salesprofCertMap.get(obj.sfEmployeeId).Prediction_Value__c = obj.QuantPredicted;
                        
                       system.debug(' obj.sfEmployeeId pred '+obj.sfEmployeeId+' obj.QuantPredicted'+obj.QuantPredicted);
                   }
                   
                   /*if(obj.quantitativeScore != null && obj.quantitativeScore >= 0){
                       system.debug(' obj.sfEmployeeId '+obj.sfEmployeeId+' obj.quantitativeScore '+obj.quantitativeScore);
                   }
                   if(obj.qualitativeScore != null && obj.qualitativeScore >= 0){
                       system.debug(' obj.sfEmployeeId qual '+obj.sfEmployeeId+' obj.qualitativeScore '+obj.qualitativeScore);
                   }*/

              }
             
              system.debug(' salesprofCertMap.values() '+salesprofCertMap.values());
              
              CalculateScoreAggregates.modelDataPull = true;
              Database.SaveResult[] srList = Database.update(salesprofCertMap.values(), false);
              CalculateScoreAggregates.modelDataPull = false;
              
              Boolean successful = true;
              for (Database.SaveResult sr : srList) {
                 if(!sr.isSuccess()){
                    successful = false;
                 } else {
                        // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                  }
              }
              
              // Iterate through each returned result
            
              if (!successful)  {
              
                 FunnelTriggerBatchHelper.sendErrorMail(' FS and QS scores have not been updated '+srList[0].getErrors() );
                 
              }                          
             
              //End updating the latest certification snapshots                       
     }
     
     
     /*public void getAndUpdateQuantStats(){
         
          string jbody;
          jsonData = '';
          
          lstOrg = new List<Organization>();
          lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
         
          jbody= lstOrg[0].Id+'/quant';  
          
          //if(!test.isRunningTest()){
       
              jsonData = httpHandler('GET', token, '/api/stats/'+jbody, '');          
          
              //-----UPSERT--------///
              
              lstCerRatingObj = new List<Certification_Rating__c>();
              lstCerRatingObj = [SELECT id, Correlation_Coefficient__c, Important_flag__c, Importance__c FROM Certification_Rating__c WHERE Assessment_type__c = 'Quantitative'];
              
              Map <id,Certification_rating__c> ratingMap = new Map <id,Certification_rating__c>();
              
              for(Certification_rating__c cr:lstCerRatingObj){
                  ratingMap.put(cr.id,cr);
              }
              
              Map<String, Object> mapStats= (Map<String, Object>)JSON.deserializeUntyped(jsonData);
              Map<String, Object>  m2=(Map<String, Object>)mapStats.get('stats');
              
              Set<id> impRatings = new Set<id>();
                
              for(string s:m2.keyset()){
                impRatings.add((Id)(s));
                Map<String, Object>  m3=(Map<String, Object>)m2.get(s); //s refers to the rating id
                if(m3.get('coefficient') != null){
                    ratingMap.get(s).Correlation_Coefficient__c = (decimal)m3.get('coefficient');
                    system.debug(' ratingMap.get.Correlation_Coefficient__c '+ratingMap.get(s).Correlation_Coefficient__c);
                }
                
                if(m3.get('importance') != null){
                    ratingMap.get(s).Importance__c = (decimal)m3.get('importance');
                    system.debug(' ratingMap.get.Importance__c '+ratingMap.get(s).Importance__c);
                }
                
                ratingMap.get(s).Important_flag__c = true; 
                system.debug(' important flag is true '+ratingMap.get(s));            
              }
              
              for(Id i: ratingMap.keySet()){
                  if(!impRatings.contains(i)){
                      ratingMap.get(i).Important_flag__c = false;  
                      system.debug(' important flag is false '+ratingMap.get(i)); 
                  }
              }
              
              system.debug(' ratingMap.values() '+ratingMap.values());
              update ratingMap.values();
          //}
     } */   
    
    public void getAndUpdateQuantStats(){
         
          string jbody;
          jsonData = '';
          
          lstOrg = new List<Organization>();
          lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
         
          jbody= lstOrg[0].Id+'/quant';  
          
          //jbody= '00D1U000000ELJWUA4'+'/quant';
          
          //if(!test.isRunningTest()){
       
              jsonData = httpHandler('GET', token, '/stats/'+jbody, '');          
              //jsonData = '{"stats": [{"coefficient":8,"importance": 5,"intercept": 0, "metricName": "string","roleName": "string"},{"coefficient":0,"importance": 0,"intercept": 0, "metricName": "string","roleName": "string"},{"coefficient":0,"importance": 0,"intercept": 0, "metricName": "string","roleName": "string"}]}';
              
              system.debug(' jsonData '+jsonData);
              
              List<String> roleLst = new List<String>();
              List<AggregateResult> lstSRPS  =  new List<AggregateResult>([Select Role__c r from Sales_Rep_Profile__c where Annual_Quota_Amount__c > 0 GROUP BY Role__c]);
              
              for(AggregateResult ar: lstSRPS){
                  if(ar.get('r') != null && ar.get('r') != '')
                      roleLst.add((String)ar.get('r'));              
              }
              
              system.debug(roleLst);
              
              Map<String,id> apiNameSfIdMap = new Map<String,id>();
              List<Certification_Rating__c> certRatings = [SELECT id, Metric_Field_Name__c FROM Certification_Rating__c WHERE Assessment_type__c = 'Quantitative' AND Deactivated__c = FALSE];
              for(Certification_Rating__c r: certRatings){
                  apiNameSfIdMap.put(r.Metric_Field_Name__c, r.id);
              }
                                                        
              List<Important_Rating__c> newImpRatings = new List<Important_Rating__c>();
              
              Map<String, Object> mapStats= (Map<String, Object>)JSON.deserializeUntyped(jsonData);
              List<Object>  fieldList =(List<Object>)mapStats.get('stats');                            
                
                system.debug(' mapStats '+mapStats);
                
                for(String s: roleLst){          
                    for(Object fld : fieldList){                    
                        Map<String,Object> data = (Map<String,Object>)fld;
                        //if(data.get('metricSFId') != null &&  data.get('roleName') != null && data.get('coefficient') != null){
                            //Important_Rating__c i = new Important_Rating__c();                       
                            //i.Importance_coefficient__c = (Decimal)data.get('coefficient');
                            //i.Role__c = (String)data.get('roleName');
                            
                            if( data.get('metricName') != null && apiNameSfIdMap.get((String)data.get('metricName')) != null && data.get('importance') != null){
                                Important_Rating__c i = new Important_Rating__c();                       
                                i.Importance_coefficient__c = (Decimal)data.get('importance');
                                
                                if (i.Importance_coefficient__c > 0){
                                    i.Importance_Flag__c = 1;
                                }
                                else{
                                    i.Importance_Flag__c = 0;
                                }
                                
                                i.Role__c = s;
                                i.Certification_Rating__c = apiNameSfIdMap.get((String)data.get('metricName'));
                                
                                newImpRatings.add(i);
                            }
                            
                            //newImpRatings.add(i);
                        //}
                    } 
                }                                   
                
                if(newImpRatings != null && newImpRatings.size() > 0){   
                    List<Important_Rating__c> lstCerRatingObj = new List<Important_Rating__c>();
                    lstCerRatingObj = [SELECT id FROM Important_Rating__c WHERE Certification_Rating__r.Assessment_type__c = 'Quantitative'];                                                        
              
                    DELETE lstCerRatingObj;  
                    
                    insert newImpRatings;  
                    
                    // Default rating //
                    Set<String> groupSet = new Set<String>();
                    List<AggregateResult> imp  =  new List<AggregateResult>([Select Certification_Rating__r.Group__c r from Important_Rating__c  WHERE Certification_Rating__r.Assessment_type__c = 'Quantitative' GROUP BY Certification_Rating__r.Group__c ]);
                    
                    
                      for(AggregateResult i: imp){
                          if(i.get('r') != null && i.get('r') != '')
                              groupSet.add((String)i.get('r'));              
                      }
                      
                      List<Application_Setting__c> aps = [Select Leads_used__c,Meetings_used__c From Application_Setting__c Limit 1];
                      List<String> DefaultMetric = new List<String>();
                      
                      if(!groupSet.contains('Opportunity Close Rate')){
                          DefaultMetric.add('YTD_Opportunity_Close_Rate__c');
                      }
                      if(!groupSet.contains('Qualified Opportunities Added')){
                          DefaultMetric.add('Ytd_QO_added_Quantitative__c');
                      }
                      if(!groupSet.contains('Sales Cycle')){
                          DefaultMetric.add('YTD_Average_Sales_Cycle__c');
                      }
                      if(!groupSet.contains('Deal Size')){
                          DefaultMetric.add('Average_Deal_Size__c');
                      }
                      
                      if(!groupSet.contains('Meetings') && aps[0].Meetings_used__c){
                          DefaultMetric.add('Number_of_meetings_YTD__c');
                      }
                      
                      if(!groupSet.contains('Leads') && aps[0].Leads_used__c){
                          DefaultMetric.add('Lead_to_Opportunity_Conversion_Rate__c');
                      }
                     
                     
                     List<Important_Rating__c> newDefaultImpRatings = new List<Important_Rating__c>();
                    for(String s: roleLst){          
                        for(String fld : DefaultMetric){                    
                         
                         
                            Important_Rating__c i = new Important_Rating__c();                       
                            i.Importance_coefficient__c = 0.000001;
                            i.Importance_Flag__c = 1;
                            i.Role__c = s;
                            i.Certification_Rating__c = apiNameSfIdMap.get(fld);
                            
                            newDefaultImpRatings.add(i);
                             
                               
                        } 
                    } 

                    if(newDefaultImpRatings != null && newDefaultImpRatings.size() > 0){ 
                        insert newDefaultImpRatings;
                    }
                }            
     }
     public void getAndUpdateQuantStatsSnap(){
         
          string jbody;
          jsonData = '';
          
          lstOrg = new List<Organization>();
          lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
         
          jbody= lstOrg[0].Id+'/quant';  
           
          jsonData = httpHandler('GET', token, '/stats/'+jbody, '');          
          system.debug(' jsonData '+jsonData);
              
          List<String> roleLst = new List<String>();
          List<AggregateResult> lstSRPS  =  new List<AggregateResult>([Select Role__c r from Sales_Rep_Profile__c where Annual_Quota_Amount__c > 0 GROUP BY Role__c]);
              
          for(AggregateResult ar: lstSRPS){
              if(ar.get('r') != null && ar.get('r') != '')
                  roleLst.add((String)ar.get('r'));              
          }
              
              system.debug(roleLst);
              
              Map<String,id> apiNameSfIdMap = new Map<String,id>();
              List<Certification_Rating__c> certRatings = [SELECT id, Metric_Field_Name__c FROM Certification_Rating__c WHERE Assessment_type__c = 'Quantitative' AND Deactivated__c = FALSE];
              for(Certification_Rating__c r: certRatings){
                  apiNameSfIdMap.put(r.Metric_Field_Name__c, r.id);
              }
                                                        
              List<Important_Rating_Snapshot__c> newImpRatings = new List<Important_Rating_Snapshot__c>();
              
              Map<String, Object> mapStats= (Map<String, Object>)JSON.deserializeUntyped(jsonData);
              List<Object>  fieldList =(List<Object>)mapStats.get('stats');                            
                
                system.debug(' mapStats '+mapStats);
                
                for(String s: roleLst){          
                    for(Object fld : fieldList){                    
                        Map<String,Object> data = (Map<String,Object>)fld;
                         
                            
                            if( data.get('metricName') != null && apiNameSfIdMap.get((String)data.get('metricName')) != null && data.get('importance') != null){
                                Important_Rating_Snapshot__c i = new Important_Rating_Snapshot__c();                       
                                i.Importance_coefficient__c = (Decimal)data.get('importance');
                                
                                if (i.Importance_coefficient__c > 0){
                                    i.Importance_Flag__c = 1;
                                }
                                else{
                                    i.Importance_Flag__c = 0;
                                }
                                
                                i.Role__c = s;
                                i.Certification_Rating__c = apiNameSfIdMap.get((String)data.get('metricName'));
                                i.Snapshot_Scheduled_Date__c = Date.today();
                                newImpRatings.add(i);
                            }
                            
                    } 
                }                                   
                
                if(newImpRatings != null && newImpRatings.size() > 0){   
                    
                    insert newImpRatings;  
                    
                    // Default rating //
                    Set<String> groupSet = new Set<String>();
                    List<AggregateResult> imp  =  new List<AggregateResult>([Select Certification_Rating__r.Group__c r from Important_Rating__c  WHERE Certification_Rating__r.Assessment_type__c = 'Quantitative' GROUP BY Certification_Rating__r.Group__c ]);
                    
                    
                      for(AggregateResult i: imp){
                          if(i.get('r') != null && i.get('r') != '')
                              groupSet.add((String)i.get('r'));              
                      }
                      
                      List<Application_Setting__c> aps = [Select Leads_used__c,Meetings_used__c From Application_Setting__c Limit 1];
                      List<String> DefaultMetric = new List<String>();
                      
                      if(!groupSet.contains('Opportunity Close Rate')){
                          DefaultMetric.add('YTD_Opportunity_Close_Rate__c');
                      }
                      if(!groupSet.contains('Qualified Opportunities Added')){
                          DefaultMetric.add('Ytd_QO_added_Quantitative__c');
                      }
                      if(!groupSet.contains('Sales Cycle')){
                          DefaultMetric.add('YTD_Average_Sales_Cycle__c');
                      }
                      if(!groupSet.contains('Deal Size')){
                          DefaultMetric.add('Average_Deal_Size__c');
                      }
                      
                      if(!groupSet.contains('Meetings') && aps[0].Meetings_used__c){
                          DefaultMetric.add('Number_of_meetings_YTD__c');
                      }
                      
                      if(!groupSet.contains('Leads') && aps[0].Leads_used__c){
                          DefaultMetric.add('Lead_to_Opportunity_Conversion_Rate__c');
                      }
                     
                     
                     List<Important_Rating_Snapshot__c> newDefaultImpRatings = new List<Important_Rating_Snapshot__c>();
                    for(String s: roleLst){          
                        for(String fld : DefaultMetric){                    
                         
                         
                            Important_Rating_Snapshot__c i = new Important_Rating_Snapshot__c();                       
                            i.Importance_coefficient__c = 0.000001;
                            i.Importance_Flag__c = 1;
                            i.Role__c = s;
                            i.Certification_Rating__c = apiNameSfIdMap.get(fld);
                            i.Snapshot_Scheduled_Date__c = Date.today();
                            
                            newDefaultImpRatings.add(i);
                             
                               
                        } 
                    } 

                    if(newDefaultImpRatings != null && newDefaultImpRatings.size() > 0){ 
                        insert newDefaultImpRatings;
                    }
                }            
     }
     
     public void getAndUpdateQualStats(){
         
          string jbody;
          jsonData = '';
          
          lstOrg = new List<Organization>();
          lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
         
          jbody= lstOrg[0].Id+'/qual';  
          
          //jbody= '00D1U000000ELJWUA4'+'/qual';
          
          //if(!test.isRunningTest()){
       
              jsonData = httpHandler('GET', token, '/stats/'+jbody, '');          
              //jsonData = '{"stats": [{"coefficient":8,"importance": 5,"intercept": 0, "metricName": "string","roleName": "string"},{"coefficient":0,"importance": 0,"intercept": 0, "metricName": "string","roleName": "string"},{"coefficient":0,"importance": 0,"intercept": 0, "metricName": "string","roleName": "string"}]}';
              
              /*
              List<Important_Rating__c> lstCerRatingObj = new List<Important_Rating__c>();
              lstCerRatingObj = [SELECT id FROM Important_Rating__c WHERE Certification_Rating__r.Assessment_type__c = 'Qualitative'];                                                        
              
              DELETE lstCerRatingObj;
              */
              
              Map<String,id> apiNameSfIdMap = new Map<String,id>();
              List<Certification_Rating__c> certRatings = [SELECT id, API_Identifier_Qual__c FROM Certification_Rating__c WHERE Assessment_type__c = 'Qualitative'];
              for(Certification_Rating__c r: certRatings){
                  apiNameSfIdMap.put(String.valueOf(r.API_Identifier_Qual__c), r.id);
              }
              
              List<String> roleLst = new List<String>();
              List<AggregateResult> lstSRPS  =  new List<AggregateResult>([Select Role__c r from Sales_Rep_Profile__c where Active__c = true GROUP BY Role__c]);
              
              for(AggregateResult ar: lstSRPS){
                  if(ar.get('r') != null && ar.get('r') != '')
                      roleLst.add((String)ar.get('r'));              
              }
              
              system.debug(roleLst);
                            
              List<Important_Rating__c> newImpRatings = new List<Important_Rating__c>();
              
              Map<String, Object> mapStats= (Map<String, Object>)JSON.deserializeUntyped(jsonData);
              
              system.debug(' mapStats '+mapStats);
              
              List<Object>  fieldList =(List<Object>)mapStats.get('stats');                            
                
                
                for(String s: roleLst){         
                    for(Object fld : fieldList){                                    
                        Map<String,Object> data = (Map<String,Object>)fld;
                        if(data.get('Api_Identifier') != null && apiNameSfIdMap.get((String)data.get('Api_Identifier')) != null && data.get('importance') != null){ 
                            Important_Rating__c i = new Important_Rating__c();                       
                            i.Importance_coefficient__c = (Decimal)data.get('importance');
                            
                            if (i.Importance_coefficient__c > 0){
                                i.Importance_Flag__c = 1;
                            }
                            else{
                                i.Importance_Flag__c = 0;
                            }
                            
                            i.Role__c = s;
                            i.Certification_Rating__c =  apiNameSfIdMap.get((String)data.get('Api_Identifier'));
                             
                            newImpRatings.add(i);
                        }
                    }
                }
                
                if(newImpRatings != null && newImpRatings.size() > 0){   
                    List<Important_Rating__c> lstCerRatingObj = new List<Important_Rating__c>();
                    lstCerRatingObj = [SELECT id FROM Important_Rating__c WHERE Certification_Rating__r.Assessment_type__c = 'Qualitative'];                                                        
                
                    DELETE lstCerRatingObj;  
                    
                    insert newImpRatings;  
                } 
                
     }
     public void getAndUpdateQualStatsSnap(){
         
          string jbody;
          jsonData = '';
          
          lstOrg = new List<Organization>();
          lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
         
          jbody= lstOrg[0].Id+'/qual';  
          
          jsonData = httpHandler('GET', token, '/stats/'+jbody, '');          
              
              
              Map<String,id> apiNameSfIdMap = new Map<String,id>();
              List<Certification_Rating__c> certRatings = [SELECT id, API_Identifier_Qual__c FROM Certification_Rating__c WHERE Assessment_type__c = 'Qualitative'];
              for(Certification_Rating__c r: certRatings){
                  apiNameSfIdMap.put(String.valueOf(r.API_Identifier_Qual__c), r.id);
              }
              
              List<String> roleLst = new List<String>();
              List<AggregateResult> lstSRPS  =  new List<AggregateResult>([Select Role__c r from Sales_Rep_Profile__c where Active__c = true GROUP BY Role__c]);
              
              for(AggregateResult ar: lstSRPS){
                  if(ar.get('r') != null && ar.get('r') != '')
                      roleLst.add((String)ar.get('r'));              
              }
              
              system.debug(roleLst);
                            
              List<Important_Rating_Snapshot__c> newImpRatings = new List<Important_Rating_Snapshot__c>();
              
              Map<String, Object> mapStats= (Map<String, Object>)JSON.deserializeUntyped(jsonData);
              
              system.debug(' mapStats '+mapStats);
              
              List<Object>  fieldList =(List<Object>)mapStats.get('stats');                            
                
                
                for(String s: roleLst){         
                    for(Object fld : fieldList){                                    
                        Map<String,Object> data = (Map<String,Object>)fld;
                        if(data.get('Api_Identifier') != null && apiNameSfIdMap.get((String)data.get('Api_Identifier')) != null && data.get('importance') != null){ 
                            Important_Rating_Snapshot__c i = new Important_Rating_Snapshot__c();                       
                            i.Importance_coefficient__c = (Decimal)data.get('importance');
                            
                            if (i.Importance_coefficient__c > 0){
                                i.Importance_Flag__c = 1;
                            }
                            else{
                                i.Importance_Flag__c = 0;
                            }
                            
                            i.Role__c = s;
                            i.Certification_Rating__c =  apiNameSfIdMap.get((String)data.get('Api_Identifier'));
                            i.Snapshot_Scheduled_Date__c = Date.today();
                            newImpRatings.add(i);
                        }
                    }
                }
                
                if(newImpRatings != null && newImpRatings.size() > 0){   
                     
                    insert newImpRatings;  
                } 
                
     }
     
     /*
     public void getAndUpdateQualStats(){
         
          string jbody;
         
          lstOrg = new List<Organization>();
          lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
         
          jbody= lstOrg[0].Id+'/qual';       
          
          if(!test.isRunningTest()){
  
              jsonData = httpHandler('GET', token, '/api/stats/'+jbody, '');
                    
              lstCerRatingObj = new List<Certification_Rating__c>();
              lstCerRatingObj = [SELECT id, Correlation_Coefficient__c, Important_flag__c, Importance__c FROM Certification_Rating__c WHERE Assessment_type__c = 'Qualitative'];
              
              Map <id,Certification_rating__c> ratingMap = new Map <id,Certification_rating__c>();
              
              for(Certification_rating__c cr:lstCerRatingObj){
                  ratingMap.put(cr.id,cr);
              }
              
              Map<String, Object> mapStats= (Map<String, Object>)JSON.deserializeUntyped(jsonData);
                 
              Map<String, Object>  m2=(Map<String, Object>)mapStats.get('stats');
              
              Set<id> impRatings = new Set<id>();
              
              for(string s:m2.keyset()){
                  impRatings.add((Id)(s));
                  Map<String, Object>  m3=(Map<String, Object>)m2.get(s);
                    
                    if(m3.get('coefficient') != null){
                        ratingMap.get(s).Correlation_Coefficient__c = (decimal)m3.get('coefficient');
                        system.debug(' ratingMap.get.Correlation_Coefficient__c '+ratingMap.get(s).Correlation_Coefficient__c);
                    }
                
                    if(m3.get('importance') != null){
                        ratingMap.get(s).Importance__c = (decimal)m3.get('importance');
                        system.debug(' ratingMap.get.Importance__c '+ratingMap.get(s).Importance__c);
                    }                                    
                    
                    ratingMap.get(s).Important_flag__c = true; 
                    system.debug(' important flag is true '+ratingMap.get(s));    
               }
               
               for(Id i: ratingMap.keySet()){
                  if(!impRatings.contains(i)){
                      ratingMap.get(i).Important_flag__c = false;   
                      system.debug(' important flag is false '+ratingMap.get(i)); 
                  }
               }
               
               system.debug(' ratingMap.values() '+ratingMap.values());
               update ratingMap.values();
          }     
     }*/
    
    // Wrap the parameters from JSON object
     public class fromJSON{
            
        // Session token
        public string access_token;
        
        //FS and QS score from API
        public String sfEmployeeId;
        //public Decimal qualitativeScore;
        //public Decimal quantitativeScore;
        public Decimal QualScore;
        public Decimal QuantActual;
        public Decimal QuantPredicted;
        public Decimal QuantScore;
        
        // Wrapper Interface, Importance, Coeffecient from APIs
        //public class fromJSON2{
            public decimal intercept;
            public decimal coefficient;
            public decimal importance;
       // }
       
    }
    
    public class details{
        public decimal intercept;
        public decimal coefficient;
        public String sfEmployeeId;
        public decimal importance;
        public decimal qualitativeScore;
        public String quantitativeScore;
    }
    
    public class fromJSON2{
        public List<details> dts;
    }
     public String httpHandler(string method, string atoken, string endpoint, string jbody){
   
         Http http = new Http();
         HttpRequest request = new HttpRequest();
         
         request.setMethod(method);
        
          
             request.setEndpoint(lstApiParam[0].Token_url__c+endpoint);
          
         //atoken = '14B9609FFEXYSSTTV63C0886046DD3B0F20DF12DEB758E4';
         
         // Set HEADER based on the token vs other urls
         if(atoken == ''){
             
              //String strBase64Encode  = EncodingUtil.base64Encode(Blob.valueof(lstApiParam[0].Client_Id__c+':'+lstApiParam[0].Client_secret__c));
            // request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            // request.setHeader('Authorization', 'Basic '+ strBase64Encode);
            
            request.setHeader('Content-Type', 'application/json');
         }
          else{
              
              /*
              request.setHeader('Content-Type', 'application/json;charset=UTF-8');
              request.setHeader('Authorization', 'bearer '+token);*/
              
                request.setHeader('Content-Type', 'application/json');
              request.setHeader('Authorization', 'Bearer '+token);
          }
         
         if(jbody != ''){
           request.setBody(jbody);
         }
                 
         HttpResponse response = http.send(request);
         
         system.debug(' response '+response);
         
         if(response.getStatusCode() != 200){
             throw new MyException('REST call failed '+' statusCode '+response.getStatusCode()+' response is '+response);
         }
         
         jsonData = response.getBody();
         
         Return jsonData;
     }
     
     public class clsJSON2 {
          
          
        //Writes String Fields and replaces null values
        public void wsf(JSONGenerator gen, String fieldName, String fieldValue) {
            if(fieldValue == null) {
                gen.writeNullField(fieldName); // Could be replaced with writeStringField(...,'') if you prefer an empty string over a null field
            } else {
                gen.writeStringField(fieldName, fieldValue);
            }
        }
        
        
        
                 
        
   }
     
     public class MyException extends Exception{} 
}