global class ContentDocumentBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id FROM ContentDocument');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<Id, Set<Id>> contentDocumentToLinkedEntitiesMap = new Map<Id, Set<Id>>();
        
        // Populate contentDocumentToLinkedEntitiesMap with ContentDocumentIds and corresponding LinkedEntityIds
        for (sObject record : scope) {
            ContentDocument cd = (ContentDocument)record;
            contentDocumentToLinkedEntitiesMap.put(cd.Id, new Set<Id>());
        }
        
        
        List<User> userLst = [Select Id, Name from user];
        list<id> userNames = new List<id>();
        
       for( User userRec : userLst)
        {
            userNames.add(userRec.id);
        }
        List<ContentDocumentLink> cdLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentToLinkedEntitiesMap.keySet() AND  LinkedEntity.id !=:userNames];
        system.debug('List<ContentDocumentLink> cdLinks' + cdLinks.size());
        // Update contentDocumentToLinkedEntitiesMap with LinkedEntityIds for each ContentDocumentId
        for (ContentDocumentLink cdl : cdLinks) {
            if (contentDocumentToLinkedEntitiesMap.containsKey(cdl.ContentDocumentId)) {
                contentDocumentToLinkedEntitiesMap.get(cdl.ContentDocumentId).add(cdl.LinkedEntityId);
            }
        }
        
        // Find Content Document IDs linked to multiple objects
        Map<Id, Set<Id>> linkedToMultipleEntities = new Map<Id, Set<Id>>();
        for (Id contentDocId : contentDocumentToLinkedEntitiesMap.keySet()) {
            Set<Id> linkedEntities = contentDocumentToLinkedEntitiesMap.get(contentDocId);
            if (linkedEntities.size() > 1) {
                linkedToMultipleEntities.put(contentDocId, linkedEntities);
            }
        }
        
        // Fetch object names associated with linked entity IDs
        Map<Id, String> linkedEntityNames = new Map<Id, String>();
        for (Set<Id> linkedEntities : linkedToMultipleEntities.values()) {
            for (Id linkedEntityId : linkedEntities) {
                String objectName = getObjectName(linkedEntityId);
                linkedEntityNames.put(linkedEntityId, objectName);
            }
        }
        Integer mSize = linkedToMultipleEntities.keySet().size();
        system.debug('number of content documents ' + mSize);
		//system.assertEquals(2, mSize);
        
        system.debug('Content Document IDs linked to multiple objects:');
        for (Id contentDocId : linkedToMultipleEntities.keySet()) {
            system.debug('Content Document ID: ' + contentDocId);
            Set<Id> linkedEntityIds = linkedToMultipleEntities.get(contentDocId);
            system.debug('Linked Entity IDs and Object Names:');
            for (Id linkedEntityId : linkedEntityIds) {
                system.debug('   ID: ' + linkedEntityId + ', Object Name: ' + linkedEntityNames.get(linkedEntityId));
            }
        }
    }
    
    global String getObjectName(Id linkedEntityId) {
        SObjectType objectType = linkedEntityId.getSObjectType();
        DescribeSObjectResult objDescribe = objectType.getDescribe();
        return objDescribe.getName();
    }
    
    global void finish(Database.BatchableContext BC) {
        // Add any finishing logic here
    }
}