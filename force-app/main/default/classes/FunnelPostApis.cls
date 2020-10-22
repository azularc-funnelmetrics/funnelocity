/*--++---------------------+++----------------++++-------------------
Author:    Irfan Shaikh                     
Date:      13th, Feb 2019
Desc:      This controller is for making the callout to Trifecta APIs 
           for sending the Rating and Snapshots data pertainig to QUAL AND QUANT 
           scores of the employees.
Copyright: Funnel Metrics, LLC
++-------------------+++++-----------++++--------------------------*/
public class FunnelPostApis{
     
    public String access_token{ get; set; }
    public String token{get;set;}
    public String jsonMetricData { get; set; }
    public String jsonCertRating { get; set; }
    public String jsonData {get;set;}
    public String msg {get;set;}
   
    public List<FM_API__mdt> lstApiParam {get; set;}
    public List<Certification_Answer__c> lstCA {get;set;}
    public List<Sales_Rep_Profile_Snapshot__c> lstSRPS {get;set;}
    public List<Organization> lstOrg {get;set;}
    public list<object> lstobj{get;set;}
    
    //public date dt = date.newinstance(2018,07,31);
    
    public Map<String, List<Certification_Answer__c>> mapCert {get; set;}
    public Map<String, String> mapSRPS {get; set;}
    
    public Date dtSnapShot {get;set;}
        
    public FunnelPostApis() {
        
      // Retrieve the API param data from Custom Meta Data Types
      lstApiParam = new List<FM_API__mdt>();
      lstApiParam = [Select Client_Id__c,Client_secret__c,Password__c,Scopes__c,Token_url__c,Type__c,Username__c from FM_API__mdt LIMIT 5000]; 
           
      //GET an access token from Auth API before a call to other APIs   
     
    }

    public void getAccessToken() {
         
        //String body = 'username='+lstApiParam[0].Username__c +'&password='+ lstApiParam[0].Password__c;
        
        /* ANBLICK */
        JSONGenerator gen = JSON.createGenerator(true);
        clsJSON2 cjObj = new clsJSON2();
            gen.writeStartObject();
                        
               /* cjObj.wsf(gen,'username',lstApiParam[0].Username__c);
                cjObj.wsf(gen,'password',lstApiParam[0].Password__c);*/
                
                cjObj.wsf(gen,'username','funnelmetrics');
                cjObj.wsf(gen,'password','F@u&n^n)e*l&P#r*o)d');
                 
            gen.writeEndObject();
                  
        String body= gen.getAsString(); 
        /* ANBLICK */
        // Parameters required for httpHandler() method : httpHandler(string method, string atoken, string endpoint, string jbody)
        
        //if(!test.isRunningtest()){
          
        jsonData = httpHandler('POST', '', '/oauth/token', body);
        fromJSON j = (fromJSON)JSON.deserialize(jsonData, fromJSON.class);
        token = j.access_token;
        msg = token;
        //}
        system.debug('token -'+token );
        //return j.access_token;    
         
  }
  
    public void createCustomer(){
       
     // 00D4C0000008mtZ     
     // 00D4C0000008mtZUAQ
     String CustJsonBody;
     lstOrg = new List<Organization>();
     lstOrg = [SELECT Id,Name FROM Organization LIMIT 1];
     
     Map<String,object> mapOrg = new Map<String, object>();
     mapOrg.put('sfOrgId', lstOrg[0].Id);
     mapOrg.put('name', lstOrg[0].name);
     mapOrg.put('enabled', true);
     mapOrg.put('description', lstOrg[0].name);
     
     CustJsonBody = JSON.serialize(mapOrg);
     
     system.debug(' CustJsonBody '+CustJsonBody);
     // Parameters required for httpHandler() method : httpHandler(string method, string atoken, string endpoint, string jbody)
     
     // POST or Create a Customer
     //if(!test.isRunningtest())
         msg = httpHandler('POST', token, '/api/customer', CustJsonBody);
     
     // PUT or Update a Customer
     //msg = httpHandler('PUT', token, '/api/customer/'+lstOrg[0].Id, CustJsonBody);
   } 
    
   public void getCustomers() {
      
     // Get all created customer at Postgres
     msg = httpHandler('GET', token, '/api/customers', '');
     
   }
   
   //----------------------------------------QUALITATIVE RATINGS------------------//
   
   public void createQualRating(){
       
       String jQual; // to hold Qual Json data
       String jQuant; // to hold Quant Json data
       
       // Retrieve ORG Id to pass along with the APIs
       lstOrg = new List<Organization>();
       lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
       
       // Retrieve Qual ratings
       List<Certification_Rating__c> QualRating  = new List<Certification_Rating__c>([Select Name, Assessment_type__c,User_Type__c, Calculation_type__c,Deactivated__c,Timing__c, API_Identifier_Qual__c from Certification_Rating__c where Assessment_type__c = 'Qualitative']);
     
       JSONGenerator gen = JSON.createGenerator(true);
          clsJSON2 cjObj = new clsJSON2();
           gen.writeStartObject();
              gen.writeFieldName('metrics');
                 gen.writeStartArray();
                        
                      for(Certification_Rating__c lcr:QualRating){
                      
                        gen.writeStartObject();
                            
                            cjObj.wsf(gen,'API_Identifier',''+lcr.API_Identifier_Qual__c+'');
                            cjObj.wsf(gen,'Assessment_type__c',lcr.Assessment_type__c);
                            cjObj.wsf(gen,'Calculation_type__c',lcr.Calculation_type__c);
                            cjObj.wbf(gen,'Deactivated__c',lcr.Deactivated__c);
                            cjObj.wsf(gen,'Id',lcr.Id);
                            cjObj.wsf(gen,'Name',lcr.Name);
                            cjObj.wsf(gen,'Timing__c',lcr.Timing__c);
       
                         gen.writeEndObject();
                      }
                       
               gen.writeEndArray();
           gen.writeEndObject();
        jQual = gen.getAsString();
        
        system.debug(' jQual '+jQual);
        
       // msg = jQual;
       // Call out to Trifecta Rating APIs /api/metrics/OrgId/definition
       //if(!test.isRunningtest()){
           msg = httpHandler('POST', token, '/api/metrics/'+lstOrg[0].Id+'/qualDefinition', jQual);
       //}
       //jsonData = httpHandler('POST', token, '/api/metrics/'+ lstOrg[0].Id+'/quantDefinition', jQuant);
   
   }
   
   // -------------------------------------QUANTITATIVE RATINGS---------------------//
   
    public void createQuantRating(){
       
       String jQual; // to hold Qual Json data
       String jQuant; // to hold Quant Json data
       
       // Retrieve ORG Id to pass along with the APIs
       lstOrg = new List<Organization>();
       lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
       
       // Retrieve Quant ratings
       
       List<Certification_Rating__c> QuantRating = new List<Certification_Rating__c>([Select Metric_Field_Name__c,Name, Assessment_type__c,User_Type__c, Calculation_type__c,Deactivated__c,Timing__c from Certification_Rating__c where Assessment_type__c = 'Quantitative']);
       
       //List<Certification_Rating__c> QuantRatingCustom = new List<Certification_Rating__c>([Select Metric_Field_Name__c,Name, Assessment_type__c,User_Type__c, Calculation_type__c,Deactivated__c,Timing__c from Certification_Rating__c where Assessment_type__c = 'Quantitative'  AND SRP_Field_Name__c != NULL]);
    
        JSONGenerator gen = JSON.createGenerator(true);
          clsJSON2 cjObj = new clsJSON2();
           gen.writeStartObject();
              gen.writeFieldName('metrics');
                 gen.writeStartArray();
                        
                      for(Certification_Rating__c lcr:QuantRating){
                      
                        gen.writeStartObject();
                            
                            cjObj.wsf(gen,'API_name',lcr.Metric_Field_Name__c);
                            cjObj.wsf(gen,'Assessment_type__c',lcr.Assessment_type__c);
                            cjObj.wsf(gen,'Calculation_type__c',lcr.Calculation_type__c);
                            cjObj.wbf(gen,'Deactivated__c',lcr.Deactivated__c);
                            cjObj.wsf(gen,'Id',lcr.Id);
                            cjObj.wsf(gen,'Name',lcr.Name);
                            cjObj.wsf(gen,'Timing__c',lcr.Timing__c);
       
                         gen.writeEndObject();
                      }
                      
                      /*
                      for(Certification_Rating__c lcr:QuantRatingCustom){
                      
                        gen.writeStartObject();
                            
                            cjObj.wsf(gen,'API_name',lcr.Metric_Field_Name__c);
                            cjObj.wsf(gen,'Assessment_type__c',lcr.Assessment_type__c);
                            cjObj.wsf(gen,'Calculation_type__c',lcr.Calculation_type__c);
                            cjObj.wbf(gen,'Deactivated__c',lcr.Deactivated__c);
                            cjObj.wsf(gen,'Id',lcr.Id);
                            cjObj.wsf(gen,'Name',lcr.Name);
                            cjObj.wsf(gen,'Timing__c',lcr.Timing__c);
       
                         gen.writeEndObject();
                      }
                      
                      Integer custSize = 1;
                      if(QuantRatingCustom != null & QuantRatingCustom.size() > 0){
                          custSize = QuantRatingCustom.size();
                      }
                      
                      for(Integer i = 1; i < 29; i++){
                          gen.writeStartObject();
                            
                            cjObj.wsf(gen,'API_name','FMCustom_Metric_'+i+'__c');
                            cjObj.wsf(gen,'Assessment_type__c','Quantitative');
                            cjObj.wsf(gen,'Calculation_type__c','Bucketed');
                            cjObj.wbf(gen,'Deactivated__c',false);
                            cjObj.wsf(gen,'Id','');
                            cjObj.wsf(gen,'FMCustom_Metric_'+i+'__c');
                            cjObj.wsf(gen,'Timing__c',lcr.Timing__c);
       
                         gen.writeEndObject();
                      }*/
                          
                  gen.writeEndArray();
             gen.writeEndObject();
        jQuant = gen.getAsString();
        
        system.debug(' jQuant '+jQuant);
        //msg = jQuant;
       // Call out to Trifecta Rating APIs /api/metrics/OrgId/definition
       
       //if(!test.isRunningtest()){ 
          msg = httpHandler('POST', token, '/api/metrics/'+ lstOrg[0].Id+'/quantDefinition', jQuant);
       //}
   }
       
   //---------------------------------------QUAL EMPLOYEE METRIC---------------------------------//
   
   public void createQualMetric(List<Sales_rep_profile__c> srps){
   
       String jQual; // to hold Qual Json data
      
       // Retrieve ORG Id to pass along with the APIs as a param
       lstOrg = new List<Organization>();
       lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
       
       // ---------------------------------Retrieve QUAL SCORES per Employee----------------//
      
      //Get the monthly Answer
        
        /*list<Certification_Answer__c> cerDuedateMonthly = new list<Certification_Answer__c>();
        
        
        cerDuedateMonthly  =[select id, Due_Date__c from Certification_Answer__c where Rating_Score__c != null AND Due_Date__c  != null AND  Certifcation_Rating__r.Assessment_type__c='Qualitative' order by Due_Date__c  Desc limit 1];
        
        if(cerDuedateMonthly != null && cerDuedateMonthly.size()>0){*/
           
          
        //}
        
        
        
        List<Certification_Rating__c> lstQualRatings = [SELECT name, Id, API_Identifier_qual__c FROM Certification_Rating__c WHERE Assessment_Type__c = 'Qualitative'];
        Integer numRatings = lstQualRatings.size();
        
        lstCA = new List<Certification_Answer__c>();
        
        lstCA = [select Certifcation_Rating__c, Certifcation_Rating__r.API_Identifier_qual__c, Due_Date__c, ID,Rating_Score__c, Sales_Rep_Profile__c, Sales_Rep_Profile__r.Role__c from Certification_Answer__c where Rating_Score__c != null AND Due_Date__c = :dtSnapShot AND  Certifcation_Rating__r.Assessment_type__c='Qualitative' AND Sales_rep_profile__c IN :srps];
            Map<id,Map<Integer,Certification_Answer__c>> profRatingMap = new Map <id,Map<Integer,Certification_Answer__c>>();
        
        if(lstCA != null && lstCA.size() > 0){
            for(Certification_Answer__c lca:lstCA ){
                if (profRatingMap.containsKey(lca.Sales_Rep_Profile__c)){
                    profRatingMap.get(lca.Sales_Rep_Profile__c).put((Integer)lca.Certifcation_Rating__r.API_Identifier_qual__c,lca);
                    
                }
                else{
                    Map<Integer,Certification_Answer__c> mr = new Map<Integer,Certification_Answer__c>();
                    mr.put((Integer)lca.Certifcation_Rating__r.API_Identifier_qual__c,lca);
                    
                    profRatingMap.put(lca.Sales_Rep_Profile__c,mr);
                }
            }
        }
        
        system.debug(' profRatingMap '+profRatingMap);
        
        if(lstCA != null && lstCA.size() > 0){
        
          JSONGenerator gen = JSON.createGenerator(true);
          clsJSON2 cjObj = new clsJSON2();
          gen.writeStartObject();
              
              //cjObj.wdf(gen,'dueDate',lstCA[0].Due_Date__c);
              
              gen.writeFieldName('employees');
              
              gen.writeStartArray();
                    
                  for(Id i: profRatingMap.keySet()){
                      
                      gen.writeStartObject();
                      
                          gen.writeFieldName('metrics');
                          
                          gen.writeStartObject();
                          
                          Map<Integer,Certification_Answer__c> cansMap = profRatingMap.get(i);
                          
                          for(integer cnt = 1; cnt < 201; cnt ++){
                              
                              if (cansMap.containsKey(cnt)){
                                  
                                  //gen.writeStartObject();
                                                                    
                                  cjObj.wnf(gen, ''+cnt+'' ,cansMap.get(cnt).Rating_score__c);
                                  
                                  //gen.writeEndObject();    
                                  
                              }
                              else{
                              
                                  //gen.writeStartObject();
                                                                    
                                  cjObj.wsf(gen, ''+cnt+'','null');
                                  
                                  //gen.writeEndObject(); 
                                  
                              }
                              
                          }
                          gen.writeEndObject();
                          
                          List<Integer> keys = new List<Integer>();
                          keys.addAll(cansMap.keyset());
                          gen.writeFieldName('sfEmployeeId');
                          gen.writeObject(cansMap.get(keys[0]).Sales_Rep_Profile__c);
                          
                          gen.writeFieldName('roleName');
                          gen.writeObject(cansMap.get(keys[0]).Sales_Rep_Profile__r.Role__c);
                          
                      gen.writeEndObject(); 
                      
                      
                  }
                  
                  /*
                  for(Certification_Answer__c lca:lstCA ){
                  
                      gen.writeStartObject();
                        
                        cjObj.wsf(gen,'Certifcation_Rating__c',lca.Certifcation_Rating__c);
                        cjObj.wnf(gen,'Rating_Score__c',lca.Rating_Score__c);
                        cjObj.wsf(gen,'Sales_Rep_Profile__c',lca.Sales_Rep_Profile__c );
                        cjObj.wsf(gen,'Role_Name',lca.Sales_Rep_Profile__r.Role__c );
                        
                      gen.writeEndObject();
                  }*/
                                                
              gen.writeEndArray(); 
              
              gen.writeFieldName('dueDate');
              gen.writeObject(dtSnapShot);
                        
           gen.writeEndObject();
           jQual = gen.getAsString();
         }
       
        /*
        if(lstCA != null && lstCA.size() > 0){
        
          JSONGenerator gen = JSON.createGenerator(true);
          clsJSON2 cjObj = new clsJSON2();
          gen.writeStartObject();
              
              cjObj.wdf(gen,'dueDate',lstCA[0].Due_Date__c);
              
              gen.writeFieldName('employees');
              
                  gen.writeStartArray();
                        
                      for(Certification_Answer__c lca:lstCA ){
                      
                        gen.writeStartObject();
                            
                            cjObj.wsf(gen,'Certifcation_Rating__c',lca.Certifcation_Rating__c);
                            cjObj.wnf(gen,'Rating_Score__c',lca.Rating_Score__c);
                            cjObj.wsf(gen,'Sales_Rep_Profile__c',lca.Sales_Rep_Profile__c );
                            cjObj.wsf(gen,'Role_Name',lca.Sales_Rep_Profile__r.Role__c );
                            
                         gen.writeEndObject();
                      }
                          
                  gen.writeEndArray();   
             gen.writeEndObject();
             jQual = gen.getAsString();
       }*/
       // Trifecta endpoint : /api/metrics/{orgId}/qual
       //msg =jQual;
       system.debug(' jQual '+jQual);
       //if(!test.isRunningtest()){
           msg = httpHandler('POST', token, '/metrics/'+lstOrg[0].Id+'/qual', jQual);
       //}
   }

   
       
   //---------Quant Employee Metrics------------------//
   
   public void createQuantMetric(List<Sales_rep_profile__c> srps){
  
       String jQuant; // to hold Quant Json data
       
       // Retrieve ORG Id to pass along with the APIs as a param
       lstOrg = new List<Organization>();
       lstOrg = [SELECT Id,Name FROM Organization LIMIT 5000];
       
       
       // ---------------------------------Retrieve QUANT SCORES per Employee----------------//
        
            lstSRPS = new List<Sales_Rep_Profile_Snapshot__c>();
                              
            String dateVal = String.valueOf(dtSnapshot);
            dateVal = dateVal.substring(0,10);
            
            //Fetch active quantitative certification ratings
            List<Certification_Rating__c> ratings = [SELECT Metric_Field_Name__c FROM Certification_rating__c WHERE Assessment_type__c = 'Quantitative' AND Metric_Field_Name__c != NULL AND SRP_field_name__c = null];
            
            system.debug(' ratings '+ratings);
            
            //String queryString = 'SELECT Role__c, Sales_Rep_Profile__c,Goal_12_Month_Opportunitie_added_funnel__c, Goal_12_Month_Rolling_Opptys_Won__c, Goal_12m_Avg_Selling_Price__c, Goal_12m_Lead_To_Opp_Conv_Rate__c, Goal_12m_length_of_sales_cycle__c, Goal_12m_rolling_close_rate__c, Goal_Number_of_meetings_12_months__c,Goal_of_annual_leads_to_achieve_quota__c, Goal_of_annual_opptys_added_to_funnel__c, Goal_of_monthly_leads_to_achieve_quota__c, Goal_of_monthly_meetings__c, Goal_of_monthly_opptys_added_to_funnel__c, Goal_of_quartly_leads_to_achieve_quota__c, Goal_of_quartly_opptys_added_to_funnel__c, Goal_of_wins_to_achieve_annual_quota__c,  Goal_of_wins_to_achieve_monthly_quota__c,   Goal_of_wins_to_achieve_quartly_quota__c, Goal_YTD_Opportunities_Added__c,   Monthly_Lead_to_Opp_Conversion_Rate__c, Monthly_Average_Win_size__c,     Monthly_Lead_Added__c, Monthly_Opportunities_Added_amt__c, Monthly_opp_lost__c,     Monthly_opp_won__c, Monthly_Opportunities_added_to_Qualifie__c, Monthly_Opportunity_Quota__c, Monthly_Quota_Revenue__c, Number_of_meetings_per_month__c, Number_of_meetings_per_quarter__c, Number_of_meetings_Rolling_12_months__c, Number_of_meetings_YTD__c, Quarterly_Lead_to_Opp_Conversion_Rate__c, Quarterly_Average_Win_Size__c, Quarterly_Lead_Added__c, Quarterly_Opportunities_Added_amt__c, Quarterly_opp_won__c, Quarterly_Opportunities_added_to_Qualifi__c, Quarterly_Opportunity_Quota__c, Quarterly_Quota_Revenue__c, X12_Month_Average_Selling_Price__c, X12_Month_Lead_Conv_for_1_oppty__c, X12_Month_Leads_Added__c, X12_Month_Opprties_Added_to_the_funnel__c, X12_Month_Rolling_Average_Sales_Cycle__c, X12_Month_Rolling_Opptys_Won__c, X12_Month_Rolling_Quota__c, X12_Month_Rolling_Revenue__c, YTD_Average_win_size__c, YTD_Leads_Added__c, YTD_Opportunities_Added__c, YTD_Opportunities_Won__c, YTD_Quota__c, YTD_Revenue__c'  ;
            
            //String queryString = 'SELECT Role__c, Sales_Rep_Profile__c,Goal_12_Month_Opportunitie_added_funnel__c,Goal_12_Month_Rolling_Opptys_Won__c,Goal_12m_Avg_Selling_Price__c,Goal_12m_Lead_To_Opp_Conv_Rate__c,Goal_12m_length_of_sales_cycle__c,Goal_12m_rolling_close_rate__c,Goal_Number_of_meetings_12_months__c,Goal_of_annual_leads_to_achieve_quota__c,Goal_of_annual_opptys_added_to_funnel__c,Goal_of_monthly_leads_to_achieve_quota__c,Goal_of_monthly_meetings__c,Goal_of_monthly_opptys_added_to_funnel__c,Goal_of_quartly_leads_to_achieve_quota__c,Goal_of_quartly_opptys_added_to_funnel__c,Goal_of_wins_to_achieve_annual_quota__c,Goal_of_wins_to_achieve_monthly_quota__c,Goal_of_wins_to_achieve_quartly_quota__c,Goal_YTD_Opportunities_Added__c,Monthly_Lead_to_Opp_Conversion_Rate__c,Monthly_Lead_Added__c,Monthly_Opportunities_Added_amt__c,Monthly_opp_lost__c,Monthly_Opportunities_added_to_Qualifie__c,Monthly_Opportunity_Quota__c,Quarterly_Lead_to_Opp_Conversion_Rate__c,Quarterly_Lead_Added__c,Quarterly_Opportunities_Added_amt__c,Quarterly_Opportunities_added_to_Qualifi__c,Quarterly_Opportunity_Quota__c,X12_Month_Lead_Conv_for_1_oppty__c,X12_Month_Leads_Added__c,X12_Month_Opprties_Added_to_the_funnel__c,X12_Month_Rolling_Average_Sales_Cycle__c,X12_Month_Rolling_Quota__c,YTD_Leads_Added__c,YTD_Opportunities_Added__c,YTD_Quota__c'  ;

            String queryString = 'SELECT Role__c,New_or_Tenured__c, Sales_Rep_Profile__c,Monthly_Lead_to_Opp_Conversion_Rate__c,Monthly_Opportunities_Added_amt__c,Monthly_opp_lost__c,Monthly_Opportunities_added_to_Qualifie__c,Monthly_Opportunity_Quota__c,Quarterly_Lead_to_Opp_Conversion_Rate__c,Quarterly_Opportunities_Added_amt__c,Quarterly_Opportunities_added_to_Qualifi__c,Quarterly_Opportunity_Quota__c,X12_Month_Lead_Conv_for_1_oppty__c,X12_Month_Opprties_Added_to_the_funnel__c,X12_Month_Rolling_Average_Sales_Cycle__c,X12_Month_Rolling_Quota__c,YTD_Opportunities_Added__c,YTD_Quota__c, FMCustom_Metric_1__c,FMCustom_Metric_2__c,FMCustom_Metric_3__c,FMCustom_Metric_4__c,FMCustom_Metric_5__c,FMCustom_Metric_6__c,FMCustom_Metric_7__c,FMCustom_Metric_8__c,FMCustom_Metric_9__c,FMCustom_Metric_10__c,FMCustom_Metric_11__c,FMCustom_Metric_12__c,FMCustom_Metric_13__c,FMCustom_Metric_14__c,FMCustom_Metric_15__c,FMCustom_Metric_16__c,FMCustom_Metric_17__c,FMCustom_Metric_18__c,FMCustom_Metric_19__c,FMCustom_Metric_20__c,FMCustom_Metric_21__c,FMCustom_Metric_22__c,FMCustom_Metric_23__c,FMCustom_Metric_24__c,FMCustom_Metric_25__c,FMCustom_Metric_26__c,FMCustom_Metric_27__c,FMCustom_Metric_28__c'  ;
                      
            for(Certification_Rating__c r: ratings){
                queryString += ', '+String.valueOf(r.Metric_Field_Name__c);
            }                    
                                    
            String srpList;
            
            system.debug(' srps '+srps);
            
            for(Sales_rep_profile__c s: srps){
                if(srpList == null || srpList == '' || srpList.length() == 0){
                    srpList = '(\''+s.id+'\'';
                }
                else{
                    srpList += ','+'\''+s.id+'\'';
                }
            }
            
            srpList = srpList + ')'; 
            
            system.debug(' srpList '+srpList);
            
            //queryString = queryString + ' FROM Sales_rep_profile_snapshot__c WHERE Snapshot_Scheduled_Date__c = '+dateVal +' AND YTD_Quota__c > 0 AND Sales_rep_profile__c IN '+srpList+' AND Sales_rep_profile__r.Rep_Start_Date__c < '+dateVal;                                       
            
            queryString = queryString + ' FROM Sales_rep_profile_snapshot__c WHERE Snapshot_Scheduled_Date__c = '+dateVal +' AND YTD_Quota__c > 0 AND Sales_rep_profile__c IN '+srpList;
            
            system.debug(' queryString '+queryString);
            
            lstSRPS = Database.query(queryString);

            JSONGenerator gen = JSON.createGenerator(true);
            clsJSON2 cjObj = new clsJSON2();
            gen.writeStartObject();
              gen.writeFieldName('employees');
                  gen.writeStartArray();
                        
                          for(Sales_Rep_Profile_Snapshot__c sr:lstSRPS){
                            system.debug(' sr.Sales_Rep_Profile__c '+sr.Sales_Rep_Profile__c);
                            gen.writeStartObject();
                             gen.writeFieldName('metrics');
                                gen.writeStartObject();
                                    /*
                                    //cjObj.wnf(gen,'Average_Sales_Price__c',sr.Average_Sales_Price__c);
                                    //cjObj.wsf(gen,'Role__c',sr.Role__c);
                                    cjObj.wnf(gen,'Monthly_Average_Win_size_percentage__c',sr.Monthly_Average_Win_size_percentage__c);
                                    cjObj.wnf(gen,'Lead_to_Opportunity_Conversion_Rate__c',sr.Lead_to_Opportunity_Conversion_Rate__c);
                                    cjObj.wnf(gen,'Monthly_Close_Rate__c',sr.Monthly_Close_Rate__c);
                                    cjObj.wnf(gen,'Monthly_Opp_added_to_Qualif_Percentage__c',sr.Monthly_Opp_added_to_Qualif_Percentage__c);
                                    cjObj.wnf(gen,'Monthly_Opportunities_Closed_percentage__c',sr.Monthly_Opportunities_Closed_percentage__c);
                                    cjObj.wnf(gen,'Monthly_Opportunity_Close_Rate__c',sr.Monthly_Opportunity_Close_Rate__c);
                                    cjObj.wnf(gen,'Monthly_Quota_Performance__c',sr.Monthly_Quota_Performance__c);
                                    cjObj.wnf(gen,'Number_of_meetings_12_months_percentage__c',sr.Number_of_meetings_12_months_percentage__c);
                                    cjObj.wnf(gen,'Number_of_meetings_per_month_percentage__c',sr.Number_of_meetings_per_month_percentage__c);
                                    cjObj.wnf(gen,'Number_of_meetings_per_quarte_percentage__c',sr.Number_of_meetings_per_quarte_percentage__c);
                                    cjObj.wnf(gen,'Number_of_meetings_YTD_percentage__c',sr.Number_of_meetings_YTD_percentage__c);
                                    cjObj.wnf(gen,'Quarterly_Close_Rate__c',sr.Quarterly_Close_Rate__c);
                                    cjObj.wnf(gen,'Quarterly_Opp_added_to_Qualif_Percentage__c',sr.Quarterly_Opp_added_to_Qualif_Percentage__c);
                                    cjObj.wnf(gen,'Quarterly_Opportunitie_Closed_percentage__c',sr.Quarterly_Opportunitie_Closed_percentage__c);
                                    cjObj.wnf(gen,'Quarterly_Opportunity_Close_Rate__c',sr.Quarterly_Opportunity_Close_Rate__c);
                                    cjObj.wnf(gen,'Quarterly_Quota_Performance__c',sr.Quarterly_Quota_Performance__c);
                                    cjObj.wnf(gen,'X12_Month_Opportunities_added_percentage__c',sr.X12_Month_Opportunities_added_percentage__c);
                                    cjObj.wnf(gen,'X12_Month_Rolling_Close_Rate__c',sr.X12_Month_Rolling_Close_Rate__c);
                                    cjObj.wnf(gen,'X12_Month_Rolling_Opportunity_Close_Rate__c',sr.X12_Month_Rolling_Opportunity_Close_Rate__c);
                                    cjObj.wnf(gen,'X12_Month_Rolling_Opptys_Won_percentage__c',sr.X12_Month_Rolling_Opptys_Won_percentage__c);
                                    cjObj.wnf(gen,'X12_Month_Rolling_Quota_Performance__c',sr.X12_Month_Rolling_Quota_Performance__c);
                                    cjObj.wnf(gen,'YTD_Average_Sales_Cycle__c',sr.YTD_Average_Sales_Cycle__c);
                                    cjObj.wnf(gen,'YTD_Close_Rate__c',sr.YTD_Close_Rate__c);
                                    cjObj.wnf(gen,'YTD_Opportunities_Added_percentage__c',sr.YTD_Opportunities_Added_percentage__c);
                                    cjObj.wnf(gen,'YTD_Opportunities_Closed_percentage__c',sr.YTD_Opportunities_Closed_percentage__c);
                                    cjObj.wnf(gen,'YTD_Opportunity_Close_Rate__c',sr.YTD_Opportunity_Close_Rate__c);
                                    cjObj.wnf(gen,'YTD_Quota_Percentage__c',sr.YTD_Quota_Percentage__c);
                                    */
                                    
                                    for(Certification_Rating__c r: ratings){
                                        //queryString = queryString + ', '+r.Metric_Field_Name__c;
                                        cjObj.wnf(gen,String.valueOf(r.Metric_Field_Name__c),(Decimal)sr.get(String.valueOf(r.Metric_Field_Name__c)));
                                        
                                    }                    
                                    
                                    /*                   
                                    cjObj.wnf(gen,'Goal_12_Month_Opportunitie_added_funnel__c',sr.Goal_12_Month_Opportunitie_added_funnel__c);
                                    cjObj.wnf(gen,'Goal_12_Month_Rolling_Opptys_Won__c',sr.Goal_12_Month_Rolling_Opptys_Won__c);
                                    cjObj.wnf(gen,'Goal_12m_Avg_Selling_Price__c',sr.Goal_12m_Avg_Selling_Price__c);
                                    cjObj.wnf(gen,'Goal_12m_Lead_To_Opp_Conv_Rate__c',sr.Goal_12m_Lead_To_Opp_Conv_Rate__c);
                                    cjObj.wnf(gen,'Goal_12m_length_of_sales_cycle__c',sr.Goal_12m_length_of_sales_cycle__c);
                                    cjObj.wnf(gen,'Goal_12m_rolling_close_rate__c',sr.Goal_12m_rolling_close_rate__c);
                                    cjObj.wnf(gen,'Goal_Number_of_meetings_12_months__c',sr.Goal_Number_of_meetings_12_months__c);
                                    //cjObj.wnf(gen,'Goal_12Month_Rolling_Opptys_Added_amt__c',sr.Goal_12Month_Rolling_Opptys_Added_amt__c);
                                    cjObj.wnf(gen,'Goal_of_annual_leads_to_achieve_quota__c',sr.Goal_of_annual_leads_to_achieve_quota__c);
                                    cjObj.wnf(gen,'Goal_of_annual_opptys_added_to_funnel__c',sr.Goal_of_annual_opptys_added_to_funnel__c);
                                    cjObj.wnf(gen,'Goal_of_monthly_leads_to_achieve_quota__c',sr.Goal_of_monthly_leads_to_achieve_quota__c);
                                    cjObj.wnf(gen,'Goal_of_monthly_meetings__c',sr.Goal_of_monthly_meetings__c);
                                    cjObj.wnf(gen,'Goal_of_monthly_opptys_added_to_funnel__c',sr.Goal_of_monthly_opptys_added_to_funnel__c);
                                    cjObj.wnf(gen,'Goal_of_quartly_leads_to_achieve_quota__c',sr.Goal_of_quartly_leads_to_achieve_quota__c);
                                    cjObj.wnf(gen,'Goal_of_quartly_opptys_added_to_funnel__c',sr.Goal_of_quartly_opptys_added_to_funnel__c);
                                    cjObj.wnf(gen,'Goal_of_wins_to_achieve_annual_quota__c',sr.Goal_of_wins_to_achieve_annual_quota__c);
                                    cjObj.wnf(gen,'Goal_of_wins_to_achieve_monthly_quota__c',sr.Goal_of_wins_to_achieve_monthly_quota__c);
                                    cjObj.wnf(gen,'Goal_of_wins_to_achieve_quartly_quota__c',sr.Goal_of_wins_to_achieve_quartly_quota__c);
                                    cjObj.wnf(gen,'Goal_YTD_Opportunities_Added__c',sr.Goal_YTD_Opportunities_Added__c);
                                    */
                                    
                                    //cjObj.wnf(gen,'Monthly_Lead_to_Opp_Conversion_Rate__c',sr.Monthly_Lead_to_Opp_Conversion_Rate__c);
                                    //cjObj.wnf(gen,'Monthly_Average_Win_size__c',sr.Monthly_Average_Win_size__c);
                                    
                                    //cjObj.wnf(gen,'Monthly_Lead_Added__c',sr.Monthly_Lead_Added__c);
                                    
                                    //cjObj.wnf(gen,'Monthly_Opportunities_Added_amt__c',sr.Monthly_Opportunities_Added_amt__c);
                                    //cjObj.wnf(gen,'Monthly_opp_lost__c',sr.Monthly_opp_lost__c);
                                    //cjObj.wnf(gen,'Monthly_opp_won__c',sr.Monthly_opp_won__c);
                                    //cjObj.wnf(gen,'Monthly_Opportunities_added_to_Qualifie__c',sr.Monthly_Opportunities_added_to_Qualifie__c);
                                    
                                    
                                    //cjObj.wnf(gen,'Monthly_Opportunity_Quota__c',sr.Monthly_Opportunity_Quota__c);
                                    
                                    //cjObj.wnf(gen,'Monthly_Quota_Revenue__c',sr.Monthly_Quota_Revenue__c);
                                    
                                    //cjObj.wnf(gen,'Number_of_meetings_per_month__c',sr.Number_of_meetings_per_month__c);
                                    
                                    
                                    //cjObj.wnf(gen,'Number_of_meetings_per_quarter__c',sr.Number_of_meetings_per_quarter__c);
                                    //cjObj.wnf(gen,'Number_of_meetings_Rolling_12_months__c',sr.Number_of_meetings_Rolling_12_months__c);
                                    //cjObj.wnf(gen,'Number_of_meetings_YTD__c',sr.Number_of_meetings_YTD__c);
                                    
                                    //cjObj.wnf(gen,'Quarterly_Lead_to_Opp_Conversion_Rate__c',sr.Quarterly_Lead_to_Opp_Conversion_Rate__c);
                                    //cjObj.wnf(gen,'Quarterly_Average_Win_Size__c',sr.Quarterly_Average_Win_Size__c);
                                    
                                    //cjObj.wnf(gen,'Quarterly_Lead_Added__c',sr.Quarterly_Lead_Added__c);
                                    
                                    //cjObj.wnf(gen,'Quarterly_Opportunities_Added_amt__c',sr.Quarterly_Opportunities_Added_amt__c);
                                    //cjObj.wnf(gen,'Quarterly_opp_won__c',sr.Quarterly_opp_won__c);
                                    
                                    //cjObj.wnf(gen,'Quarterly_Opportunities_added_to_Qualifi__c',sr.Quarterly_Opportunities_added_to_Qualifi__c);
                                    
                                    //cjObj.wnf(gen,'Quarterly_Opportunity_Quota__c',sr.Quarterly_Opportunity_Quota__c);
                                    
                                    //cjObj.wnf(gen,'Quarterly_Quota_Revenue__c',sr.Quarterly_Quota_Revenue__c);
                                    //cjObj.wnf(gen,'X12_Month_Average_Selling_Price__c',sr.X12_Month_Average_Selling_Price__c);
                                    //cjObj.wnf(gen,'X12_Month_Lead_Conv_for_1_oppty__c',sr.X12_Month_Lead_Conv_for_1_oppty__c);
                                    //cjObj.wnf(gen,'X12_Month_Leads_Added__c',sr.X12_Month_Leads_Added__c);
                                    
                                    //cjObj.wnf(gen,'X12_Month_Opprties_Added_to_the_funnel__c',sr.X12_Month_Opprties_Added_to_the_funnel__c);
                                    //cjObj.wnf(gen,'X12_Month_Rolling_Average_Sales_Cycle__c',sr.X12_Month_Rolling_Average_Sales_Cycle__c);
                                    
                                    
                                    //cjObj.wnf(gen,'X12_Month_Rolling_Opptys_Won__c',sr.X12_Month_Rolling_Opptys_Won__c);
                                    
                                    //cjObj.wnf(gen,'X12_Month_Rolling_Quota__c',sr.X12_Month_Rolling_Quota__c);
                                    
                                    //cjObj.wnf(gen,'X12_Month_Rolling_Revenue__c',sr.X12_Month_Rolling_Revenue__c);
                                    
                                    //cjObj.wnf(gen,'YTD_Average_win_size__c',sr.YTD_Average_win_size__c);
                                    
                                    //cjObj.wnf(gen,'YTD_Leads_Added__c',sr.YTD_Leads_Added__c);
                                    //cjObj.wnf(gen,'YTD_Opportunities_Added__c',sr.YTD_Opportunities_Added__c);
                                    
                                    
                                    //cjObj.wnf(gen,'YTD_Opportunities_Won__c',sr.YTD_Opportunities_Won__c);
                                    
                                    //cjObj.wnf(gen,'YTD_Quota__c',sr.YTD_Quota__c);
                                    
                                    //cjObj.wnf(gen,'YTD_Revenue__c',sr.YTD_Revenue__c);
                                    
                                    cjObj.wnf(gen,'FMCustom_Metric_1__c',sr.FMCustom_Metric_1__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_2__c',sr.FMCustom_Metric_2__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_3__c',sr.FMCustom_Metric_3__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_4__c',sr.FMCustom_Metric_4__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_5__c',sr.FMCustom_Metric_5__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_6__c',sr.FMCustom_Metric_6__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_7__c',sr.FMCustom_Metric_7__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_8__c',sr.FMCustom_Metric_8__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_9__c',sr.FMCustom_Metric_9__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_10__c',sr.FMCustom_Metric_10__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_11__c',sr.FMCustom_Metric_11__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_12__c',sr.FMCustom_Metric_12__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_13__c',sr.FMCustom_Metric_13__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_14__c',sr.FMCustom_Metric_14__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_15__c',sr.FMCustom_Metric_15__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_16__c',sr.FMCustom_Metric_16__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_17__c',sr.FMCustom_Metric_17__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_18__c',sr.FMCustom_Metric_18__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_19__c',sr.FMCustom_Metric_19__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_20__c',sr.FMCustom_Metric_20__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_21__c',sr.FMCustom_Metric_21__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_22__c',sr.FMCustom_Metric_22__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_23__c',sr.FMCustom_Metric_23__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_24__c',sr.FMCustom_Metric_24__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_25__c',sr.FMCustom_Metric_25__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_26__c',sr.FMCustom_Metric_26__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_27__c',sr.FMCustom_Metric_27__c);
                                    cjObj.wnf(gen,'FMCustom_Metric_28__c',sr.FMCustom_Metric_28__c);
                                    
                                    cjObj.wsf(gen,'New_or_Tenured__c',sr.New_or_Tenured__c);   
                                    
                                 gen.writeEndObject();
                            
                                gen.writeFieldName('sfEmployeeId');
                                gen.writeObject(sr.Sales_Rep_Profile__c);
                                
                                if(sr.Role__c != null){
                                    gen.writeFieldName('roleName');
                                    gen.writeObject(sr.Role__c);
                                }
                            gen.writeEndObject();
                          }
                          
                      gen.writeEndArray();
                    //gen.writeNumberField('month', ssd[0].Snapshot_Scheduled_Date__c.month());
                  //gen.writeNumberField('year', ssd[0].Snapshot_Scheduled_Date__c.year());
                   gen.writeNumberField('month', dtSnapShot.month());
                  gen.writeNumberField('year', dtSnapShot.year());
                  
            gen.writeEndObject();

          jQuant = gen.getAsString();
          //msg =jQuant;
          system.debug(' jQuant '+jQuant);
          //if(!test.isRunningtest()){
              msg = httpHandler('POST', token, '/metrics/'+ lstOrg[0].Id+'/quant', jQuant);
           //     msg = httpHandler('POST', token, '/api/metrics/00DE0000000IYQcMAO/quant', jQuant);
          //}
   }
 
  // Wrap the parameters from JSON object
   public class fromJSON{
        public string access_token;
    }
  
  // Checks for the null values in the list and replaces it with just a key.
  public class clsJSON2 {
          
         // Writes Number Fields and replaces null values
         public void wnf(JSONGenerator gen, String fieldName, Decimal fieldValue) {
                if(fieldValue == null) {
                    gen.writeNullField(fieldName); // Could be replaced with writeStringField(...,'') if you prefer an empty string over a null field
                } else {
                    gen.writeNumberField(fieldName, fieldValue);
                }
            }
        
        //Writes String Fields and replaces null values
        public void wsf(JSONGenerator gen, String fieldName, String fieldValue) {
            if(fieldValue == null) {
                gen.writeNullField(fieldName); // Could be replaced with writeStringField(...,'') if you prefer an empty string over a null field
            } else {
                gen.writeStringField(fieldName, fieldValue);
            }
        }
        
        //Writes Date Fields and replaces null values
        public void wdf(JSONGenerator gen, String fieldName, Date fieldValue) {
            if(fieldValue == null) {
                gen.writeNullField(fieldName); // Could be replaced with writeStringField(...,'') if you prefer an empty string over a null field
            } else {
                gen.writeDateField(fieldName, fieldValue);
            }
        }
        
        //Writes Boolean Fields and replaces null values
        public void wbf(JSONGenerator gen, String fieldName, Boolean fieldValue) {
            if(fieldValue == null) {
                gen.writeNullField(fieldName); // Could be replaced with writeStringField(...,'') if you prefer an empty string over a null field
            } else {
                gen.writeBooleanField(fieldName, fieldValue);
            }
        }        
        
   }
  
    public String httpHandler(string method, string atoken, string endpoint, string jbody){
         
         system.debug(' jbody '+jbody);
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
         
         if(jbody != '' && jbody != null){
           request.setBody(jbody);
         }
         
         system.debug(' request '+request);
                 
         HttpResponse response = http.send(request);
         
         system.debug(' response is '+response);
         
         if(response.getStatusCode() != 200){
             throw new MyException('REST call failed '+' statusCode '+response.getStatusCode()+' response is '+response);
         }
         
         jsonData = response.getBody();
         
         Return jsonData;
     }
     
     public class MyException extends Exception{} 
}