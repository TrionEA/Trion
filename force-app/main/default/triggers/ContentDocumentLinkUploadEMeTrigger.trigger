trigger ContentDocumentLinkUploadEMeTrigger on ContentDocumentLink (After insert) {
    List<Id> linkedEntityIds = new List<Id>();
    for (ContentDocumentLink cdLink : Trigger.new) {
        linkedEntityIds.add(cdLink.LinkedEntityId);
    }
    
    Map<Id, SObjectType> linkedEntityTypes = new Map<Id, SObjectType>();
    
    for (Id linkedEntityId : linkedEntityIds) {
        SObjectType linkedEntityType = linkedEntityId.getSObjectType();
        linkedEntityTypes.put(linkedEntityId, linkedEntityType);
    }
    System.debug('printing map:'+ linkedEntityTypes);
    List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
    for (ContentDocumentLink cdLinkList : Trigger.new) {
        if (linkedEntityTypes.get(cdLinkList.LinkedEntityId) ==EmailMessage.SObjectType) {
            contentDocumentLinkList.add(cdLinkList);
        }
    }
    if(trigger.isAfter && trigger.isInsert){
        if (!contentDocumentLinkList.isEmpty()) {
            ContentDocumentUploadQueue.doCalloutFromQueueids(contentDocumentLinkList);
           /* System.debug('Ckecking triggercheck:==========>'+Trigger.new[0].ContentDocument.LatestPublishedVersion.TriggerCheck__c);
            if(Trigger.new[0].ContentDocument.LatestPublishedVersion.TriggerCheck__c == False){
                
                CaseCreationHandler.handleEmailMessageLinks(Trigger.new);
            }
        }
        // CaseCreationHandler.handleEmailMessageLinks(Trigger.new);
        System.debug('Class called from trigger');*/
        }     
       // CaseCreationHandler.handleEmailMessageLinks(Trigger.new);
        
    }
    
}