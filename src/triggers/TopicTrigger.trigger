trigger TopicTrigger on Topic (after insert, after update) {

    for (Topic t : Trigger.new){
        System.debug(SobjectType.Topic.fields);
    }

}