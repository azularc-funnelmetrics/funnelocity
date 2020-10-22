@isTest
public class FunnelAssignRoleControllerTest {
    
    static testmethod void testFunnelAssignRoleController() {           
           
            
           test.startTest();
          
           DescribeFieldResult describe = Sales_Rep_Profile__c.Role__c.getDescribe();
           List<PicklistEntry> availableValues = describe.getPicklistValues();
           
           List<Certification_Rating__c> certs = new List<Certification_Rating__c>();
          
            Certification_Rating__c cr = new Certification_Rating__c();
            cr.Assessment_type__c = 'Qualitative';   
            cr.Calculation_type__c = 'Y/N';
            cr.Category__c = 'Test';            
            cr.User_Type__c = 'New';
            cr.Timing__c = 'End of month';
            cr.Weight__c = '4';
            cr.Description__c = 'Test description 1';
            cr.Roles_Enabled__c =  availableValues[0].getValue();
            certs.add(cr);
            
            cr = new Certification_Rating__c();
            cr.Assessment_type__c = 'Qualitative';   
            cr.Calculation_type__c = 'Y/N';
            cr.Category__c = 'Test';            
            cr.User_Type__c = 'New';
            cr.Timing__c = 'End of month';
            cr.Weight__c = '4';
            cr.Description__c = 'Test description 2';
            cr.Roles_Enabled__c =  availableValues[1].getValue();
            certs.add(cr);
         
            cr = new Certification_Rating__c();
            cr.Assessment_type__c = 'Qualitative';   
            cr.Calculation_type__c = 'Y/N';
            cr.Category__c = 'Test';            
            cr.User_Type__c = 'New';
            cr.Timing__c = 'End of month';
            cr.Weight__c = '4';
            cr.Description__c = 'Test description 3';
            certs.add(cr);
            
            insert certs ;
            FunnelAssignRoleController fc = new FunnelAssignRoleController();    
            fc.editCerti();
            fc.updatecerti();
            
            List<Certification_Rating__c> certs1 =[Select id from Certification_Rating__c ];
            system.assertEquals(certs1.size(),3); 
            
            
            test.stopTest();
        
                            
    }
    
    
    
    static testmethod void testNavigation() {           
        
            test.startTest();
            
            FunnelAssignRoleController fc = new FunnelAssignRoleController();                        

            
            PageReference p = fc.navigateToCertification();
            system.assert(true,p.getUrl().contains('FunnelCerificationTable'));
            p = fc.navigateToCalculator();
            system.assert(true,p.getUrl().contains('FunnelCalculator'));
            p = fc.navigateToHomePage();
            system.assert(true,p.getUrl().contains('FunnelHomePage'));
            p = fc.navigateToDashboard();
            system.assert(true,p.getUrl().contains('FunnelSalesDashboard'));
            p = fc.navigateToReportsPage();
            system.assert(true,p.getUrl().contains('FunnelReportingPage'));
            p = fc.navigateToAppSetup();
            system.assert(true,p.getUrl().contains('FunnelSalesCertification'));
            p = fc.navigateToCertificateReports();
            system.assert(true,p.getUrl().contains('FunnelCerificationReports'));
            p = fc.navigateToRatings();
            system.assert(true,p.getUrl().contains('FunnelSalesCertification'));
            p = fc.navigateToNotifications();
            system.assert(true,p.getUrl().contains('FunnelNotification'));
            p = fc.navigateToCategories();
            system.assert(true,p.getUrl().contains('navigateToCategories'));
            p = fc.navigateToAnalytics();
            system.assert(true,p.getUrl().contains('navigateToAnalytics'));
            p = fc.navigateToFunnelAnalyticQualitative();
            system.assert(true,p.getUrl().contains('navigateToFunnelAnalyticQualitative'));
            p = fc.navigateToFunnelAnalytic();
            system.assert(true,p.getUrl().contains('navigateToFunnelAnalytic'));
            
            
            test.stopTest();
         
                            
    }              
    
}