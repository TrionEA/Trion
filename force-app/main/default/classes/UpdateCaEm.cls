global class UpdateCaEm implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String eQuery = 'SELECT Id, Subject, ParentId, CreatedDate, Parent.CaseNumber FROM EmailMessage WHERE CreatedDate < LAST_N_DAYS:1 LIMIT 10';
        system.debug('Query: ' + eQuery);
        return Database.getQueryLocator(eQuery);
    }

    global void execute(Database.BatchableContext BC, List<EmailMessage> scope) {
        try {
            // Collect EmailMessage Ids
            Set<Id> emailMessageIds = new Set<Id>();
            for (EmailMessage em : scope) {
                emailMessageIds.add(em.Id);
            }
            
            // Query Attachments related to EmailMessages
            Map<Id, List<Attachment>> emailAttachmentsMap = new Map<Id, List<Attachment>>();
            for (Attachment att : [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId IN :emailMessageIds]) {
                if (!emailAttachmentsMap.containsKey(att.ParentId)) {
                    emailAttachmentsMap.put(att.ParentId, new List<Attachment>());
                }
                emailAttachmentsMap.get(att.ParentId).add(att);
            }

            List<CaseEm__c> listToInsert = new List<CaseEm__c>();

            // Iterate over EmailMessages and their Attachments
            for (EmailMessage em : scope) {
                List<Attachment> attachments = emailAttachmentsMap.get(em.Id);

                if (attachments != null) {
                    for (Attachment att : attachments) {
                        CaseEm__c customObject = new CaseEm__c();
                        customObject.EmailMessage_Id__c = em.Id;
                        customObject.Case_Id__c = em.ParentId;
                        customObject.Attachment_Name__c = att.Name;
                        customObject.Attachment_Id__c = att.Id;

                        listToInsert.add(customObject);

                        system.debug('Creating CaseEm__c record for Attachment: ' + att.Name);
                    }
                }
            }

            if (!listToInsert.isEmpty()) {
                insert listToInsert;
                system.debug('Inserted ' + listToInsert.size() + ' CaseEm__c records.');
            } else {
                system.debug('No CaseEm__c records to insert.');
            }
        } catch(Exception e) {
            system.debug('Error occurred: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Add any finish logic if needed
    }
}