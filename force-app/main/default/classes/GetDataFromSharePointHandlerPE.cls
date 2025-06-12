public with sharing class GetDataFromSharePointHandlerPE /*implements EventBusSubscriberInterface*/ {
  /*  public void handleEvent(EventBusSubscriber.EventPayload event) {
        GetDataFromSharepoint__e emailEvent = (GetDataFromSharepoint__e) event.getEvent();
        
        List<Map<String, String>> csvInfoList = emailEvent.csvInfoList;
        
        try {
            List<CustomObject__c> recordsToInsert = new List<CustomObject__c>();
            for (Map<String, String> csvInfo : csvInfoList) {
                CustomObject__c obj = new CustomObject__c();
                obj.Name = csvInfo.get('fileName');
                recordsToInsert.add(obj);
            }
            insert recordsToInsert;
        } catch (Exception e) {
            System.debug('Error processing Platform Event: ' + e.getMessage());
        }
    }
    

    
    public interface EventBusSubscriberInterface {
        void handleEvent(EventBusSubscriber.EventPayload event);
    }
    public class EventBusSubscriber implements EventBusSubscriberInterface {
        public void handleEvent(EventBusSubscriber.EventPayload event) {
        }
    }
    
    public class EventBus {
        public static Database.SaveResult publish(Object event) {
            return new Database.SaveResult();
        }
    }
*/
}