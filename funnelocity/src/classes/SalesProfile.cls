public class SalesProfile {
    @AuraEnabled
    public static Sales_Rep_Profile__c getsaleprof(Id accountId){
        return [select id,X12_Month_Opprties_Added_to_the_funnel__c,
                X12_Month_Rolling_Average_Sales_Cycle__c,X12_Month_Rolling_Opptys_Won__c,
				X12_Month_Rolling_Revenue__c,X12_Month_Rolling_Win_Percentage__c,
				Annual_Opportunity_Quota__c,Annual_Quota_Amount__c,Annual_Win_Quota__c,
				Average_Sales_Price__c,Current_Active_Opportunities__c,Monthly_Wins__c,
				Quarterly_Opportunity_Quota__c,Quarterly_Wins__c,YTD_Average_Sales_Cycle__c,
				YTD_Opportunities_won__c,YTD_Revenue__c,YTD_Revenue_Close_Rate__c,
				YTD_Revenue_Quota_Percent__c,YTD_Win_Percentage__c,Monthly_Opportunity_Quota__c
				from Sales_Rep_Profile__c where Id=:accountId];
    }

}