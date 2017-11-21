public class FunnelYearlyBatch implements Database.Batchable<sobject>{
    
    public Date fiscalYr;
    
    public Date nextYr;
    
    public Database.QueryLocator start(Database.BatchableContext con){
         return Database.getQueryLocator('Id, YTD_Opportunities_won__c, YTD_Revenue__c, YTD_Revenue_Quota_Percent__c, YTD_Win_Percentage__c, YTD_Average_Sales_Cycle__c, YTD_Revenue_Close_Rate__c, Month_1_Quota_Amount__c, Month_2_Quota_Amount__c, Month_3_Quota_Amount__c, Month_4_Quota_Amount__c, Month_5_Quota_Amount__c, Month_6_Quota_Amount__c, Month_7_Quota_Amount__c, Month_9_Quota_Amount__c, Month_8_Quota_Amount__c, Month_10_Quota_Amount__c, Month_11_Quota_Amount__c, Month_12_Quota_Amount__c, Annual_Quota_Amount__c, Q1_Quota_Amount__c, Q2_Quota_Amount__c, Q3_Quota_Amount__c, Q4_Quota_Amount__c, Sales_Manager__c, Aggregated_Annual_Quota__c FROM Sales_Rep_Profile__c');
    }
    
    public void execute(Database.BatchableContext con, List<Sales_Rep_Profile__c> srp){
        
        //Fetch the previous fiscal year start date to fetch the data stored for last year
        fiscalYr = FunnelTriggerBatchHelper.getFiscalYearDate('Current_Year');        
        nextYr = Date.newInstance((fiscalYr.year() + 1), fiscalYr.month(), fiscalYr.day());                
        
        List<YTD_Quota_Revenue__c> quotaRecsToBeInserted = new List<YTD_Quota_Revenue__c>();   
                             
        for(Sales_Rep_Profile__c s : srp){
        
            YTD_Quota_Revenue__c yq = new YTD_Quota_Revenue__c();
            yq.Month_1_Quota_Amount__c = s.Month_1_Quota_Amount__c;
            yq.Month_2_Quota_Amount__c = s.Month_2_Quota_Amount__c;
            yq.Month_3_Quota_Amount__c = s.Month_3_Quota_Amount__c;
            yq.Month_4_Quota_Amount__c = s.Month_4_Quota_Amount__c;
            yq.Month_5_Quota_Amount__c = s.Month_5_Quota_Amount__c;
            yq.Month_6_Quota_Amount__c = s.Month_6_Quota_Amount__c;
            yq.Month_7_Quota_Amount__c = s.Month_7_Quota_Amount__c;
            yq.Month_8_Quota_Amount__c = s.Month_8_Quota_Amount__c;
            yq.Month_9_Quota_Amount__c = s.Month_9_Quota_Amount__c;
            yq.Month_10_Quota_Amount__c = s.Month_10_Quota_Amount__c;
            yq.Month_11_Quota_Amount__c = s.Month_11_Quota_Amount__c;
            yq.Month_12_Quota_Amount__c = s.Month_12_Quota_Amount__c;
            yq.Sales_Rep_Profile__c = s.id;
            yq.Start_date__c = fiscalYr;
            yq.YTD_Opportunities_Won__c = s.YTD_Opportunities_won__c;
            yq.YTD_Revenue__c = s.YTD_Revenue__c;
            quotaRecsToBeInserted.add(yq);  
            
            s.Month_1_Quota_Amount__c = 0;
            s.Month_2_Quota_Amount__c = 0;
            s.Month_3_Quota_Amount__c = 0;
            s.Month_4_Quota_Amount__c = 0;
            s.Month_5_Quota_Amount__c = 0;
            s.Month_6_Quota_Amount__c = 0;
            s.Month_7_Quota_Amount__c = 0;
            s.Month_8_Quota_Amount__c = 0;
            s.Month_9_Quota_Amount__c = 0;
            s.Month_10_Quota_Amount__c = 0;
            s.Month_11_Quota_Amount__c = 0;
            s.Month_12_Quota_Amount__c = 0;
            s.YTD_Opportunities_won__c = 0;
            s.YTD_Revenue__c = 0;                      
        }
        
        insert quotaRecsToBeInserted;
        update srp;
        //system.debug(srp);
        
    }
    
    public void finish(Database.BatchableContext con){
        
        Fiscal_Year_Setting__c fy = FunnelTriggerBatchHelper.getFiscalYearRecord('Current_Year');
        fy.Start_Date__c = nextYr;
        update fy;
                        
    }
}