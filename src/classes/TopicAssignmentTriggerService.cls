public with sharing class TopicAssignmentTriggerService {
	
	public static void processTriggerData(List<TopicAssignment> newList, List<TopicAssignment> oldList){
		
	}

	public static void processTriggerDataConnectApi(List<TopicAssignment> newList, List<TopicAssignment> oldList){
		
		

	    List<TopicAssignment> correctTAInsert = new List<TopicAssignment>();
	    List<TopicAssignment> graylistTADelete = new List<TopicAssignment>();
	    
	    Map<Id,Set<Id>> parentTopicsUsed = TopicHelper.getExistingEntityTopics(newList);
		
		//might not need the trip to the DB. need to check ConnectApi to see if we can get the Topic Name field value
	    for (TopicAssignment ta : newList) {
			Id parentId = ConnectApi.ChatterFeeds.getFeedItem(null,String.valueof(ta.EntityId)).parent.Id;
			ConnectApi.Topic thisTopic = ConnectApi.Topics.getTopic(null,String.valueOf(ta.TopicId));
	        
	        if (TopicHelper.firstRun){ //skip this block if trigger is recursive. 
		        if (TopicHelper.kGraylist.keySet().contains(thisTopic.name)
		        	&& !TopicHelper.missingTopicNames.contains(thisTopic.name) ){
		        	//&& !parentTopicsUsed.get(ta.EntityId).contains(ta.TopicId)) //this might be mutually exclusive to the delete conditional
		            TopicAssignment newTopic = new TopicAssignment();
		            newTopic.EntityId=ta.EntityId;
		            System.debug('The bad topic is: '+thisTopic.name);
		            newTopic.TopicId=TopicHelper.whiteTopicsDB.get(TopicHelper.kGraylist.get(thisTopic.name).Alternate_Topic__c).Id;
		            
		            correctTAInsert.add(newTopic);
		            
		            if (TopicHelper.kGraylist.get(thisTopic.name).Cleanse__c) {
		            	graylistTADelete.add(new TopicAssignment(Id=ta.Id));
		            }
		            
		        }
	        }
	        
	        if (parentId.getSObjectType().getDescribe().getName().equals('Lead') 
	        			&& thisTopic.name.equalsIgnoreCase(TopicHelper.kConvertLeadTopic)){
	        	TopicHelper.convertLeads.add(parentId);
	        }
	        
	    }
		TopicHelper.firstRun = false;
		        
	    System.debug('To INSERT----->' +correctTAInsert);
	    System.debug('To DELETE----->' +graylistTADelete);
		
		//Use of standard DML calls will ignore (hopefully) the restrictive permissions rules of 
		//ConnectApi Apex methods. 
	    delete graylistTADelete;
	    insert correctTAInsert;
	    TopicHelper.convertLeads(TopicHelper.convertLeads);
		
	}


}