@isTest

public class Funnel12MonthRollingFieldsTest
{
    static testMethod void testMethod1() 
    {    
        account ac = new account();
        ac.Name='test ac';
        
        insert ac;
        
        Sales_Rep_Profile__c testsrp = new Sales_Rep_Profile__c();
        Date closeDt = Date.Today();
        
        testsrp.Name ='Test SRP';
        insert testsrp;
        
        Opportunity op = new Opportunity();
        op.Name = 'test op';
        op.AccountId = ac.id;
        op.StageName='Closed Won';
        op.CloseDate = closeDt ;
        op.amount = 50;
        op.Sales_Rep_Profile__c = testsrp.id;
        
        insert op;
        
        Test.startTest();

            Funnel12MonthRollingFieldsBatch obj = new Funnel12MonthRollingFieldsBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
        }
}