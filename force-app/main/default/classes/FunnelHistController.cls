/*
Copyright: Funnel Metrics, LLC
*/
public with sharing class FunnelHistController {

    public Boolean schMonBatch{get;set;}
    public Boolean schDayBatch{get;set;}
    public Boolean schDataPullBatch{get;set;}
    
    public FunnelHistController(FunnelSetupController controller) {
        srps = [SELECT id FROM Sales_rep_profile__c WHERE (Active__c = TRUE OR Annual_quota_amount__c > 0)];
        checkSchjob();
    }
    
    public void checkSchjob(){
        
        List<CronTrigger> cornListMon = new List<CronTrigger>();
        cornListMon =[SELECT Id, CronJobDetail.name, State FROM CronTrigger where CronJobDetail.name='FM Monthly batch'];
        if(cornListMon != null && cornListMon.size()>0){
            schMonBatch= false;
        }else{
            schMonBatch= true;
        }
        
        List<CronTrigger> cornListDay = new List<CronTrigger>();
        cornListDay =[SELECT Id, CronJobDetail.name, State FROM CronTrigger where CronJobDetail.name='FM Daily batch'];
        if(cornListDay != null && cornListDay.size()>0){
            schDayBatch= false;
        }else{
            schDayBatch= true;
        }
        
        List<CronTrigger> cornListpull = new List<CronTrigger>();
        cornListpull =[SELECT Id, CronJobDetail.name, State FROM CronTrigger where CronJobDetail.name='FM Model Score Data Pull'];
        if(cornListpull != null && cornListpull .size()>0){
            schDataPullBatch = false;
        }else{
            schDataPullBatch = true;
        }
    }

    public boolean timer {get; set;}
    List<Sales_rep_profile__c> srps = new List<Sales_rep_profile__c>();
    
    public FunnelHistController (){
        srps = [SELECT id FROM Sales_rep_profile__c WHERE (Active__c = TRUE OR Annual_quota_amount__c > 0)];
    }
    
    public PageReference createHistData() {
        try{
            system.debug(' histDateValue '+histDateValue);
            //srps = [SELECT id FROM Sales_rep_profile__c];
            
            List<AsyncApexJob> a = new List<AsyncApexJob>();
            a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email, ExtendedStatus
            from AsyncApexJob WHERE (Status = 'Holding' OR Status = 'Queued' OR Status = 'Preparing' OR Status = 'Processing') AND JobType = 'BatchApex'];
            
            if(a.size() > 0 ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Another batch in progress');
                ApexPages.addMessage(myMsg);
            }
            else{
                List<Sales_rep_profile_snapshot__c> ss = new List<Sales_rep_profile_snapshot__c>();
                ss = [SELECT id FROM Sales_rep_profile_snapshot__c WHERE Snapshot_scheduled_date__c = :histDateValue];
                
                if(ss.size() > 0 ){
                
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Snapshots already exist for this date');
                    ApexPages.addMessage(myMsg);            
                    
                }
                else{
                    FunnelCalculateYTDFieldsBatch fb = new FunnelCalculateYTDFieldsBatch(histDateValue,true,false);
                    //Funnel12MonthBatch fb = new Funnel12MonthBatch(histDateValue,false,false);        
                    Database.executeBatch(fb);
                    
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Batch is executing. Please monitor the status under Apex Jobs before running the next cycle.');
                    ApexPages.addMessage(myMsg);
                    
                    timerOn();
                }
            }
        }catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }
            return null;
            
    }
    
    public void scheduleMonthlyBatch() {
        try{
            FunnelScheduleSnapshotBatches sb = new FunnelScheduleSnapshotBatches();
            String sch = '0 0 23 L * ?';
            system.schedule('FM Monthly batch', sch, sb);
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Monthly Batch Scheduled');
            ApexPages.addMessage(myMsg);
            checkSchjob();
            timerOn();
        }catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }

    }
    
    public void scheduleDailyBatch() {
        try{
            FunnelScheduleCertificationEmails sb = new FunnelScheduleCertificationEmails();
            String sch = '0 0 6 * * ?';
            system.schedule('FM Daily batch', sch, sb);
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Daily Batch Scheduled');
            ApexPages.addMessage(myMsg);
            
            checkSchjob();
            timerOn();
        }catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }

    }       
    
    public void updateQualAnswers() {
        try{
            FunnelUpdateAnswersOnImplementation  fc = new FunnelUpdateAnswersOnImplementation ();
            Database.executeBatch(fc,50);
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Qualitative measures setup completed');
            ApexPages.addMessage(myMsg);
            
            timerOn();
        }catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }
    
    }
    
    public void createCustomer() {
        
        FunnelPostAPIs fp = new FunnelPostAPIs();
        
        /*fp.getAccessToken();*/
        
       // fp.createCustomer();
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Customer created');
        ApexPages.addMessage(myMsg);
        
        timerOn();
        
        //FunnelCreateCertAnswersBatch fc = new FunnelCreateCertAnswersBatch ();
        //Database.executeBatch(fc);

    }
    
    public void pushDefinitions() {
        
        FunnelPostAPIs fp = new FunnelPostAPIs();
        
        /*fp.getAccessToken();*/
        
        //fp.createCustomer();
        
        fp.createQuantRating();
        fp.createQualRating();
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Qualitative and Quantitative definitions pushed');
        ApexPages.addMessage(myMsg);
        
        timerOn();
        //FunnelCreateCertAnswersBatch fc = new FunnelCreateCertAnswersBatch ();
        //Database.executeBatch(fc);

    }
    
    public void pushQuantData() {
        try{
            system.debug(' srps '+srps);
            FunnelPostAPIs fp = new FunnelPostAPIs();
            fp.getAccessToken();
            
            fp.dtSnapShot = quantDateValue;
            fp.createQuantMetric(srps);
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Quantitative data pushed');
            ApexPages.addMessage(myMsg);
            
            timerOn();
        }
        catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }
    }
    
    public void pushQualData() {
        try{
            FunnelPostAPIs fp = new FunnelPostAPIs();
            fp.getAccessToken();
            
            fp.dtSnapShot = qualDateValue;
            fp.createQualMetric(srps);
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Qualitative data pushed');
            ApexPages.addMessage(myMsg);
            
            timerOn();
            }catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }

    }
    
     public static PageReference navigateToUserReport(){
        
        PageReference redirect;
        
        redirect = new PageReference('/apex/FunnelMetrics__FunnelUserReport'); 
 
        redirect.setRedirect(true);  
           
        return redirect;
    
    }
    
    public static PageReference navigateToGoalInput(){
        
        PageReference redirect;
        
        redirect = new PageReference('/apex/FunnelMetrics__FunnelAssignGoal'); 
 
        redirect.setRedirect(true);  
           
        return redirect;
    
    }
    
    public void scheduleDataPush() {
        try{
            /*
            FunnelScheduleDataPush sb = new FunnelScheduleDataPush();
            String sch = '0 0 23 3 * ?';
            system.schedule('FM Model Data Push', sch, sb);*/
            
            FunnelScheduleAnswerUpdates sb = new FunnelScheduleAnswerUpdates();
            String sch = '0 0 23 3 * ?';
            system.schedule('FM Model Data Push', sch, sb);
        }catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }

    }
    
    public void scheduleDataPull() {
        try{
             integer pullday = 4;
             List<Notification_Setting__c> noti = [select Last_Date_for_submit__c  from  Notification_Setting__c ORDER BY createddate DESC limit 1 ];
             if(noti != null && noti.size()>0 && noti[0].Last_Date_for_submit__c !=null){
                 pullday = Integer.valueOf(noti[0].Last_Date_for_submit__c)  + 1;
             }
            FunnelScheduleDataPull sb = new FunnelScheduleDataPull();
            String sch = '0 0 23 '+pullday +' * ?';
            //String sch = '0 1 0 '+pullday +' * ?';
             
            system.schedule('FM Model Score Data Pull', sch, sb);
            
            checkSchjob();
                   
            FunnelScheduleQualDataPull sb1 = new FunnelScheduleQualDataPull();
            sch = '0 0 23 '+pullday +' * ?';
            system.schedule('FM Model Qual Data Pull', sch, sb1);
            
            FunnelScheduleQuantDataPull sb2 = new FunnelScheduleQuantDataPull();
            sch = '0 0 23 '+pullday +' * ?';
            system.schedule('FM Model Quant Data Pull', sch, sb2);
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Data pull Scheduled');
            ApexPages.addMessage(myMsg);
            
            timerOn();
        }catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }

    }

    public Date histDateValue{ get; set; }
    
    public Date quantDateValue{ get; set; }
    
    public Date qualDateValue{ get; set; }
    
    public Date emailDateValue{ get; set; }
    
    public Date custMetDateValue{ get; set; }
    
    /*public void cm(){
        system.debug('inside cm');
        custommetric.updatecustomMetric();
    }*/
    
    public void pullScores(){
        try{
            FunnelGetApis fp = new FunnelGetApis();
            fp.getAccessToken();
              
            fp.getandUpdateFSQS();
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Scores pulled');
            ApexPages.addMessage(myMsg);
        
            timerOn();
        }
        catch(Exception ex){
            FunnelTriggerBatchHelper.sendErrorMail(' FunnelHistController '+ex.getMessage()+' '+ex.getStackTraceString()+ ' line number: '+ex.getLineNumber()+' cause '+ex.getCause());
        }
    }
    
    public void pullQualRatings(){
        try{
            FunnelGetApis fp = new FunnelGetApis();
            fp.getAccessToken();
              
            fp.getAndUpdateQualStats();
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Importanted Qualitative measures pulled');
            ApexPages.addMessage(myMsg);
        
            timerOn();
        }
        catch(Exception ex){
            FunnelTriggerBatchHelper.sendErrorMail(' FunnelHistController '+ex.getMessage()+' '+ex.getStackTraceString()+ ' line number: '+ex.getLineNumber()+' cause '+ex.getCause());
        }
    }
    
    public void pullQuantRatings(){
        try{    
            FunnelGetApis fp = new FunnelGetApis();
            fp.getAccessToken();
              
            fp.getAndUpdateQuantStats();
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Importanted Quantitative ratings pulled');
            ApexPages.addMessage(myMsg);
        
            timerOn();
        }
        catch(Exception ex){
            FunnelTriggerBatchHelper.sendErrorMail(' FunnelHistController '+ex.getMessage()+' '+ex.getStackTraceString()+ ' line number: '+ex.getLineNumber()+' cause '+ex.getCause());
        } 
    }
    
    public void executeEmailBatch(){
        try{    
            FunnelCertificationsDailyBatch m = new FunnelCertificationsDailyBatch();      
            database.executebatch(m);    
        }
        catch(Exception ex){
            FunnelTriggerBatchHelper.sendErrorMail(' FunnelHistController '+ex.getMessage()+' '+ex.getStackTraceString()+ ' line number: '+ex.getLineNumber()+' cause '+ex.getCause());
        } 
    }
    
    
                
    public void executeCustomMetricBatch(){
        try{    
            FunnelCustomMetricBatch fb = new FunnelCustomMetricBatch(custMetDateValue,false,false);
            //Funnel12MonthBatch fb = new Funnel12MonthBatch(histDateValue,false,false);        
            Database.executeBatch(fb);
        }
        catch(Exception ex){
            FunnelTriggerBatchHelper.sendErrorMail(' FunnelHistController '+ex.getMessage()+' '+ex.getStackTraceString()+ ' line number: '+ex.getLineNumber()+' cause '+ex.getCause());
        } 
    }
    
    public date leadDt {get; set;}
    public void executeLeadsBatch(){
            
        FunnelCalculateYTDFieldsBatch fb = new FunnelCalculateYTDFieldsBatch(leadDt,false,true);
        Database.executeBatch(fb);
                
    }
    
    public date mbDt {get; set;}
    public void executeMonthlyBatch(){
            
        Funnel12MonthBatch fb = new Funnel12MonthBatch(mbDt,false,true);
        Database.executeBatch(fb);
                 
    }
    
    public date csDt {get; set;}
    public void changeCSDt(){
        try{
            Fiscal_Year_Setting__c fy = FunnelTriggerBatchHelper.getFiscalYearRecord('Current_Year');
            fy.Start_Date__c = csDt;
            update fy;  
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Fiscal year updated');
            ApexPages.addMessage(myMsg);
            
            timerOn();
        }catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }
         
    }
    
     public void createMT(){
         try{
            Map<String, Object> maptest = new Map<String, Object>();
            maptest.put('FunnelMetrics__Bypass__c',false);
            FMCreateUpdateMetadataUtils.createUpdateMetadata('FunnelMetrics__New_Data_load_setting.FunnelMetrics__Trigger','Bypass Funnel opp & lead triggers',maptest);
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Triggers Activated');
            ApexPages.addMessage(myMsg);
            
            timerOn();
        }catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }
    }
    
    public void deactiveTrigger(){
        try{
            Map<String, Object> maptest = new Map<String, Object>();
            maptest.put('FunnelMetrics__Bypass__c',true);
            FMCreateUpdateMetadataUtils.createUpdateMetadata('FunnelMetrics__New_Data_load_setting.FunnelMetrics__Trigger','Bypass Funnel opp & lead triggers',maptest);
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Triggers deactivated');
            ApexPages.addMessage(myMsg);
            
            timerOn();
        }catch(Exception ex){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
             ApexPages.addMessage(myMsg);
        }
    } 
    
    public void clearMessage(){
      ApexPages.getMessages().clear();

    }

    public void timerOn(){
        timer = true;
    }

    public void timerOff(){
         timer = false;
    }
}