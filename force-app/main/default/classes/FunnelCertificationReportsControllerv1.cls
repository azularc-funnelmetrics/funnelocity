/*
Copyright: Funnel Metrics, LLC
*/
public with sharing class FunnelCertificationReportsControllerv1{

    public string appsetup {get;set;}
    public FunnelFilterWrapper fw {get; set;}
    public list<Certification__c> certiTable{get;set;}
    public Set<Id> certiTableId;
    public List<String> chartLabels {get;set;}  
    public List<Decimal> chartData {get;set;}
    public List<Decimal> char2qualitative{get;set;}
    public List<Decimal> char2quantitative{get;set;}
    
    public List<Decimal> monthsValues{get;set;}
    public List<Decimal> monthsRevenue{get;set;}
    public List<Decimal> monthsValuesqualitative{get;set;}
    public List<String> months{get;set;}
    
    public List<String> chartLabelsbelow {get;set;}  
    public List<Decimal> chartDatabelow {get;set;}
    
    public List<Decimal> char2qualitativebelow{get;set;}
    public List<Decimal> char2quantitativebelow{get;set;}
    
    public List<Decimal> chartrevenue {get;set;}
    public List<Decimal> chartDataQuota{get;set;}
    
    public List<Decimal> chartrevenuebelow {get;set;}
    public List<Decimal> chartDataQuotabelow{get;set;}
    
    Public Map<String,String> managemenetReports{get;set;}
    
    private id cllookupid;
    /* Filters */
            
    //Variable that indicates if logged in user is a manager
    private Boolean mgr;
    
    public Boolean isMgr{
        get{
            return mgr;
        }
        set{
            mgr = value;
        }
    }
    
    
    //Variable that indicates reset button has been clicked
    public boolean isReset {get; set;}
    
    
    //Variables to store the parameters passed in the URL
    public String label1 {get; set;}
    public String label2 {get; set;}
    public String label3 {get; set;}
    public String selectedLevel1 {get; set;}
    public String selectedLevel2 {get; set;}
    public String selectedLevel3 {get; set;}
    
    public String defaultBreadCrumb{get; set;}
    /* Filters */        
    
    public FunnelCertificationReportsControllerv1(){
        try{    
            List<AggregateResult> asperm = [SELECT count(Id) c FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Funnel_App_Setup'];
            
            if(asperm != null && asperm.size() > 0 && asperm[0].get('c') != null && (Integer)asperm[0].get('c') > 0 ){
                appsetup ='';
            }else{
                appsetup ='none';
            }
            
            label1 = ApexPages.currentPage().getParameters().get('labelOne');
            label2 = ApexPages.currentPage().getParameters().get('labelTwo');
            label3 = ApexPages.currentPage().getParameters().get('labelThree');
            selectedLevel1 = ApexPages.currentPage().getParameters().get('selectOne');
            selectedLevel2 = ApexPages.currentPage().getParameters().get('selectTwo');
            selectedLevel3 = ApexPages.currentPage().getParameters().get('selectThree');  
            
            fw = new FunnelFilterWrapper();
            
            fw.userId = UserInfo.getUserId();
            
            FunnelFilterHelper.populateFilters(fw, 
            label1, label2, label3,
            selectedLevel1, selectedLevel2, selectedLevel3);
            
            system.debug('fw.selectedLevelThree '+fw.selectedLevelThree);
                    
            showUpdated();
            
            defaultBreadCrumb = FunnelFilterHelper.fetchDefaultBreadCrumbs(fw);     
            
            managemenetReports = new Map<String,String>();
            
            String currentTheme = UserInfo.getUiThemeDisplayed();
            
            List<String> dashList = new List<String>();
            Map<String,String> dashMap = new Map<String,String>();
            
            Dashboard_detail__mdt [] dl = new List<Dashboard_detail__mdt>();
            
            if (currentTheme == 'Theme2' || currentTheme == 'Theme3'){
                dl = [SELECT Display_name__c, Classic_ID__c FROM Dashboard_detail__mdt];
                
                for(Dashboard_detail__mdt d: dl){
                    dashList.add(d.Classic_ID__c);
                    dashMap.put(d.Classic_ID__c,d.Display_name__c);
                }
                currentTheme = 'classic';
            }
            else{
                dl = [SELECT Display_name__c, Lightning_ID__c FROM Dashboard_detail__mdt];
                
                for(Dashboard_detail__mdt d: dl){
                    dashList.add(d.Lightning_ID__c);
                    dashMap.put(d.Lightning_ID__c,d.Display_name__c);
                }
                currentTheme = 'lightning';
            }
            
            
            User u = [SELECT Name, UserPreferencesLightningExperiencePreferred FROM User WHERE id = :UserInfo.getUserId()];
            
            /*
            List<String> dashList = new List<String>();
            dashList.add('hSsMVyWdIxAjXYklsYKDdYCBfKXsJR');
            dashList.add('mXaDybYGcSDujlyIRRJQxUrUEqXiFe');
            //dashList.add('DxuhZAivHpkABAymYfptJXEOTpVOlT');
            //dashList.add('fmgXUMIJqlqAzJxuBeEBtVnJJfjwXk');
            dashList.add('huqQNOgZEmSiCoJxckvWjoQyaiYHmA');
            
            dashList.add('tjEAwmwyUQmzXgsbZRJKxLxUkyBApY');
            dashList.add('qUTiJdvGHTNptSLSTEbJAcnzwuRNpS');                                    
            
            dashList.add('ctZiIkriORyfFycuUkukDpmIqdwJgd');*/
    
                                            
            managemenetReports = FunnelNavigationHelper.fetchDashboardsv1(dashList,dashMap,currentTheme);
            
            List<Report> reportList = [SELECT id, name,developerName FROM Report WHERE developerName IN ('Cross_Filter_Report','Cert_Ratings_By_Rep1','Average_Sales_Cycle_76Q',
                                      'Cert_Answer_Report','Cert_By_Sales_Profile_Matrix','Cert_Rating_Overall_with_Detail_Filter_jma','New_Certification_Ratings_Report_hDZ',
                                      'Certs_by_Sales_Profile_by_Month','New_Report_W6I1','Lead_to_Oppty_Conversion_Rate_Zzi','Meetings_per_Month_6NA',
                                      'New_Report_2pD','Cert_Ratings_By_Rep','Monthly_Quota_dQh','New_Report_W6I111','New_Report_W6I11','New_Certifications_with_levels_Report_u3','New_Report_xMg',
                                      'Sales_Rep_Certification_by_Level_and_Rat','New_Report_W6I','Lead_Conversion_Rate_oo6','Lead_Conversion_Rate_oo61','New_Report_2pD2','New_Report_2pD1',
                                      'New_Report_oOd11','New_Report_oOd','New_Report_oOd1','New_Report_oOd132','New_Report_oOd13','New_Report_oOd131') ];
            
            //List<Dashboard> dashList = [SELECT Id, DeveloperName FROM Dashboard WHERE DeveloperName IN ('hSsMVyWdIxAjXYklsYKDdYCBfKXsJR','SqfapLezuGsRjRKZTlCuqXJVCBhnGw')];                
            
            if(u.UserPreferencesLightningExperiencePreferred  == true){
                /*for(Dashboard r : dashList){
                    managemenetReports.put(r.developerName,'/one/one.app#/alohaRedirect/'+(String)r.id);
                }*/
                
                for(Report r : reportList){
                    managemenetReports.put(r.developerName,'/one/one.app#/alohaRedirect/'+(String)r.id);
                }
            }else{
            
                /*for(Dashboard r : dashList){
                    managemenetReports.put(r.developerName,'/'+(String)r.id);
                }*/
                
                for(Report r : reportList){
                    managemenetReports.put(r.developerName,'/'+(String)r.id);
                }
            
            }
            List<String> reportName = new List<String>();
            reportName.add('Cross_Filter_Report');
            reportName.add('Cert_Ratings_By_Rep1');
            reportName.add('Average_Sales_Cycle_76Q');
            reportName.add('Cert_Answer_Report');
            reportName.add('Cert_By_Sales_Profile_Matrix');
            reportName.add('Cert_Rating_Overall_with_Detail_Filter_jma');
            reportName.add('New_Certification_Ratings_Report_hDZ');
            reportName.add('Certs_by_Sales_Profile_by_Month');
            reportName.add('New_Report_W6I1');
            reportName.add('Lead_to_Oppty_Conversion_Rate_Zzi');
            reportName.add('Meetings_per_Month_6NA');
            reportName.add('New_Report_2pD');
            reportName.add('Cert_Ratings_By_Rep');
            reportName.add('Monthly_Quota_dQh');
            reportName.add('New_Report_W6I111');
            reportName.add('New_Report_W6I11');
            reportName.add('New_Certifications_with_levels_Report_u3');
            reportName.add('New_Report_xMg');
            reportName.add('Sales_Rep_Certification_by_Level_and_Rat');
            reportName.add('New_Report_W6I');
            reportName.add('Lead_Conversion_Rate_oo6');
            reportName.add('Lead_Conversion_Rate_oo61');
            reportName.add('New_Report_2pD2');
            reportName.add('New_Report_2pD1');  
            reportName.add('hSsMVyWdIxAjXYklsYKDdYCBfKXsJR');
            reportName.add('SqfapLezuGsRjRKZTlCuqXJVCBhnGw'); 
            reportName.add('New_Report_oOd132'); 
            reportName.add('New_Report_oOd13');
            reportName.add('New_Report_oOd131'); 
                  
            
            for(String s : reportName ){
                if(!managemenetReports.containsKey(s)){
                managemenetReports.put(s,'FunnelNoReport');
                }
            }  
        }
        catch(Exception ex){
            System.debug('Exception occured: '+ ex+' Line number: '+ex.getLineNumber());
            FunnelTriggerBatchHelper.sendErrorMail(' FunnelCertificationReportsController '+ex.getMessage()+' '+ex.getStackTraceString()+ ' line number: '+ex.getLineNumber()+' cause '+ex.getCause());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }             
    }
    
    
    
    //Action method when level one is changed
    public void levelOneAction(){
        FunnelFilterHelper.levelOneAction(fw);
        defaultBreadCrumb = FunnelFilterHelper.fetchDefaultBreadCrumbs(fw);
    }
    
    //Action method when level two is changed
    public void levelTwoAction(){
        FunnelFilterHelper.levelTwoAction(fw);
        system.debug(' fw.labelOne '+fw.labelOne);
        system.debug(' fw.labelTwo '+fw.labelTwo);
        system.debug(' fw.labelThree '+fw.labelThree);
        
        system.debug(' fw.selectedLevelOne '+fw.selectedLevelOne );
        system.debug(' fw.selectedLevelTwo '+fw.selectedLevelTwo );
        system.debug(' fw.selectedLevelThree '+fw.selectedLevelThree );
    }
    
    /*Filters*/
    //Method called when reset button is selected
    public PageReference reset(){
       
        return FunnelNavigationHelper.navigateToCertificateReports('','','','','','');
            
    }
    /*Filters*/                  
    /*Aggregation*/
   
     
   
    /*Aggregation*/
     
    
    /*Navigation*/
    //Method called on clicking on View Scoring Dashboard
    public PageReference navigateToDashboard(){
        
        return FunnelNavigationHelper.navigateToDashboard(fw.labelOne,fw.labelTwo,fw.labelThree,fw.selectedLevelOne,fw.selectedLevelTwo,fw.selectedLevelThree);
    
    }
    
    public PageReference navigateToCalculator(){
        
        return FunnelNavigationHelper.navigateToCalculator(fw.labelOne,fw.labelTwo,fw.labelThree,fw.selectedLevelOne,fw.selectedLevelTwo,fw.selectedLevelThree);
        
    }
    
    public PageReference navigateToHomePage(){
        
        return FunnelNavigationHelper.navigateToHomePage();
        
    }
    
    //Method called on clicking Reporting on header    
    public PageReference navigateToReportsPage(){
        
        return FunnelNavigationHelper.navigateToReportsPage(fw.labelOne,fw.labelTwo,fw.labelThree,fw.selectedLevelOne,fw.selectedLevelTwo,fw.selectedLevelThree);
        
    }
    
    //Method called on clicking App Setup on header    
    public PageReference navigateToAppSetup(){
        
        return FunnelNavigationHelper.navigateToAppSetupPage(fw.labelOne,fw.labelTwo,fw.labelThree,fw.selectedLevelOne,fw.selectedLevelTwo,fw.selectedLevelThree);
        
    }
     public PageReference navigateToCertificateReports(){
        
        return FunnelNavigationHelper.navigateToCertificateReports(fw.labelOne,fw.labelTwo,fw.labelThree,fw.selectedLevelOne,fw.selectedLevelTwo,fw.selectedLevelThree);
        
    } 
    
    public PageReference navigateToCertification(){
        
        return FunnelNavigationHelper.navigateToCertification(fw.labelOne,fw.labelTwo,fw.labelThree,fw.selectedLevelOne,fw.selectedLevelTwo,fw.selectedLevelThree);
    
    }
    
    public PageReference navigateToAnalytics(){
        
        return FunnelNavigationHelper.navigateToAnalytics(fw.labelOne,fw.labelTwo,fw.labelThree,fw.selectedLevelOne,fw.selectedLevelTwo,fw.selectedLevelThree);
    
    }
    
    public PageReference navigateToFunnelAnalyticQualitative(){
        
        return FunnelNavigationHelper.navigateToFunnelAnalyticQualitative(fw.labelOne,fw.labelTwo,fw.labelThree,fw.selectedLevelOne,fw.selectedLevelTwo,fw.selectedLevelThree);
    
    }
    
    public PageReference navigateToFunnelAnalytic(){
        
        return FunnelNavigationHelper.navigateToFunnelAnalytic(fw.labelOne,fw.labelTwo,fw.labelThree,fw.selectedLevelOne,fw.selectedLevelTwo,fw.selectedLevelThree);
    
    }
    /*Navigation*/
    
    /*Filters*/
    
    public void showUpdated(){
        try{    
             chartLabels = new list<String>();
             chartData = new list<Decimal>();
             char2qualitative = new list<Decimal>();
             char2quantitative = new list<Decimal>();
             
             monthsValues = new list<Decimal>();
             monthsRevenue = new list<Decimal>();
             monthsValuesqualitative = new list<Decimal>();
             months = new list<String>();
             
             chartLabelsbelow = new list<String>();
             chartDatabelow = new list<Decimal>();
             
             char2qualitativebelow = new list<Decimal>();
             char2quantitativebelow = new list<Decimal>();
             
             chartrevenue = new list<Decimal>();
             chartDataQuota = new list<Decimal>();
             
             chartrevenuebelow= new list<Decimal>();
             chartDataQuotabelow = new list<Decimal>();
             
            //Aggregates of a particular level value need to be done
            if(fw.selectedLevelThree == 'All'){
                //Fetch the sales profile record associated with that level
                List<Company_Level__c> cl = [SELECT Sales_Rep_Profile__c FROM Company_Level__c WHERE Level_Value__c = : fw.selectedLevelOne LIMIT 1];
                aggregate(cl[0].Sales_Rep_Profile__c);  // team aggregation method
                fetchData('team');                      // 12 month graph aggregation method
                mgr = true;
            }
            //A particular rep has been selected and his values need to be displayed
            else if(fw.labelTwo == 'Rep' && fw.selectedLevelTwo != 'All'){
                singleRep(fw.selectedLevelTwo,null);   
                mgr = false;             
            }
            //A particular role has been selected 
            else if (fw.selectedLevelThree != '' && fw.selectedLevelThree != 'All'){
                system.debug('role aggregates');
                mgr = true;
                aggregateOnRole();
                fetchData('role');
            }
        }
        catch(Exception ex){
            System.debug('Exception occured: '+ ex+' Line number: '+ex.getLineNumber());
            FunnelTriggerBatchHelper.sendErrorMail(' FunnelCertificationReportsController '+ex.getMessage()+' '+ex.getStackTraceString()+ ' line number: '+ex.getLineNumber()+' cause '+ex.getCause());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
    }    
    
    private void aggregateOnRole(){ 

        //Fetch the company level record associated with the particular level
        
        
        List<Company_Level__c> cl = [SELECT id,Sales_Rep_Profile__c, Sales_Rep_Profile__r.name FROM Company_Level__c WHERE Level_Value__c = :fw.SelectedLevelOne AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];
        
        // Level below
        List<Company_Level__c> c2=[select id, Level_Value__c FROM Company_Level__c WHERE Sales_Rep_Profile__r.Sales_Manager__c = :cl[0].Sales_Rep_Profile__c AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];
        
        set<string> levelnm = new set<string>();
        
        for(Company_Level__c c :c2){
            levelnm.add(c.Level_Value__c);
        }
        
        //Fetch the records at the selected level and role
        List<Sales_Profile_Company_Level_Junction__c> sReps = [SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.name, Sales_Rep_Profile__r.Sales_Manager__c, Sales_Rep_Profile__r.Role__c, Company_Level__c, Company_Level__r.Level_Value__c FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c = :fw.SelectedLevelOne AND Sales_Rep_Profile__r.Role__c = :fw.SelectedLevelThree AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];                
        
        Set<String> levels = new Set<String>();
        
        //List to store the ids of the reps to be aggregated
        Set<ID> aggregateIds = new Set<Id>();
        
        Set<ID> profIds = new Set<Id>();
        
        //Store the profile ids of the managers
        for(Sales_Profile_Company_Level_Junction__c s: sReps){
            profIds.add(s.Sales_Rep_Profile__c);
            aggregateIds.add(s.Sales_Rep_Profile__c);
        }
        
        
           
        //Aggregate the results
        List<AggregateResult> r = [SELECT AVG(Overall_Rating__c) avor, AVG(Overall_Qualitative_Rating__c) avoq FROM Certification__c WHERE Sales_Rep_Profile__c IN :aggregateIds AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)] ;
        
        //Populate the wrapper
        if(r != null && r.size() > 0){   
            
            chartLabels.add(String.escapeSingleQuotes((String)fw.SelectedLevelone));
            
            
            if(r[0].get('avor') != null){
                    chartData.add((Decimal)r[0].get('avor'));
                } else{
                    chartData.add(0);
                }
            if(r[0].get('avoq') != null){
                    char2qualitative.add((Decimal)r[0].get('avoq'));
                } else{
                    char2qualitative.add(0);
                }    
           
        } 
        
        //
        
        //Fetch the records at the selected level and role
        List<Sales_Profile_Company_Level_Junction__c> sReps1 = [SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.name, Sales_Rep_Profile__r.Sales_Manager__c, Sales_Rep_Profile__r.Role__c, Company_Level__c, Company_Level__r.Level_Value__c FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c = :fw.SelectedLevelOne AND Sales_Rep_Profile__r.Role__c = :fw.SelectedLevelThree AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];                
        
        Set<String> levels1 = new Set<String>();
        
        //List to store the ids of the reps to be aggregated
        Set<ID> aggregateIds1 = new Set<Id>();
        
        Set<ID> profIds1 = new Set<Id>();
        
        //Store the profile ids of the managers
        for(Sales_Profile_Company_Level_Junction__c s: sReps1){
            profIds1.add(s.Sales_Rep_Profile__c);
            aggregateIds1.add(s.Sales_Rep_Profile__c);
        }
        
        //Fetch the company levels associated with the sales profiles
         List<Company_Level__c> cl1 = [SELECT id, Level_Value__c FROM Company_Level__c WHERE Sales_Rep_Profile__c IN :profIds1 AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];
        
        levels1.clear();
        
        //Store all the levels associated with the managers
        for(Company_Level__c c: cl1){
            levels1.add(c.Level_Value__c);
        }
        
        //Fetch the sales profiles associated with the levels
        sReps1 = [SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.name, Sales_Rep_Profile__r.Role__c, Company_Level__c, Company_Level__r.Level_Value__c FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c IN :levels1 AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];
                
        //Add the sales profiles to the ids to be aggregated        
        for(Sales_Profile_Company_Level_Junction__c s: sReps1){
            aggregateIds1.add(s.Sales_Rep_Profile__c);
        }
        List<AggregateResult> rr = [Select SUM(YTD_Revenue__c) ytdrev, SUM(YTD_Quota__c) ytdquo from Sales_Rep_Profile__c where id IN :aggregateIds1 AND  Annual_Quota_Amount__c > 0 ];
        if(rr != null && rr.size() > 0){   
            if(rr[0].get('ytdrev') != null){
                    chartrevenue.add((Decimal)rr[0].get('ytdrev'));
                } else{
                    chartrevenue.add(0);
                }
                
            if(rr[0].get('ytdquo') != null){
                    chartDataQuota.add((Decimal)rr[0].get('ytdquo'));
                } else{
                    chartDataQuota.add(0);
                }
                
        } 
        if(levelnm != null && levelnm.size() > 0){
        List<AggregateResult> rbelow = [Select Company_Level__r.Level_Value__c c,AVG(Certification__r.Overall_Rating__c) avor, AVG(Certification__r.Overall_Qualitative_Rating__c) avoq From Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c IN :levelnm AND Sales_Rep_Profile__r.Role__c = :fw.SelectedLevelThree AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0) Group By Company_Level__r.Level_Value__c order by  Company_Level__r.Level_Value__c asc];
        
        for(AggregateResult rb : rbelow){
            chartLabelsbelow.add((String)rb.get('c'));
            if(rb.get('avor') != null){
                    chartDatabelow.add((Decimal)rb.get('avor'));
                } else{
                    chartDatabelow.add(0);
                }
            if(rb.get('avoq') != null){
                    char2qualitativebelow.add((Decimal)rb.get('avoq'));
                } else{
                    char2qualitativebelow.add(0);
                }    
        }
         
        List<Sales_Profile_Company_Level_Junction__c> sRepsbelow = [SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.name, Sales_Rep_Profile__r.Sales_Manager__c, Sales_Rep_Profile__r.Role__c, Company_Level__c, Company_Level__r.Level_Value__c FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c IN :levelnm AND Sales_Rep_Profile__r.Role__c = :fw.SelectedLevelThree AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];                
        Set<String> levelsbelow = new Set<String>();
        
        //List to store the ids of the reps to be aggregated
        Set<ID> aggregateIdsbelow = new Set<Id>();
        
        Set<ID> profIdsbelow = new Set<Id>();
        
        //Store the profile ids of the managers
        for(Sales_Profile_Company_Level_Junction__c sbelow : sRepsbelow){
            profIdsbelow.add(sbelow.Sales_Rep_Profile__c);
            aggregateIdsbelow.add(sbelow.Sales_Rep_Profile__c);
        }
        
        //Fetch the company levels associated with the sales profiles
        c2 = [SELECT id, Level_Value__c FROM Company_Level__c WHERE Sales_Rep_Profile__c IN :profIdsbelow AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];
        
        levelsbelow.clear();
        
        //Store all the levels associated with the managers
        for(Company_Level__c cbelow : c2){
            levelsbelow.add(cbelow.Level_Value__c);
        }
        system.debug('levelsbelow--->'+levelsbelow);
        //Fetch the sales profiles associated with the levels
        sRepsbelow = [SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.name, Sales_Rep_Profile__r.Role__c, Company_Level__c, Company_Level__r.Level_Value__c FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c IN :levelsbelow AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];
                
        //Add the sales profiles to the ids to be aggregated        
        for(Sales_Profile_Company_Level_Junction__c sbelow: sRepsbelow){
            aggregateIdsbelow.add(sbelow.Sales_Rep_Profile__c);
        }
           
        //Aggregate the results
        List<AggregateResult> rbelow1 = [Select Company_Level__r.Level_Value__c c, SUM(Sales_Rep_Profile__r.YTD_Revenue__c) ytdrev, SUM(Sales_Rep_Profile__r.YTD_Quota__c) ytdquo
                                    from Sales_Profile_Company_Level_Junction__c where Sales_Rep_Profile__c IN :aggregateIdsbelow AND  Sales_Rep_Profile__r.Annual_Quota_Amount__c > 0 AND Company_Level__r.Level_Value__c IN :levelnm group by Company_Level__r.Level_Value__c order by  Company_Level__r.Level_Value__c asc];
           
        
        //Populate the wrapper
        for(AggregateResult rb: rbelow1){   
            
            //chartLabelsbelow.add(String.escapeSingleQuotes((String)fw.SelectedLevelThree));
            
            if( rb.get('c')  != null && chartLabelsbelow.contains(String.escapeSingleQuotes((String)rb.get('c')))){
            if(rb.get('ytdrev') != null){
                    chartrevenuebelow.add((Decimal)rb.get('ytdrev'));
                } else{
                    chartrevenuebelow.add(0);
                }
                
            if(rb.get('ytdquo') != null){
                    chartDataQuotabelow.add((Decimal)rb.get('ytdquo'));
                } else{
                    chartDataQuotabelow.add(0);
                }
              }
        }   
         
        
      for(string ls: levelnm ){
          if(!chartLabelsbelow.contains(ls)){
              chartLabelsbelow.add(ls);
              chartDatabelow.add(0);
              char2qualitativebelow.add(0);
              chartrevenuebelow.add(0);
              chartDataQuotabelow.add(0);
              
          }
      
      }
        }else if(fw.labelTwo == 'Rep'){
            List<Sales_Profile_Company_Level_Junction__c> clR = [SELECT id,Certification__r.Overall_Rating__c,Certification__r.Overall_Qualitative_Rating__c,Sales_Rep_Profile__r.name,Sales_Rep_Profile__r.YTD_Quota__c,Sales_Rep_Profile__r.YTD_Revenue__c  FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c = :fw.SelectedLevelOne AND Sales_Rep_Profile__r.Role__c =:fw.selectedLevelThree AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];
            
            for( Sales_Profile_Company_Level_Junction__c cc: clR){
                  chartLabelsbelow.add(cc.Sales_Rep_Profile__r.name);
                  chartDatabelow.add(cc.Certification__r.Overall_Rating__c);
                  char2qualitativebelow.add(cc.Certification__r.Overall_Qualitative_Rating__c);
                  chartrevenuebelow.add(cc.Sales_Rep_Profile__r.YTD_Revenue__c);
                  chartDataQuotabelow.add(cc.Sales_Rep_Profile__r.YTD_Quota__c);
            }
        }
      
      system.debug('chartLabelsbelow ---->'+chartLabelsbelow);
    }
    
    private void singleRep(Id sr, Id ur){
        
        Set<Id> aggregateIds = new Set<Id>();
        aggregateIds.add(sr);
        
    
                     
        List<Certification__c>    s = new  List<Certification__c>();
          
        if(sr != null){
            s=[Select id,Overall_Qualitative_Rating__c, Overall_Quantitative_Rating__c, Overall_Rating__c,Sales_Rep_Profile__r.name from Certification__c   where Sales_Rep_Profile__c = :String.escapeSingleQuotes(sr) limit  1];
        }
        
        if(s != null && s.size() > 0){ 
           
           chartLabels.add(String.escapeSingleQuotes(s[0].Sales_Rep_Profile__r.name));
               
            if(s[0].Overall_Rating__c != null){
                chartData.add(s[0].Overall_Rating__c);
            }else{
                chartData.add(0);
            }
            
            if( s[0].Overall_Qualitative_Rating__c != null){
                char2qualitative.add(s[0].Overall_Qualitative_Rating__c);
            }else{
                char2qualitative.add(0);
            }
                
                 fetchForRep(s[0].id);  
               
        } 
        Sales_Rep_Profile__c ss = new  Sales_Rep_Profile__c();
          
        if(sr != null){
            ss =[Select id,YTD_Quota__c,YTD_Revenue__c from Sales_Rep_Profile__c  where id = :String.escapeSingleQuotes(sr) limit  1];
        }
        if(ss != null){ 
           
            
              if( ss.YTD_Quota__c != null){
                    chartDataQuota.add(ss.YTD_Quota__c);
                }else{
                    chartDataQuota.add(0);
                }
   
                if(ss.YTD_Revenue__c != null){
                    chartrevenue.add(ss.YTD_Revenue__c);
                    
                }else{
                    chartrevenue.add(0);
                }
            }
    }
    
     public void aggregate(Id mgrId){
     
         list<Certification__c> srpresult = new list<Certification__c>();
         list<Certification__c> srpTeamresult = new list<Certification__c>();
         
         list<Sales_Rep_Profile__c> srplevel = new list<Sales_Rep_Profile__c>();
         list<Certification__c> certlevel = new list<Certification__c>();
         list<Company_Level__c> complevel = new list<Company_Level__c>();
      
         list<AggregateResult> aggValue = new list<AggregateResult>();
            
        List<Sales_Rep_Profile__c> sRep = new List<Sales_Rep_Profile__c>();
        
        sRep = [Select id,User_Record_Name__c, name from Sales_Rep_Profile__c where id =:mgrId AND (Active__c = TRUE OR Annual_Quota_Amount__c > 0)];
        
        List<Certification__c> mngRecord =[SELECT id,Overall_Rating__c,Overall_Qualitative_Rating__c,Overall_Quantitative_Rating__c,Management_Qualitative_Score__c from Certification__c WHERE Sales_Rep_Profile__c = :mgrId limit 1];
        
       
        //Aggregate the results
        
            
        if(mngRecord != null && mngRecord.size() > 0){   
            
            chartLabels.add(String.escapeSingleQuotes((String)fw.SelectedLevelOne));
            
            
            if(mngRecord[0].Overall_Rating__c != null){
                    chartData.add(mngRecord[0].Overall_Rating__c);
                } else{
                    chartData.add(0);
                }
          
           if(mngRecord[0].Overall_Qualitative_Rating__c != null){
                    char2qualitative.add(mngRecord[0].Overall_Qualitative_Rating__c);
                } else{
                    char2qualitative.add(0);
                }    
            
        } 
        
        List<Company_Level__c> cl = [SELECT id, Level_Value__c FROM Company_Level__c WHERE Level_Value__c = :fw.SelectedLevelOne];
        
        Set<Id> sr = new Set<Id>();
        if(cl != null && cl.size()>0){
            List<Sales_Profile_Company_Level_Junction__c> spCLJun = [SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.name, Sales_Rep_Profile__r.User_record_name__c, Company_Level__c FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c = :cl[0].Level_Value__c AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0)];
            
            for(Sales_Profile_Company_Level_Junction__c sj: spCLJun){
                 sr.add(sj.Sales_Rep_Profile__c);
            }
        }    
      
        if(sr != null && sr.size()>0){
        List<AggregateResult> r = [Select SUM(YTD_Revenue__c) ytdrev, SUM(YTD_Quota__c) ytdquo from Sales_Rep_Profile__c where id IN :sr AND Annual_quota_amount__c > 0];
        
            if(r != null && r.size() > 0){                            
                
                if(r[0].get('ytdrev') != null){
                        chartrevenue.add((Decimal)r[0].get('ytdrev'));
                    } else{
                        chartrevenue.add(0);
                    }
                    
                if(r[0].get('ytdquo') != null){
                        chartDataQuota.add((Decimal)r[0].get('ytdquo'));
                    } else{
                        chartDataQuota.add(0);
                    }
                    
                
            }
        }
        
         if(mgrId != null && fw.labelTwo != 'Rep'){
            system.debug(' 1 inside data  method');
            
            List<Sales_Rep_Profile__c> repundermng = [SELECT id,name FROM Sales_Rep_Profile__c WHERE Sales_Manager__c = :mgrId AND (Active__c = TRUE OR Annual_Quota_Amount__c > 0)];
            Set<id> cmid = new Set<id>();
            
            for(Sales_Rep_Profile__c s : repundermng){
                cmid.add(s.id);
            }
            
            if(cmid != null && cmid.size() >0){
                List<Company_Level__c> complevelname = [select id,Level_Value__c,Certification__r.Overall_Qualitative_Rating__c,Certification__r.Overall_Rating__c,Sales_Rep_Profile__c from Company_Level__c where Sales_Rep_Profile__c IN :cmid AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0) order by  Level_Value__c asc] ;
                
                
                for(Company_Level__c c : complevelname){
                   chartLabelsbelow.add(c.Level_Value__c);
                   char2qualitativebelow.add(c.Certification__r.Overall_Qualitative_Rating__c );
                   chartDatabelow.add(c.Certification__r.Overall_Rating__c);
                }
            }
            // 
             
            if(chartLabelsbelow != null && chartLabelsbelow.size()>0){
                List<AggregateResult> arList=[Select Company_Level__r.Level_Value__c c, Sum(Sales_Rep_Profile__r.YTD_Revenue__c) ytdrev, Sum(Sales_Rep_Profile__r.YTD_Quota__c) ytdquo,AVG(Sales_Rep_Profile__r.YTD_Opportunity_Close_Rate__c) ytdocr ,AVG(Sales_Rep_Profile__r.Goal_12m_rolling_close_rate__c) gytdocr,SUM(Sales_Rep_Profile__r.YTD_Opportunities_won__c) ytdow,SUM(Sales_Rep_Profile__r.Goal_of_wins_to_achieve_monthly_quota__c) gytdow,AVG(Sales_Rep_Profile__r.Current_Fiscal_Months__c) cfy From Sales_Profile_Company_Level_Junction__c where Company_Level__r.Level_Value__c IN : chartLabelsbelow AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0) group by Company_Level__r.Level_Value__c order by  Company_Level__r.Level_Value__c asc];
                
                for(AggregateResult rb : arList){
                  if( rb.get('c')  != null && chartLabelsbelow.contains(String.escapeSingleQuotes((String)rb.get('c')))){
                    if(rb.get('ytdrev') != null){
                        chartrevenuebelow.add((Decimal)rb.get('ytdrev'));
                    } else{
                        chartrevenuebelow.add(0);
                    }
                    if(rb.get('ytdquo') != null){
                        chartDataQuotabelow.add((Decimal)rb.get('ytdquo'));
                    } else{
                        chartDataQuotabelow.add(0);
                    }
                  } 
                    
                } 
            }
             
        }else if(mgrId != null && fw.labelTwo == 'Rep'){
           system.debug(' 2 inside data  method');
           
              
           //Population of Funnelocity Score
         /* test class   List<Sales_Profile_Company_Level_Junction__c> cl1 = [SELECT id,Sales_Rep_Profile__c FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c = :fw.SelectedLevelOne];
            
            Set<Id> aggregateIds = new Set<Id>();
            
            for(Sales_Profile_Company_Level_Junction__c cj: cl1){
                aggregateIds.add(cj.Sales_Rep_Profile__c);    
            }
         */   
            certlevel = [Select Overall_Qualitative_Rating__c, Overall_Quantitative_Rating__c, Overall_Rating__c,Sales_Rep_Profile__r.name,Sales_Rep_Profile__r.YTD_Revenue__c,Sales_Rep_Profile__r.YTD_Quota__c from    Certification__c   where Sales_Rep_Profile__r.Sales_Manager__c = :mgrId AND (Sales_rep_profile__r.Active__c = TRUE OR Sales_rep_profile__r.Annual_Quota_Amount__c > 0) ];
            
            for(Certification__c s:  certlevel){
                
                chartLabelsbelow.add(s.Sales_Rep_Profile__r.name);
                char2qualitativebelow.add(s.Overall_Qualitative_Rating__c);
                chartDatabelow.add(s.Overall_Rating__c);
                if(s.Sales_Rep_Profile__r.YTD_Revenue__c != null){
                    chartrevenuebelow.add(s.Sales_Rep_Profile__r.YTD_Revenue__c);
                }else{
                    chartrevenuebelow.add(0);
                }
                if(s.Sales_Rep_Profile__r.YTD_Quota__c != null){
                    chartDataQuotabelow.add(s.Sales_Rep_Profile__r.YTD_Quota__c);
                }else{
                    chartDataQuotabelow.add(0);
                }
                
                
                 
            }
            
          
               
        }
        
    } 
    
    public void fetchForRep(Id srid){
        
        List<Certification_Snapshot__c> certisnap =[SELECT Overall_Rating__c,Overall_Qualitative_Rating__c ,Sales_Rep_Profile_Snapshot__r.Monthly_Quota_Revenue__c,Snapshot_Scheduled_Date__c FROM Certification_Snapshot__c where Certification__c = :srid AND (Sales_rep_profile_snapshot__r.Active__c = TRUE OR Sales_rep_profile_snapshot__r.Annual_Quota_Amount__c > 0) Order By Snapshot_Scheduled_Date__c desc Limit 12];
        
        for(Certification_Snapshot__c c : certisnap){
            
            if(c.Snapshot_Scheduled_Date__c != null){
                //string s = fetchMonthString(c.Snapshot_Scheduled_Date__c.month());
                months.add(fetchMonthString(c.Snapshot_Scheduled_Date__c.month()));
            }else{
                months.add('');
            }
            
            if(c.Overall_Rating__c!= null){
                monthsValues.add(c.Overall_Rating__c);
            }else{
                monthsValues.add(0);
            }
            if(c.Overall_Qualitative_Rating__c!= null){
                monthsValuesqualitative .add(c.Overall_Qualitative_Rating__c);
            }else{
                monthsValuesqualitative .add(0);
            }
            if(c.Sales_Rep_Profile_Snapshot__r.Monthly_Quota_Revenue__c!= null){
                monthsRevenue.add(c.Sales_Rep_Profile_Snapshot__r.Monthly_Quota_Revenue__c);
            }else{
                monthsRevenue.add(0);
            }
        }
    }
    
     private void fetchData(String scenario){
        
        String level = String.escapeSingleQuotes(fw.selectedLevelOne);
        List<Company_Level__c> cllookup =[Select id from Company_Level__c where Level_Value__c = :level limit 1]; 
        cllookupid = cllookup[0].id;
        List<Company_Level_Junction_snapshot__c> spCLJun = [SELECT Snapshot_Scheduled_Date__c FROM Company_Level_Junction_snapshot__c  ORDER BY Snapshot_Scheduled_Date__c DESC LIMIT 1];
        
        Date schedDate;
        if(spCLJun != null && spCLJun.size() > 0){
            schedDate = spCLJun[0].Snapshot_Scheduled_Date__c;
        
             
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,1);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,1);    
        }
        
        schedDate = schedDate.addMonths(-1);
        Integer lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,2);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,2);
        }
        
        schedDate = schedDate.addMonths(-1);
        lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,3);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,3);
        }
        
        schedDate = schedDate.addMonths(-1);
        lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,4);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,4);
        }
        
        schedDate = schedDate.addMonths(-1);
        lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,5);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,5);
        }
        
        schedDate = schedDate.addMonths(-1);
        lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,6);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,6);
        }
        
        schedDate = schedDate.addMonths(-1);
        lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,7);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,7);
        }
        
        schedDate = schedDate.addMonths(-1);
        lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,8);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,8);
        }
        
        schedDate = schedDate.addMonths(-1);
        lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,9);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,9);
        }
        
        schedDate = schedDate.addMonths(-1);
        lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,10);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,10);
        }
        
        schedDate = schedDate.addMonths(-1);
        lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,11);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,11);
        }
        
        schedDate = schedDate.addMonths(-1);
        lastDay = Date.daysInMonth(schedDate.year(), schedDate.month());
        schedDate = Date.newInstance(schedDate.year(), schedDate.month(), lastDay); 
        
        if(scenario == 'team'){
            fetchTableDataForTeam(schedDate,12);
        }
        else if(scenario == 'role'){
            fetchTableDataForRole(schedDate,12);
        }
       } 
    }
    
    private void fetchTableDataForTeam(Date scheduleDate, Integer month){
        
        
        
       /* List<Company_Level_Junction_snapshot__c> spCLJun = [SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.name, Sales_Rep_Profile__r.User_record_name__c, Company_Level__c FROM Company_Level_Junction_snapshot__c  WHERE Snapshot_Scheduled_Date__c = :scheduleDate AND Company_Level__r.Level_Value__c = :level];
        system.debug('scheduleDate '+scheduleDate);
        system.debug(' spCLJun '+spCLJun);
        Set<id> srIds = new Set<id>();
        
        for(Company_Level_Junction_snapshot__c sj: spCLJun){
             srIds.add(sj.Sales_Rep_Profile__c);
        }*/
         
        List<Company_Levels_snapshot__c>  spmn =[SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.name  FROM Company_Levels_snapshot__c  WHERE Snapshot_Scheduled_Date__c = :scheduleDate AND Company_Level__c = :cllookupid limit 1];
        Set<id> srIds = new Set<id>();
        
        for(Company_Levels_snapshot__c sj: spmn){
             srIds.add(sj.Sales_Rep_Profile__c);
             system.debug(' Sales_Rep_Profile__r.name '+sj.Sales_Rep_Profile__r.name);
        }
        
        /*
        List<Company_Level_Junction_snapshot__c> juncLi = [SELECT id, Sales_Rep_Profile__c, Sales_Rep_Profile__r.name FROM Company_Level_Junction_snapshot__c WHERE Company_Level__c = :cllookupid];
        
        srIds = new Set<id>();
        
        for(Company_Level_Junction_snapshot__c sj: juncLi ){
             srIds.add(sj.Sales_Rep_Profile__c);
             system.debug(' Sales_Rep_Profile__r.name '+sj.Sales_Rep_Profile__r.name);
        }*/
       if(srIds != null && srIds.size()>0){ 
            List<AggregateResult> r = [SELECT AVG(Overall_Rating__c) avor,AVG(Overall_Qualitative_Rating__c) avoq  FROM Certification_Snapshot__c  WHERE Snapshot_Scheduled_Date__c = :scheduleDate AND Sales_Rep_Profile__c IN : srIds AND (Sales_rep_profile_snapshot__r.Active__c = TRUE OR Sales_rep_profile_snapshot__r.Annual_Quota_Amount__c > 0) ];
            
                
            if(r != null && r.size() > 0 && srIds.size()>0){   
                
                
                if(scheduleDate != null){
                     months.add(fetchMonthString(scheduleDate.month()));
                }else{
                    months.add('');
                }
                 
                
                if(r[0].get('avor') != null){
                        monthsValues.add((Decimal)r[0].get('avor'));
                    } else{
                        monthsValues.add(0);
                    }
                 if(r[0].get('avoq') != null){
                        monthsValuesqualitative .add((Decimal)r[0].get('avoq'));
                    } else{
                        monthsValuesqualitative .add(0);
                    }   
                
            } 
        }
          /*  List<AggregateResult> rr = [SELECT  SUM(Sales_Rep_Profile_Snapshot__r.Monthly_Quota_Revenue__c) mr FROM Company_Level_Junction_snapshot__c WHERE Company_Level__c = :cllookupid AND Snapshot_Scheduled_Date__c = :scheduleDate];
            if(rr != null && rr.size() > 0){
                if(rr[0].get('mr') != null){
                    monthsRevenue.add((Decimal)rr[0].get('mr'));
                } else{
                    monthsRevenue.add(0);
                } 
            } */
            //test
            List<Company_Level_Junction_snapshot__c > sReps = [SELECT Sales_Rep_Profile__c FROM Company_Level_Junction_snapshot__c WHERE Company_Level__r.Level_Value__c = :fw.SelectedLevelOne  AND Snapshot_Scheduled_Date__c = :scheduleDate AND (Sales_rep_profile_snapshot__r.Active__c = TRUE OR Sales_rep_profile_snapshot__r.Annual_Quota_Amount__c > 0)];
            
            Set<ID> profIds = new Set<Id>();
        
            for(Company_Level_Junction_snapshot__c s: sReps){
                profIds.add(s.Sales_Rep_Profile__c);
            }
            
            if(profIds != null && profIds.size()>0){
                List<AggregateResult> rr = [SELECT  SUM(Monthly_Quota_Revenue__c) mr FROM Sales_Rep_Profile_Snapshot__c WHERE Sales_Rep_Profile__c IN : profIds AND Snapshot_Scheduled_Date__c = :scheduleDate AND Annual_Quota_Amount__c > 0];
                if(rr != null && rr.size() > 0){
                    if(rr[0].get('mr') != null){
                        monthsRevenue.add((Decimal)rr[0].get('mr'));
                    } else{
                        monthsRevenue.add(0);
                    } 
                }
            }
  }
    
    
    private void fetchTableDataForRole(Date scheduleDate, Integer month){
        
        //Fetch the records at the selected level and role
        List<Company_Level_Junction_snapshot__c > sReps = [SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.name, Sales_Rep_Profile__r.Sales_Manager__c, Sales_Rep_Profile__r.Role__c, Company_Level__c, Company_Level__r.Level_Value__c FROM Company_Level_Junction_snapshot__c WHERE Company_Level__r.Level_Value__c = :fw.SelectedLevelOne AND Sales_Rep_Profile__r.Role__c = :fw.SelectedLevelThree AND Snapshot_Scheduled_Date__c = :scheduleDate AND (Sales_rep_profile_snapshot__r.Active__c = TRUE OR Sales_rep_profile_snapshot__r.Annual_Quota_Amount__c > 0)];                
        
        Set<String> levels = new Set<String>();
        
        //List to store the ids of the reps to be aggregated
        Set<ID> aggregateIds = new Set<Id>();
        
        Set<ID> profIds = new Set<Id>();
        
        //Store the profile ids of the managers
        for(Company_Level_Junction_snapshot__c s: sReps){
            profIds.add(s.Sales_Rep_Profile__c);
            aggregateIds.add(s.Sales_Rep_Profile__c);
        }
        
        List<Company_Levels_snapshot__c> cl = [SELECT id, Level_Value__c FROM Company_Levels_snapshot__c WHERE Sales_Rep_Profile__c IN :profIds AND Snapshot_Scheduled_Date__c = :scheduleDate AND (Sales_rep_profile_snapshot__r.Active__c = TRUE OR Sales_rep_profile_snapshot__r.Annual_Quota_Amount__c > 0)];
        
        levels.clear();
        
        //Store all the levels associated with the managers
        for(Company_Levels_snapshot__c c: cl){
            levels.add(c.Level_Value__c);
        }
        
        //Fetch the sales profiles associated with the levels
        sReps = [SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.name, Sales_Rep_Profile__r.Sales_Manager__c, Sales_Rep_Profile__r.Role__c, Company_Level__c, Company_Level__r.Level_Value__c FROM Company_Level_Junction_snapshot__c WHERE Company_Level__r.Level_Value__c IN :levels AND Snapshot_Scheduled_Date__c = :scheduleDate AND (Sales_rep_profile_snapshot__r.Active__c = TRUE OR Sales_rep_profile_snapshot__r.Annual_Quota_Amount__c > 0)];
                
        //Add the sales profiles to the ids to be aggregated        
        for(Company_Level_Junction_snapshot__c s: sReps){
            profIds.add(s.Sales_Rep_Profile__c);
        }
        
        List<AggregateResult> r = [SELECT AVG(Overall_Rating__c) avor ,AVG(Overall_Qualitative_Rating__c) avoq  FROM Certification_Snapshot__c WHERE Snapshot_Scheduled_Date__c = :scheduleDate AND Sales_Rep_Profile__c IN : aggregateIds AND (Sales_rep_profile_snapshot__r.Active__c = TRUE OR Sales_rep_profile_snapshot__r.Annual_Quota_Amount__c > 0)];
        
        if(r != null && r.size() > 0 && aggregateIds.size() > 0){   
            
            
            if(scheduleDate != null){
                 months.add(fetchMonthString(scheduleDate.month()));
            }else{
                months.add('');
            }
             
            
            if(r[0].get('avor') != null){
                    monthsValues.add((Decimal)r[0].get('avor'));
                } else{
                    monthsValues.add(0);
                }
             if(r[0].get('avoq') != null){
                    monthsValuesqualitative .add((Decimal)r[0].get('avoq'));
                } else{
                    monthsValuesqualitative .add(0);
                }   
            
        } 
        
        List<AggregateResult> rr = [SELECT  SUM(Monthly_Quota_Revenue__c) mr FROM Sales_Rep_Profile_Snapshot__c WHERE Sales_Rep_Profile__c IN : profIds AND Snapshot_Scheduled_Date__c = :scheduleDate AND Annual_Quota_Amount__c > 0];
            if(rr != null && rr.size() > 0){
                if(rr[0].get('mr') != null){
                    monthsRevenue.add((Decimal)rr[0].get('mr'));
                } else{
                    monthsRevenue.add(0);
                } 
            }
    }
     
     private String fetchMonthString(Integer mon){

        if(mon == 1){
            return 'Jan';
        }
        else if(mon == 2){
            return 'Feb';
        }
        else if(mon == 3){
            return 'Mar';
        }
        else if(mon == 4){
            return 'Apr';
        }
        else if(mon == 5){
            return 'May';
        }
        else if(mon == 6){
            return 'June';
        }
        else if(mon == 7){
            return 'July';
        }
        else if(mon == 8){
            return 'Aug';
        }
        else if(mon == 9){
            return 'Sep';
        }
        else if(mon == 10){
            return 'Oct';
        }
        else if(mon == 11){
            return 'Nov';
        }
        else if(mon == 12){
            return 'Dec';
        }
        
        return '';
    }
     //Serealize the json object for VF page
     public String getCharLabels() {
        return JSON.serialize(chartLabels);
     }
     
     public String getFScores() {
        return JSON.serialize(chartData); // First graph - Funnelocity Score
     }
     
      public String getQualitativeScores() {
        return JSON.serialize(char2qualitative); // Second graph - Funnelocity Score
     }
     
     public String getQuantitativeScores() {
        return JSON.serialize(char2quantitative); // Third graph - Funnelocity Score
     }
     
     public String getMonthss() {
        return JSON.serialize(months); // Third graph - Funnelocity Score
     }
     
     public String getMonthsValuess() {
        return JSON.serialize(monthsValues); // Third graph - Funnelocity Score
     }
    
     public String getmonthsValuesqualitatives() {
        return JSON.serialize(monthsValuesqualitative); // Third graph - Funnelocity Score
     }
     public String getCharLabelsbelow() {
        return JSON.serialize(chartLabelsbelow);
     }
     
     public String getFScoresbelow() {
        return JSON.serialize(chartDatabelow); // First graph - Funnelocity Score
     }
     
      public String getQualitativeScoresbelow() {
        return JSON.serialize(char2qualitativebelow); // Second graph - Funnelocity Score
     }
     
     public String getQuantitativeScoresbelow() {
        return JSON.serialize(char2quantitativebelow); // Third graph - Funnelocity Score
     }
     
     public String getrevenue() {
        return JSON.serialize(chartrevenue);
    }
    public String getQuotas() {
        return JSON.serialize(chartDataQuota);
    }
    
    public String getrevenuebelow() {
        return JSON.serialize(chartrevenuebelow);
    }
    public String getQuotasbelow() {
        return JSON.serialize(chartDataQuotabelow);
    }
    public String getmonthrevenue() {
        return JSON.serialize(monthsRevenue);
    }
    
}