public without sharing class TopicHelper {
	
	/*
	
	*/
	
	//we are calling insert for an object with an insert trigger
	//to avoid invoking the code twice, we will control reentry with this variable
	public static Boolean firstRun = true;
	public static final LeadStatus kConvertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
	
	public static final String kConvertLeadTopic = 'Convert';
	public static final String kEscalateCaseTopic = 'Escalate';

    //Custom setting: Name field is topic we want to clean up. Alternate_Topic__c containes the 
    //correct topic we will reassign. 
    public static final Map<String,topic_Graylisted_Topic__c> kGraylist = topic_Graylisted_Topic__c.getAll();
        												
    // I need a map between the acceptable topics and an Id value.     												
    public static final Map<String,Topic> whiteTopicsDB = new Map<String,Topic>();
    
    //create a check to ensure the Topic name in the custom setting is valid and has an Id. Otherwise 
    //we could create problems when we try to update the junction. 
    public static Set<String> missingTopicNames = new Set<String>();
    public static Set<Id> convertLeads = new Set<Id>();
    
    static {
    	Set<String> whiteTopicNames = new Set<String>();
    	
    	for(topic_Graylisted_Topic__c gt : kGraylist.values()){
    		whiteTopicNames.add(gt.Alternate_Topic__c);
    	}
    	
    	for (Topic t : [SELECT Id,Name,TalkingAbout from Topic where Name in : whiteTopicNames]){
    		whiteTopicsDB.put(t.Name,t);
    	}
    	
    	//whiteTopics.keySet() contains actual Topic names in the DB
    	//whiteTopicNames contains the alternate Topic names from the Custom setting
    	//produce a set of names that are in the custom setting, but *not* in the DB to prevent errors
    	missingTopicNames = whiteTopicNames;
    	missingTopicNames.removeAll(whiteTopicsDB.keySet()); 
    	
    	System.debug('GRAYLIST----->' + kGraylist);
    	System.debug('TOPICS in DB----->' + whiteTopicsDB);
    	System.debug('TOPICNAMES misconfigured----->' + missingTopicNames);
    	
    }    												
	
	//need all topics currently associated with this Entity record so that we don't duplicate 
	//the topic association record. No two topics should be assigned to the same feed post or
	//other entity. what is an entity will transform as this feature evolves.
	public static Map<Id,Set<Id>> getExistingEntityTopics(List<TopicAssignment> tas){
		
		Map<Id,Set<Id>> existingEntityTopics = new Map<Id,Set<Id>>();
		Set<Id> entityIds = new Set<Id>();
		
		for (TopicAssignment ta : tas) {
			
			entityIds.add(ta.EntityId);
			
		}
		
		//This query is necessary to ensure that all other topics associated with this entity record are checked. 
		//for instance, if the topic SalesforceTopics was already used, but is not in the scope of Trigger.new
		//we need to make sure we don't attempt to assign it a second time.  
		for (TopicAssignment ta : [select EntityId,TopicId from TopicAssignment where EntityId in : entityIds]){
			
			if (!existingEntityTopics.keySet().contains(ta.EntityId)){
				
				existingEntityTopics.put(ta.EntityId,new Set<Id>{ta.TopicId});
				
			} else {
				
				existingEntityTopics.get(ta.EntityId).add(ta.TopicId);
				
			}
			
		}
		
		return existingEntityTopics;
		
	}
	
	public static void convertLeads(Set<Id> leadIds){
		List<Database.LeadConvert> convertList = new List<Database.LeadConvert>();
		for (Id leadId: leadIds) {
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(leadId);
			lc.setSendNotificationEmail(true);
			lc.setConvertedStatus(TopicHelper.kConvertStatus.MasterLabel);
			convertList.add(lc);
		}
		
		List<Database.LeadConvertResult> lcr = Database.convertLead(convertList, false);
		
	}
    
    public static void test(){
		System.debug(kGraylist.keySet());
        System.debug(kGraylist.values());
    }

}