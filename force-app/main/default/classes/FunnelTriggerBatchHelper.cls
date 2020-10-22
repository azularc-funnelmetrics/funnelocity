/*
    Author:  Carine DMello
    Created On: 11/20/2017
    This class contains all methods that are called from the triggers    
    Copyright: Funnel Metrics, LLC

*/

public with sharing class FunnelTriggerBatchHelper{
     
    public static boolean doNotCallSPTrigger = false;
    
    public static boolean histDataBatch = false;
    
    public static Date histDateVal;
    
    public static DateTime histDateTimeVal;
    
    public Static Date getFiscalYearDate(String recName){
    
        Fiscal_Year_Setting__c fy = Fiscal_Year_Setting__c.getValues(recName);
        
        if(fy != null)
            return fy.Start_Date__c;
        else
            return null;
    }
    
    public static String prefix{ get{return 'FunnelMetrics__';} set; }
     
    public Static Fiscal_Year_Setting__c getFiscalYearRecord(String recName){
    
        Fiscal_Year_Setting__c fy = Fiscal_Year_Setting__c.getValues(recName);
        
        return fy;
    }
    
    /*new*/
    public Static Set<Id> fetchRelatedOwners(List<Opportunity> newVals, List<Opportunity> oldVals){
        
        //system.debug(' newVals '+newVals);
        
        //system.debug(' oldVals '+oldVals);
        
        Set<Id> ownerIds = new Set<Id>();
        
        Date currentFiscalYear = getFiscalYearDate('Current_Year');
        
        //Fetch all the sales profiles associated with the opportunities (both the old and new values)
        for (Opportunity o : newVals){ 
            
            if(currentFiscalYear == null){
                o.addError('The fiscal year start date is not set');
            }
        
            if(o.OwnerId != null){ 
                 ownerIds.add(o.OwnerId);
            }
                
        }
        
        //Fetch the sales profiles associated with the opportunities before the update
        if(trigger.isUpdate){
            //system.debug(' is update' );
            for (Opportunity o : oldVals){ 
                //system.debug(' old '+o);  
                if(o.OwnerId != null){ 
                     ownerIds.add(o.OwnerId);
                }
            }
        }
        
        return ownerIds;
        
    } 
    
    public Static Set<Id> fetchRelatedLeadOwners(List<Lead> newVals,List<Lead> oldVals){
        
        //system.debug(' newVals '+newVals);
        
        Set<Id> ownerIds = new Set<Id>();
        
        Date currentFiscalYear = getFiscalYearDate('Current_Year');
        
        //Fetch all the sales profiles associated with the leads (both the old and new values)
        for (Lead o : newVals){ 
            
            if(currentFiscalYear == null){
                o.addError('The fiscal year start date is not set');
            }
        
            if(o.OwnerId != null){ 
                 ownerIds.add(o.OwnerId);
            }
                
        }
        
        if(trigger.isUpdate){
            //system.debug(' is update' );
            for (Lead o : oldVals){ 
                //system.debug(' old '+o);  
                if(o.OwnerId != null){ 
                     ownerIds.add(o.OwnerId);
                }
            }
        }
                
        return ownerIds;
        
    }
      
    /*new*/
    public Static Map<Id,Sales_Rep_Profile__c> fetchSalesProfileUpdatedMapFromOwners(Set<Id> ownerIds, DateTime executionDate){
        //try{    
        Decimal userprob = 0;
        List<Application_Setting__c> prob = [SELECT Id, Probability__c FROM Application_Setting__c limit 1];
        if(prob != null && prob.size()>0){
            userprob = prob[0].Probability__c;
        }
        
        //Map to store the sales profiles to be updated
        Map<id, Sales_Rep_Profile__c> profMap = new Map<id, Sales_Rep_Profile__c>();
        
        //Map to store the user id and the corresponding sales profile id
        Map<Id,Id> ownerSalesReps = new Map<Id,Id>();
        
        List<Sales_Rep_Profile__c> salesReps = [SELECT id,User_Record_Name__c FROM Sales_Rep_Profile__c WHERE User_Record_Name__c IN :ownerIds];
        
        for(Sales_Rep_Profile__c sr: salesReps ){
            ownerSalesReps.put(sr.User_Record_Name__c,sr.id);    
        }
                           
        Date currentFiscalYear = getFiscalYearDate('Current_Year');
        DateTime FyearDateTime = getFiscalYearDate('Current_Year');
        /*Start fetching quarterly created opportunities*/
        // Cyear = Date.Today(); Static date
        
        //DateTime Cyear;
        
        //if(executionDate != null)
        //    Cyear = Date.Today();
        //else
        //Cyear = DateTime.newInstance(2018,05,31,0,0,0);
        //Date CyearDate = Date.newInstance(2018,11,30);
        
        //Date CyearDate = Date.Today();
        //DateTime CyearGMT = DateTime.newInstance(2018,11,30,0,0,0);
        //DateTime CyearGMT = Date.Today();
        
        Date CyearDate;
        
        DateTime CyearDateTime;
        
        DateTime CyearGMT;
        
        //system.debug(' hist data in trigger '+FunnelTriggerBatchHelper.histDataBatch);
        
        if(FunnelTriggerBatchHelper.histDataBatch){
            CyearDate = FunnelTriggerBatchHelper.histDateVal;   
            CyearGMT = FunnelTriggerBatchHelper.histDateTimeVal;
            //CyearDateTime = CyearGMT;
        }
        else if( FunnelTriggerBatchHelper.histDateVal != null){
            CyearDate = FunnelTriggerBatchHelper.histDateVal;   
            CyearGMT = FunnelTriggerBatchHelper.histDateTimeVal;
            //CyearDateTime = CyearGMT;
        }
        else{
            CyearDate = Date.today();  
            CyearDateTime = System.now(); 
            CyearGMT = Date.today();
        }
        
        //system.debug('CyearGMT  -->'+CyearGMT );
        Integer offset = UserInfo.getTimezone().getOffset(CyearGMT);
        Datetime Cyear = CyearGMT.addSeconds(offset/1000);
        //system.debug(' Cyear '+Cyear);
        String CyearString = Cyear.formatgmt('yyyy-MM-dd\'T\'00:00:00\'Z\'');
        String CyearStringDate = CyearString.substring(0,10);
        
        //system.debug('Cyear'+Cyear);
        
        String ownerString = '';
        
        //Create a string of all the owners associated with the sales profiles
        for(Id i : ownerIds){
            
            if (ownerString == ''){
                ownerString = '\''+i+'\''+','; 
            }
            else{
            
                ownerString += '\''+i+'\''+',';
            }
           
        }
        
        DateTime Q0 = FyearDateTime ;
        DateTime Q1 = FyearDateTime.addMonths(3);
        DateTime Q2 = Q1.addMonths(3);
        DateTime Q3 = Q2.addMonths(3);
        DateTime Q4 = Q3.addMonths(3);
        
        DateTime startDate;
        DateTime endDate;
        
        //system.debug(' Cyear '+Cyear);
        //system.debug(' Q0 '+Q0);
        //system.debug(' Q1 '+Q1);
        //system.debug(' Q2 '+Q2);
        //system.debug(' Q3 '+Q3);
        
        //To find which quarter we are lying in
        if( (Q0 <= Cyear) && (Cyear < Q1)){
        
            startDate= Q0;
            endDate = Q1;
                  
        }else if((Q1 <= Cyear) && (Cyear < Q2)){
        
            startDate= Q1;
            endDate = Q2;
        
        }else if((Q2 <= Cyear) && (Cyear < Q3)){
        
            startDate= Q2;
            endDate = Q3;
            
        }else if((Q3 <= Cyear) && (Cyear < Q4)){
        
            startDate= Q3;
            endDate = Q4;
            
        }  
        //system.debug('startDate'+startDate);
        //system.debug('endDate'+endDate);       
        String dateTimeStartDate = startDate.formatgmt('yyyy-MM-dd\'T\'00:00:00\'Z\'');
        String dateTimeEndDate = endDate.formatgmt('yyyy-MM-dd\'T\'23:59:59\'Z\'');                
        
        if(ownerString != null && ownerString.length() > 0)
            ownerString = ownerString.subString(0,(ownerString.length() - 1));
            
        List<AggregateResult> quarterlyOpp= database.query('SELECT ownerId sr , COUNT(id) cq From Opportunity WHERE OwnerId IN ('+ownerString+') And CreatedDate >= '+dateTimeStartDate+' AND CreatedDate <= '+dateTimeEndDate+' GROUP BY OwnerId');
        //system.debug(' quarterlyOpp added--> '+'SELECT ownerId sr , COUNT(id) cq From Opportunity WHERE OwnerId IN  And CreatedDate >= '+dateTimeStartDate+' AND CreatedDate <= '+dateTimeEndDate+' GROUP BY OwnerId');
        //Leadcount=database.query('SELECT COUNT(id) cq From Lead WHERE OwnerId IN ('+ownerString+ ') And CreatedDate >= '+dateTimeFormats +'AND CreatedDate <'+dateTimeFormate );
            
        Map<Id,Integer> repCountQuarCreatedOpps = new Map<Id,Integer>();
        
        //Store map of owner id versus count of opptys created and amount in a map
        for(AggregateResult ar: quarterlyOpp){
            if(ar.get('sr') != null)
                repCountQuarCreatedOpps.put((Id)ar.get('sr'),(Integer)ar.get('cq'));
        }
        //system.debug(' repCountQuarCreatedOpps '+repCountQuarCreatedOpps);
        /*End fetching quarterly created opportunities*/
        
        String dateTimeStartDateCD = dateTimeStartDate;
        
        dateTimeStartDate = dateTimeStartDate.substring(0,10);
        dateTimeEndDate = dateTimeEndDate.substring(0,10);
        
        /*Custom metadata code*/
        createRecordTypeMap();
        
        Map<Id,Decimal> repQuarRevenue  =  fetchRevenueNumbers(ownerString, dateTimeStartDate, dateTimeEndDate, 'closed');   
        /*Custom metadata code*/
        
        /*Start fetching quarterly revenue*/
        /*List<AggregateResult> quarOppRevenue = database.query('SELECT ownerId sr , SUM(Amount) a From Opportunity WHERE OwnerId IN ('+ownerString+') And CloseDate >= '+dateTimeStartDate+' AND CloseDate < '+dateTimeEndDate+'  AND isWon = true  GROUP BY OwnerId');
        //system.debug('quarOppRevenue $ -->'+'SELECT ownerId sr , SUM(Amount) a From Opportunity WHERE OwnerId IN And CloseDate >= '+dateTimeStartDate+' AND CloseDate < '+dateTimeEndDate+'  AND isWon = true  GROUP BY OwnerId');
        Map<Id,Decimal> repQuarRevenue = new Map<Id,Decimal>();
        
        //Store map of owner id versus count of opptys created and amount in a map
        for(AggregateResult ar: quarOppRevenue){
            if(ar.get('sr') != null)
                repQuarRevenue.put((Id)ar.get('sr'),(Decimal)ar.get('a'));
        }
        //system.debug(' repQuarRevenue '+repQuarRevenue); */
        /*End fetching quarterly revenue*/ 
        
        /*Start fetching monthly created opportunities*/
        // Cyear = Date.Today(); Static date
        startDate = Datetime.newInstance(Cyear.yearGmt(),Cyear.monthGmt(),1);
        endDate = Datetime.newInstance(Cyear.yearGmt(),Cyear.monthGmt(),Date.daysInMonth(Cyear.yearGmt(),Cyear.monthGmt()));
        
        startDate = startDate.addSeconds(offset/1000);
        endDate = endDate.addSeconds(offset/1000);
        
        dateTimeStartDate = startDate.formatgmt('yyyy-MM-dd\'T\'00:00:00\'Z\'');
        dateTimeEndDate = endDate.formatgmt('yyyy-MM-dd\'T\'23:59:59\'Z\'');
        
        List<AggregateResult> monthlyOpp = database.query('SELECT ownerId sr , COUNT(id) cq From Opportunity WHERE OwnerId IN ('+ownerString+') And CreatedDate >= '+dateTimeStartDate+' AND CreatedDate <= '+dateTimeEndDate+' GROUP BY OwnerId');
        //system.debug(' monthlyOpp added --> '+'SELECT ownerId sr , COUNT(id) cq From Opportunity WHERE OwnerId IN  And CreatedDate >= '+dateTimeStartDate+' AND CreatedDate <= '+dateTimeEndDate+' GROUP BY OwnerId');
        //Leadcount=database.query('SELECT COUNT(id) cq From Lead WHERE OwnerId IN ('+ownerString+ ') And CreatedDate >= '+dateTimeFormats +'AND CreatedDate <'+dateTimeFormate );
            
        Map<Id,Integer> repCountMonCreatedOpps = new Map<Id,Integer>();
        
        //Store map of owner id versus count of opptys created and amount in a map
        for(AggregateResult ar: monthlyOpp){
            if(ar.get('sr') != null)
                repCountMonCreatedOpps.put((Id)ar.get('sr'),(Integer)ar.get('cq'));
        }
        //system.debug(' repCountMonCreatedOpps '+repCountMonCreatedOpps);
        /*End fetching monthly created opportunities*/
        
        dateTimeStartDateCD = dateTimeStartDate;
        dateTimeStartDate = dateTimeStartDate.substring(0,10);
        dateTimeEndDate = dateTimeEndDate.substring(0,10);
                
        /*Custom metadata code*/
        Map<Id,Decimal> repMonRevenue  =  fetchRevenueNumbers(ownerString, dateTimeStartDate, dateTimeEndDate, 'closed');   
        Map<Id,Decimal> repCurrentPipeline  =  fetchCurrentPipeline(ownerString);   
       
       /*Custom metadata code*/
               
        /*Start fetching monthly revenue*/
        /*List<AggregateResult> monthlyOppRevenue = database.query('SELECT ownerId sr , SUM(Amount) a From Opportunity WHERE OwnerId IN ('+ownerString+') And CloseDate >= '+dateTimeStartDate+' AND CloseDate < '+dateTimeEndDate+' AND isWon = true GROUP BY OwnerId');
        //system.debug(' monthlyOppRevenue $ -->'+'SELECT ownerId sr , SUM(Amount) a From Opportunity WHERE OwnerId IN ('+ownerString+') And CloseDate >= '+dateTimeStartDate+' AND CloseDate < '+dateTimeEndDate+'  AND isWon = true  GROUP BY OwnerId');
        Map<Id,Decimal> repMonRevenue = new Map<Id,Decimal>();
        
        //Store map of owner id versus count of opptys created and amount in a map
        for(AggregateResult ar: monthlyOppRevenue){
            if(ar.get('sr') != null)
                repMonRevenue.put((Id)ar.get('sr'),(Decimal)ar.get('a'));
        }*/
        //system.debug(' repMonRevenue '+repMonRevenue); 
        /*End fetching monthly revenue*/        
        
        //DateTime Syear = datetime.newInstance(2018,11,30, 0, 0, 0);
        //String Syears = Syear.formatgmt('yyyy-MM-dd\'T\'00:00:00\'Z\'');
        
        //This is used under dynamic query for Annual Added             
        String Fisyear =FyearDateTime.formatgmt('yyyy-MM-dd\'T\'00:00:00\'Z\'');    
                         
        
        //system.debug(' currentFiscalYear '+currentFiscalYear);
        //system.debug(' CyearDate '+CyearDate);
        
        DateTime currentFiscalYearDT = currentFiscalYear;
        String currentFiscalYearStr = currentFiscalYearDT.formatgmt('yyyy-MM-dd\'T\'00:00:00\'Z\'');
        currentFiscalYearStr = currentFiscalYearStr.substring(0,10);
        
        DateTime CyearDateDT = CyearDate;
        String CyearDateStr = CyearDateDT.formatgmt('yyyy-MM-dd\'T\'00:00:00\'Z\'');
        CyearDateStr = CyearDateStr.substring(0,10);
        
        /*Custom metadata code*/
        Map<Id,Decimal> mapRepsClosedYtd =  fetchRevenueNumbers(ownerString, currentFiscalYearStr, CyearDateStr, 'closed ytd');   
        /*Custom metadata code*/
        
        
        //Fetch the count of closed opportunities, sum of revenue, avg of days to close an opportunity for all the sales profiles
        List<AggregateResult> listRepsClosedOpps = [SELECT COUNT(id) c, SUM(Amount) s, OwnerId sr FROM Opportunity WHERE isWon = true  AND CloseDate >= :currentFiscalYear AND CloseDate <= :CyearDate AND OwnerId IN :ownerIds GROUP BY OwnerId];    
        //system.debug('listRepsClosedOpps -->'+'SELECT COUNT(id) c, SUM(Amount) s, OwnerId sr FROM Opportunity WHERE isWon = true  AND CloseDate >= :'+currentFiscalYear+' AND CloseDate <= :'+CyearDate +'AND OwnerId IN :ownerIds GROUP BY OwnerId');
        Map<Id, AggregateResult> mapRepsClosedOpps = new Map<Id, AggregateResult>();
        for(AggregateResult a: listRepsClosedOpps){
            mapRepsClosedOpps.put((Id)a.get('sr'),a);
        }
        
        String FC= Fisyear.substring(0,10);                        
        
        //system.debug(' currentFiscalYear '+currentFiscalYear);
        //system.debug(' listRepsClosedOpps  '+listRepsClosedOpps);
        
        //Fetch the count of open opportunities associated with every sales profile
        List<AggregateResult> listRepsOpenOpps = [SELECT COUNT(id) c,  OwnerId sr FROM Opportunity WHERE IsClosed = false AND OwnerId IN :ownerIds GROUP BY OwnerId]; 
        
        Map<Id, AggregateResult> mapRepsOpenOpps = new Map<Id, AggregateResult>();
        for(AggregateResult a: listRepsOpenOpps){
            mapRepsOpenOpps.put((Id)a.get('sr'),a);
        }
        
        //system.debug(' currentFiscalYear '+currentFiscalYear);
        //system.debug(' CyearDate '+CyearDate);
        
        DateTime CyearEndDate = Cyear.addDays(1);
        
        
        //Fetch the count of open opportunities created by every sales profile in the current fiscal year
        List<AggregateResult> listRepsCreatedOpps = [SELECT COUNT(id) c,  OwnerId sr FROM Opportunity WHERE CreatedDate >= :currentFiscalYear AND CreatedDate < :CyearEndDate AND OwnerId IN :ownerIds GROUP BY OwnerId]; 
        //system.debug('YTD created -->'+'SELECT COUNT(id) c,  OwnerId sr FROM Opportunity WHERE CreatedDate >= :'+currentFiscalYear+' AND CreatedDate < :'+CyearEndDate+' AND OwnerId IN :ownerIds GROUP BY OwnerId');
        Map<Id, AggregateResult> mapRepsCreatedOpps = new Map<Id, AggregateResult>();
        for(AggregateResult a: listRepsCreatedOpps){
            mapRepsCreatedOpps.put((Id)a.get('sr'),a);
        }
        
        //FunnelTriggerBatchHelper.sendErrorMail(' FunnelCalculateYTDFieldsBatch date fields start date is '+currentFiscalYear+' end date is '+CyearEndDate+' listRepsCreatedOpps '+listRepsCreatedOpps);                                                          

        //Fetch the count of open opportunities created by every sales profile in the current fiscal year
        //List<AggregateResult> listRepsCreatedOpps1 = [SELECT COUNT(id) c,  OwnerId sr FROM Opportunity WHERE CreatedDate >= :currentFiscalYear AND CreatedDate <= :CyearDateTime AND OwnerId IN :ownerIds GROUP BY OwnerId]; 
        
        //FunnelTriggerBatchHelper.sendErrorMail(' FunnelCalculateYTDFieldsBatch date fields start date 1 is '+currentFiscalYear+' end date is '+CyearDateTime+' listRepsCreatedOpps1 '+listRepsCreatedOpps1);                                                          
        
        Map<Id,Integer> repCountCreatedOpps = new Map<Id,Integer>();
        //Store map of owner id versus count of opptys created in a map
        for(AggregateResult ar: listRepsCreatedOpps){
            if(ar.get('sr') != null)
                repCountCreatedOpps.put((Id)ar.get('sr'),(Integer)ar.get('c'));
        }
        
        //system.debug(' repCountCreatedOpps '+repCountCreatedOpps);
        
        for(Sales_Rep_Profile__c s: salesReps){
                
            Boolean associatedWithOpp = false;
                
            if(mapRepsClosedOpps.get(s.User_Record_Name__c) != null){
                s.YTD_Opportunities_won__c = (Integer)(mapRepsClosedOpps.get(s.User_Record_Name__c).get('c')); 
                //s.YTD_Revenue__c = (Decimal)(mapRepsClosedOpps.get(s.User_Record_Name__c).get('s'));
                }    
            else{
                s.YTD_Opportunities_won__c = 0;
                //s.YTD_Revenue__c = 0;
            }
            
            /*Custom metadata code*/
            if(mapRepsClosedYtd.get(s.User_Record_Name__c) != null){
                s.YTD_Revenue__c = mapRepsClosedYtd.get(s.User_Record_Name__c);
                }    
            else{
                s.YTD_Revenue__c = 0;
            }
            /*Custom metadata code*/
            
            if(mapRepsOpenOpps.get(s.User_Record_Name__c) != null){
                
                s.Current_Active_Opportunities__c = (Integer)(mapRepsOpenOpps.get(s.User_Record_Name__c).get('c'));
            }
            else{
                s.Current_Active_Opportunities__c = 0;
            }
            
            if(repCountCreatedOpps.get(s.User_Record_Name__c) != null){
                s.YTD_Opportunities_Added__c = repCountCreatedOpps.get(s.User_Record_Name__c);
            }
            else{
                s.YTD_Opportunities_Added__c = 0;
            }
            
            
            //Update Quarterly opportunities added field 
            if(repCountQuarCreatedOpps.get(s.User_Record_Name__c) != null){
                s.Quarterly_Opportunities_added_to_Qualifi__c = repCountQuarCreatedOpps.get(s.User_Record_Name__c);
            }
            else{
                s.Quarterly_Opportunities_added_to_Qualifi__c = 0;
            }
            
            //Update Monthly opportunities added field 
            if(repCountMonCreatedOpps.get(s.User_Record_Name__c) != null){
                s.Monthly_Opportunities_added_to_Qualifie__c = repCountMonCreatedOpps.get(s.User_Record_Name__c);
        }
            else{
                s.Monthly_Opportunities_added_to_Qualifie__c = 0;
            }            
                
            //Update Monthly revenue field 
            if(repMonRevenue.get(s.User_Record_Name__c) != null){
                s.Monthly_Quota_Revenue__c = repMonRevenue.get(s.User_Record_Name__c);
        }
            else{
                s.Monthly_Quota_Revenue__c = 0;
        }
        
            //Update Quarterly revenue field 
            
        if(repCurrentPipeline.get(s.User_Record_Name__c) != null){
                s.Current_Pipeline__c = repCurrentPipeline.get(s.User_Record_Name__c);
        }
            else{
                s.Current_Pipeline__c = 0;
        }   
            
            if(repQuarRevenue.get(s.User_Record_Name__c) != null){
                s.Quarterly_Quota_Revenue__c = repQuarRevenue.get(s.User_Record_Name__c);
            }
            else{
                s.Quarterly_Quota_Revenue__c = 0;
        }
        
        
        
                profMap.put(s.id,s);
            }
        
        //system.debug(' profMap in helper returned '+profMap);
        return profMap;         
        /*}
        catch(Exception ex){
            //system.debug(' error occured '+ex.getMessage());
            FunnelTriggerBatchHelper.sendErrorMail('fetchSalesProfileUpdatedMapFromOwners'+ex.getMessage()+' '+ex.getStackTraceString()+' '+ex.getLineNumber());
            return null;     
        }*/
    }
    
    public Static Map<Id,Sales_Rep_Profile__c> fetchSalesProfileUpdatedMapFromLeadOwners(Set<Id> ownerIds){
            
        Date CyearDate;
        DateTime CyearDateTime;
        
        DateTime CyearGMT;   
        
        Date currentFiscalYear = getFiscalYearDate('Current_Year');
        
        if(FunnelTriggerBatchHelper.histDataBatch){
            CyearDate = FunnelTriggerBatchHelper.histDateVal;   
            CyearGMT = FunnelTriggerBatchHelper.histDateTimeVal;
        }        
        else if( FunnelTriggerBatchHelper.histDateVal != null){
            CyearDate = FunnelTriggerBatchHelper.histDateVal;   
            CyearGMT = FunnelTriggerBatchHelper.histDateTimeVal;
        }
        else{
            CyearDate = Date.today();   
            CyearDateTime = System.now();
            CyearGMT = Date.today();
        }
        
        //Date CyearDate = Date.newInstance(2018,11,30);             
        
        //DateTime CyearGMT = DateTime.newInstance(2018,11,30,0,0,0);
        Integer offset = UserInfo.getTimezone().getOffset(CyearGMT);
        Datetime Cyear = CyearGMT.addSeconds(offset/1000);
        //system.debug(' Cyear '+Cyear);
        String CyearString = Cyear.formatgmt('yyyy-MM-dd\'T\'00:00:00\'Z\'');
        String CyearStringDate = CyearString.substring(0,10);
        
        //system.debug('Cyear'+Cyear);                
        
        //Map to store the sales profiles to be updated
        Map<id, Sales_Rep_Profile__c> profMap = new Map<id, Sales_Rep_Profile__c>();
        
        //Map to store the user id and the corresponding sales profile id
        Map<Id,Id> ownerSalesReps = new Map<Id,Id>();
        
        List<Sales_Rep_Profile__c> salesReps = [SELECT id,User_Record_Name__c FROM Sales_Rep_Profile__c WHERE User_Record_Name__c IN :ownerIds];
        
        for(Sales_Rep_Profile__c sr: salesReps ){
            ownerSalesReps.put(sr.User_Record_Name__c,sr.id);    
        }
        
        DateTime CyearEndDate = Cyear.addDays(1);
        
        //Fetch the count of created leads for all the sales profiles
        List<AggregateResult> listCreatedLeads = [SELECT COUNT(id) c, ownerid sr FROM Lead WHERE CreatedDate >= :currentFiscalYear AND CreatedDate < :CyearEndDate AND OwnerId IN :ownerIds GROUP BY OwnerId];            
        
        //FunnelTriggerBatchHelper.sendErrorMail(' FunnelCalculateYTDleadsFieldsBatch date fields start date 1 is '+currentFiscalYear+' end date is '+CyearEndDate);                                                          

        Map<Id,Integer> mapCreatedLeads = new Map<Id,Integer>();
        
        for(AggregateResult ar: listCreatedLeads){
            if(ar.get('sr') != null)
                mapCreatedLeads.put((Id)ar.get('sr'),(Integer)ar.get('c'));
        }
        
        //DateTime Cyear;
        
       // Cyear = Date.today();
       //Cyear = DateTime.newInstance(2018,05,31,0,0,0);                
        
        String ownerString = '';
        
        //Create a string of all the owners associated with the sales profiles
        for(Id i : ownerIds){
            
            if (ownerString == ''){
                ownerString = '\''+i+'\''+','; 
            }
            else{
            
                ownerString += '\''+i+'\''+',';
            }
           
        }
        
        DateTime FyearDateTime = getFiscalYearDate('Current_Year');
        
        DateTime Q0 = FyearDateTime ;
        DateTime Q1 = FyearDateTime.addMonths(3);
        DateTime Q2 = Q1.addMonths(3);
        DateTime Q3 = Q2.addMonths(3);
        DateTime Q4 = Q3.addMonths(3);
        
        DateTime startDate;
        DateTime endDate;
        
        //To find which quarter we are lying in
        if( (Q0 <= Cyear) && (Cyear < Q1)){
        
            startDate= Q0;
            endDate = Q1;
                  
        }else if((Q1 <= Cyear) && (Cyear < Q2)){
        
            startDate= Q1;
            endDate = Q2;
        
        }else if((Q2 <= Cyear) && (Cyear < Q3)){
        
            startDate= Q2;
            endDate = Q3;
            
        }else if((Q3 <= Cyear) && (Cyear < Q4)){
        
            startDate= Q3;
            endDate = Q4;
            
        }  
        //system.debug('startDate'+startDate);
        //system.debug('endDate'+endDate);       
        String dateTimeStartDate = startDate.formatgmt('yyyy-MM-dd\'T\'00:00:00\'Z\'');
        String dateTimeEndDate = endDate.formatgmt('yyyy-MM-dd\'T\'23:59:59\'Z\'');                
                        
        if(ownerString != null && ownerString.length() > 0)
            ownerString = ownerString.subString(0,(ownerString.length() - 1));
                    
        List<AggregateResult> quarterlyLeads = database.query('SELECT ownerId sr , COUNT(id) cq From Lead WHERE OwnerId IN ('+ownerString+') And CreatedDate >= '+dateTimeStartDate+' AND CreatedDate <= '+dateTimeEndDate+' GROUP BY OwnerId');
        //system.debug(' quarterlyLeads '+quarterlyLeads);
        //Leadcount=database.query('SELECT COUNT(id) cq From Lead WHERE OwnerId IN ('+ownerString+ ') And CreatedDate >= '+dateTimeFormats +'AND CreatedDate <'+dateTimeFormate );
            
        Map<Id,Integer> repCountQuarLeads = new Map<Id,Integer>();
        
        //Store map of owner id versus count of leads created and amount in a map
        for(AggregateResult ar: quarterlyLeads){
            if(ar.get('sr') != null){
                repCountQuarLeads.put((Id)ar.get('sr'),(Integer)ar.get('cq'));
        }
        }
        //system.debug(' repCountQuarLeads '+repCountQuarLeads);
        /*End fetching quarterly created leads*/
        
        /*Start fetching monthly created leads*/
        // Cyear = Date.Today(); Static date
        startDate = Datetime.newInstance(Cyear.yearGmt(),Cyear.monthGmt(),1);
        endDate = Datetime.newInstance(Cyear.yearGmt(),Cyear.monthGmt(),Date.daysInMonth(Cyear.yearGmt(),Cyear.monthGmt()));
        
        startDate = startDate.addSeconds(offset/1000);
        endDate = endDate.addSeconds(offset/1000);
        
        dateTimeStartDate = startDate.formatgmt('yyyy-MM-dd\'T\'00:00:00\'Z\'');
        dateTimeEndDate = endDate.formatgmt('yyyy-MM-dd\'T\'23:59:59\'Z\'');
        
        List<AggregateResult> monthlyLead = database.query('SELECT ownerId sr , COUNT(id) cq From Lead WHERE OwnerId IN ('+ownerString+') And CreatedDate >= '+dateTimeStartDate+' AND CreatedDate <= '+dateTimeEndDate+' GROUP BY OwnerId');
        //system.debug(' monthlyLead '+monthlyLead);
        //Leadcount=database.query('SELECT COUNT(id) cq From Lead WHERE OwnerId IN ('+ownerString+ ') And CreatedDate >= '+dateTimeFormats +'AND CreatedDate <'+dateTimeFormate );
            
        Map<Id,Integer> repCountMonCreatedLeads = new Map<Id,Integer>();
        
        //Store map of owner id versus count of leads created and amount in a map
        for(AggregateResult ar: monthlyLead){
            if(ar.get('sr') != null)
                repCountMonCreatedLeads.put((Id)ar.get('sr'),(Integer)ar.get('cq'));
        }
        //system.debug(' repCountMonCreatedLeads '+repCountMonCreatedLeads);
        /*End fetching monthly created leads*/
        
        for(Sales_Rep_Profile__c s: salesReps){
            
            if(repCountMonCreatedLeads.get(s.User_Record_Name__c) != null){
                s.Monthly_Lead_Added__c = repCountMonCreatedLeads.get(s.User_Record_Name__c);
            }
            else{
                s.Monthly_Lead_Added__c = 0;
            }
            
            if(repCountQuarLeads.get(s.User_Record_Name__c) != null){
                s.Quarterly_Lead_Added__c = repCountQuarLeads.get(s.User_Record_Name__c);
            }
            else{
                s.Quarterly_Lead_Added__c = 0;
            }
            
            if(mapCreatedLeads.get(s.User_Record_Name__c) != null){
                s.YTD_Leads_Added__c = mapCreatedLeads.get(s.User_Record_Name__c);
            }
            else{
                s.YTD_Leads_Added__c = 0;
            }
            profMap.put(s.id,s);        
        }
        
        /*
        for(AggregateResult ar: listCreatedLeads){
            
            //Populate the fields on the sales profile related to closed opportunities
            Sales_Rep_Profile__c s = new Sales_Rep_Profile__c(); 
            s.id = ownerSalesReps.get((Id)ar.get('sr'));
            s.YTD_Leads_Added__c = (Integer)ar.get('c'); 
            
            //Update Quarterly leads added field 
            if(repCountQuarLeads.get((Id)ar.get('sr')) != null){
                s.Quarterly_Lead_Added__c = repCountQuarLeads.get((Id)ar.get('sr'));
            }
            
            //Update Monthly leads added field 
            if(repCountMonCreatedLeads.get((Id)ar.get('sr')) != null){
                s.Monthly_Lead_Added__c = repCountMonCreatedLeads.get((Id)ar.get('sr'));
            }
                        
            profMap.put(s.id,s);     
            //system.debug(' profMap in helper '+profMap);     
        }
        */
        
        //Fetch the below fields
        /*
        YTD opportunities added
        Quarterly opportunities added
        Monthly opportunities added
        
        YTD leads added
        Quarterly leads added
        Monthly leads added
        //Daily leads added
        
        Quarterly Revenue
        Monthly Revenue
        */
        
        //system.debug(' currentFiscalYear '+currentFiscalYear);
        
        return profMap;         
    
    }
    
    /*new*/
    public Static void updateSalesProfsNotAssociatedWithAnyOpptyUsingOwner(Set<Id> ownerIds, Map<Id,Sales_Rep_Profile__c> profMap){
        //try{ 
        Set<Id> salesRepIds = new Set<Id>();
        
        List<Sales_Rep_Profile__c> salesReps = [SELECT id, User_Record_Name__c FROM Sales_Rep_Profile__c WHERE User_Record_Name__c IN :ownerIds];
        
        for(Sales_Rep_Profile__c sr: salesReps ){
            
            salesRepIds.add(sr.id);    
        }
                
        //Remove the ids that have already been added to the map that is being updated
        salesRepIds.removeAll(profMap.keySet());
        
        //The current active opportunities field should be updated to 0
        for(Id i: salesRepIds){
            Sales_Rep_Profile__c s = new Sales_Rep_Profile__c();
            s.id = i;
            s.Current_Active_Opportunities__c = 0; 
            profMap.put(s.id,s);
        }  
        /*}catch(Exception ex){
            //system.debug(' error occured '+ex.getMessage());
            FunnelTriggerBatchHelper.sendErrorMail('updateSalesProfsNotAssociatedWithAnyOpptyUsingOwner'+ex.getMessage()+' '+ex.getStackTraceString()+' '+ex.getLineNumber());
        }*/         
    }            
    
    /*
    public Static void updateSalesProfsNotAssociatedWithAnyLeadUsingOwner(Set<Id> ownerIds, Map<Id,Sales_Rep_Profile__c> profMap){
        
        Set<Id> salesRepIds = new Set<Id>();
        
        List<Sales_Rep_Profile__c> salesReps = [SELECT id, User_Record_Name__c FROM Sales_Rep_Profile__c WHERE User_Record_Name__c IN :ownerIds];
        
        for(Sales_Rep_Profile__c sr: salesReps ){
            
            salesRepIds.add(sr.id);    
        }
                
        //Remove the ids that have already been added to the map that is being updated
        salesRepIds.removeAll(profMap.keySet());
        
        //The current active opportunities field should be updated to 0
        for(Id i: salesRepIds){
            Sales_Rep_Profile__c s = new Sales_Rep_Profile__c();
            s.id = i;
            s.YTD_Leads_Added__c = 0; 
            profMap.put(s.id,s);
        }            
    }*/
    
    /*new*/
    
    
    /*  This Method update the counter when a Qulifiled opp is created  */
    public static void updateSalesProfsCounterQO(Map<id,Opportunity> oppNewmap , List<Opportunity> triggernew){
        //system.debug('inside updateSalesProfsCounterQO');
        Decimal userprob = 10;
        List<Application_Setting__c> prob = [SELECT Id, Probability__c FROM Application_Setting__c limit 1];
        if(prob != null && prob.size()>0){
            userprob = prob[0].Probability__c;
        }
        
        set<id> srpid = new set<id>();
        for(Opportunity o : triggernew){
            srpid.add(o.ownerid);
        }
        list<Sales_Rep_Profile__c> splist = [select id,User_Record_Name__c,Monthly_QO_added__c,Quarterly_QO_added__c,Ytd_QO_added__c from Sales_Rep_Profile__c where User_Record_Name__c IN : srpid];
        map<id,Sales_Rep_Profile__c> splistmap = new map<id,Sales_Rep_Profile__c>();
        
        for(Sales_Rep_Profile__c s : splist){
            splistmap.put(s.User_Record_Name__c, s);
        }
        list<Sales_Rep_Profile__c> updatesplist = new list<Sales_Rep_Profile__c>();
        Map<id,Sales_Rep_Profile__c> updateMap = new Map<id,Sales_Rep_Profile__c>();
        Sales_Rep_Profile__c sp = new Sales_Rep_Profile__c();
        
          for(Opportunity o : triggernew){
            
            sp = new Sales_Rep_Profile__c();
            
            if(oppNewmap != null && oppNewmap.get(o.id) != null && oppNewmap.get(o.id).Probability >= userprob){
            
                /*sp =  splistmap.get(o.ownerid);
                
                if(sp.Monthly_QO_added__c != null){
                  sp.Monthly_QO_added__c = sp.Monthly_QO_added__c+ 1;
                }else{
                  sp.Monthly_QO_added__c =  1;
                }
                
                if(sp.Quarterly_QO_added__c != null){
                  sp.Quarterly_QO_added__c = sp.Quarterly_QO_added__c+ 1;
                }else{
                  sp.Quarterly_QO_added__c =  1;
                }
                
                if(sp.Ytd_QO_added__c != null){
                  sp.Ytd_QO_added__c = sp.Ytd_QO_added__c+ 1;
                }else{
                  sp.Ytd_QO_added__c =  1;
                }
                 
                updatesplist.add(sp);*/
                
                if(updateMap.containsKey(sp.id)){
                    sp = updateMap.get(sp.id);                                                
                }
                else{
                    sp = splistmap.get(o.ownerid);                                            
                } 
                
                if(sp != null){
                    
                    if(sp.Monthly_QO_added__c != null){
                      sp.Monthly_QO_added__c = sp.Monthly_QO_added__c+ 1;
                    }else{
                      sp.Monthly_QO_added__c =  1;
                    }
                    
                    if(sp.Quarterly_QO_added__c != null){
                      sp.Quarterly_QO_added__c = sp.Quarterly_QO_added__c+ 1;
                    }else{
                      sp.Quarterly_QO_added__c =  1;
                    }
                    
                    if(sp.Ytd_QO_added__c != null){
                      sp.Ytd_QO_added__c = sp.Ytd_QO_added__c+ 1;
                    }else{
                      sp.Ytd_QO_added__c =  1;
                    }
                    
                    updateMap.put(sp.id,sp); 
                }                   
            }
        }
        //update updatesplist;  
        update updateMap.values();  
    }
    
    /*
        This Method update the counter on the salesprofile when the QO 
        is moved out of the month or quarter and QO moved in the current month or quarter 
    */
        public static List<Client_custom_field_mapping__mdt> lstCustMd ;
        public static List<RecordType> recTypes;
        public static Map<String,List<String>>  recTypeFldMap;
        public static Map<String,String> recTypeNameIdMap;
        public static Map<String,String> recTypeIdNameMap ;
        public static Map<id,String> recTypeIdActionMap;
        public static Map<String,String> recTypeActionMap = new Map<String,String>(); 
        public static Map<String, Decimal> conversionRates = new Map<String, Decimal>();
        public static Boolean multiCurrencyEnabled;
        
    public static Decimal amountValue( opportunity op){
        decimal totAmt = 0;
        
        if(lstCustMd != null && lstCustMd.size() > 0){
             string recId = (String)op.get('RecordTypeId');
             List<String> flds = recTypeFldMap.get(recTypeIdNameMap.get(recId));
             if(recTypeIdActionMap.get(recId) == 'Add'){
                                                            
                    if(op.amount != null)
                        totAmt  += op.amount;
                }
                    
                for(Integer i = 0; i < flds.size(); i++){
                    if(op.get(flds[i]) != null)
                        totAmt += (Decimal)op.get(flds[i]);       
                }      
        }else if(op.amount != null){
            totAmt = op.amount;
        }
        
        
        if(multiCurrencyEnabled && totAmt > 0){
            String currencyCode = (String)op.get('CurrencyIsoCode');
            String cr = 'CurrencyIsoCode';    
            totAmt = totAmt / conversionRates.get(currencyCode);
        }   
           // //system.debug('totAmt'+totAmt);
            return totAmt;
    }
    
    public static void createConvertionRateMap(){
         
            string isoCode;
            Decimal convertionRate;
            String s;
            
            s = 'SELECT Id, isoCode, Conversionrate, nextStartDate, startDate FROM DatedConversionRate ORDER BY NextStartDate DESC';
            List<Sobject> rates =  database.query(s);
            for(Sobject r: rates){
                isoCode = (String)r.get('isocode');
                convertionRate = (Decimal)r.get('Conversionrate');
                
                if(!conversionRates.containsKey(isoCode )){
                    conversionRates.put(isoCode,convertionRate);
                }
            }
            
            s = 'SELECT Id, isoCode, Conversionrate FROM CurrencyType';
            List<Sobject> crates  =  database.query(s);
            
            for(Sobject r: crates){
                isoCode = (String)r.get('isocode');
                convertionRate = (Decimal)r.get('Conversionrate');
                
                if(!conversionRates.containsKey(isoCode)){
                    conversionRates.put(isoCode,convertionRate);
                }
           }   
         
    }
    
    public Static void updateSalesProfsCounter(Map<id,Opportunity> oppNewmap , Map<id,Opportunity> oppOldmap , List<Opportunity> triggernew){
        
       createRecordTypeMap();
       
        multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if(multiCurrencyEnabled){
            createConvertionRateMap();
        }
        
        Decimal userprob = 0;
        List<Application_Setting__c> prob = [SELECT Id, Probability__c FROM Application_Setting__c limit 1];
        if(prob != null && prob.size()>0){
            userprob = prob[0].Probability__c;
        }
        
        date presentDate  = date.today();
        //system.debug('close rate trigger ');
        date endDate = date.newInstance(presentDate.year(), presentDate.month(),Date.daysInMonth(presentDate.year(), presentDate.month()));
        ////system.debug('endDate '+endDate);

        date Fyear = getFiscalYearDate('Current_Year');
        date Q0 = Fyear ;
        date Q1 = Fyear.addMonths(3);
        date Q2 = Q1.addMonths(3);
        date Q3 = Q2.addMonths(3);
        date Q4 = Q3.addMonths(3);
        date endDateq;
        if( (Q0 <= presentDate) && (presentDate < Q1)){
              endDateq = Q1;
        }else if((Q1 <= presentDate) && (presentDate < Q2)){
              endDateq = Q2;
            
        }else if((Q2 <= presentDate) && (presentDate < Q3)){
              endDateq = Q3;
        
        }else if((Q3 <= presentDate) && (presentDate < Q4)){
              endDateq = Q4;
        
        }  
        set<id> srpid = new set<id>();
        for(Opportunity o : triggernew){
            srpid.add(o.ownerid);
        }
        list<Sales_Rep_Profile__c> splist = [select id,User_Record_Name__c,Monthly_QO_added__c,Quarterly_QO_added__c,Ytd_QO_added__c,Monthly_lost_QO_Amt__c,Quarterly_lost_QO_Amt__c,Ytd_lost_QO_Amt__c,Monthly_lost_QO__c,Quarterly_lost_QO__c,Ytd_lost_QO__c,Close_rate_monthly_opp_count__c ,Close_rate_monthly_opp_amount__c,Close_rate_YTD_opp_count__c,Close_rate_YTD_opp_amount__c,Close_rate_Quarterly_opp_count__c,Close_rate_Quarterly_opp_amount__c  from Sales_Rep_Profile__c where User_Record_Name__c IN : srpid];
        map<id,Sales_Rep_Profile__c> splistmap = new map<id,Sales_Rep_Profile__c>();
        
        for(Sales_Rep_Profile__c s : splist){
            splistmap.put(s.User_Record_Name__c, s);
        }
        list<Sales_Rep_Profile__c> updatesplist = new list<Sales_Rep_Profile__c>();
        Map<id,Sales_Rep_Profile__c> updateMap = new Map<id,Sales_Rep_Profile__c>();
        Sales_Rep_Profile__c sp = new Sales_Rep_Profile__c();
        
        List<String> fldList1 = new List<String>{prefix+'close_rate_monthly_opp_count__c',prefix+'close_rate_monthly_opp_amount__c',prefix+'close_rate_ytd_opp_count__c',prefix+'close_rate_ytd_opp_amount__c',prefix+'close_rate_quarterly_opp_count__c',prefix+'close_rate_quarterly_opp_amount__c'};
            
        Boolean updateAccess = true;
        
        /*            
        Map <String, Schema.SObjectField> fieldMap1 = Schema.getGlobalDescribe().get(prefix+'Sales_Rep_Profile__c').getDescribe().fields.getMap();
        
        for(String fldName: fldList1){
            if(!fieldMap1.get(fldName).getDescribe().isUpdateable()){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
              updateAccess = false;
            }                           
        }*/ 
        
        if(updateAccess){
            
            /*List<String> oppIds = new List<String>();
            
            for(Opportunity o : triggernew){
                oppIds.add(o.recordtype.name);
            }
            */
            
            
            for(Opportunity o : triggernew){
                sp = new Sales_Rep_Profile__c();
                ////system.debug(oppOldmap);
                ////system.debug(oppNewmap);
                if((oppOldmap != null && oppNewmap != null && ( oppOldmap.get(o.id) != null && oppOldmap.get(o.id).CloseDate != oppNewmap.get(o.id).CloseDate) && (oppNewmap.get(o.id) != null && oppNewmap.get(o.id).CloseDate > endDate)) 
                    || (oppOldmap != null && oppNewmap != null && (oppOldmap != null && oppOldmap.get(o.id) != null && oppOldmap.get(o.id).IsClosed == false && oppNewmap.get(o.id).IsClosed == true && oppNewmap.get(o.id).IsWon  == false)) 
                    || (oppOldmap != null && oppOldmap.get(o.id) != null && oppOldmap.get(o.id).Probability < userprob && oppNewmap.get(o.id).Probability >= userprob ) 
                    || (oppOldmap != null && oppNewmap != null && (oppOldmap.get(o.id) != null && oppOldmap.get(o.id).CloseDate != oppNewmap.get(o.id).CloseDate) && (oppNewmap.get(o.id) != null && oppNewmap.get(o.id).CloseDate < endDateq) && oppNewmap.get(o.id).Probability >= userprob) ){
                    //system.debug(' inside 1st  if----> > endDate'+endDate);
                    
                    if(updateMap.containsKey(sp.id)){
                        sp = updateMap.get(sp.id);                                                
                    }
                    else{
                        sp = splistmap.get(o.ownerid);                                            
                    } 
                    
                    if(sp != null){
                    
                        /* When QO is moved out*/
                        
                        if(oppOldmap != null && oppNewmap != null && (oppOldmap != null && oppOldmap.get(o.id) != null && oppOldmap.get(o.id).CloseDate != oppNewmap.get(o.id).CloseDate) && (oppNewmap != null && oppNewmap.get(o.id) != null && oppNewmap.get(o.id).CloseDate > endDate) && (oppNewmap.get(o.id).Probability  >= userprob ) ){
                        //system.debug(' inside if opp moved---->endDate'+endDate);
                    if(sp.Close_rate_monthly_opp_count__c != null){
                      sp.Close_rate_monthly_opp_count__c = sp.Close_rate_monthly_opp_count__c+1;
                    }else{
                      sp.Close_rate_monthly_opp_count__c = 1;
                    }
                  
                    if(sp.Close_rate_monthly_opp_amount__c != null){
                      sp.Close_rate_monthly_opp_amount__c = sp.Close_rate_monthly_opp_amount__c+ amountValue(o);
                    }else{
                      sp.Close_rate_monthly_opp_amount__c =  amountValue(o);
                    }
                    
                    if(sp.Close_rate_YTD_opp_count__c != null){
                      sp.Close_rate_YTD_opp_count__c = sp.Close_rate_YTD_opp_count__c+1;
                    }else{
                      sp.Close_rate_YTD_opp_count__c = 1;
                    }
                  
                    if(sp.Close_rate_YTD_opp_amount__c != null){
                      sp.Close_rate_YTD_opp_amount__c = sp.Close_rate_YTD_opp_amount__c+ amountValue(o);
                    }else{
                      sp.Close_rate_YTD_opp_amount__c =  amountValue(o);
                    }
                  
                  if( oppNewmap.get(o.id).CloseDate >= endDateq ){
                      if(sp.Close_rate_Quarterly_opp_count__c != null){
                          sp.Close_rate_Quarterly_opp_count__c = sp.Close_rate_Quarterly_opp_count__c+ 1;
                      }else{
                         sp.Close_rate_Quarterly_opp_count__c =  1;
                      } 
                      if(sp.Close_rate_Quarterly_opp_amount__c != null){
                          sp.Close_rate_Quarterly_opp_amount__c = sp.Close_rate_Quarterly_opp_amount__c+ amountValue(o);
                      }else{
                          sp.Close_rate_Quarterly_opp_amount__c =  amountValue(o);
                      } 
                    }  
                    
                        }
                        /* When QO is Lost*/
                        if(oppOldmap != null && oppNewmap != null && (oppOldmap != null && oppOldmap.get(o.id) != null && oppOldmap.get(o.id).IsClosed == false && oppNewmap.get(o.id).IsClosed == true && oppNewmap.get(o.id).IsWon  == false && oppOldmap.get(o.id).Probability  >= userprob )){
                            //system.debug(' inside  if opp lost---->');
                            if(sp.Monthly_lost_QO__c != null){
                              sp.Monthly_lost_QO__c = sp.Monthly_lost_QO__c+1;
                            }else{
                              sp.Monthly_lost_QO__c = 1;
                            }
                            if(sp.Quarterly_lost_QO__c != null){
                              sp.Quarterly_lost_QO__c = sp.Quarterly_lost_QO__c+1;
                            }else{
                              sp.Quarterly_lost_QO__c = 1;
                            }
                            if(sp.Ytd_lost_QO__c != null){
                              sp.Ytd_lost_QO__c = sp.Ytd_lost_QO__c+1;
                            }else{
                              sp.Ytd_lost_QO__c = 1;
                            }
                            if(sp.Monthly_lost_QO_Amt__c != null){
                              sp.Monthly_lost_QO_Amt__c = sp.Monthly_lost_QO_Amt__c+ amountValue(o);
                            }else{
                              sp.Monthly_lost_QO_Amt__c = amountValue(o);
                            }
                            if(sp.Quarterly_lost_QO_Amt__c != null){
                              sp.Quarterly_lost_QO_Amt__c = sp.Quarterly_lost_QO_Amt__c+ amountValue(o);
                            }else{
                              sp.Quarterly_lost_QO_Amt__c =  amountValue(o);
                            }
                            if(sp.Ytd_lost_QO_Amt__c != null){
                              sp.Ytd_lost_QO_Amt__c = sp.Ytd_lost_QO_Amt__c+ amountValue(o);
                            }else{
                              sp.Ytd_lost_QO_Amt__c =  amountValue(o);
                            }
                             
                        }
                        /* When opp become QO  */
                        if(oppOldmap != null && oppOldmap.get(o.id) != null && oppOldmap.get(o.id).Probability < userprob && oppNewmap.get(o.id).Probability >= userprob ){
                            if(sp.Monthly_QO_added__c != null){
                                sp.Monthly_QO_added__c = sp.Monthly_QO_added__c+ 1;
                            }else{
                                sp.Monthly_QO_added__c =  1;
                            }
                        
                            if(sp.Quarterly_QO_added__c != null){
                                sp.Quarterly_QO_added__c = sp.Quarterly_QO_added__c+ 1;
                            }else{
                                sp.Quarterly_QO_added__c =  1;
                            }
                        
                            if(sp.Ytd_QO_added__c != null){
                                sp.Ytd_QO_added__c = sp.Ytd_QO_added__c+ 1;
                            }else{
                                sp.Ytd_QO_added__c =  1;
                            }
                        }
                        /* When QO is moved in*/
                         //system.debug('->-M'+ oppNewmap.get(o.id).CloseDate +'<='+ endDate +' &&'+ oppOldmap.get(o.id).CloseDate +' >'+ endDate);
                         //system.debug('->-Q'+oppNewmap.get(o.id).CloseDate +'<'+ endDateq +' &&'+  oppOldmap.get(o.id).CloseDate +'>='+ endDateq);
                        
                        if(oppOldmap != null && oppNewmap != null && (oppOldmap.get(o.id) != null && oppOldmap.get(o.id).CloseDate != oppNewmap.get(o.id).CloseDate) && (oppNewmap.get(o.id) != null && oppNewmap.get(o.id).CloseDate < endDateq) && oppNewmap.get(o.id).Probability >= userprob ){
                            
                            if(oppNewmap.get(o.id).CloseDate <= endDate && oppOldmap.get(o.id).CloseDate > endDate ){
                                if(sp.Monthly_QO_added__c != null){
                                    sp.Monthly_QO_added__c = sp.Monthly_QO_added__c+ 1;
                                }else{
                                    sp.Monthly_QO_added__c =  1;
                                }
                                
                                if(sp.Ytd_QO_added__c != null){
                                    sp.Ytd_QO_added__c = sp.Ytd_QO_added__c+ 1;
                                }else{
                                    sp.Ytd_QO_added__c =  1;
                                }
                            }
                            if(oppNewmap.get(o.id).CloseDate < endDateq && oppOldmap.get(o.id).CloseDate >= endDateq ){
                                
                                if(sp.Quarterly_QO_added__c != null){
                                    sp.Quarterly_QO_added__c = sp.Quarterly_QO_added__c+ 1;
                                }else{
                                    sp.Quarterly_QO_added__c =  1;
                                }
                            }
                        }
                  //updatesplist.add(sp); 
                  updateMap.put(sp.id,sp);
                }
                }
               
                  
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
        }
        
        //if(Schema.sObjectType.Sales_Rep_Profile__c.isUpdateable()){
           // update updatesplist;
           update updateMap.values();  
        //}
        /*else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
        }*/
    }
    
    public static void updateYTDQuotaOnCert(Set<Id> spIds){
        
        List<Certification__c> crReplist = new List<Certification__c>();

        //For the reps
        List<Certification__c> certRecs = [SELECT Sales_Rep_Profile__r.YTD_Quota_Percentage__c  FROM Certification__c WHERE Sales_Rep_Profile__c IN :spIds AND Sales_rep_profile__r.Active__c = TRUE];
        for(Certification__c c:certRecs){
            c.YTD_Quota_Percentage__c  = c.Sales_Rep_Profile__r.YTD_Quota_Percentage__c;
            crReplist.add(c);
        }
        
        //system.debug(' cert updated '+crReplist);
        //if(Schema.getGlobalDescribe().get(prefix+'Certification__c').getDescribe().isUpdateable()){ 
            update crReplist;
        //}
    }
    
    public static void calculateAggregateScoreForManagers(Set<Id> spIds){
                        
        //For manager aggregates
        
        List<Certification__c> crmnglist = new List<Certification__c>();
        
        List<AggregateResult> levels = [SELECT Company_Level__r.Level_Value__c v FROM Sales_Profile_Company_Level_Junction__c WHERE Sales_Rep_Profile__c IN :spIds GROUP BY Company_Level__r.Level_Value__c];
        
        List<String> levelVals = new List<String>();                
        
        for(AggregateResult ar: levels){
            levelVals.add((String)ar.get('v'));
        }
        
        //system.debug(' levelVals '+levelVals);
        
        List<AggregateResult> scoreAggr = [SELECT Company_Level__r.Level_Value__c v,AVG(Sales_Rep_Profile__r.YTD_Quota_Percentage__c) ytd FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c IN :levelVals AND Sales_Rep_Profile__r.Annual_Quota_Amount__c > 0 GROUP BY Company_Level__r.Level_Value__c];
        
        Map<String,Decimal> mapValYtd = new Map<String,Decimal>();
        
        for(AggregateResult ar: scoreAggr){
            mapValYtd.put((String)ar.get('v'),(Decimal)ar.get('ytd'));
        }
        
        //system.debug(' mapValYtd '+mapValYtd);
        
        List<Company_Level__c> cls = [SELECT Certification__c, Level_Value__c FROM Company_Level__c WHERE Level_Value__c IN :levelVals];        
                
        for(Company_Level__c cl: cls){ 
            Certification__c updateMng = new Certification__c(); 
            updateMng.id = cl.Certification__c;
            updateMng.YTD_Quota_Percentage__c = mapValYtd.get(cl.Level_Value__c);
             
            crmnglist.add(updateMng);      
        }
        
        //system.debug(' crmnglist '+crmnglist);                        
        
        //if(Schema.getGlobalDescribe().get(prefix+'Certification__c').getDescribe().isUpdateable()){ 
            update crmnglist;
        //}            
        
    }
     public static void sendErrorMail(String errorMessage){              
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        
        Admin_Email__mdt[] adminEmails = [SELECT Email_Address__c FROM Admin_Email__mdt LIMIT 20];

        for (Admin_Email__mdt em: adminEmails) {
            toAddresses.add(em.Email_Address__c);    
        }
        if(toAddresses.size() > 0){
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Apex error message');
            mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody(errorMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
   }
    @future
    public static void updateSalesProfsInactive(List<Id> recIds){
        
        List<Sales_Rep_Profile__c> profs = [SELECT id,Active__c FROM Sales_Rep_Profile__c WHERE User_Record_Name__c IN :recIds];  
        
        List<Sales_Rep_Profile__c> updatedProfs = new List<Sales_Rep_Profile__c>();
        
        for(Sales_Rep_Profile__c s:profs){
            if(s.Active__c){
                s.Active__c = false;
                updatedProfs.add(s);
            }
        }
        
        if(updatedProfs.size() > 0)
            update updatedProfs; 
    }
    
    @future
    public static void updateSalesProfsActive(List<Id> recIds){
        
        List<Sales_Rep_Profile__c> profs = [SELECT id,Active__c FROM Sales_Rep_Profile__c WHERE User_Record_Name__c IN :recIds];  
        
        List<Sales_Rep_Profile__c> updatedProfs = new List<Sales_Rep_Profile__c>();
        
        for(Sales_Rep_Profile__c s:profs){
            if(!s.Active__c){
                s.Active__c = true;
                updatedProfs.add(s);
            }
        }
        
        if(updatedProfs.size() > 0)
            update updatedProfs; 
    }
    
    @future
    public static void createSalesProfs(List<Id> recIds){
        
        List<User> userRecs = [SELECT id,name,Username,ManagerId FROM User WHERE id IN :recIds];
        
        Map<id,User> usersMap = new Map<id,User>();
        for(User u: userRecs){
            usersMap.put(u.id,u);
        }
                
        List<Sales_Rep_Profile__c> sReps = [select id, User_Record_Name__c from Sales_Rep_Profile__c limit 5000];    
    
        Map<Id,Id> userProfMap = new Map<Id,Id>();
        
        for(Sales_Rep_Profile__c s: sReps){
            userProfMap.put(s.User_Record_Name__c,s.id);
        }
    
        List<Sales_Rep_Profile__c> newSReps = new List<Sales_Rep_Profile__c> ();

        for(Id i:recIds){            
            Sales_Rep_Profile__c s = new Sales_Rep_Profile__c();
            s.User_Record_Name__c = i;
            s.Name = usersMap.get(i).name;
            s.Active__c = true;
            if(usersMap.get(i) != null && usersMap.get(i).ManagerId != null && userProfMap.get(usersMap.get(i).ManagerId) != null){
                s.Sales_Manager__c = userProfMap.get(usersMap.get(i).ManagerId);
            }
            newSReps.add(s);
        }
        
        insert newSReps;
        //system.debug(' new reps '+newSReps);
    }
    
    @future
    public static void deleteJunctionRecords(Set<Id> recIds){
        
        List<Sales_Profile_Company_Level_Junction__c> juncs = [SELECT id FROM Sales_Profile_Company_Level_Junction__c WHERE id IN :recIds];  
        
        delete juncs; 
    }
    
    @future
    public static void sendEmail(Set<String> srpName){
                
        List<Funnel_Org_Wide_Address__mdt> owMd = [SELECT label FROM Funnel_Org_Wide_Address__mdt LIMIT 1];
        Id owEmailId;
        
        if(owMd != null && owMd.size() > 0){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :owMd[0].label];
            if(owea != null && owea.size() > 0){
                owEmailId = owea[0].id;
            }
        }
        
        List<FM_Admins__mdt > ad= [SELECT label FROM FM_Admins__mdt LIMIT 100];
        List<String> sentTo = new List<String>();
        
        for(FM_Admins__mdt a : ad){
            sentTo.add(a.label);
        }
        
        String srpnameString = '';
        for(String s:srpname) {
           srpnameString += (srpnameString ==''?'':',')+s;
        }
                
        Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage();
        
        if(owEmailId != null) 
            mail.setOrgWideEmailAddressId(owEmailId);
        
        mail.setSubject('Sales Rep profile not created');
        //system.debug('srpname---'+srpname);
        String body;
        
        String headerURL = '';
        List<Application_Setting__c> prob = [SELECT Id, Header_Image__c FROM Application_Setting__c limit 1];
        if(prob != null && prob.size()>0){
          headerURL = prob[0].Header_Image__c;
        }
        
        body='For the following users create Sales profile :'+srpnameString ;
        mail.setHtmlBody('<html><body><img src="' +headerURL+ '"/><br/>'+body+'</body></html>');  
        
        if(sentTo != null && sentTo.size()>0) {
            mail.setToAddresses(sentTo);
            Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});
   
        }
    }

    public static void sendErrorMail(String errorMessage, String getStackTraceString){              
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        
        /*List<FM_Admins__mdt > ad= [SELECT label FROM FM_Admins__mdt LIMIT 5000];

        for(FM_Admins__mdt a : ad){
            toAddresses.add(a.label);
        }*/
        
        Admin_Email__mdt[] adminEmails = [SELECT Email_Address__c FROM Admin_Email__mdt LIMIT 20];

        for (Admin_Email__mdt em: adminEmails) {
            toAddresses.add(em.Email_Address__c);    
        }
                
        if(toAddresses.size() > 0){
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Apex error message');
            mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody(' errorMessage '+errorMessage+' '+getStackTraceString);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    /* Custom metadata code */
        public static void createRecordTypeMap(){
            
            lstCustMd = new List<Client_custom_field_mapping__mdt>();
            lstCustMd = [SELECT Action__c, Custom_field_name__c, Standard_field_name__c, Record_type_name__c FROM Client_custom_field_mapping__mdt WHERE Standard_field_name__c = 'Amount'];
            
            //recTypes = new List<RecordType>();
            //recTypes = [SELECT id, Name FROM RecordType WHERE SobjectType='Opportunity'];
            
            recTypeFldMap = new Map<String,List<String>>();                                                                
            
            recTypeNameIdMap = new Map<String,String>();
             
            recTypeIdNameMap = new Map<String,String>();
            
            recTypeIdActionMap = new Map<id,String>();
          
            List<String> rectypeNames = new List<String>();                
            
            for(Client_custom_field_mapping__mdt cm: lstCustMd){
                rectypeNames.add(cm.Record_type_name__c);
            }
            
            List<RecordType> lstRT = [SELECT id, name FROM RecordType WHERE name IN :rectypeNames];
            for(RecordType r:lstRT ){
                recTypeNameIdMap.put(r.name,r.id);
                recTypeIdNameMap.put(r.id,r.name);
            }
            
            if(lstCustMd != null && lstCustMd.size() > 0){
                for(Client_custom_field_mapping__mdt cm: lstCustMd){
                    if(recTypeFldMap.containsKey(cm.Record_type_name__c)){
                        recTypeFldMap.get(cm.Record_type_name__c).add(cm.Custom_field_name__c);
                    }
                    else{
                        List<String> flds = new List<String>();
                        flds.add(cm.Custom_field_name__c);
                        recTypeFldMap.put(cm.Record_type_name__c,flds);
                        recTypeIdActionMap.put(recTypeNameIdMap.get(cm.Record_type_name__c),cm.Action__c);
                        recTypeActionMap.put(cm.Record_type_name__c,cm.Action__c);
                
                    }
                    
                    
                }
            }    
            
        }
        
            
    /* Custom metadata code */ 
    
    /* Custom metadata code */
    
    public static Map<id,Decimal> fetchRevenueNumbers(String SOQL_IDs, String startDate12Monthsd, String Cyeard, String scenario){
        
        Map<id,Decimal> ownerAmtMap = new Map<id,Decimal>();
            
        List<AggregateResult> oppAggrAmt = new List<AggregateResult>();                         
        
        String q;
                  
        if(lstCustMd != null && lstCustMd.size() > 0){                    
            
            for (String recTypeName : recTypeFldMap.keySet()){
                
                
                q = 'SELECT ownerId o ';
        
                if(recTypeActionMap.get(recTypeName) == 'Add'){
                    q += ', SUM(amount) s ';
                }
            
                List<String> flds = recTypeFldMap.get(recTypeName);
                
                for(Integer i = 0; i < flds.size(); i++){
                    q += ', SUM('+flds[i]+') '+flds[i];       
                }
                
                if(scenario == 'closed ytd')
                    q += ' FROM Opportunity WHERE OwnerId IN ('+SOQL_IDs+') AND CloseDate >=  '+ startDate12Monthsd+' AND CloseDate <=  '+ Cyeard;
                else
                    q += ' FROM Opportunity WHERE OwnerId IN ('+SOQL_IDs+') AND CloseDate >=  '+ startDate12Monthsd+' AND CloseDate <  '+ Cyeard;
                
                if(scenario == 'closed' || scenario == 'closed ytd'){
                    q += ' AND  iswon = true ';
                }
                
                String orgid = Userinfo.getOrganizationId();
                
                //if(!orgid.contains('00D3C0000004dw9')){ 
                    q += ' AND RecordTypeId = '+'\''+recTypeNameIdMap.get(recTypeName)+'\'';
                //}
                //else{*/
                //    q +=' AND Symbol_Reserved__c  = '+'\''+recTypeName+'\'';
                //} 
            
                q += ' GROUP BY OwnerId';                
                
                // system.debug(' final query is '+q);
                // system.debug(' recTypeNameIdMap'+recTypeNameIdMap);
                
                //FunnelTriggerBatchHelper.sendErrorMail('final query is '+q);                                                                
                
                oppAggrAmt = database.query(q);
                
                //system.debug(' oppAggrAmt '+oppAggrAmt);
                
                for(AggregateResult ar: oppAggrAmt){
                    
                    Decimal totAmt = 0;
                    
                    if(recTypeActionMap.get(recTypeName) == 'Add'){
                                                    
                        if(ar.get('s') != null)
                            totAmt  += (Decimal)ar.get('s');
                    }
                        
                    for(Integer i = 0; i < flds.size(); i++){
                        if(ar.get(flds[i]) != null)
                            totAmt += (Decimal)ar.get(flds[i]);       
                    }                            
                
                    if(!ownerAmtMap.containsKey((id)ar.get('o'))){
                        ownerAmtMap.put((id)ar.get('o'),(Decimal)totAmt);        
                    }
                    else{
                        Decimal amt = ownerAmtMap.get((id)ar.get('o'));
                        amt += totAmt;                           
                        ownerAmtMap.put((id)ar.get('o'),amt);
                    }
                       
                } 
                
                                   
            }                                
                            
            /*for(Client_custom_field_mapping__mdt cm: lstCustMd){
                q += ', SUM('+cm.Custom_field_name__c+') '+cm.Custom_field_name__c;    
            }*/
               
        }
        else{
            
            if(scenario == 'closed'){
                q = 'SELECT ownerId o, SUM(amount) s FROM Opportunity WHERE OwnerId IN ('+SOQL_IDs+') AND  iswon = true AND CloseDate >=  '+ startDate12Monthsd+' AND CloseDate <  '+ Cyeard+' GROUP BY OwnerId'; 
            }
            else if(scenario == 'closed ytd'){
                q = 'SELECT ownerId o, SUM(amount) s FROM Opportunity WHERE OwnerId IN ('+SOQL_IDs+') AND  iswon = true AND CloseDate >=  '+ startDate12Monthsd+' AND CloseDate <=  '+ Cyeard+' GROUP BY OwnerId';
            }
            
            
                                                            
            ////system.debug('q--'+q);
            oppAggrAmt = database.query(q);
            
            for(AggregateResult ar: oppAggrAmt){                    
                if(ar.get('s') != null){
                    ownerAmtMap.put((id)ar.get('o'),(Decimal)ar.get('s'));        
                }
            }
        }
        
        return ownerAmtMap;
    } 
    
     public static Map<id,Decimal> fetchCurrentPipeline(String SOQL_IDs){
        
        Map<id,Decimal> ownerAmtMap = new Map<id,Decimal>();
            
        List<AggregateResult> oppAggrAmt = new List<AggregateResult>();                         
        
        String q;
                  
        if(lstCustMd != null && lstCustMd.size() > 0){                    
            
            for (String recTypeName : recTypeFldMap.keySet()){
                
                
                q = 'SELECT ownerId o ';
        
                if(recTypeActionMap.get(recTypeName) == 'Add'){
                    q += ', SUM(amount) s ';
                }
            
                List<String> flds = recTypeFldMap.get(recTypeName);
                
                for(Integer i = 0; i < flds.size(); i++){
                    q += ', SUM('+flds[i]+') '+flds[i];       
                }
                
                q += ' FROM Opportunity WHERE OwnerId IN ('+SOQL_IDs+') AND  IsClosed = false AND RecordTypeId = '+'\''+recTypeNameIdMap.get(recTypeName)+'\'';
                
                q += ' GROUP BY OwnerId';                
                
                                                                             
                
                oppAggrAmt = database.query(q);
                
                //system.debug(' oppAggrAmt '+oppAggrAmt);
                
                for(AggregateResult ar: oppAggrAmt){
                    
                    Decimal totAmt = 0;
                    
                    if(recTypeActionMap.get(recTypeName) == 'Add'){
                                                    
                        if(ar.get('s') != null)
                            totAmt  += (Decimal)ar.get('s');
                    }
                        
                    for(Integer i = 0; i < flds.size(); i++){
                        if(ar.get(flds[i]) != null)
                            totAmt += (Decimal)ar.get(flds[i]);       
                    }                            
                
                    if(!ownerAmtMap.containsKey((id)ar.get('o'))){
                        ownerAmtMap.put((id)ar.get('o'),(Decimal)totAmt);        
                    }
                    else{
                        Decimal amt = ownerAmtMap.get((id)ar.get('o'));
                        amt += totAmt;                           
                        ownerAmtMap.put((id)ar.get('o'),amt);
                    }
                       
                } 
                
                                   
            }                                
                            
            
               
        }
        else{
            
            q = 'SELECT ownerId o, SUM(amount) s, Count(id) c FROM Opportunity WHERE OwnerId IN ('+SOQL_IDs+') AND   IsClosed = false GROUP BY OwnerId'; 
            
            system.debug(' final query is '+q);                                                
            oppAggrAmt = database.query(q);
            
            for(AggregateResult ar: oppAggrAmt){                    
                if(ar.get('s') != null){
                    ownerAmtMap.put((id)ar.get('o'),(Decimal)ar.get('s'));        
                }
            }
        }
        
        return ownerAmtMap;
    }
    
    /* Custom metadata code */ 
   
    public static void installationMail(String subject, String msg){
    
    List<Funnel_Org_Wide_Address__mdt> owMd = [SELECT label FROM Funnel_Org_Wide_Address__mdt LIMIT 1];
    Id owEmailId;
        
    if(owMd != null && owMd.size() > 0){
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :owMd[0].label];
        if(owea != null && owea.size() > 0){
            owEmailId = owea[0].id;
        }
    }
        
    List<Admin_Email__mdt> ad= [SELECT Email_Address__c  FROM Admin_Email__mdt LIMIT 100];
    List<String> sentTo = new List<String>();
        
    for(Admin_Email__mdt a : ad){
        sentTo.add(a.Email_Address__c );
    }
    
    List<PermissionSetAssignment> psa = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Funnel_App_Setup'];
    if(psa != null && psa.size()>0){
        Set<id> userId = new Set<id>();
        for(PermissionSetAssignment p :psa){
            userId.add(p.AssigneeId);
        }
        List<User> users = [Select Email from User where id IN :userId];
        if(users != null && users.size()>0){
            for(User u : users ){
                 sentTo.add(u.Email);
            }
        }
    } 
             
    Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage();
        
    if(owEmailId != null) 
        mail.setOrgWideEmailAddressId(owEmailId);
    
    mail.setSubject(subject);
    String body;
        
    String headerURL = '';
    List<Application_Setting__c> prob = [SELECT Id, Header_Image__c FROM Application_Setting__c limit 1];
    if(prob != null && prob.size()>0){
      headerURL = prob[0].Header_Image__c;
    }
    
    body= msg+'Our automation process has calculated suggested goals for all of your roles. Please log in to review and save these goals. You can then allow managers to customize these goals for their teams.' ;
    body += '<br/>'+'Review the suggested goals <a href="https://'+URL.getSalesforceBaseUrl().getHost()+'/apex/FunnelReviewGoals">here.</a>';   
        
    mail.setHtmlBody('<html><body><img src="' +headerURL+ '"/><br/>'+body+'</body></html>');  
    
    if(sentTo != null && sentTo.size()>0) {
        mail.setToAddresses(sentTo);
        Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});
         
    }
} 

 public static void activateTrigger(){
     if(!Test.isRunningTest()){
         Map<String, Object> maptest = new Map<String, Object>();
         maptest.put('FunnelMetrics__Bypass__c',false);
         FMCreateUpdateMetadataUtils.createUpdateMetadata('FunnelMetrics__New_Data_load_setting.FunnelMetrics__Trigger','Bypass Funnel opp & lead triggers',maptest);
     }
  
 }
     
 public static void schActivateTrigger(){
    
    Date todayDate = Date.today();
                         
    Integer day = todayDate.day();
    Integer month= todayDate.month();
    Integer year= todayDate.year();
    
    datetime NOW  = system.now();
    NOW = NOW.addMinutes(3);
     
    Integer hr =NOW.hour();
    Integer sc = NOW.minute();

    List<CronTrigger> cornList = new List<CronTrigger>();
    cornList =[SELECT Id, CronJobDetail.name, State FROM CronTrigger where CronJobDetail.name='FM Activate Trigger'];
    
    if(cornList == NULL || (cornList != null && cornList.size() == 0)){    
        FunnelTriggerActivateFrombatch sb = new FunnelTriggerActivateFrombatch();
        String sch = '0 '+sc+' '+hr+' '+day+' '+month+ ' ? '+year;
        system.schedule('FM Activate Trigger', sch, sb);
    } 
 }
 
   public static void ManagerUpdateMail(){
    
        List<Funnel_Org_Wide_Address__mdt> owMd = [SELECT label FROM Funnel_Org_Wide_Address__mdt LIMIT 1];
        Id owEmailId;
            
        if(owMd != null && owMd.size() > 0){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :owMd[0].label];
            if(owea != null && owea.size() > 0){
                owEmailId = owea[0].id;
            }
        }
            
        //List<Admin_Email__mdt> ad= [SELECT Email_Address__c  FROM Admin_Email__mdt LIMIT 100];
        List<String> sentTo = new List<String>();
        
        List<Company_Level__c> ad =[Select Sales_Rep_Profile__r.User_Record_Name__r.Email from Company_Level__c Limit 1000];    
        for(Company_Level__c a : ad){
            sentTo.add(a.Sales_Rep_Profile__r.User_Record_Name__r.Email);
        }
        
        /*List<PermissionSetAssignment> psa = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Funnel_App_Setup'];
        if(psa != null && psa.size()>0){
            Set<id> userId = new Set<id>();
            for(PermissionSetAssignment p :psa){
                userId.add(p.AssigneeId);
            }
            List<User> users = [Select Email from User where id IN :userId];
            if(users != null && users.size()>0){
                for(User u : users ){
                     sentTo.add(u.Email);
                }
            }
        } */
            
        Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage();
            
        if(owEmailId != null) 
            mail.setOrgWideEmailAddressId(owEmailId);
        
        mail.setSubject('Review Goals');
        String body;
            
        String headerURL = '';
        List<Application_Setting__c> prob = [SELECT Id, Header_Image__c FROM Application_Setting__c limit 1];
        if(prob != null && prob.size()>0){
          headerURL = prob[0].Header_Image__c;
        }
        
        body='Suggested goals have been calculated for your team. Please log in to review and save these goals. You can customize them per person if necessary.' ;
        body += '<br/>'+'Review the suggested goals <a href="https://'+URL.getSalesforceBaseUrl().getHost()+'/apex/FunnelManagerUpdate">here.</a>';   
        
        mail.setHtmlBody('<html><body><img src="' +headerURL+ '"/><br/>'+body+'</body></html>');  
        
        if(sentTo != null && sentTo.size()>0) {
            mail.setToAddresses(sentTo);
            Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});
             
        }
    }   
    
    public static  Boolean isManager(String id){
        boolean ismgr = false;
        List<Company_Level__c> mgr = [Select id from Company_Level__c where Sales_Rep_Profile__r.User_Record_Name__c = :id LIMIT 1];
        
        if(mgr!= null && mgr.size()>0){
            ismgr = true;
        }
       // system.debug('ismgr ---'+ismgr );
        return ismgr;
    
    }
}