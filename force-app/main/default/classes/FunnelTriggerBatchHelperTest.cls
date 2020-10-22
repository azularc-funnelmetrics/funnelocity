@isTest

public class FunnelTriggerBatchHelperTest{

    static testmethod void testOpptyCounter(){

        FunnelDataFactory.FunnelTestWrapper fw1 = new FunnelDataFactory.FunnelTestWrapper();
        
        fw1.index = 1;   
        fw1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole0A'+fw1.index , Name = 'My Role'+fw1.index);
        insert r1;
        
        fw1.userRoleId = r1.id;
        
        List<User> userList1 = FunnelDataFactory.createUser(fw1,1);
        insert userList1;                
            
        //PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Funnel_Sales_Profile_Company_Level_access'];
        //insert new PermissionSetAssignment(AssigneeId = userList1[0].id, PermissionSetId = ps.Id );
        
        System.runAs ( userList1[0] ) {
        
            date d = date.newinstance(date.today().year(), 1, 1);
            Fiscal_Year_Setting__c fiscalYr = FunnelDataFactory.setFiscalYear(d);
            insert fiscalYr;
            
            Application_Setting__c appSet = new Application_Setting__c(Probability__c=20);
            insert appSet;
        
            FunnelDataFactory.FunnelTestWrapper fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.index = 1;   
            fw.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
                    
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole'+fw.index , Name = 'My Role'+fw.index);
            insert r;
            
            fw.userRoleId = r.id;
            
            List<User> userList = FunnelDataFactory.createUser(fw,2);
            insert userList;
            system.debug(userList);
            
            List<Sales_Rep_Profile__c> sp = FunnelDataFactory.createSalesReplist(userList);
            insert sp;            
            
            sp[0].Sales_Manager__c = sp[1].id;
            update sp[0];                       
            
            List<Opportunity > op= FunnelDataFactory.createopplist(userList);
            op[0].Probability = 10;
            op[0].CloseDate = Date.today()+1;
            insert op;           
            
            Test.startTest();
            
            op[0].Probability = 30;
            op[0].CloseDate = Date.today()+40;
            update op;
            
            List<Lead> l= FunnelDataFactory.createLeadlist(userList);
            insert l;
                                                
            Sales_rep_profile__c sr = [SELECT Monthly_QO_Added__c FROM Sales_rep_profile__c WHERE id = :sp[0].id];
            System.assertEquals(1 , sr.Monthly_QO_Added__c);
            
            op[0].StageName = 'Closed/Lost';
            update op;
            
            Test.stopTest();
            
        }
    
    }
          
}