trigger TopicAssignmentTrigger on TopicAssignment (after insert) {
    
    /*SOQL of note: 
    TOPIC All Fields 
    Select t.TalkingAbout, t.SystemModstamp, t.Name, t.Id, t.Description, t.CreatedDate, t.CreatedById From Topic t
    
    TOPICASSIGNMENT All Fields:
    
    FEEDITEM All Fields
    
    */
    
    List<TopicAssignment> correctTAInsert = new List<TopicAssignment>();
    List<TopicAssignment> graylistTADelete = new List<TopicAssignment>();
    
    Set<Id> leadsToConvert = new Set<Id>();
    Set<Id> feedItemIdSet = new Set<Id>();
    Map<Id,FeedItem> topicFeedItemMap;
    
    for (TopicAssignment ta : Trigger.new) {
    	if (ta.EntityId.getSObjectType().getDescribe().getName().equals('FeedItem')) {
    		feedItemIdSet.add(ta.EntityId);
    	}
    }
    
    topicFeedItemMap = new Map<Id,FeedItem>([select Id, ParentId from FeedItem where Id in : feedItemIdSet]);
	
    for (TopicAssignment ta : [SELECT Id,EntityId,TopicId,Topic.Name from TopicAssignment where Id in : Trigger.new]) {
    	
    	Id feedItemParentId = topicFeedItemMap.get(ta.EntityId).ParentId;
        
        //skip if trigger is recursive. 
        if (TopicHelper.firstRun){ 
	        if (TopicHelper.kGraylist.keySet().contains(ta.Topic.Name)
	        	&& !TopicHelper.missingTopicNames.contains(ta.Topic.Name) ){

	            TopicAssignment newTopic = new TopicAssignment();
	            newTopic.EntityId=ta.EntityId;
	            System.debug('The bad topic is: '+ta.Topic.Name);
	            newTopic.TopicId=TopicHelper.whiteTopicsDB.get(TopicHelper.kGraylist.get(ta.Topic.Name).Alternate_Topic__c).Id;
	            
	            correctTAInsert.add(newTopic);
	            
	            if (TopicHelper.kGraylist.get(ta.Topic.Name).Cleanse__c) {
	            	graylistTADelete.add(new TopicAssignment(Id=ta.Id));
	            }
	            
	        }
        }
        
        if (feedItemParentId.getSObjectType().getDescribe().getName().equals('Lead')
        			&& ta.Topic.Name.equalsIgnoreCase(TopicHelper.kConvertLeadTopic)){
        	leadsToConvert.add(feedItemParentId);
        }
      
    }
	TopicHelper.firstRun = false;
	        
    System.debug('To INSERT----->' +correctTAInsert);
    System.debug('To DELETE----->' +graylistTADelete);
	
    delete graylistTADelete;
    insert correctTAInsert;
    
    TopicHelper.convertLeads(leadsToConvert);
}