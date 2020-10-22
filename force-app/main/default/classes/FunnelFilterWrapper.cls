/*
Copyright: Funnel Metrics, LLC
*/
public class FunnelFilterWrapper{
        
    public String labelOne {get; set;}
    
    public String labelTwo {get; set;}
    
    public String labelThree {get; set;}    
    
    public String SelectedLevelOne { get;set;} 
    
    public String SelectedLevelTwo { get;set;} 
    
    public String SelectedLevelThree { get;set;}
        
    public List<SelectOption> levelOne {get; set;}
    
    public List<SelectOption> levelTwo {get; set;}
    
    public List<SelectOption> levelThree{get; set;}
    
    public Id userId{get; set;}
    
    public Boolean isRep{get; set;}
    
    public Boolean disableLevelThree{get; set;}
    
    public List<SelectOption> defaultLevelOne{get; set;}
    
}