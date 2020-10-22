trigger FunnelCertificationRatingMetadata on Certification_Rating__c (after insert , after update) {
  /*   Set<String> RatingNames = new Set<String>();
    Set<String> OldRatingNames = new Set<String>();
    Schema.DescribeFieldResult statusFieldDescription = Certification_Answer__c.Rating_name_picklist__c.getDescribe();
    for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues()){ 
             RatingNames.add(pickListEntry.getLabel());
            OldRatingNames.add(pickListEntry.getLabel());
    }
    
    for(Certification_Rating__c s : Trigger.new){ 
        RatingNames.add(s.Name);
    }
    if(!Test.isRunningTest()){
        if(! RatingNames.equals(OldRatingNames)){
            FunnelUpdateMetaData.createRating(RatingNames,UserInfo.getSessionId() );
        }
    } 
    */ 
}