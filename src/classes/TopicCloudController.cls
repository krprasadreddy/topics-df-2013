public class TopicCloudController {
    
    //attributes used in Chatter in Apex topic retrieval
    public Id commId { get; set; }
    public String query { get; set; }
    public Integer pSize { get; set; }
    public Integer pNum { get; set; }
    public List<WordCloudTopic> topics {get;set;}
    
    //generates JSON string for the JQCloud plugin to render https://github.com/lucaong/jQCloud
    public String chatterTopicCloudJSON {
        get {
        	
        	list<WordCloudTopic> wordCloudTopics = new list<WordCloudTopic>();
        	
        	if (topics != null && topics.size() > 0) {
        		
        		wordCloudTopics = topics; 
        		
        	} else {
	            //query chatter in apex API for trending topics
	            //for appropriate network / query / page number / page size
	            ConnectApi.TopicPage chatterTopicPage = ConnectApi.Topics.getTopics(commId, query, pNum, pSize);
	            
	            
	            
	            for(ConnectApi.Topic chatterTopic : chatterTopicPage.topics) {
	                wordCloudTopics.add(new WordCloudTopic(chatterTopic));
	            }
            
        	}
            return JSON.serialize(wordCloudTopics);
        }
    }

//refactored to top level class    
    //object that represents a topic in the word cloud with weighting / description / link
/*    public class WordCloudTopic {
        public String text;
        public Integer weight;
        public String link;
        public HtmlAttribute html;
        
        public WordCloudTopic(ConnectApi.Topic chatterTopic) {
			//this should be working, but isn't for some reason. 
            //WordCloudTopic(chatterTopic.name, chatterTopic.TalkingAbout, chatterTopic.Id, chatterTopic.Description);

            this.text= chatterTopic.Name; //, 
            this.weight = chatterTopic.TalkingAbout; // weight = number of people talking about topic
            this.link = '/' + chatterTopic.Id; // link to the topic page
            this.html = new htmlAttribute(chatterTopic.Description); // title = topic description
        }
        
        public WordCloudTopic(String name, Integer weight, String id, String descr){
            this.text = name;
            this.weight = weight; // weight = number of people talking about topic
            this.link = '/' + id; // link to the topic page
            this.html = new htmlAttribute(descr); // title = topic description
        }
    }
    
    public class HtmlAttribute {
        public String title;
        
        public HtmlAttribute(String title) {
            this.title = title;
        }
    }
*/    
}