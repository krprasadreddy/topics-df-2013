//object that represents a topic in the word cloud with weighting / description / link
public class WordCloudTopic {
        public String text {get;set;}
        public Integer weight {get;set;}
        public LinkAttribute link {get;set;}
        public HtmlAttribute html {get;set;}
        
        public WordCloudTopic(ConnectApi.Topic chatterTopic) {
			//this should be working, but isn't for some reason. 
            //WordCloudTopic(chatterTopic.name, chatterTopic.TalkingAbout, chatterTopic.Id, chatterTopic.Description);

            this.text= chatterTopic.Name; //, 
            this.weight = chatterTopic.TalkingAbout; // weight = number of people talking about topic
            this.link = new LinkAttribute('/' + chatterTopic.Id,'_top'); // link to the topic page
            this.html = new htmlAttribute(chatterTopic.Description); // title = topic description
        }
        
        public WordCloudTopic(String name, Integer weight, String id, String descr){
            this.text = name;
            this.weight = weight; // weight = number of people talking about topic
            this.link = new LinkAttribute('/' + id,'_top') ; // link to the topic page
            this.html = new htmlAttribute(descr); // title = topic description
        }

    public class HtmlAttribute {
        public String title;
        
        public HtmlAttribute(String title) {
            this.title = title;
        }
    }
    
    public class LinkAttribute {
    	public String href;
    	public String target;
    	
    	public LinkAttribute(String h, String t){
    		this.href = h;
    		this.target = t;
    	}
    	
    }

}