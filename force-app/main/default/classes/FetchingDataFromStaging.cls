global class FetchingDataFromStaging implements Database.Batchable<SObject>, Database.Stateful {
    List<Stagging__c> listStagin;  // This list is passed in the constructor
 
    // Constructor to initialize the list from the trigger
    global FetchingDataFromStaging(List<Stagging__c> listStagin) {
        this.listStagin = listStagin;
    }
 
    // Use the provided list in the start method
    global Iterable<Stagging__c> start(Database.BatchableContext BC) {
        // Return the already filtered list of Stagging__c records
        return listStagin;
    }
 
    // The execute method remains the same
    global void execute(Database.BatchableContext BC, List<Stagging__c> scope) {
        // Step 1: Collect all Linked Entity IDs from the scope
       /* Set<String> linkedEntityIds = new Set<String>();
        for (Stagging__c s : scope) {
            if (s.Linked_Entity_Id__c != null) {
                linkedEntityIds.add(s.Linked_Entity_Id__c);
            }
        }
 
        // Step 2: Map Case IDs to Email Message IDs
        Map<String, List<String>> caseToEmailMap = new Map<String, List<String>>();
        List<Purge_Case__c> purgeCases = [SELECT Id, EmailMessage_Id__c, Case_Id__c, ContentDocument_Id__c, Attachment_Ids__c, Status__c
                                          FROM Purge_Case__c 
                                          WHERE Status__c = 'Ready to Upload'];
 
        for (Purge_Case__c p : purgeCases) {
            if (p.EmailMessage_Id__c != null) {
                List<String> emailIds = p.EmailMessage_Id__c.split(',');
                caseToEmailMap.put(p.Case_Id__c, emailIds);
            }
        }
 
        // Step 3: Organize the queried data for Content Document and Attachment IDs
        Map<String, List<String>> contentDocumentMap = new Map<String, List<String>>();
        Map<String, List<String>> attachmentMap = new Map<String, List<String>>();
 
        for (Stagging__c s : scope) {
            // Add content documents
            if (s.Content_Document_Id__c != null) {
                if (!contentDocumentMap.containsKey(s.Linked_Entity_Id__c)) {
                    contentDocumentMap.put(s.Linked_Entity_Id__c, new List<String>());
                }
                contentDocumentMap.get(s.Linked_Entity_Id__c).add(s.Content_Document_Id__c);
            }
 
            // Add attachments
            if (s.From_sObject__c == 'Attachment' && s.Chunk__c != null) {
                if (!attachmentMap.containsKey(s.Linked_Entity_Id__c)) {
                    attachmentMap.put(s.Linked_Entity_Id__c, new List<String>());
                }
                attachmentMap.get(s.Linked_Entity_Id__c).add(s.Chunk__c);
            }
        }
 
        // Step 4: Compare and update Purge_Case__c records
        List<Purge_Case__c> casesToUpdate = new List<Purge_Case__c>();
 
        for (String caseId : caseToEmailMap.keySet()) {
            List<String> emailIds = caseToEmailMap.get(caseId);
            Set<String> emailIdSet = new Set<String>(emailIds);
 
            // Collect Content Document IDs for the current case
            List<String> collectedContentDocIds = new List<String>();
            for (String linkedEntityId : contentDocumentMap.keySet()) {
                if (emailIdSet.contains(linkedEntityId)) {
                    collectedContentDocIds.addAll(contentDocumentMap.get(linkedEntityId));
                }
            }
 
            // Collect Attachment IDs for the current case
            List<String> collectedAttachments = new List<String>();
            for (String linkedEntityId : attachmentMap.keySet()) {
                if (emailIdSet.contains(linkedEntityId)) {
                    collectedAttachments.addAll(attachmentMap.get(linkedEntityId));
                }
            }
 
            // Update Purge_Case__c record with both Content Document IDs and Attachment IDs
            for (Purge_Case__c p : purgeCases) {
                if (p.Case_Id__c == caseId) {
                    if (!collectedContentDocIds.isEmpty()) {
                        p.ContentDocument_Id__c = String.join(collectedContentDocIds, ',');
                    }
                    if (!collectedAttachments.isEmpty()) {
                        p.Attachment_Ids__c = String.join(collectedAttachments, ',');
                    }
                    casesToUpdate.add(p);
                }
            }
        }
 
        // Step 5: Perform DML update
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }*/
    }
 
    
    global void finish(Database.BatchableContext BC) {
        // Test
    }
}