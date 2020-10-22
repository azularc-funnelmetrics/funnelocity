/*
Copyright: Funnel Metrics, LLC
*/
public with sharing class FunnelAssignRoleController{

Public Map<String,String> managemenetReports{get;set;}

public string selectedValue { get;set; }
public list<Certification_Rating__c> certificate {get;set;}
public list<certificateWrapper> cwList{get;set;}
public list<Certification_Rating__c> certificateDisplay {get;set;}
public class certificateWrapper{
    
    public Certification_Rating__c certificateRating{get;set;}
    public Boolean isSelected{ get; set; }
}

public list<certificateWrapper> certificateWrapperList {get;set;} 
public boolean crpanel{get;set;}
public boolean crDisplaypanel{get;set;}
public boolean credit{get;set;}
public static String prefix{ get{return 'FunnelMetrics__';} set; }
public Boolean readAccess = true;
   
    //Variables to store the parameters passed in the URL
    public String label1{get; set;}
    public String label2{get; set;}
    public String label3{get; set;}
    public String selectedLevel1{get; set;}
    public String selectedLevel2{get; set;}
    public String selectedLevel3{get; set;}
    
    public Boolean adminPer{get;set;}
    public Boolean isManger{get;set;}
    /* Filters */    
    
    public FunnelAssignRoleController(){
        try{    
            getRole();   
            selectedValue = defaultRole;
            system.debug('selectedValue ' +selectedValue );
            
            List<String> fldList1 = new List<String>{prefix+'Name', prefix+'Weight__c', prefix+'User_Type__c', prefix+'Timing__c', prefix+'Roles_enabled__c', prefix+'Rating_type__c', prefix+'Numeric_Weight__c', prefix+'Field_Name__c',prefix+'Display_Order__c',prefix+'Description__c',prefix+'Deactivated__c',prefix+'Category__c',prefix+'Calculation_type__c',prefix+'Assessment_type__c',prefix+'X4LevelLow__c',prefix+'X4LevelHigh__c',prefix+'X3LevelLow__c',prefix+'X3LevelHigh__c',prefix+'X2LevelLow__c',prefix+'X2LevelHigh__c',prefix+'X1LevelLow__c',prefix+'X1LevelHigh__c',prefix+'X0LevelLow__c',prefix+'X0LevelHigh__c'};
                
            Map <String, Schema.SObjectField> fieldMap1 = Schema.getGlobalDescribe().get(prefix+'Certification_Rating__c').getDescribe().fields.getMap();
            
            for(String fldName: fldList1){
                if(!fieldMap1.get(fldName).getDescribe().isAccessible()){
                    readAccess = false;
                }                           
            }
            
                    
            cr();
            crDisplay();
       
       /*filters*/
        label1 = ApexPages.currentPage().getParameters().get('labelOne');
        label2 = ApexPages.currentPage().getParameters().get('labelTwo');
        label3 = ApexPages.currentPage().getParameters().get('labelThree');
        selectedLevel1 = ApexPages.currentPage().getParameters().get('selectOne');
        selectedLevel2 = ApexPages.currentPage().getParameters().get('selectTwo');
        selectedLevel3 = ApexPages.currentPage().getParameters().get('selectThree');
        
        List<AggregateResult> asperm = [SELECT count(Id) c FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Funnel_App_Setup'];
        if((asperm != null && asperm.size() > 0 && asperm[0].get('c') != null && (Integer)asperm[0].get('c') > 0)   ){
            adminPer= true;
        }else{
            adminPer= false;
        }
        
        isManger = FunnelTriggerBatchHelper.isManager(UserInfo.getUserId());
        
        /*
        managemenetReports = new Map<String,String>();
        
        User u = [SELECT Name, UserPreferencesLightningExperiencePreferred FROM User WHERE id = :UserInfo.getUserId()];
        
        List<String> dashList = new List<String>();
        dashList.add('mXaDybYGcSDujlyIRRJQxUrUEqXiFe');
        
        managemenetReports = FunnelNavigationHelper.fetchDashboards(dashList,u);*/
        
    }
        catch(Exception ex){
            System.debug('Exception occured: '+ ex+' Line number: '+ex.getLineNumber());
            FunnelTriggerBatchHelper.sendErrorMail(' FunnelAssignRoleController '+ex.getMessage()+' '+ex.getStackTraceString()+ ' line number: '+ex.getLineNumber()+' cause '+ex.getCause());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        } 
    }
    string defaultRole;
    Map<Id,Certification_Rating__c> mapCerts = new Map<Id,Certification_Rating__c>();
    
     public List<SelectOption>  getRole() {
       
           List<SelectOption> Options = new List<SelectOption>();
           
           //Schema.DescribeFieldResult statusFieldDescription = FunnelMetrics__Certification_Rating__c.Roles_enabled__c.getDescribe();
           Schema.DescribeFieldResult statusFieldDescription = Certification_Rating__c.Roles_enabled__c.getDescribe();
         
           for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())
           {
               Options.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
           }
           defaultRole= string.valueOf(options[0].getvalue());
           system.debug('defaultRole---' +defaultRole);
           return Options ;
    }
           
    public void cr(){
       
        cwList = new list<certificateWrapper>();
        certificate = new list<Certification_Rating__c>();
        if(readAccess){    
        
             List<Certification_Rating__c> cc = [Select id, Name,User_Type__c,Roles_enabled__c,Weight__c,Timing__c,Description__c,Calculation_type__c,Assessment_type__c, Category__c from Certification_Rating__c WHERE Deactivated__c = false AND SRP_Field_Name__c !=null  ORDER BY Category__c DESC,Display_Order__c ASC, CreatedDate DESC];   
             certificate.addAll(cc);
             cc.clear();
             
             cc = [Select id, Name,User_Type__c,Roles_enabled__c,Weight__c,Timing__c,Description__c,Calculation_type__c,Assessment_type__c, Category__c from Certification_Rating__c WHERE Deactivated__c = false  AND SRP_Field_Name__c =null  ORDER BY Category__c DESC,Display_Order__c ASC, CreatedDate DESC];   
             certificate.addAll(cc);
             
            for(Certification_Rating__c c : certificate ){
            system.debug('c--'+c);
            Set<String> rolesSet = new Set<String>();
            
                if(c.Roles_enabled__c != null){
                    List<String> rolesList = c.Roles_enabled__c.split(';');
                    for(String r:rolesList){
                        rolesSet.add(r);
                    }
                }
            certificateWrapper cW = new certificateWrapper();
            //cw.certificateRating  = new Certification_Rating__c();
            if( (c.Roles_enabled__c != null  && selectedValue != null && rolesSet.contains(selectedValue)) || c.Assessment_type__c== 'Quantitative' ){
                cW.certificateRating  = c;
                cW.isSelected = true;
            }else{
                cW.certificateRating= c;
                cW.isSelected = false;
            }
            cwList.add(cw);
            mapCerts.put(c.id,c);
        }
            crDisplay();
        }
    }
   
    public void crDisplay(){
       
       if(readAccess){ 
        certificateDisplay = new List<Certification_Rating__c> ();
        List<Certification_Rating__c> cc=[Select id, Name,User_Type__c ,Roles_enabled__c,Weight__c,Timing__c,Description__c,Calculation_type__c,Assessment_type__c, Category__c from Certification_Rating__c   where  ( Roles_enabled__c includes (:selectedValue) OR Assessment_type__c='Quantitative') AND Deactivated__c = false AND SRP_Field_Name__c !=null ORDER BY Category__c DESC,Display_Order__c ASC, CreatedDate DESC];
        certificateDisplay.addAll(cc); 
        cc.clear();
        cc= [Select id, Name,User_Type__c ,Roles_enabled__c,Weight__c,Timing__c,Description__c,Calculation_type__c,Assessment_type__c, Category__c from Certification_Rating__c   where  ( Roles_enabled__c includes (:selectedValue) OR Assessment_type__c='Quantitative') AND Deactivated__c = false AND SRP_Field_Name__c =null ORDER BY Category__c DESC,Display_Order__c ASC, CreatedDate DESC  ];
        certificateDisplay.addAll(cc); 

        if(certificateDisplay.size() > 0 && credit != true){
            crDisplaypanel = true;
            crpanel = false;
            system.debug('DISPLAY__');
        }else{
            crDisplaypanel = false;
            crpanel = true;
            system.debug('EDIT__');
        }
       }
    }      
           
    public void editCerti(){
        crDisplaypanel = false;
        crpanel = true;
        credit = true;
    }  

    public void updatecerti(){
        
        try{
            
            list<Certification_Rating__c> updateCertificate = new list<Certification_Rating__c>();
            
            List<String> fldList1 = new List<String>{prefix+'Roles_enabled__c'};
                
            Boolean updateAccess = true;
                        
            Map <String, Schema.SObjectField> fieldMap1 = Schema.getGlobalDescribe().get(prefix+'Certification_Rating__c').getDescribe().fields.getMap();
            
            for(String fldName: fldList1){
                if(!fieldMap1.get(fldName).getDescribe().isUpdateable()){
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
                  updateAccess = false;
                }                           
            }
            
            if(updateAccess){
            
                for(certificateWrapper c : cwList){
                   
                    Certification_Rating__c updateCerti;
                    
                    updateCerti = mapCerts.get(c.certificateRating.id);
                    
                    if(c.isSelected){
                        if(!checkcontain(c.certificateRating.Roles_enabled__c,selectedValue)){
                            if(c.certificateRating.Roles_enabled__c != null){
                                c.certificateRating.Roles_enabled__c = c.certificateRating.Roles_enabled__c+';'+selectedValue ; 
                            }else{
                                c.certificateRating.Roles_enabled__c = selectedValue ; 
                            }
                            
                        }
                    }else{
                        if(checkcontain(c.certificateRating.Roles_enabled__c,selectedValue)){
                           
                            c.certificateRating.Roles_enabled__c  = c.certificateRating.Roles_enabled__c.replaceAll(';?'+selectedValue +'?','');
                        }
                    }
                    //updateCerti.id=c.certificateRating.id;
                    updateCerti.Roles_enabled__c  =c.certificateRating.Roles_enabled__c ;
                    updateCertificate.add(updateCerti); 
                }
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
            }
            
            system.debug('updateCertificate ---'+updateCertificate );
           
       if(Schema.getGlobalDescribe().get(prefix+'Certification_Rating__c').getDescribe().isUpdateable()){ 
               update updateCertificate ;
           }
           else{
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
           }
           
           // crDisplaypanel = true;
           // crpanel = false;
            credit = false;
            cr();
            ansCreDel();
        }
        catch(Exception ex){
            System.debug('Exception occured: '+ ex+' Line number: '+ex.getLineNumber());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            FunnelTriggerBatchHelper.sendErrorMail(' FunnelAssignRoleController '+ex.getMessage()+' '+ex.getStackTraceString()+ ' line number: '+ex.getLineNumber()+' cause '+ex.getCause());
        } 
    }
    
    public void ansCreDel(){
        List<Sales_Rep_Profile__c> srplist = [Select id from Sales_Rep_Profile__c where Active__c = true];
        if(srplist != null && srplist.size() > 0){
            Set<Id> profsForAnsCreation = new Set<Id>();
            for(Sales_Rep_Profile__c s : srplist ){
                profsForAnsCreation.add(s.id);
            }
             FunnelCreateCertAnswers_Controller.deleteAndCreateCertAnswers(profsForAnsCreation,profsForAnsCreation);    
        }
    
    }
    
    public boolean checkcontain(string ro, string cp){
        list<string> str = new list<string>();
        boolean f ;
        system.debug('ro---'+ro);
        if(ro != null){
           str =  ro.split(';');
            if(str.contains(cp)){
                f = true;
            }else{
                f= false;
            } 
        }else{
                f= false;
        }
        
        return f;
    }
    
    /*Navigation*/
    //Method called on clicking on View Scoring Dashboard
    public PageReference navigateToCertification(){
        
        return FunnelNavigationHelper.navigateToCertification(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    
    }
    
    //Method called on clicking on View Scoring Dashboard
    public PageReference navigateToDashboard(){
        
        return FunnelNavigationHelper.navigateToDashboard(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    
    }
    
    //Method called on clicking Performance Dashboard on header
    public PageReference navigateToCalculator(){
        
        return FunnelNavigationHelper.navigateToCalculator(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
        
    }
    
    //Method called on clicking Home on header    
    public PageReference navigateToHomePage(){
        
       return FunnelNavigationHelper.navigateToHomePage(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
        
    }
    
    //Method called on clicking Reporting on header    
    public PageReference navigateToReportsPage(){
        
        return FunnelNavigationHelper.navigateToReportsPage(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
        
    }
    
    //Method called on clicking App Setup on header    
    public PageReference navigateToAppSetup(){
        
        return FunnelNavigationHelper.navigateToAppSetupPage(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
        
    }
    public PageReference navigateToCertificateReports(){
        
        return FunnelNavigationHelper.navigateToCertificateReports(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
        
    } 
    
    public PageReference navigateToRatings(){
        
        return FunnelNavigationHelper.navigateToCreateEditRatings(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
        
    }  
    public PageReference navigateToCustomMetric(){
        
        return FunnelNavigationHelper.navigateToCustomMetric(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);    
    
    }
    public PageReference navigateToNotifications(){
        
        return FunnelNavigationHelper.navigateToNotifications(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    }
    
    public PageReference navigateToCategories(){
        
        return FunnelNavigationHelper.navigateToCategories(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    }
    
    public PageReference navigateToAnalytics(){
        
        return FunnelNavigationHelper.navigateToAnalytics(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    
    }
    
    public PageReference navigateToFunnelAnalyticQualitative(){
        
        return FunnelNavigationHelper.navigateToFunnelAnalyticQualitative(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    
    }
    
    public PageReference navigateToFunnelAnalytic(){
        
        return FunnelNavigationHelper.navigateToFunnelAnalytic(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    
    }
    
     public PageReference navigateToFunnelEvaluationGuidelines(){
        
        return FunnelNavigationHelper.navigateToFunnelEvaluationGuidelines(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    
    }
    public PageReference navigateToAnnualizationDashboard(){
        
        return FunnelNavigationHelper.navigateToFunnelAnnualizationDashboard(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    
    }
     public PageReference navigateToFunnelSetup(){
        
        return FunnelNavigationHelper.navigateToFunnelSetup(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    
    }
    
    public PageReference navigateToFunnelReviewGoals(){
        
        return FunnelNavigationHelper.navigateToFunnelReviewGoals(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    
    }
    public PageReference navigateToFunnelManagerUpdate(){
        
        return FunnelNavigationHelper.navigateToFunnelManagerUpdate(label1,label2,label3,selectedLevel1,selectedLevel2,selectedLevel3);
    
    }
    /*Navigation*/
    

}