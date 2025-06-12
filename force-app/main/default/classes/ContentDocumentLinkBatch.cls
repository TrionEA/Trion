global class ContentDocumentLinkBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink ');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<Id> contentDocumentIds = new Set<Id>();
        
        for (sObject record : scope) {
            ContentDocumentLink cdLink = (ContentDocumentLink)record;
            
            contentDocumentIds.add(cdLink.ContentDocumentId);
        }
        
        // Now you can do whatever you want with the set of ContentDocumentIds
        
        // Example: Print out the set
        System.debug(contentDocumentIds);
        
    }
    
    global void finish(Database.BatchableContext BC) {
        // Any finish logic you want to implement
    }
}