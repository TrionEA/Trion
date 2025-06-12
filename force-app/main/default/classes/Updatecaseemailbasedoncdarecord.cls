global class Updatecaseemailbasedoncdarecord implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Fetch EmailMessages related to accounts marked for deletion in the last 4 days
        String eQuery = 'SELECT Id, Subject, ParentId, CreatedDate, Parent.CaseNumber FROM EmailMessage WHERE Parent.Account.toBeDeleted__c = true AND CreatedDate = LAST_N_DAYS:4';
        system.debug('Query: ' + eQuery);
        return Database.getQueryLocator(eQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<EmailMessage> scope) {
    List<CaseEm__c> listToInsert = new List<CaseEm__c>();
    
    for(EmailMessage em : scope) {
        // Query ContentDocumentLinks related to the EmailMessage
        List<ContentDocumentLink> cdlinkList = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility, ContentDocument.Title, ContentDocument.FileExtension 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId = :em.Id];        
        Integer cdlinkListSize = cdlinkList.size();
        system.debug('ContentDocumentLink count: ' + cdlinkListSize);
        
        // Query Attachments related to the EmailMessage
        List<Attachment> attList = [SELECT Id, IsDeleted, ParentId, Name, IsPrivate, ContentType, BodyLength, Body, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Description 
                                    FROM Attachment 
                                    WHERE ParentId = :em.Id];
        Integer attListSize = attList.size();
        system.debug('Attachment count: ' + attListSize);
        
        // If there are more ContentDocumentLinks than Attachments, insert a CaseEm__c record
        if(cdlinkListSize > attListSize) {
            for (Attachment att : attList) {
                for (ContentDocumentLink cdLink : cdlinkList) {
                    CaseEm__c customObject = new CaseEm__c();
                    customObject.EmailMessage_Id__c = em.Id;
                    customObject.Case_Id__c = em.ParentId;
                    customObject.Attachment_Id__c = att.Id;
                    customObject.Attachment_Name__c = att.Name;
                   // customObject.ContentDocumentId__c = cdLink.ContentDocumentId;
                    listToInsert.add(customObject);
                }
            }
        }
    }
    
    // Insert CaseEm__c records if any
    if(!listToInsert.isEmpty()) {
        insert listToInsert;
        system.debug('Inserted ' + listToInsert.size() + ' CaseEm__c records.');
    }
}

    
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch is completed');
    }
}