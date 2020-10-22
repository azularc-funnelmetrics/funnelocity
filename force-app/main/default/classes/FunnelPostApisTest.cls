@isTest
public class FunnelPostApisTest {
    
    //static testmethod void testAccess() {           
        
        /*               
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
         
        FunnelDataFactory.FunnelTestWrapper fw = new FunnelDataFactory.FunnelTestWrapper();
        fw.index = 1;
        fw.profileId = profileId;        
        fw.userRoleId = r.id;
        
        List<User> us = FunnelDataFactory.createUser(fw,1);
        insert us;
        User u = us[0];
        
        fw = new FunnelDataFactory.FunnelTestWrapper();
        fw.index = 2;
        fw.profileId = profileId;        
        fw.userRoleId = r.id;
        us = FunnelDataFactory.createUser(fw,1);
        insert us;
        User u2 = us[0];
        
        fw = new FunnelDataFactory.FunnelTestWrapper();
        fw.index = 3;
        fw.profileId = profileId;        
        fw.userRoleId = r.id;
        us = FunnelDataFactory.createUser(fw,1);
        insert us;
        User u3 = us[0];
        
        fw = new FunnelDataFactory.FunnelTestWrapper();
        fw.index = 4;
        fw.profileId = profileId;        
        fw.userRoleId = r.id;
        us = FunnelDataFactory.createUser(fw,1);
        insert us;
        User u4 = us[0];
        
        fw = new FunnelDataFactory.FunnelTestWrapper();
        fw.index = 5;
        fw.profileId = profileId;        
        fw.userRoleId = r.id;
        us = FunnelDataFactory.createUser(fw,1);
        insert us;
        User u5 = us[0];
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'FunnelReadAccessAllObjs'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );         
        
        
        system.runAs(u){
            
            test.startTest();
            List<Sales_Rep_Profile__c > splist= new List<Sales_Rep_Profile__c >();
            
            Fiscal_Year_Setting__c fiscalYr = FunnelDataFactory.setFiscalYear(System.Today()-1);
            insert fiscalYr;
            
            Notification_Setting__c  noti = new Notification_Setting__c (Enable_Notifications__c = true,Advance_Reminders__c = '1 day prior',Notification_Frequency__c = 'Daily', Escalation__c ='Never');
            insert noti ;
            
            fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.index = 4;
            fw.userId = u4.id;
            system.debug(' fw.userId '+fw.userId);
            Sales_Rep_Profile__c spMgrMgr = FunnelDataFactory.createSalesRep(fw);
            insert spMgrMgr;
            splist.add(spMgrMgr);
            
            fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.index = 1;
            fw.userId = u.id;
            fw.salesMgr = spMgrMgr.id;
            system.debug(' fw.userId '+fw.userId);
            Sales_Rep_Profile__c spMgr = FunnelDataFactory.createSalesRep(fw);
            insert spMgr;
            splist.add(spMgr);
            
            fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.index = 5;
            fw.userId = u5.id;
            fw.salesMgr = spMgrMgr.id;
            system.debug(' fw.userId '+fw.userId);
            Sales_Rep_Profile__c spMgr2 = FunnelDataFactory.createSalesRep(fw);
            insert spMgr2;
            splist.add(spMgr2);
            
            fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.index = 2;        
            fw.userId = u2.id;
            fw.salesMgr = spMgr.id;
            system.debug(' fw.userId '+fw.userId);        
            Sales_Rep_Profile__c spProf = FunnelDataFactory.createSalesRep(fw);
            spProf.Quarterly_Opportunities_added_to_Qualifi__c = 5;
            spProf.Quarterly_Lead_Added__c = 5;
            spProf.Quarterly_Quota_Revenue__c = 500;
            spProf.Month_1_Quota_Amount__c= 500;
            spProf.YTD_Revenue__c = 500;
            spProf.X12_Month_Rolling_Opportunity_Close_Rate__c = 50;
            insert spProf;
            splist.add(spProf);
            
            fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.index = 3;        
            fw.userId = u3.id;
            fw.salesMgr = spMgr.id;
            system.debug(' fw.userId '+fw.userId);        
            Sales_Rep_Profile__c spProf1 = FunnelDataFactory.createSalesRep(fw);
            spProf1.Quarterly_Opportunities_added_to_Qualifi__c = 5;
            spProf1.Quarterly_Lead_Added__c = 5;
            spProf1.Quarterly_Quota_Revenue__c = 500;
            spProf1.Month_1_Quota_Amount__c= 500;
            spProf1.YTD_Revenue__c = 500;
            spProf1.X12_Month_Rolling_Opportunity_Close_Rate__c = 50;
            insert spProf1;
            splist.add(spProf1);
            
            List<YTD_Quota_Revenue__c> yrq = FunnelDataFactory.createPriorYearResult(splist);   
            
            yrq[3].YTD_Revenue__c = 200;
            yrq[3].X12_Month_Rolling_Average_Sales_Cycle__c = 20;
            yrq[3].X12_Month_Average_Selling_Price__c = 200;
            yrq[3].X12_Month_Opprties_Added_to_the_funnel__c = 20;
            yrq[3].X12_Month_Leads_Added__c = 35;
            
            yrq[4].YTD_Revenue__c = 200;
            yrq[4].X12_Month_Rolling_Average_Sales_Cycle__c = 20;
            yrq[4].X12_Month_Average_Selling_Price__c = 200;
            yrq[4].X12_Month_Opprties_Added_to_the_funnel__c = 20;
            yrq[4].X12_Month_Leads_Added__c = 35;           
            
            insert yrq;
            
            fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.index = 1;  
            fw.levelName = 'Country';
            fw.levelValue = 'US';
            fw.salesProfForCompLevel = spMgr.id;
            
            List<Sales_Rep_Profile__c> sp = new List<Sales_Rep_Profile__c>();
            sp.add(spMgr);
            List<Company_Level__c> cl = FunnelDataFactory.createCompanyLevel(fw,sp);                        
            insert cl;
            
            fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.index = 2;  
            fw.levelName = 'Country';
            fw.levelValue = 'Canada';
            fw.salesProfForCompLevel = spMgr2.id;
            
            sp = new List<Sales_Rep_Profile__c>();
            sp.add(spMgr2);
            cl = FunnelDataFactory.createCompanyLevel(fw,sp);                        
            insert cl;
            
            fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.index = 3;  
            fw.levelName = 'Company';
            fw.levelValue = 'Funnel Metrics';
            fw.salesProfForCompLevel = spMgrMgr.id;
            
            sp = new List<Sales_Rep_Profile__c>();
            sp.add(spMgrMgr);
            cl = FunnelDataFactory.createCompanyLevel(fw,sp);                        
            insert cl;
                                    
            FunnelCalculator fc = new FunnelCalculator();
            system.assertEquals(fc.fcw7.Resultstring,'$1,000');
            test.stopTest();
            
        //}
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/claimApi'; 
        req.params.put('phoneNumber', '9876543210');
        req.params.put('claimNumber', '111111');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;                 
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        FunnelPostApis fp = new FunnelPostApis();
        fp.getAccessToken();
            
        system.assert(fp.msg != '');*/
                                    
    //}
    
    
    static testMethod void createCustomerTest(){
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/claimApi'; 
        req.params.put('phoneNumber', '9876543210');
        req.params.put('claimNumber', '111111');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;                 
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        FunnelPostApis fp = new FunnelPostApis();
        fp.createCustomer();
        system.assert(fp.msg != null);
        Test.stopTest(); 
    
    }        
    
    static testMethod void createQualRatingTest(){
        
        FunnelDataFactory.FunnelTestWrapper fw = new FunnelDataFactory.FunnelTestWrapper();
        fw.type = 'Qualitative';   
        fw.calcType = 'Y/N';
        fw.category = 'Test category';            
        fw.userType = 'Tenured';
        fw.timing = 'End of month';
        fw.weight = '4';      
        
        DescribeFieldResult describe = Sales_Rep_Profile__c.Role__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        String val = availableValues[0].getValue();
                               
        fw.rolesEnabled = val;          
        List<Certification_Rating__c> ratings = FunnelDataFactory.createCertificationRatings(fw,4);
        ratings[0].Timing__c = 'End of quarter';
        ratings[1].Timing__c = 'Bi-annual';
        ratings[2].Timing__c = 'Annual';
                                
        insert ratings;
                
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/claimApi'; 
        req.params.put('phoneNumber', '9876543210');
        req.params.put('claimNumber', '111111');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;                 
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        FunnelPostApis fp = new FunnelPostApis();
        fp.createQualRating();
        system.assert(fp.msg != null);
        Test.stopTest(); 
    
    }
    
    
    static testMethod void createQuantRatingTest(){
        
        FunnelDataFactory.FunnelTestWrapper fw = new FunnelDataFactory.FunnelTestWrapper();
        fw.type = 'Quantitative';   
        fw.calcType = 'Y/N';
        fw.category = 'Test category';            
        fw.userType = 'Tenured';
        fw.timing = 'End of month';
        fw.weight = '4';      
        
        DescribeFieldResult describe = Sales_Rep_Profile__c.Role__c.getDescribe();
        List<PicklistEntry> availableValues = describe.getPicklistValues();
        String val = availableValues[0].getValue();
                               
        fw.rolesEnabled = val;          
        List<Certification_Rating__c> ratings = FunnelDataFactory.createCertificationRatings(fw,4);
        ratings[0].Timing__c = 'End of quarter';
        ratings[1].Timing__c = 'Bi-annual';
        ratings[2].Timing__c = 'Annual';
                                
        insert ratings;
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/claimApi'; 
        req.params.put('phoneNumber', '9876543210');
        req.params.put('claimNumber', '111111');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;                 
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        FunnelPostApis fp = new FunnelPostApis();
        fp.createQuantRating();
        system.assert(fp.msg != null);
        Test.stopTest(); 
    
    }
    
    
    static testMethod void createQualMetricTest(){
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;                        
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole' , Name = 'My Role');
        insert r;
        
        FunnelDataFactory.FunnelTestWrapper fw = new FunnelDataFactory.FunnelTestWrapper();
        fw.profileId = profileId;
        fw.index = 1;
        fw.userRoleId = r.id;
        
        List<User> userList = FunnelDataFactory.createUser(fw,100);
        insert userList;
        
        System.runAs (userList[0]) { 
            
            Fiscal_Year_Setting__c fiscalYr = FunnelDataFactory.setFiscalYear(System.Today()-1);
            insert fiscalYr;
                           
            
            system.debug(userList);
            
            List<Sales_Rep_Profile__c> sp = FunnelDataFactory.createSalesReplist(userList);
            insert sp;
            
            system.debug(sp);
            
            fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.type = 'Qualitative';   
            fw.calcType = 'Y/N';
            fw.category = 'Test category';            
            fw.userType = 'Tenured';
            fw.timing = 'End of month';
            fw.weight = '4';      
            
            DescribeFieldResult describe = Sales_Rep_Profile__c.Role__c.getDescribe();
            List<PicklistEntry> availableValues = describe.getPicklistValues();
            String val = availableValues[0].getValue();
                                   
            fw.rolesEnabled = val;          
            List<Certification_Rating__c> ratings = FunnelDataFactory.createCertificationRatings(fw,4);
            ratings[0].Timing__c = 'End of quarter';
            ratings[1].Timing__c = 'Bi-annual';
            ratings[2].Timing__c = 'Annual';
                                    
            insert ratings;
            
            List<Certification_Answer__c> ans = FunnelDataFactory.createCertificationAnswers(fw,ratings);
            for(Certification_Answer__c a: ans){
                a.Rating_start_date__c = Date.today() - 4;
                a.Due_Date__c = Date.today();
            }
            
            ans[3].Rating_Score__c = 4;
            insert ans;
                
            Test.startTest();
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/claimApi'; 
            req.params.put('phoneNumber', '9876543210');
            req.params.put('claimNumber', '111111');
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req;
            RestContext.response = res;                 
            
            SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                     'Complete',
                                                     '[{"Name": "sForceTest1"}]',
                                                     null);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            
            FunnelPostApis fp = new FunnelPostApis();
            fp.dtSnapShot = Date.today();
            fp.createQualMetric(sp);
            
            system.assert(fp.msg != null);
            Test.stopTest();
        }                
    
    }
    
    static testMethod void createQuantMetricTest(){
        
        FunnelDataFactory.FunnelTestWrapper fw1 = new FunnelDataFactory.FunnelTestWrapper();
        fw1.index = 1;   
        fw1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;                
        UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole0A'+fw1.index , Name = 'My Role'+fw1.index);
        
        List<User> userList1 = FunnelDataFactory.createUser(fw1,1);        
        insert userList1;
        
        System.runAs (userList1[0]) { 
        
            List<Sales_Rep_Profile__c> ss = FunnelDataFactory.createSalesReplist(userList1);
            system.debug(' ss '+ss); 
            insert ss;
            
            List<Sales_Rep_Profile_Snapshot__c> spsnap = FunnelDataFactory.createSalesReplistSnapshot(ss);
            
            for(Sales_Rep_Profile_Snapshot__c s: spsnap){    
               s.Snapshot_Scheduled_Date__c = Date.today();
               system.debug(' ss[0].id '+ss[0].id);
               s.Sales_rep_profile__c = ss[0].id;
               s.YTD_Quota__c = 1000;
            }
            insert spsnap;
                     
            Test.startTest();                
            
            system.debug(' spsnap '+spsnap[0].Sales_rep_profile__c);
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/claimApi'; 
            req.params.put('phoneNumber', '9876543210');
            req.params.put('claimNumber', '111111');
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req;
            RestContext.response = res;                 
            
            SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                     'Complete',
                                                     '[{"Name": "sForceTest1"}]',
                                                     null);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            
            FunnelPostApis fp = new FunnelPostApis();
            fp.dtSnapShot = Date.today();
            fp.createQuantMetric(ss);
            
            system.assert(fp.msg != null);
            Test.stopTest();     
        }           
    
    }
    
    public class SingleRequestMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;

        public SingleRequestMock(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsString = body;
            this.bodyAsBlob = null;
            this.responseHeaders = responseHeaders;
        }

        public SingleRequestMock(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsBlob = body;
            this.bodyAsString = null;
            this.responseHeaders = responseHeaders;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(code);
            resp.setStatus(status);
            if (bodyAsBlob != null) {
                resp.setBodyAsBlob(bodyAsBlob);
            } else {
                resp.setBody(bodyAsString);
            }

            if (responseHeaders != null) {
                 for (String key : responseHeaders.keySet()) {
                resp.setHeader(key, responseHeaders.get(key));
                 }
            }
            return resp;
        }
    }
    
}