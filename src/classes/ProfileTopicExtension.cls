public with sharing class ProfileTopicExtension {
	
	private ApexPages.StandardController controller; 
	
	private static Map<Id,Topic> topicMap = new Map<Id,Topic>();
	
	private User theUser; 
	
	public List<WordCloudTopic> topicCounts {get;set;}
	public List<Aggregator> lastFiveTopics {get;set;}
	public Integer maxTopicCount {get;set;}
	
	public ProfileTopicExtension(){
		
		try {
			theUser = [select Id, FirstName, LastName, Name from User where Id = : ApexPages.currentPage().getParameters().get('sfdc.userId')]; 
		} catch (Queryexception e) {
			ApexPages.Message mymsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Failed to lookup user for charts.');
			ApexPages.addMessage(mymsg);
		}
		
	}
	
	public void updateTopicCount() {
		System.debug('begin updateTopicCount()');
		updateTopicCount(theUser);
	}
		
	public void updateTopicCount(User u){
		System.debug('begin updateTopicCount(User)');
		topicCounts = new List<WordCloudTopic>();
		lastFiveTopics = new List<Aggregator>();

		Map<Id,ConnectApi.Topic> lastFiveMap = new Map<Id,ConnectApi.Topic>(); 
		List<AggregateResult> results = new List<AggregateResult>();
		
		if (u != null){
			for (ConnectApi.Topic t: ConnectApi.Topics.getRecentlyTalkingAboutTopicsForUser(null,u.Id).topics) {
				lastFiveMap.put(t.Id,t);
			}
		
			results = [Select TopicId TId, Count(Id) TopicCount
											From TopicAssignment 
											Where CreatedById = : u.Id
											Group By TopicId
											Order By TopicId DESC
											Limit 1000];
		}
		
		System.debug('agg query returned: '+results);									
		for (AggregateResult ar : results) {
			
			Integer uTopicCount = Integer.valueof(ar.get('TopicCount'));
			maxTopicCount = uTopicCount > maxTopicCount ? uTopicCount : maxTopicCount;
			
			ConnectApi.Topic t = ConnectApi.Topics.getTopic(null,(String)ar.get('TId'));
			WordCloudTopic cloud = new WordCloudTopic(t.Name,uTopicCount,t.Id,t.Description);
			topicCounts.add(cloud);
			
			if (lastFiveMap.keyset().contains(t.Id)){
				lastFiveTopics.add(new Aggregator(t.Name,uTopicCount,t.TalkingAbout));
			}
			
		}	
		System.debug(lastFiveTopics);
		System.debug(topicCounts);		
	}
	
	public Class Aggregator {
		public String topic {get;set;}
		public Integer userWeight {get;set;}
		public Integer orgWeight {get;set;}
		
		public Aggregator(String t, Integer uWeight, Integer oWeight){
			topic = t;
			userWeight = uWeight;
			orgWeight = oWeight;
		}
	}
	
	
	public ProfileTopicExtension(ApexPages.StandardController ctrl){
		
		this.controller = ctrl; 
		this.theUser = (User) ctrl.getRecord();
		
		System.debug('the current user is: ' + theUser);
		System.debug('my params are:' + ApexPages.currentPage().getParameters().keyset());	
		System.debug('user: ' + ApexPages.currentPage().getParameters().get('sfdc.userId'));	
	}
}