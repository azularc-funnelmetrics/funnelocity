/*
Copyright: Funnel Metrics, LLC
*/
public class FunnelFilterHelper{
    
    public static void populateFilters(FunnelFilterWrapper fw,         
        String label1Para, String label2Para, String label3Para,
        String selectedLevel1Para, String selectedLevel2Para, String selectedLevel3Para){
    
        //userId = UserInfo.getUserId();
        
        //Find if the filter parameters have been passed in the URL
        //label1Para = ApexPages.currentPage().getParameters().get('labelOne');
        
        system.debug(' inside populate filters ');
        
        if(label1Para == null || label1Para == ''){
        
            //list<Sales_Rep_Profile__c> names = querySalesProfileAndPopulateWrapper(null,userId);                                
            system.debug(' user id passed '+fw.userId);
            //Fetch the sales profile for the logged in user    
            List<Sales_Rep_Profile__c> sr = [select id, User_Record_Name__c, Name, Sales_Manager__c from Sales_Rep_Profile__c where User_Record_Name__c =:String.escapeSingleQuotes(fw.userId) AND Active__c = TRUE limit 1];
            List<Company_Level__c> c = new List<Company_Level__c>();

            if(sr != null && sr.size() > 0){
            //Fetch the company level record associated with the logged in user
                c = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__c = :String.escapeSingleQuotes(sr[0].id) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
            }else{
                List<AggregateResult> aaperm = [SELECT count(Id) c FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Funnel_App_access'];
                if(aaperm != null && aaperm.size() > 0 && aaperm[0].get('c') != null && (Integer)aaperm[0].get('c') > 0 ){
                    c = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__r.Sales_Manager__c = '' AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];   
                }
            }
            
            
            //If a company level record exists for the logged in user
            if(c != null && c.size() > 0){
               
                //User is a manager
                system.debug(' User is a manager ');
                fw.levelOne = populateLevelOne(fw);
                fw.labelOne = 'Select Level';  
                
                //The first filter is set to the logged in users level name in the org
                fw.SelectedLevelOne = c[0].Level_Name__c;  
                system.debug(' fw.SelectedLevelOne '+fw.SelectedLevelOne);
                levelOneAction(fw);
                
                //The second filter is set to the level value of the company level               
                fw.labelTwo = 'Select Value';
                fw.SelectedLevelTwo = c[0].Level_Value__c;
                system.debug('fw.SelectedLevelTwo'+fw.SelectedLevelTwo);
                levelTwoAction(fw);
                
                //The third filter is defaulted to All
                fw.SelectedLevelThree = 'All';                                         
                
            }
            else{
                
                //If there are no company level records associated, the logged in user is a sales rep, the filters should be non editable
                fw.isRep = true;
                
                //Find the company level of the manager of the logged in sales rep
                List<Company_Level__c> cl = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__c = : String.escapeSingleQuotes(sr[0].Sales_Manager__c) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];            
                
                if(cl != null && cl.size() > 0){
                    //User is a manager
                    fw.levelOne = populateLevelOne(fw);
                    fw.labelOne = 'Select Level';  
                    
                    //The first filter is set to the logged in users level name in the org
                    fw.SelectedLevelOne = cl[0].Level_Name__c;  
                    levelOneAction(fw);
                    
                    //The second filter is set to the level value of the company level               
                    fw.labelTwo = 'Select Value';
                    fw.SelectedLevelTwo = cl[0].Level_Value__c;
                    levelTwoAction(fw);
                    
                    fw.SelectedLevelTwo = sr[0].id;
                    
                    //The third filter is defaulted to All
                    fw.SelectedLevelThree = '';         
                }
                
                /*
                //The first filter label is defaulted to the company level name
                fw.labelOne = c1[0].Level_Name__c;            
                
                //The first filter is read only so it should have a single value of the company level value
                fw.levelOne = new List<SelectOption>();
                SelectOption s = new SelectOption(c1[0].Level_Value__c,c1[0].Level_Value__c);
                fw.levelOne.add(s);
                fw.SelectedLevelOne = c1[0].Level_Value__c; 
                
                //The second filter should be defaulted to the rep who has logged in
                fw.labelTwo = 'Rep';
                fw.levelTwo = new List<SelectOption>();
                s = new SelectOption(sr[0].id,sr[0].Name);
                fw.levelTwo.add(s);
                fw.SelectedLevelTwo = sr[0].id;
                
                //The third filter is not valid and hence should be read only
                fw.labelThree = 'Role';
                fw.SelectedLevelThree = '';
                */                                 
            }
        }
        else{
            
            system.debug(' parameters are passed');
            
            //Fetch the sales profile for the logged in user    
            List<Sales_Rep_Profile__c> srp = [select id, User_Record_Name__c, Name, Sales_Manager__c from Sales_Rep_Profile__c where User_Record_Name__c =:String.escapeSingleQuotes(fw.userId) AND Active__c = TRUE limit 1];
            
            List<Company_Level__c> clSp = new List<Company_Level__c>();
            //Fetch the company level record associated with the logged in user
            if(srp != null && srp.size() > 0){
            //Fetch the company level record associated with the logged in user
                clSp = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__c = :String.escapeSingleQuotes(srp[0].id) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
            }else{
                List<AggregateResult> aaperm = [SELECT count(Id) c FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Funnel_App_access'];
                if(aaperm != null && aaperm.size() > 0 && aaperm[0].get('c') != null && (Integer)aaperm[0].get('c') > 0 ){
                    clSp = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__r.Sales_Manager__c = '' AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];    
                }
            }
            
            
            if(clSp == null || clSp.size() ==0){
                fw.isRep = true;
            }
            
            system.debug('  selectedLevel2Para  '+selectedLevel2Para);         
            //If filter 2 does not contain reps/ filter 2 contains reps but all is selected
            if(label2Para != 'Rep' || (label2Para == 'Rep' && selectedLevel2Para == 'All')){
                
                system.debug(' Rep all ');
                //Fetch the company level record associated with the selected value in filter 1
                List<Company_Level__c> cl = [SELECT id, Level_Name__c, Level_Value__c FROM Company_Level__c WHERE Level_Value__c = :String.escapeSingleQuotes(selectedLevel1Para) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
                
                
                if(cl != null && cl.size() > 0){
                    //User is a manager
                    fw.levelOne = populateLevelOne(fw);
                    fw.labelOne = 'Select Level';  
                    
                    system.debug(' cl[0].Level_Name__c '+cl[0].Level_Name__c);
                    //The first filter is set to the logged in users level name in the org
                    fw.SelectedLevelOne = cl[0].Level_Name__c;  
                    levelOneAction(fw);
                    
                    system.debug('fw.levelOne '+fw.levelOne);
                    system.debug('fw.levelTwo '+fw.levelTwo);
                    
                    system.debug(' cl[0].Level_Value__c '+cl[0].Level_Value__c);
                    //The second filter is set to the level value of the company level               
                    fw.labelTwo = 'Select Value';
                    fw.SelectedLevelTwo = cl[0].Level_Value__c;
                    levelTwoAction(fw);
                    
                    system.debug('fw.levelOne '+fw.levelOne);
                    system.debug('fw.levelTwo '+fw.levelTwo);
                    
                    if(selectedLevel3Para != null && selectedLevel3Para != ''){ 
                        fw.SelectedLevelThree = selectedLevel3Para;           
                    }
                    else{
                    //The third filter is defaulted to All
                    fw.SelectedLevelThree = 'All';         
                }
                }                                
                
                /*
                //Fetch the other records at the same level using the Level name 
                cl = [SELECT id, Level_Value__c FROM Company_Level__c WHERE Level_Name__c = :cl[0].Level_Name__c];
                
                //The fetched values are the options available in the first filter, accordingly the selected value in level1 and the label are populated
                List<SelectOption> so = new List<SelectOption>();                
                for(Company_Level__c c:cl){
                    so.add(new SelectOption(c.Level_Value__c,c.Level_Value__c));
                }                
                fw.levelOne = so;
                fw.selectedLevelOne = selectedLevel1Para;                
                fw.labelOne = label1Para;
                
                //Call the action method when level 1 is selected to fetch the filter values of level 2 and level 3
                levelOneAction(fw);
                
                system.debug(fw.levelTwo);
                //Default the level 2 and 3 
                fw.labelTwo = label2Para;
                fw.labelThree = label3Para;
                fw.selectedLevelOne = selectedLevel1Para;
                fw.selectedLevelTwo = selectedLevel2Para;
                system.debug(' selectedLevelTwo  is '+fw.selectedLevelTwo );
                //If All is selected in the second filter and label 2 is rep, role filter should be disabled
                if(label2Para == 'Rep' && selectedLevel2Para == 'All'){
                    //fw.disableLevelThree = true;
                    fw.levelThree = populateLevelThree(fw);
                    //fw.levelThree = null;
                    fw.selectedLevelThree = selectedLevel3Para;
                }
                else{
                    fw.selectedLevelThree = selectedLevel3Para;
                } */  
            }
            //The second filter contains reps and All is not selected
            else if(selectedLevel2Para != 'All'){
                
                //Fetch the sales rep profile associated with the logged in sales rep0
                List<Sales_Rep_Profile__c> sr = [SELECT id, Sales_Manager__c,name FROM Sales_Rep_Profile__c WHERE id = :String.escapeSingleQuotes(selectedLevel2Para) AND Active__c = TRUE LIMIT 1];
                
                //Fetch the company level record associated with the manager of the rep
                List<Company_Level__c> cl = [SELECT Level_Name__c, Level_Value__c FROM Company_Level__c WHERE Sales_Rep_Profile__c = : String.escapeSingleQuotes(sr[0].Sales_Manager__c) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
                
                system.debug(' cl '+cl);
                
                if(cl != null && cl.size() > 0){
                    //User is a manager
                    fw.levelOne = populateLevelOne(fw);
                    fw.labelOne = 'Select Level';  
                    
                    //The first filter is set to the logged in users level name in the org
                    fw.SelectedLevelOne = cl[0].Level_Name__c;  
                    levelOneAction(fw);
                    
                    //The second filter is set to the level value of the company level               
                    fw.labelTwo = 'Select Value';
                    fw.SelectedLevelTwo = cl[0].Level_Value__c;
                    system.debug(' level two is '+fw.levelTwo);
                    levelTwoAction(fw);
                    system.debug(' level two is '+fw.levelTwo);
                    fw.SelectedLevelTwo = selectedLevel2Para;
                    
                    //The third filter is defaulted to All
                    fw.SelectedLevelThree = '';
                    fw.disableLevelThree = true;                             
                }
                /*
                //Default the first level filter values
                fw.labelOne = cl[0].Level_Name__c;
                
                List<SelectOption> s = new List<SelectOption>();
                s.add(new SelectOption(cl[0].Level_Value__c,cl[0].Level_Value__c));
                fw.levelOne = s;
                fw.selectedLevelOne = cl[0].Level_Value__c;
                
                //Default the second level filter values
                fw.labelTwo = 'Rep';
                s = new List<SelectOption>();
                s.add(new SelectOption(sr[0].id,sr[0].name));
                fw.levelTwo = s;
                fw.selectedLevelTwo = sr[0].id;
                fw.disableLevelThree = true;
                fw.labelThree = 'Role';
                */
            }
                
        }
        
        system.debug(fw.labelOne);
        system.debug(fw.selectedLevelOne);
        system.debug(fw.levelOne);
    }
    
    /*Filters*/
    public static List<SelectOption> populateLevelOne(FunnelFilterWrapper fw){
        
        system.debug('Step track populate level one method ');
        
        //Default with levels when level two is not selected
        if(fw.SelectedLevelTwo == null || fw.SelectedLevelTwo == '' ){   
            system.debug('getLevel');         
            return getLevel(fw);
        }
        //If level two is selected, the level one is populated with level two options
        else{                                            
            if(fw.defaultLevelOne != null && fw.defaultLevelOne.size() > 0 && fw.defaultLevelOne[0].getValue() == 'All'){
                fw.defaultLevelOne.remove(0);
            } 
            else if(fw.defaultLevelOne != null && fw.defaultLevelOne.size() > 1 && fw.defaultLevelOne[1].getValue() == 'All'){
                fw.defaultLevelOne.remove(1);
            }
            return fw.defaultLevelOne;        
        }        
        
    }
    /*Filters*/
    
    /*Filters*/    
    //Method to fetch all the levels below the manager
    public static List<SelectOption>  getLevel(FunnelFilterWrapper fw) {
        
        system.debug('Step track getLevel method ');
        List<SelectOption> Options = new List<SelectOption>();        
        //Options.add(new SelectOption('--Select--','--Select--'));
        
        List<Company_Level__c> c = new List<Company_Level__c>();
        
        List<Sales_Rep_Profile__c> sr = [SELECT id, Sales_Manager__c FROM Sales_Rep_Profile__c WHERE User_Record_Name__c = :String.escapeSingleQuotes(fw.userId)  AND Active__c = TRUE LIMIT 1];
        if(sr != null && sr.size() >0){
            c = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__c = :String.escapeSingleQuotes(sr[0].id) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
        }else{
            c=[select Sales_Rep_Profile__c ,Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__r.Sales_Manager__c ='' AND Sales_Rep_Profile__c  != '' AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
        }
        
        system.debug(' c lev '+c);
        if(c != null && c.size() > 0){
        
            Options.add(new SelectOption(c[0].Level_Name__c,c[0].Level_Name__c));                
            system.debug('Options1'+Options);
            /*new code*/                       
            Set<String> opts = new Set<String>();
            
            opts.add(c[0].Level_Name__c);   
            
            //system.debug(' opts '+opts);
            
            List<Sales_Profile_Company_Level_Junction__c> sj = [SELECT id, Sales_Rep_Profile__c,Company_Level__r.Level_Value__c,Company_Level__r.Level_Name__c FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c = :String.escapeSingleQuotes(c[0].Level_Value__c) AND Sales_Rep_Profile__r.Active__c = TRUE];
            system.debug(' sj 1 '+sj);
            Set<Id> sReps = new Set<Id>();
            
            for(Sales_Profile_Company_Level_Junction__c s:sj){
                sReps.add(s.Sales_Rep_Profile__c);  
                system.debug(' Company_Level__r.Level_Value__c '+s.Company_Level__r.Level_Value__c); 
                system.debug(' Company_Level__r.Level_Name__c '+s.Company_Level__r.Level_Name__c);         
            }
            
            sj = new List<Sales_Profile_Company_Level_Junction__c>();
            
            sj = [SELECT id, Company_Level__r.Level_Name__c FROM Sales_Profile_Company_Level_Junction__c WHERE Sales_Rep_Profile__c IN : sReps AND Company_Level__r.Sales_Rep_Profile__c IN :sReps AND Sales_Rep_Profile__r.Active__c = TRUE];
            system.debug(' sj 2 '+sj);
            
            for(Sales_Profile_Company_Level_Junction__c s:sj){
                if(!opts.contains(s.Company_Level__r.Level_Name__c)){
                    opts.add(s.Company_Level__r.Level_Name__c);
                    Options.add(new SelectOption(s.Company_Level__r.Level_Name__c,s.Company_Level__r.Level_Name__c));
                }
                //opts.add(s.Company_Level__r.Level_Name__c);            
            }
            
            //system.debug(' level names '+opts);
            
            /*new code*/
            /*
            List<Id> srIds = new List<Id>(); 
            
            List<Sales_Rep_Profile__c> srList = [SELECT id FROM Sales_Rep_Profile__c WHERE Sales_Manager__c = :sr.id];
            for(Sales_Rep_Profile__c s: srList){
                srIds.add(s.id);
            }        
                        
            //Fetch all the levels under the manager
            while(srList != null && srList.size() > 0){
            
                for(AggregateResult ar : [Select Level_Name__c l from Company_Level__c WHERE Sales_Rep_Profile__c IN :srIds GROUP BY Level_Name__c]){                    
                    Options.add(new SelectOption((String)ar.get('l'),(String)ar.get('l')));
                } 
                
                srList = [SELECT id FROM Sales_Rep_Profile__c WHERE Sales_Manager__c IN :srIds];
                
                srIds = new List<Id>();        
                
                for(Sales_Rep_Profile__c s: srList){
                    srIds.add(s.id);
                }
                           
            }            
            */
            system.debug(' options are '+options);
            
        }
        //A sales rep has logged in, so there is not company level record associated with the sales rep profile
        else{        
            List<Company_Level__c> c1 = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__c = :String.escapeSingleQuotes(sr[0].Sales_Manager__c) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
            
            if(c1 != null && c1.size() > 0)
                Options.add(new SelectOption(c1[0].Level_Name__c,c1[0].Level_Name__c));                            
        }
        
        return Options;        
    }
    /*Filters*/
    
    /*Filters*/
    //Action method called on changing filter 1
    public static void levelOneAction(FunnelFilterWrapper fw){
        
        //If --Select-- is selected, it is not valid scenario
        if(fw.SelectedLevelOne != '--Select--'){
        
            if(fw.labelTwo != 'Rep' || fw.selectedLevelTwo != 'All'){
                fw.disableLevelThree = false;
            }
            
            List<SelectOption> Options = new List<SelectOption>();
            
          //  Options.add(new SelectOption('--Select--','--Select--'));
            
            //The default levels are selected in the first filter
            if(fw.labelOne == 'Select Level'){
            
                List<AggregateResult> compList = [Select Level_Value__c ln from Company_Level__c WHERE Level_Name__c = :String.escapeSingleQuotes(fw.SelectedLevelOne) AND Sales_Rep_Profile__r.Active__c = TRUE GROUP BY Level_Value__c];
                
                //Values are fetched for the selected level
                for(AggregateResult ar:compList){
                    
                    Options.add(new SelectOption((String)ar.get('ln'),(String)ar.get('ln')));        
                }
                                
                fw.levelTwo = Options;
            }
            //A value has been selectd in filter 1
            else{
                
                //Fetch the company level record associated with the selected levels
                List<Company_Level__c> cl = [SELECT Sales_Rep_Profile__c, Level_Name__c FROM Company_Level__c WHERE Level_Name__c = :String.escapeSingleQuotes(fw.labelOne) AND Level_Value__c = :String.escapeSingleQuotes(fw.SelectedLevelOne) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
                
                System.debug('fw.labelOne'+fw.labelOne);
                System.debug('fw.SelectedLevelOne'+fw.SelectedLevelOne);
                //Fetch the people under the manager
                List<Sales_Rep_Profile__c> srList = [SELECT id, Name FROM Sales_Rep_Profile__c WHERE Sales_Manager__c = :String.escapeSingleQuotes(cl[0].Sales_Rep_Profile__c) AND Active__c = TRUE];
                
                Map<Id, String> srIdMap = new Map<Id, String>();        
                    
                for(Sales_Rep_Profile__c s: srList){
                    srIdMap.put(s.id,s.Name);
                }        
                
                //Fetch the levels associated with the people under the manager
                cl = [SELECT Level_Name__c, Level_Value__c FROM Company_Level__c WHERE Sales_Rep_Profile__c IN :srIdMap.keySet() AND Sales_Rep_Profile__r.Active__c = TRUE];
                
                /*
                List<SelectOption> so = new List<SelectOption>();
                List<Id> salesR = new List<Id>();
                
                //If there is any sales rep profile that is not associated with a company level, it is considered as a rep at the lowest level
                if(cl != null && cl.size() != srIdMap.keySet().size()){
                    for(Id i : srIdMap.keySet()){
                        if(!compSalesProfs.contains(i)){
                            salesR.add(i);    
                        }
                    }
                }
                
                List<Sales_Rep_Profile__c> srp = [SELECT id, name FROM Sales_Rep_Profile__c WHERE id IN :salesR];  
                
                //Create select options for the reps
                for(Sales_Rep_Profile__c s: srp){
                    so.add(new SelectOption(s.id,s.name));
                }
                             
                
                
                
                
                if(so != null && so.size() > 0){
                    options.addAll(so);
                    sublevel += 'Rep / ';
                }
                */ 
                String subLevel = '';
                options.add(new SelectOption('All','All'));               
                Set<String> subLevelSet = new Set<String>();
                
                //Fetch the levels associated with people under the manager
                if(cl != null && cl.size() > 0){
                    for(Company_Level__c c: cl){
                        
                        if(!subLevelSet.contains(c.Level_Name__c)){
                            
                            if(subLevel != ''){
                                subLevel = subLevel + ' / ' + c.Level_Name__c;
                            }
                            else{
                                subLevel = c.Level_Name__c;
                            }
                            
                            subLevelSet.add(c.Level_Name__c);
                        }
                        options.add(new SelectOption(c.Level_Value__c,c.Level_Value__c));                                                
                    }    
                    
                    fw.labelTwo = subLevel;   
                }
                else{
                    //The next lower level is the sales reps
                    for (Id key : srIdMap.keySet()) {                        
                        options.add(new SelectOption(key,srIdMap.get(key)));                        
                    }
                    
                    fw.labelTwo = 'Rep';
                }
                
                fw.levelTwo = options;
                fw.SelectedLevelTwo = 'All';
                
                system.debug(' level two is '+fw.labelTwo); 
            }
            
            fw.levelThree = populateLevelThree(fw);
        }
    }
    /*Filters*/
    
    /*Filters*/
    //Action method when level two is selected           
    public static void levelTwoAction(FunnelFilterWrapper fw){
        system.debug(' checkpoint ');
        if(fw.SelectedLevelTwo != '--Select--'){  
          
            fw.disableLevelThree = false;             
            fw.levelThree = null;               
            List<Company_Level__c> cl;
                        
            if(fw.selectedLevelTwo == 'All'){
                system.debug(' checkpoint ');
                fw.levelThree = populateLevelThree(fw);
                
                return;
            }
            //A sales rep is selected from the second dropdown
            else if(fw.labelTwo == 'Rep' && fw.selectedLevelTwo != 'All'){
                system.debug(' checkpoint ');
                fw.levelThree = new List<SelectOption>();
                fw.levelThree.add(new SelectOption('',''));
                fw.SelectedLevelThree = '';
                fw.disableLevelThree = true;
                return;
            }
            //If the level has not been selected
            else if(fw.labelOne == 'Select Level'){  
                //Level two has been selected              
                cl = [SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.Sales_Manager__c FROM Company_Level__c WHERE Level_Name__c = :fw.SelectedLevelOne AND Level_Value__c = :String.escapeSingleQuotes(fw.SelectedLevelTwo) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];                                             
                system.debug('SELECT Sales_Rep_Profile__c, Sales_Rep_Profile__r.Sales_Manager__c FROM Company_Level__c WHERE Level_Name__c ='+ fw.SelectedLevelOne +' AND Level_Value__c = '+ fw.SelectedLevelTwo+')');
                fw.labelOne = fw.selectedLevelOne;      
                system.debug(' fw.SelectedLevelOne '+fw.SelectedLevelOne); 
                system.debug(' fw.SelectedLevelTwo '+fw.SelectedLevelTwo);
                
                if(cl[0].Sales_Rep_Profile__r.Sales_Manager__c != null){
                    
                    List<Company_Level__c> cl1 = [SELECT Sales_Rep_Profile__c, Level_Name__c, Level_Value__c FROM Company_Level__c WHERE Sales_Rep_Profile__r.Sales_Manager__c = :String.escapeSingleQuotes(cl[0].Sales_Rep_Profile__r.Sales_Manager__c) AND Sales_Rep_Profile__r.Active__c = TRUE];
                    
                    system.debug(' cl1 '+cl1);
                    
                    List<SelectOption> opts = new List<SelectOption>();
                    
                    for(Company_Level__c c: cl1){
                        opts.add(new SelectOption(c.Level_Value__c,c.Level_Value__c));   
                    }
                    
                    fw.defaultLevelOne = opts;
                    
                    system.debug('default level one is '+fw.defaultLevelOne);  
                }
                else{
                    fw.defaultLevelOne = fw.levelTwo; 
                }
                                    
            }
            else if(fw.labelOne != 'Select Level' && fw.selectedLevelTwo != 'All'){
                system.debug(' checkpoint ');
                //Fetch the company level record for the selected value
                //assuming level value is unique, we do not check label two as it can be a concatenated string
                cl = [SELECT Sales_Rep_Profile__c, Level_Name__c FROM Company_Level__c WHERE Level_Value__c = :String.escapeSingleQuotes(fw.SelectedLevelTwo) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
                                        
                fw.labelOne = cl[0].Level_Name__c;
                fw.defaultLevelOne = fw.levelTwo;            
            }                        
             
            //All is not valid for the first filter
            if(fw.defaultLevelOne[0].getValue() == 'All'){
                fw.defaultLevelOne.remove(0);
            }
            
            system.debug('default level one is '+fw.defaultLevelOne);                 
            
            fw.SelectedLevelOne = fw.SelectedLevelTwo;
            
            //Fetch the sales reps below the manager
            List<Sales_Rep_Profile__c> srList = [SELECT id, Name FROM Sales_Rep_Profile__c WHERE Sales_Manager__c = : String.escapeSingleQuotes(cl[0].Sales_Rep_Profile__c) AND Active__c = TRUE];
                
            Map<Id, String> srIdMap = new Map<Id, String>();        
                
            for(Sales_Rep_Profile__c s: srList){
                srIdMap.put(s.id,s.Name);
            }        
            
            //Fetch the levels associated with the sales rep profiles
            cl = [SELECT Level_Name__c, Level_Value__c FROM Company_Level__c WHERE Sales_Rep_Profile__c IN : srIdMap.keySet() AND Sales_Rep_Profile__r.Active__c = TRUE];
            
            List<SelectOption> options = new List<SelectOption>();
            
            options.add(new SelectOption('All','All'));
            
            String subLevel = '';
            Set<String> subLevelSet = new Set<String>();
            
            //Fetch all the level values below the sales rep
            if(cl != null && cl.size() > 0){
                for(Company_Level__c c: cl){
                    
                    if(!subLevelSet.contains(c.Level_Name__c)){
                        
                        if(subLevel != ''){
                            subLevel = subLevel + ' / ' + c.Level_Name__c;
                        }
                        else{
                            subLevel = c.Level_Name__c;
                        }
                        
                        subLevelSet.add(c.Level_Name__c);
                    }
                    options.add(new SelectOption(c.Level_Value__c,c.Level_Value__c));
                    
                    system.debug(' options '+options);
                    
                }
                
                fw.labelTwo = subLevel;    
            }
            //Logged in user is a sales rep
            else{
                
                system.debug('this is the lowest level');                
                for (Id key : srIdMap.keySet()) {                    
                    options.add(new SelectOption(key,srIdMap.get(key)));                    
                }
                
                fw.labelTwo = 'Rep';
                fw.selectedLevelTwo = 'All';
            }
            
            
            fw.labelThree = 'Role';
            system.debug(' level two is set to '+options);
            
            fw.levelTwo = options;        
            
            system.debug('default level one is '+fw.defaultLevelOne); 
            //Level one is populated
            fw.levelOne = populateLevelOne(fw);  
            system.debug(' level one is '+fw.levelOne);
            
            //A particular rep has not been selected
            if(fw.labelTwo != 'Rep' || (fw.labelTwo == 'Rep' && fw.selectedLevelTwo != 'All')){  
                system.debug(' checkpoint ');                                      
                fw.levelThree = populateLevelThree(fw);
            }
            else{
                fw.levelThree = populateLevelThree(fw);
                system.debug(' level three is being fetched ');                
                if(fw.SelectedLevelThree == null || fw.SelectedLevelThree == '' || fw.SelectedLevelThree == 'All'){
                fw.SelectedLevelThree = 'All';
                }
                system.debug(' fw.levelThree '+fw.levelThree);
                //fw.disableLevelThree = true;
            }
        }
    }        
    /*Filters*/
    
    /*Filters*/   
    //Populate the third filter   
    public static List<SelectOption> populateLevelThree(FunnelFilterWrapper fw){
        
        List<SelectOption> options = new List<SelectOption>();
         
        if(fw.SelectedLevelOne != null && fw.SelectedLevelTwo != null){    
           
            Set<String> roleSet = new Set<String>();
            List<Sales_Profile_Company_Level_Junction__c> sj;
            
            options.add(new SelectOption('All','All'));
            
            //A particular level has been selected
            if(fw.labelOne != 'Select Level' && fw.SelectedLevelTwo == 'All'){                        
                
                sj = [SELECT id, Sales_Rep_Profile__r.Role__c FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c = : String.escapeSingleQuotes(fw.selectedLevelOne) AND Sales_Rep_Profile__r.Active__c = TRUE limit 5000];                                
            }
            else if(fw.labelOne != 'Select Level' && fw.SelectedLevelTwo != 'All'){
                
                sj = [SELECT id, Sales_Rep_Profile__r.Role__c FROM Sales_Profile_Company_Level_Junction__c WHERE Company_Level__r.Level_Value__c = :String.escapeSingleQuotes(fw.selectedLevelTwo) AND Sales_Rep_Profile__r.Active__c = TRUE limit 5000];
                                
            } 
                        
            for(Sales_Profile_Company_Level_Junction__c s: sj){
                if(s.Sales_Rep_Profile__r.Role__c != null && !roleSet.contains(s.Sales_Rep_Profile__r.Role__c)){
                    roleSet.add(s.Sales_Rep_Profile__r.Role__c);
                    options.add(new SelectOption(s.Sales_Rep_Profile__r.Role__c,s.Sales_Rep_Profile__r.Role__c));
                }
            }
                       
            system.debug(' options '+options);
                        
        }
        
        return options;       
        
    }            
    /*Filters*/
    
    public static void reset(FunnelFilterWrapper fw){
                
        //nullify selected values                      
        fw.SelectedLevelOne = null;
        fw.SelectedLevelTwo = null;
        fw.SelectedLevelThree = null;
        
        //Populating the first filter
        fw.levelOne = FunnelFilterHelper.populateLevelOne(fw); 
        fw.SelectedLevelOne = '--Select--';
        
        //Defaulting the labels and other two filters
        fw.labelOne='Select Level';
        fw.labelTwo = 'Select Value';
        
        fw.levelTwo = null;
        fw.levelThree = null;
            
    }
    
    public static String fetchDefaultBreadCrumbs(FunnelFilterWrapper  fw){
        String startLink = '';
        String endLink = '';
        Boolean df = false;
        String defaultLable = fetchDefaultLevel();
        system.debug(' fw.selectedLevelOne '+fw.selectedLevelOne);
        
        List<Company_Level__c> cls = [SELECT id, Sales_Rep_Profile__c, Level_Name__c, Level_Value__c FROM Company_Level__c WHERE Level_Value__c = : String.escapeSingleQuotes(fw.SelectedLevelOne) AND Sales_Rep_Profile__r.Active__c = TRUE limit 5000];
        
        String breadCrumb='';
        String breadCrumbNolink = '';
        
        if(cls != null && cls.size() > 0){
        
            List<Sales_Profile_Company_Level_Junction__c> spJunct = [SELECT id, Company_Level__r.Level_Value__c, Company_Level__r.Level_Name__c, Company_Level__r.Sales_Rep_Profile__r.Sales_Manager__c, Sales_Rep_Profile__r.Sales_Manager__c FROM Sales_Profile_Company_Level_Junction__c WHERE Sales_Rep_Profile__c = :String.escapeSingleQuotes(cls[0].Sales_Rep_Profile__c) AND Sales_Rep_Profile__r.Active__c = TRUE];    
        
            Map<String,Sales_Profile_Company_Level_Junction__c> mapJunc = new Map<String,Sales_Profile_Company_Level_Junction__c>();
            
            Id mgrId;
            
            for(Sales_Profile_Company_Level_Junction__c j: spJunct){
                system.debug(' Sales_Profile_Company_Level_Junction__c j'+j.Company_Level__r.Level_Value__c);
               
                mapJunc.put(j.Company_Level__r.Level_Value__c, j);
                system.debug(' mapJunc '+mapJunc);
                system.debug(' j.Company_Level__r.Sales_Rep_Profile__r.Sales_Manager__c '+j.Company_Level__r.Sales_Rep_Profile__r.Sales_Manager__c);
                if(j.Company_Level__r.Sales_Rep_Profile__r.Sales_Manager__c == null){
                    if(breadCrumb == ''){ 
                        if(j.Company_Level__r.Level_Value__c == defaultLable){
                            startLink = '<a onclick="breadCrumClick1(\''+j.Company_Level__r.Level_Value__c+'\',\''+j.Company_Level__r.Level_Name__c+'\')">';
                            endLink = '</a>';
                            df = true;
                        }
                        
                        breadCrumbNolink = j.Company_Level__r.Level_Value__c;
                        breadCrumb += startLink+j.Company_Level__r.Level_Value__c+endLink;  
                        mgrId = j.Company_Level__r.Sales_Rep_Profile__c;
                        system.debug(mgrId);
                    }                  
                }
            }
            
            mapJunc.remove(breadCrumbNolink );
            
            system.debug(' mapJunc '+mapJunc);
            system.debug(' breadCrumb '+breadCrumb);
            do{          
                for (String key : mapJunc.keySet()) {
                    
                    system.debug(' breadCrumb '+breadCrumb);
                    
                    Sales_Profile_Company_Level_Junction__c sj = mapJunc.get(key);
                    
                    system.debug(' sj.Company_Level__r.Level_Value__c '+ sj.Company_Level__r.Level_Value__c);
                                      
                    system.debug(' sj.Company_Level__r.Sales_Rep_Profile__r.Sales_Manager__c '+sj.Company_Level__r.Sales_Rep_Profile__r.Sales_Manager__c);
                    if(sj.Company_Level__r.Sales_Rep_Profile__r.Sales_Manager__c == mgrId){
                        if(sj.Company_Level__r.Level_Value__c == defaultLable || df){
                                startLink = '<a onclick="breadCrumClick1(\''+sj.Company_Level__r.Level_Value__c+'\',\''+sj.Company_Level__r.Level_Name__c+'\')">';
                                endLink = '</a>';
                                df = true;
                            }
                        breadCrumb += ' >&nbsp '+startLink +sj.Company_Level__r.Level_Value__c+endLink ; 
                        system.debug(' concatenated breadcrumb '+breadCrumb);
                        mgrId = sj.Company_Level__r.Sales_Rep_Profile__c;
                        
                        mapJunc.remove(key);
                    }
                    
                }
            }while(mapJunc != null && mapJunc.size() > 0);
            //system.debug(' mapJunc final '+mapJunc);      
        }                
        
        system.debug(' breadCrumb '+breadCrumb);
        //system.debug(' fw.selectedLevelOne '+fw.selectedLevelOne);
        
        if(fw.labelTwo == 'Rep' && fw.SelectedLevelTwo != 'All'){
            Sales_Rep_Profile__c s = [SELECT name FROM Sales_Rep_Profile__c WHERE id = : String.escapeSingleQuotes(fw.SelectedLevelTwo) AND Active__c = TRUE limit 5000 ];
            return String.escapeSingleQuotes(breadCrumb) +' > '+ String.escapeSingleQuotes(s.name);
        }
        else if(breadCrumb != null && (breadCrumb.endsWith(' > '+fw.selectedLevelOne) || breadCrumb == fw.selectedLevelOne || breadCrumb.endsWith('>'+fw.selectedLevelOne+'</a>')))
            return String.escapeSingleQuotes(breadCrumb);
        else
            return String.escapeSingleQuotes(breadCrumb) +' > '+ String.escapeSingleQuotes(fw.selectedLevelOne); 
            
    }

    public static String fetchDefaultLevel(){
        String userId = UserInfo.getUserId();
        
        List<Sales_Rep_Profile__c> sr = [select id, User_Record_Name__c, Name, Sales_Manager__c from Sales_Rep_Profile__c where User_Record_Name__c =:userId AND Active__c = TRUE limit 1];
        List<Company_Level__c> c = new List<Company_Level__c>();

            if(sr != null && sr.size() > 0){
            //Fetch the company level record associated with the logged in user
                c = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__c = :String.escapeSingleQuotes(sr[0].id) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
            }else{
                List<AggregateResult> aaperm = [SELECT count(Id) c FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Funnel_App_access'];
                if(aaperm != null && aaperm.size() > 0 && aaperm[0].get('c') != null && (Integer)aaperm[0].get('c') > 0 ){
                    c = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__r.Sales_Manager__c = '' AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];   
                }
            }
            if(c != null && c.size()>0){
                return c[0].Level_Value__c;
            }else{
                return null;
            }
            
    }   
    
    public static void onclickpopulateFilters(String crumValue,FunnelFilterWrapper fw ){
            //list<Sales_Rep_Profile__c> names = querySalesProfileAndPopulateWrapper(null,userId);  
             List<Company_Level__c > company =  [SELECT Sales_Rep_Profile__r.User_Record_Name__c FROM Company_Level__c WHERE Level_Value__c = : crumValue LIMIT 1];      
            fw.userId = company[0].Sales_Rep_Profile__r.User_Record_Name__c;                              
            system.debug(' user id passed '+fw.userId);
            //Fetch the sales profile for the logged in user    
            List<Sales_Rep_Profile__c> sr = [select id, User_Record_Name__c, Name, Sales_Manager__c from Sales_Rep_Profile__c where User_Record_Name__c =:String.escapeSingleQuotes(fw.userId) AND Active__c = TRUE limit 1];
            List<Company_Level__c> c = new List<Company_Level__c>();

            if(sr != null && sr.size() > 0){
            //Fetch the company level record associated with the logged in user
                c = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__c = :String.escapeSingleQuotes(sr[0].id) AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];
            }else{
                List<AggregateResult> aaperm = [SELECT count(Id) c FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Funnel_App_access'];
                if(aaperm != null && aaperm.size() > 0 && aaperm[0].get('c') != null && (Integer)aaperm[0].get('c') > 0 ){
                    c = [Select Level_Name__c,Level_Value__c from Company_Level__c WHERE Sales_Rep_Profile__r.Sales_Manager__c = '' AND Sales_Rep_Profile__r.Active__c = TRUE LIMIT 1];   
                }
            }
            
            
            //If a company level record exists for the logged in user
            if(c != null && c.size() > 0){
               
                //User is a manager
                system.debug(' User is a manager ');
                fw.levelOne = populateLevelOne(fw);
                fw.labelOne = 'Select Level';  
                
                //The first filter is set to the logged in users level name in the org
                fw.SelectedLevelOne = c[0].Level_Name__c;  
                system.debug(' fw.SelectedLevelOne '+fw.SelectedLevelOne);
                levelOneAction(fw);
                
                //The second filter is set to the level value of the company level               
                fw.labelTwo = 'Select Value';
                fw.SelectedLevelTwo = c[0].Level_Value__c;
                system.debug('fw.SelectedLevelTwo'+fw.SelectedLevelTwo);
                levelTwoAction(fw);
                
                //The third filter is defaulted to All
                system.debug('role helper'+fw.SelectedLevelThree);
                fw.SelectedLevelThree = 'All';                                         
                
            }
    }

}