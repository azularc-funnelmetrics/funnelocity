public class Funnel12MonthRollingFieldsBatch implements Database.Batchable<sobject>{

    public Database.QueryLocator start(Database.BatchableContext con){
         return Database.getQueryLocator('select id, Annual_Quota_Amount__c, (select id,amount,StageName,Days_for_closure__c  from Opportunities__r where CreatedDate = LAST_N_days:365 ) from Sales_Rep_Profile__c');
    }
    
    public void execute(Database.BatchableContext con, List<Sales_Rep_Profile__c> srp){
        //list<Sales_Rep_Profile__c> updatesrp = new list<Sales_Rep_Profile__c>();
        
        //List of sales rep ids that are being processed
        Set<Id> srIds = fetchSalesRepIds(srp);
        
        //Fetch the previous fiscal year start date to fetch the data stored for last year
        Date fiscalYr = FunnelTriggerHelper.getFiscalYearDate('Current_Year');        
        Date prevYr = Date.newInstance((fiscalYr.year() - 1), fiscalYr.month(), fiscalYr.day());
        
        //Find the months to be considered in the previous and current fiscal years for calculation of 12 month rolling quota
        Integer currentFiscalMonths, previousFiscalMonths = 0;               
        fetchMonthsForCalculation(currentFiscalMonths, previousFiscalMonths);
        
        //Fetch the quota for the previous year
        Map<Id,Integer> spQuotaMap = fetchQuotaForPastYr(prevYr ,srIds);
                                
        for(Sales_Rep_Profile__c s : srp){
            
            integer countWon = 0,countTotal = 0,avg = 0, countCycle = 0;
            Decimal a = 0;
                        
            for(opportunity o : s.Opportunities__r){
                if(o.StageName == 'Closed Won'){
                    countWon++;
                    if(o.amount != null){
                    a+=o.amount;
                    }
                    countCycle = (integer)(countCycle + o.Days_for_closure__c);
                }
                countTotal++;
                
            }
            if(countCycle != 0 && countWon!= 0 ){
                avg = countCycle/countWon;
            } else{
                avg =0;
            }
            
            s.X12_Month_Rolling_Opptys_Won__c = countWon;
            s.X12_Month_Rolling_Revenue__c = a;
            s.X12_Month_Opprties_Added_to_the_funnel__c = countTotal;
            s.X12_Month_Rolling_Average_Sales_Cycle__c = avg;            
            s.X12_Month_Rolling_Quota__c = ((s.Annual_Quota_Amount__c/12) * currentFiscalMonths); 
            
            if(spQuotaMap.get(s.id) != null){                
                s.X12_Month_Rolling_Quota__c = s.X12_Month_Rolling_Quota__c + (spQuotaMap.get(s.id) * previousFiscalMonths);
            }
            system.debug('countTotal'+countTotal);
        }
        
        update srp;
        //system.debug(srp);
    }
    
    public void finish(Database.BatchableContext con){
    
    }
    
    private void fetchMonthsForCalculation(Integer currentFiscalMonths, Integer previousFiscalMonths){
        
        Integer startMonth = FunnelTriggerHelper.getFiscalYearDate('Current_Year').Month();
        Integer currentMonth = Date.Today().Month();
        
        if(currentMonth > startMonth){
            currentFiscalMonths = currentMonth - startMonth;            
        }
        else if(currentMonth < startMonth){
            currentFiscalMonths = 12 - startMonth + currentMonth;            
        }
        else if(currentMonth == startMonth){
            currentFiscalMonths = 1;
        }
        
        previousFiscalMonths = 12 - currentFiscalMonths;
                
    }
    
    private Map<Id,Integer> fetchQuotaForPastYr(Date startDate, Set<Id> salesReps){
        
        Map<Id,Integer> spQuotaMap = new Map<Id,Integer>();

        List<YTD_Quota_Revenue__c> previousYearData = [SELECT Id, Annual_Quota_Amount__c FROM YTD_Quota_Revenue__c WHERE Start_date__c = :startDate AND Sales_Rep_Profile__c IN :salesReps];                
        
        for(YTD_Quota_Revenue__c qr: previousYearData){
        
            spQuotaMap.put(qr.Sales_Rep_Profile__c , (Integer)qr.Annual_Quota_Amount__c/12);    
        }
        
        return spQuotaMap;
    }
    
    private Set<Id> fetchSalesRepIds(List<Sales_Rep_Profile__c> salesReps){
    
        Set<Id> salesRepIds = new Set<Id>();
        
        for(Sales_Rep_Profile__c sr: salesReps){
            salesRepIds.add(sr.id);
        }
        
        return salesRepIds;
    }
}