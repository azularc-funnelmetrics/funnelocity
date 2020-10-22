@isTest
public class FunnelGetApisTest {
    
    /*
    static testmethod void testAccess() {           
                               
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
            
        }
            
        FunnelGetApis fp = new FunnelGetApis();
        fp.getAccessToken();
        system.assert(fp.msg != '');
                                    
    }
    
    
    static testMethod void testGetandUpdateFSQS(){
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
         
        FunnelDataFactory.FunnelTestWrapper fw = new FunnelDataFactory.FunnelTestWrapper();
        fw.index = 1;
        fw.profileId = profileId;        
        fw.userRoleId = r.id;
        
        List<User> us = FunnelDataFactory.createUser(fw,1);
        insert us;
        
        system.runAs(us[0]){
            fw = new FunnelDataFactory.FunnelTestWrapper();
            fw.index = 1;
            fw.userId = us[0].id;
            
            Sales_Rep_Profile__c spMgr = FunnelDataFactory.createSalesRep(fw);
            spMgr.Month_1_Quota_Amount__c = 1000;
            insert spMgr;
                    
            FunnelGetApis fp = new FunnelGetApis();
            fp.getandUpdateFSQS();
        }
    
    }

    static testMethod void testGetAndUpdateQuantStats(){
        
        FunnelGetApis fp = new FunnelGetApis();
        fp.getAndUpdateQuantStats();
    
    }
    
    static testMethod void testGetAndUpdateQualStats(){
        
        FunnelGetApis fp = new FunnelGetApis();
        fp.getAndUpdateQualStats();
    
    }
    
    static testMethod void getAndUpdateFSQSTest(){
        
        Test.startTest();
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/claimApi'; 
        req.params.put('phoneNumber', '9876543210');
        req.params.put('claimNumber', '111111');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        FunnelGetApis fp = new FunnelGetApis();
        fp.getandUpdateFSQS();
        
        Test.stopTest(); 
    
    }*/
    
    /*static testMethod void getAndUpdateFSQSTest(){
        
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
        
        FunnelGetApis fp = new FunnelGetApis();
        fp.getandUpdateFSQS();
        system.assert(fp.msg != null);        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/claimApi'; 
        req.params.put('phoneNumber', '9876543210');
        req.params.put('claimNumber', '111111');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        FunnelGetApis fp = new FunnelGetApis();
        fp.getandUpdateFSQS();
        system.assert(fp.msg != null);
        Test.stopTest(); 
    
    }*/
    
    /*
    static testMethod void getAndUpdateQuantStatsTest(){
        
        Test.startTest();
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/claimApi'; 
        req.params.put('phoneNumber', '9876543210');
        req.params.put('claimNumber', '111111');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        FunnelGetApis fp = new FunnelGetApis();
        fp.getAndUpdateQuantStats();
        
        Test.stopTest(); 
    
    }
    
    static testMethod void getAndUpdateQuantStatsTest(){
        
        Test.startTest();
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/claimApi'; 
        req.params.put('phoneNumber', '9876543210');
        req.params.put('claimNumber', '111111');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        FunnelGetApis fp = new FunnelGetApis();
        fp.getAndUpdateQuantStats();
        
        Test.stopTest(); 
    
    }*/
    
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