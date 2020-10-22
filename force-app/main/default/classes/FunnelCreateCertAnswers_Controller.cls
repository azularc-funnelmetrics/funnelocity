/*
Copyright: Funnel Metrics, LLC
*/
public with sharing class FunnelCreateCertAnswers_Controller{
    
    public static void deleteAndCreateCertAnswers(Set<Id> deleteList, Set<Id> createList){        
        
        if(deleteList != null && deleteList.size() > 0){
        
            List<Certification__c> deleteCerts = [SELECT id FROM Certification__c WHERE Sales_Rep_Profile__c IN : deleteList];
            
            //List<Certification_Answer__c> ansList = [SELECT Id, Certifcation__c, Rating_Score__c FROM Certification_Answer__c WHERE Rating_Score__c = null AND Certifcation_Rating__r.Assessment_type__c='Qualitative' AND Certifcation__c IN :deleteCerts];        
            List<Certification_Answer__c> ansList = [SELECT Id, Certifcation__c, Rating_Score__c FROM Certification_Answer__c WHERE Due_Date__c >= Today AND Certifcation_Rating__r.Assessment_type__c='Qualitative' AND Certifcation__c IN :deleteCerts];
            system.debug(' deleted ans '+ansList);
            
            //if(Schema.sObjectType.Certification_Answer__c.isDeletable()){ 
                DELETE ansList;
            //}
        }
        
        List<Certification__c> certs = [SELECT id, Sales_Rep_Profile__r.Rep_Staus__c, Sales_Rep_Profile__r.Role__c FROM Certification__c WHERE Sales_Rep_Profile__c IN : createList];
        
        Integer noOfDays = Date.daysInMonth(Date.today().year(),Date.today().month());
        
        Notification_Setting__c ns = [SELECT Id, Enable_Notifications__c, Advance_Reminders__c, Notification_Frequency__c, Escalation__c FROM Notification_Setting__c LIMIT 1];
        
        List<Certification_Answer__c> createAnsRecords = new List<Certification_Answer__c>();

        //Creating certification answers for monthly ratings
        List<Certification_Rating__c> certiRating = [SELECT Id, X0LevelHigh__c, X0LevelLow__c,X1LevelHigh__c,X1LevelLow__c,X2LevelHigh__c,X2LevelLow__c,
                                                 X3LevelHigh__c,X3LevelLow__c,X4LevelHigh__c,X4LevelLow__c,Deactivated__c,Roles_enabled__c,Numeric_Weight__c,
                                                 Field_Name__c,name,User_Type__c  FROM Certification_Rating__c where Assessment_type__c='Qualitative' 
                                                 AND Deactivated__c = false And Timing__c='End of month' ];        
            
        if(certiRating != null && certiRating.size() > 0 ){                            
              
              for(Certification__c s: certs){
                  system.debug(' s '+s);                  
                  for(Certification_Rating__c cr : certiRating){
                      
                      system.debug(' cr '+cr); 
                      
                      Set<String> rolesSet = new Set<String>();
                    
                      if(cr.Roles_enabled__c != null){
                            List<String> rolesList = cr.Roles_enabled__c.split(';');
                            for(String r:rolesList){
                                rolesSet.add(r);
                            }
                      }
                                            
                      if(cr.Roles_enabled__c != null  && (s.Sales_Rep_Profile__r.Rep_Staus__c == cr.User_Type__c  || cr.User_Type__c =='Both') && s.Sales_Rep_Profile__r.Role__c != null && rolesSet.contains(s.Sales_Rep_Profile__r.Role__c)){
                          
                          system.debug(' condition matched ');
                          
                          Certification_Answer__c ca= new Certification_Answer__c();
                          ca.Name = cr.name;
                          ca.Certifcation__c = s.id;
                          ca.Certifcation_Rating__c = cr.id;
                          ca.Sales_Rep_Profile__c=s.Sales_Rep_Profile__c;                                                    

                          ca.Due_Date__c = Date.newInstance(Date.today().year(),Date.today().month(),noOfDays);
                          ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-7);
                          
                          if(ns.Enable_Notifications__c ){
                          
                                if(ns.Advance_Reminders__c == '1 day prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-1);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-1);
                                }
                                else if(ns.Advance_Reminders__c == '3 days prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-3);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-3);
                                }
                                else if(ns.Advance_Reminders__c == '7 days prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-7);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-7);
                                }
                                
                                if(ns.Escalation__c == '2 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 2;
                                }
                                else if(ns.Escalation__c == '7 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 7;
                                }
                                else if(ns.Escalation__c == '10 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 10;
                                }
                          }
                    
                          createAnsRecords.add(ca);                                          
                          
                      }
                                                                
                  }
                                    
              }
              
        } 
        
        //Creating certification answers for quarterly ratings
        /*DateTime quarterEnd = FunnelCalculationHelper.getQuarterEndDate(Date.today());
        system.debug(' quart end date '+quarterEnd);    
        Date quarterEndDate = Date.newInstance(quarterEnd.yearGmt(), quarterEnd.monthGmt(),quarterEnd.dayGmt());
        
        DateTime quarStartDateTime = FunnelCalculationHelper.getQuarterStartDate();
        quarStartDateTime = quarStartDateTime.addMonths(2);
                        
        noOfDays = Date.daysInMonth(quarStartDateTime.year(),quarStartDateTime.month());
                       
        Date dueDate = Date.newInstance(quarStartDateTime.year(),quarStartDateTime.month(),noOfDays);*/
        
        Date dueDate = FunnelCalculationHelper.getQuarterEndInDateFormat(Date.today());
           
        certiRating = [SELECT Id, X0LevelHigh__c, X0LevelLow__c,X1LevelHigh__c,X1LevelLow__c,X2LevelHigh__c,X2LevelLow__c,
                         X3LevelHigh__c,X3LevelLow__c,X4LevelHigh__c,X4LevelLow__c,Deactivated__c,Roles_enabled__c,Numeric_Weight__c,
                         Field_Name__c,name,User_Type__c  FROM Certification_Rating__c where Assessment_type__c='Qualitative' 
                         AND Deactivated__c = false And Timing__c='End of quarter' ];        
            
        if(certiRating != null && certiRating.size() > 0 ){
            
              for(Certification__c s: certs){
                                    
                  for(Certification_Rating__c cr : certiRating){                  
                      
                      Set<String> rolesSet = new Set<String>();
                    
                      if(cr.Roles_enabled__c != null){
                            List<String> rolesList = cr.Roles_enabled__c.split(';');
                            for(String r:rolesList){
                                rolesSet.add(r);
                            }
                      }
                                            
                      if(cr.Roles_enabled__c != null  && (s.Sales_Rep_Profile__r.Rep_Staus__c == cr.User_Type__c  || cr.User_Type__c =='Both') && s.Sales_Rep_Profile__r.Role__c != null && rolesSet.contains(s.Sales_Rep_Profile__r.Role__c)){                      
                          
                          system.debug(' condition matched ');
                          
                          Certification_Answer__c ca= new Certification_Answer__c();
                          ca.Name = cr.name;
                          ca.Certifcation__c = s.id;
                          ca.Certifcation_Rating__c = cr.id;
                          ca.Sales_Rep_Profile__c=s.Sales_Rep_Profile__c;                                                    

                          ca.Due_Date__c = dueDate;
                          ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-7);
                          
                          if(ns.Enable_Notifications__c ){
                          
                                if(ns.Advance_Reminders__c == '1 day prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-1);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-1);
                                }
                                else if(ns.Advance_Reminders__c == '3 days prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-3);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-3);
                                }
                                else if(ns.Advance_Reminders__c == '7 days prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-7);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-7);
                                }
                                
                                if(ns.Escalation__c == '2 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 2;
                                }
                                else if(ns.Escalation__c == '7 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 7;
                                }
                                else if(ns.Escalation__c == '10 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 10;
                                }
                          }
                    
                          createAnsRecords.add(ca);                                          
                          
                      }
                                                                
                  }
                                    
              }
                            
        } 
        
        //Creating certification answers for bi-annual ratings
        
        DateTime Fyear = FunnelTriggerBatchHelper.getFiscalYearDate('Current_Year');
                
        DateTime month6Start = Fyear.addMonths(5);
        
        noOfDays = Date.daysInMonth(month6Start.yearGMT(),month6Start.monthGMT());
        
        dueDate = Date.newInstance(month6Start.yearGMT(),month6Start.monthGMT(),noOfDays);
        
        if(Date.today() > dueDate){
            dueDate = dueDate.addMonths(6);
            noOfDays = Date.daysInMonth(dueDate.year(),dueDate.month());
            dueDate = Date.newInstance(dueDate.year(),dueDate.month(),noOfDays);
        }
                
        certiRating = [SELECT Id, X0LevelHigh__c, X0LevelLow__c,X1LevelHigh__c,X1LevelLow__c,X2LevelHigh__c,X2LevelLow__c,
                         X3LevelHigh__c,X3LevelLow__c,X4LevelHigh__c,X4LevelLow__c,Deactivated__c,Roles_enabled__c,Numeric_Weight__c,
                         Field_Name__c,name,User_Type__c  FROM Certification_Rating__c where Assessment_type__c='Qualitative' 
                         AND Deactivated__c = false And Timing__c='Bi-annual'];        
            
        if(certiRating != null && certiRating.size() > 0 ){
            
              for(Certification__c s: certs){
                                    
                  for(Certification_Rating__c cr : certiRating){                  
                      
                      Set<String> rolesSet = new Set<String>();
                    
                      if(cr.Roles_enabled__c != null){
                            List<String> rolesList = cr.Roles_enabled__c.split(';');
                            for(String r:rolesList){
                                rolesSet.add(r);
                            }
                      }
                                            
                      if(cr.Roles_enabled__c != null  && (s.Sales_Rep_Profile__r.Rep_Staus__c == cr.User_Type__c  || cr.User_Type__c =='Both') && s.Sales_Rep_Profile__r.Role__c != null && rolesSet.contains(s.Sales_Rep_Profile__r.Role__c)){                      
                      
                          system.debug(' condition matched ');
                          
                          Certification_Answer__c ca= new Certification_Answer__c();
                          ca.Name = cr.name;
                          ca.Certifcation__c = s.id;
                          ca.Certifcation_Rating__c = cr.id;
                          ca.Sales_Rep_Profile__c=s.Sales_Rep_Profile__c;                                                    

                          ca.Due_Date__c = dueDate;
                          ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-7);
                          
                          if(ns.Enable_Notifications__c ){
                          
                                if(ns.Advance_Reminders__c == '1 day prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-1);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-1);
                                }
                                else if(ns.Advance_Reminders__c == '3 days prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-3);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-3);
                                }
                                else if(ns.Advance_Reminders__c == '7 days prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-7);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-7);
                                }
                                
                                if(ns.Escalation__c == '2 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 2;
                                }
                                else if(ns.Escalation__c == '7 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 7;
                                }
                                else if(ns.Escalation__c == '10 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 10;
                                }
                          }
                    
                          createAnsRecords.add(ca);                                          
                          
                      }
                                                                
                  }
                                    
              }
                            
        }
        
        //Creating certification answers for annual ratings
        
        Fyear = FunnelTriggerBatchHelper.getFiscalYearDate('Current_Year');
        DateTime month12Start = Fyear.addMonths(11);
        
        noOfDays = Date.daysInMonth(month12Start.yearGMT(),month12Start.monthGMT());
        
        dueDate = Date.newInstance(month12Start.yearGMT(),month12Start.monthGMT(),noOfDays);
                
        certiRating = [SELECT Id, X0LevelHigh__c, X0LevelLow__c,X1LevelHigh__c,X1LevelLow__c,X2LevelHigh__c,X2LevelLow__c,
                         X3LevelHigh__c,X3LevelLow__c,X4LevelHigh__c,X4LevelLow__c,Deactivated__c,Roles_enabled__c,Numeric_Weight__c,
                         Field_Name__c,name,User_Type__c  FROM Certification_Rating__c where Assessment_type__c='Qualitative' 
                         AND Deactivated__c = false And Timing__c='Annual'];        
            
        if(certiRating != null && certiRating.size() > 0 ){
            
              for(Certification__c s: certs){
                                    
                  for(Certification_Rating__c cr : certiRating){                  
                      
                      Set<String> rolesSet = new Set<String>();
                    
                      if(cr.Roles_enabled__c != null){
                            List<String> rolesList = cr.Roles_enabled__c.split(';');
                            for(String r:rolesList){
                                rolesSet.add(r);
                            }
                      }
                                            
                      if(cr.Roles_enabled__c != null  && (s.Sales_Rep_Profile__r.Rep_Staus__c == cr.User_Type__c  || cr.User_Type__c =='Both') && s.Sales_Rep_Profile__r.Role__c != null && rolesSet.contains(s.Sales_Rep_Profile__r.Role__c)){                      
                          
                          system.debug(' condition matched ');
                          
                          Certification_Answer__c ca= new Certification_Answer__c();
                          ca.Name = cr.name;
                          ca.Certifcation__c = s.id;
                          ca.Certifcation_Rating__c = cr.id;
                          ca.Sales_Rep_Profile__c=s.Sales_Rep_Profile__c;                                                    

                          ca.Due_Date__c = dueDate;
                          ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-7);
                          
                          if(ns.Enable_Notifications__c ){
                          
                                if(ns.Advance_Reminders__c == '1 day prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-1);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-1);
                                }
                                else if(ns.Advance_Reminders__c == '3 days prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-3);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-3);
                                }
                                else if(ns.Advance_Reminders__c == '7 days prior'){
                                    ca.Manager_Email_Date__c = ca.Due_Date__c.addDays(-7);
                                    ca.Rating_Start_Date__c = ca.Due_Date__c.addDays(-7);
                                }
                                
                                if(ns.Escalation__c == '2 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 2;
                                }
                                else if(ns.Escalation__c == '7 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 7;
                                }
                                else if(ns.Escalation__c == '10 days overdue'){
                                    ca.Escalation_Email_Date__c = ca.Due_Date__c + 10;
                                }
                          }
                    
                          createAnsRecords.add(ca);                                          
                          
                      }
                                                                
                  }
                                    
              }
                            
        }
        
        certs[0].Total_Quantitative_Weight__c = createAnsRecords.size();
        update certs[0];
        system.debug(' ans records created '+createAnsRecords);
        insert createAnsRecords;
    }
    
    public static void createCerts(Set<Id> createCertList){
        
        List<Certification__c> certs = [SELECT id, Sales_Rep_Profile__c FROM Certification__c WHERE Sales_Rep_Profile__c IN :createCertList AND Sales_rep_profile__r.Active__c = TRUE];
        
        List<Sales_Rep_Profile__c> sreps = [SELECT id, name FROM Sales_Rep_Profile__c WHERE id IN :createCertList AND Active__c = TRUE];
        
        Map<id,Sales_Rep_Profile__c> srMap = new Map<id,Sales_Rep_Profile__c> ();
        
        for(Sales_Rep_Profile__c s: sreps){
            srMap.put(s.id,s);    
        }
        
        for(Certification__c c: certs){
            if(createCertList != null && createCertList.contains(c.Sales_Rep_Profile__c)){
                createCertList.remove(c.Sales_Rep_Profile__c);
            }    
        } 
        
        List<Certification__c> certsLi = new List<Certification__c>();
        
        for(Id i : createCertList){
            Certification__c c = new Certification__c();
            c.name = srMap.get(i).name + ' Cert';
            c.Sales_Rep_Profile__c = i;
            certsLi.add(c);
        }
        
        insert certsLi;      
    }    
}