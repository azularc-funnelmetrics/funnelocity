public with sharing class FunnelCalculator{

    public List<FunnelCalculatorWrapper> FunnelCalculatorWrapperList{get;set;}

    public class FunnelCalculatorWrapper{
        
        public string FunnelDescription{get;set;}
        public Decimal PriorYearResult{get;set;}
        public Decimal SalesRepGoal{get;set;}
        public Decimal TeamResult{get;set;}
        public Decimal Result{get;set;}
        public Decimal Gap_result_SalesRepGoal{get;set;}
        public Decimal Gap_result_TeamResult{get;set;}
    }
    
    
    public List<FunnelCalculatorWrapper> FunnelTable(){
        FunnelCalculatorWrapperList = new List<FunnelCalculatorWrapper>();
        
        Sales_Rep_Profile__c srp = new Sales_Rep_Profile__c();
        List<AggregateResult> srpteam = new list<AggregateResult>();
        
        srp=[Select id,Annual_Quota_Amount__c,Sales_Manager__c,YTD_Revenue__c,X12_Month_Rolling_Average_Sales_Cycle__c,X12_Month_Rolling_Opptys_Won__c,X12_Month_Rolling_Win_Percentage__c,X12_Month_Opprties_Added_to_the_funnel__c from Sales_Rep_Profile__c where id='a0129000001IXcmAAG'];
        srpteam =[Select avg(YTD_Revenue__c) aver, avg(X12_Month_Rolling_Average_Sales_Cycle__c) avgsc,avg(X12_Month_Rolling_Opptys_Won__c) avgow, avg(X12_Month_Rolling_Win_Percentage__c) avgwr, avg(X12_Month_Opprties_Added_to_the_funnel__c) avgaf from Sales_Rep_Profile__c where Sales_Manager__c=:srp.Sales_Manager__c GROUP BY Sales_Manager__c ];
        
        FunnelCalculatorWrapper fcw7 = new FunnelCalculatorWrapper();
        
        fcw7.FunnelDescription = 'Annual Quota';
        fcw7.PriorYearResult = 0;
        fcw7.SalesRepGoal= srp.Annual_Quota_Amount__c;
        fcw7.TeamResult= (Decimal)srpteam[0].get('aver');
        fcw7.Result= srp.YTD_Revenue__c;
        fcw7.Gap_result_SalesRepGoal = fcw7.Result-fcw7.SalesRepGoal;
        fcw7.Gap_result_TeamResult = fcw7.Result-fcw7.TeamResult;
        
        FunnelCalculatorWrapperList.add(fcw7);
        
        FunnelCalculatorWrapper  fcw8 = new FunnelCalculatorWrapper();
        
        fcw8.FunnelDescription = 'Quarterly Quota';
        fcw8.PriorYearResult = 0;
        fcw8.SalesRepGoal= srp.Annual_Quota_Amount__c/4;
        fcw8.TeamResult= (Decimal)srpteam[0].get('aver')/4;
        fcw8.Result= srp.YTD_Revenue__c/4;
        fcw8.Gap_result_SalesRepGoal = fcw8.Result-fcw8.SalesRepGoal/4;
        fcw8.Gap_result_TeamResult = fcw8.Result-fcw8.TeamResult/4;
        
        FunnelCalculatorWrapperList.add(fcw8);
        
        FunnelCalculatorWrapper  fcw9 = new FunnelCalculatorWrapper();
        
        fcw9.FunnelDescription = 'Monthly Quota';
        fcw9.PriorYearResult = 0;
        fcw9.SalesRepGoal= srp.Annual_Quota_Amount__c/12;
        fcw9.TeamResult= (Decimal)srpteam[0].get('aver')/12;
        fcw9.Result= srp.YTD_Revenue__c/12;
        fcw9.Gap_result_SalesRepGoal = fcw9.Result-fcw9.SalesRepGoal/12;
        fcw9.Gap_result_TeamResult = fcw9.Result-fcw9.TeamResult/12;
        
        FunnelCalculatorWrapperList.add(fcw9);
        
        FunnelCalculatorWrapper  fcw10 = new FunnelCalculatorWrapper();
        
        fcw10.FunnelDescription = 'Length of Sales Cycle';
        fcw10.PriorYearResult = 0;
        fcw10.SalesRepGoal= 0;
        fcw10.TeamResult= (Decimal)srpteam[0].get('avgsc');
        fcw10.Result= srp.X12_Month_Rolling_Average_Sales_Cycle__c;
        fcw10.Gap_result_SalesRepGoal = fcw10.Result-fcw10.SalesRepGoal;
        fcw10.Gap_result_TeamResult = fcw10.Result-fcw10.TeamResult;
        
        FunnelCalculatorWrapperList.add(fcw10);
        
        FunnelCalculatorWrapper  fcw11 = new FunnelCalculatorWrapper();
        
        fcw11.FunnelDescription = '12 month Average Selling Price or less than 12 month tenure YTD Avg. Selling Price';
        fcw11.PriorYearResult = 0;
        fcw11.SalesRepGoal= 0;
        fcw11.TeamResult= (Decimal)srpteam[0].get('aver')/(Decimal)srpteam[0].get('avgow');
        fcw11.Result= srp.YTD_Revenue__c/srp.X12_Month_Rolling_Opptys_Won__c;
        fcw11.Gap_result_SalesRepGoal = fcw11.Result-fcw11.SalesRepGoal;
        fcw11.Gap_result_TeamResult = fcw11.Result-fcw11.TeamResult;
        
        FunnelCalculatorWrapperList.add(fcw11);
        
        
        
        
        
        FunnelCalculatorWrapper  fcw23 = new FunnelCalculatorWrapper();
        
        fcw23.FunnelDescription = '12 month rolling win rate or if less than 12 months tenure use YTD Win Rate (Qualified =  10% or Greater which moved to a Win)';
        fcw23.PriorYearResult = 0;
        fcw23.SalesRepGoal= 0;
        fcw23.TeamResult= (Decimal)srpteam[0].get('avgwr');
        fcw23.Result= srp.X12_Month_Rolling_Win_Percentage__c;
        fcw23.Gap_result_SalesRepGoal = fcw23.Result-fcw23.SalesRepGoal;
        fcw23.Gap_result_TeamResult = fcw23.Result-fcw23.TeamResult;
        
        FunnelCalculatorWrapper  fcw24 = new FunnelCalculatorWrapper();
        
        fcw24.FunnelDescription = '# of Wins to Achieve Annual Quota';
        fcw24.PriorYearResult = 0;
        fcw24.SalesRepGoal= 0;
        fcw24.TeamResult= fcw7.TeamResult/fcw11.TeamResult;
        fcw24.Result= fcw7.Result/fcw11.Result;
        fcw24.Gap_result_SalesRepGoal = fcw24.Result-fcw24.SalesRepGoal;
        fcw24.Gap_result_TeamResult = fcw24.Result-fcw24.TeamResult;
        
        
        
        FunnelCalculatorWrapper  fcw18 = new FunnelCalculatorWrapper();
        
        fcw18.FunnelDescription = '# of Annual Qualifiied Opportunities - 10% to Achieve Quota';
        fcw18.PriorYearResult = 0;
        fcw18.SalesRepGoal= 0;
        fcw18.TeamResult= fcw24.TeamResult/fcw23.TeamResult;
        fcw18.Result= fcw24.Result/fcw23.Result;
        fcw18.Gap_result_SalesRepGoal = fcw18.Result-fcw18.SalesRepGoal;
        fcw18.Gap_result_TeamResult = fcw18.Result-fcw18.TeamResult;
        
        FunnelCalculatorWrapperList.add(fcw18);
        
        FunnelCalculatorWrapper  fcw19 = new FunnelCalculatorWrapper();
        
        fcw19.FunnelDescription = '# of Quarterly Qualifiied Opportunities - 10% to Achieve Quota';
        fcw19.PriorYearResult = 0;
        fcw19.SalesRepGoal= 0;
        fcw19.TeamResult= fcw18.TeamResult/4;
        fcw19.Result= fcw18.Result/4;
        fcw19.Gap_result_SalesRepGoal = fcw19.Result-fcw19.SalesRepGoal;
        fcw19.Gap_result_TeamResult = fcw19.Result-fcw19.TeamResult;
        
        FunnelCalculatorWrapperList.add(fcw19);
        
        FunnelCalculatorWrapper  fcw20 = new FunnelCalculatorWrapper();
        
        fcw20.FunnelDescription = '# of Quarterly Qualifiied Opportunities - 10% to Achieve Quota';
        fcw20.PriorYearResult = 0;
        fcw20.SalesRepGoal= 0;
        fcw20.TeamResult= fcw18.TeamResult/12;
        fcw20.Result= fcw18.Result/12;
        fcw20.Gap_result_SalesRepGoal = fcw20.Result-fcw20.SalesRepGoal;
        fcw20.Gap_result_TeamResult = fcw20.Result-fcw20.TeamResult;
        
        FunnelCalculatorWrapperList.add(fcw20);
        
        FunnelCalculatorWrapper  fcw21 = new FunnelCalculatorWrapper();
        
        fcw21.FunnelDescription = '12 month or YTD total qualified opportunities added to funnel';
        fcw21.PriorYearResult = 0;
        fcw21.SalesRepGoal= 0;
        fcw21.TeamResult= (Decimal)srpteam[0].get('avgaf');
        fcw21.Result= srp.X12_Month_Opprties_Added_to_the_funnel__c;
        fcw21.Gap_result_SalesRepGoal = fcw21.Result-fcw21.SalesRepGoal;
        fcw21.Gap_result_TeamResult = fcw21.Result-fcw21.TeamResult;
        
        FunnelCalculatorWrapperList.add(fcw21);
        FunnelCalculatorWrapperList.add(fcw23);
        FunnelCalculatorWrapperList.add(fcw24);
        
        FunnelCalculatorWrapper  fcw25 = new FunnelCalculatorWrapper();
        
        fcw25.FunnelDescription = '# of Wins to Achieve Quarterly Quota';
        fcw25.PriorYearResult = 0;
        fcw25.SalesRepGoal= 0;
        fcw25.TeamResult= fcw8.TeamResult/fcw11.TeamResult;
        fcw25.Result= fcw8.Result/fcw11.Result;
        fcw25.Gap_result_SalesRepGoal = fcw25.Result-fcw25.SalesRepGoal;
        fcw25.Gap_result_TeamResult = fcw25.Result-fcw25.TeamResult;
        
        FunnelCalculatorWrapperList.add(fcw25);
        
        FunnelCalculatorWrapper  fcw26 = new FunnelCalculatorWrapper();
        
        fcw26.FunnelDescription = '# of Wins to Achieve Quarterly Quota';
        fcw26.PriorYearResult = 0;
        fcw26.SalesRepGoal= 0;
        fcw26.TeamResult= fcw9.TeamResult/fcw11.TeamResult;
        fcw26.Result= fcw9.Result/fcw11.Result;
        fcw26.Gap_result_SalesRepGoal = fcw26.Result-fcw26.SalesRepGoal;
        fcw26.Gap_result_TeamResult = fcw26.Result-fcw26.TeamResult;
        
        FunnelCalculatorWrapperList.add(fcw26);
        
        system.debug('FunnelCalculatorWrapperList'+FunnelCalculatorWrapperList);
        return FunnelCalculatorWrapperList ;
    }
}