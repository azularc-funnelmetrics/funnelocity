trigger FunnelCertificationTrigger on Certification__c (after update, before update) {
    
    List<id> certsScoreUpdate = new List<id>();
          
    for(Certification__c c : Trigger.new){
                
        if(trigger.isupdate && trigger.isAfter 
        && (Trigger.oldMap.get(c.id).Individual_qualitative_rating__c != c.Individual_qualitative_rating__c
        || Trigger.oldMap.get(c.id).Overall_quantitative_rating__c != c.Overall_quantitative_rating__c)
        ){
            certsScoreUpdate.add(c.id);    
        } 
                          
    }
    
    if(certsScoreUpdate.size() > 0){
        CalculateScoreAggregates.findScoreAggregate(certsScoreUpdate);
        system.debug(' score updates completed ');
    }
    
}