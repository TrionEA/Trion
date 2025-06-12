trigger ContentDocumentLinkUploadTrigger on ContentDocumentLink (After insert) {
    List<Id> linkedEntityIds = new List<Id>();
    for (ContentDocumentLink cdLink : Trigger.new) {
        linkedEntityIds.add(cdLink.LinkedEntityId);
    }
    
    Map<Id, SObjectType> linkedEntityTypes = new Map<Id, SObjectType>();
    
    for (Id linkedEntityId : linkedEntityIds) {
        SObjectType linkedEntityType = linkedEntityId.getSObjectType();
        linkedEntityTypes.put(linkedEntityId, linkedEntityType);
    }
    List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
    for (ContentDocumentLink cdLinkList : Trigger.new) {
        if (linkedEntityTypes.get(cdLinkList.LinkedEntityId) ==Account.SObjectType) {
            contentDocumentLinkList.add(cdLinkList);
        }
    }
    if(trigger.isAfter && trigger.isInsert){
        if (!contentDocumentLinkList.isEmpty()) {
            ContentDocumentUploadQueue.doCalloutFromQueueids(contentDocumentLinkList);
        }
    }
    
}