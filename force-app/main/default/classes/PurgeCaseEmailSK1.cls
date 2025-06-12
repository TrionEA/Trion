global class PurgeCaseEmailSK1 implements Database.Batchable<sObject>, Database.Stateful {

    private List<EmailMessageHtml__c> scope;

    public PurgeCaseEmailSK1(List<EmailMessageHtml__c> scope) {
        this.scope = scope;
    }
    

    global List<EmailMessageHtml__c>  start(Database.BatchableContext BC) {
     //   String query = 'SELECT Id, EmailMessage_Id__c, Parent_Case_Id__c, Error_Message__c, Status__c FROM EmailMessageHtml__c WHERE Status__c != \'Closed\'';
      //  System.debug('Query used in start method: ' + query);
        return scope;
    }

    global void execute(Database.BatchableContext BC, List<EmailMessageHtml__c> scope) {
      /*  //System.debug('Executing batch with scope size: ' + scope.size());

        Set<String> emIds = new Set<String>();
        Map<String, List<String>> MapingCaseIdWithEmailId = new Map<String, List<String>>();
        Map<String, String> mappingEmailIdWithError = new Map<String, String>();
        
        for (EmailMessageHtml__c emHtmlRec : scope) {
            emIds.add(emHtmlRec.EmailMessage_Id__c);
           

            if (MapingCaseIdWithEmailId.containsKey(emHtmlRec.Parent_Case_Id__c)) {
                List<String> emailIds = MapingCaseIdWithEmailId.get(emHtmlRec.Parent_Case_Id__c);
                emailIds.add(emHtmlRec.EmailMessage_Id__c);
                MapingCaseIdWithEmailId.put(emHtmlRec.Parent_Case_Id__c, emailIds);
            } else {
                List<String> emailIds = new List<String>();
                emailIds.add(emHtmlRec.EmailMessage_Id__c);
                MapingCaseIdWithEmailId.put(emHtmlRec.Parent_Case_Id__c, emailIds);
            }

            if (emHtmlRec.Error_Message__c != null) {
                mappingEmailIdWithError.put(emHtmlRec.EmailMessage_Id__c, emHtmlRec.Error_Message__c);
            }
        }
       // System.debug('MapingCaseIdWithEmailId: ' + MapingCaseIdWithEmailId);
        //System.debug('MappingEmailIdWithError: ' + mappingEmailIdWithError);Arch_PopuPurgeLogsEmails


        Map<String, List<String>> MapingCaseIdWithEmailIdSuccess = new Map<String, List<String>>();
        for (EmailMessageHtml__c emHtSucc : scope) {
            if (emHtSucc.Status__c == 'Completed') {
                if (MapingCaseIdWithEmailIdSuccess.containsKey(emHtSucc.Parent_Case_Id__c)) {
                    List<String> emailIds = MapingCaseIdWithEmailIdSuccess.get(emHtSucc.Parent_Case_Id__c);
                    emailIds.add(emHtSucc.EmailMessage_Id__c);
                    MapingCaseIdWithEmailIdSuccess.put(emHtSucc.Parent_Case_Id__c, emailIds);
                } else {
                    List<String> emailIds = new List<String>();
                    emailIds.add(emHtSucc.EmailMessage_Id__c);
                    MapingCaseIdWithEmailIdSuccess.put(emHtSucc.Parent_Case_Id__c, emailIds);
                }
            }
        }
        //System.debug('MapingCaseIdWithEmailIdSuccess: ' + MapingCaseIdWithEmailIdSuccess);

        Map<String, List<String>> MapingCaseIdWithEmailIdFailed = new Map<String, List<String>>();
        for (EmailMessageHtml__c emHtFail : scope) {
            if (emHtFail.Status__c == 'Failed') {
                if (MapingCaseIdWithEmailIdFailed.containsKey(emHtFail.Parent_Case_Id__c)) {
                    List<String> emailIds = MapingCaseIdWithEmailIdFailed.get(emHtFail.Parent_Case_Id__c);
                    emailIds.add(emHtFail.EmailMessage_Id__c);
                    MapingCaseIdWithEmailIdFailed.put(emHtFail.Parent_Case_Id__c, emailIds);
                } else {
                    List<String> emailIds = new List<String>();
                    emailIds.add(emHtFail.EmailMessage_Id__c);
                    MapingCaseIdWithEmailIdFailed.put(emHtFail.Parent_Case_Id__c, emailIds);
                }
            }
        }
        System.debug('MapingCaseIdWithEmailIdFailed: ' + MapingCaseIdWithEmailIdFailed);

        Set<String> caseIds = MapingCaseIdWithEmailId.keySet();
        System.debug('Case IDs: ' + caseIds);

        List<Stagging__c> staggingRecordsFailure = [
            SELECT Id, Content_Document_Id__c, Error_Message__c, Linked_Entity_Id__c, Status__c 
            FROM Stagging__c 
            WHERE Linked_Entity_Id__c IN :emIds AND Status__c = 'Failed'
        ];
        System.debug('Stagging records (Failure): ' + staggingRecordsFailure);

        List<Stagging__c> staggingRecordssuccess = [
            SELECT Id, Content_Document_Id__c, Linked_Entity_Id__c, Status__c 
            FROM Stagging__c 
            WHERE Linked_Entity_Id__c IN :emIds AND Status__c = 'Completed'
        ];
        System.debug('Stagging records (Success): ' + staggingRecordssuccess);

        Map<String, List<String>> contentDocumentMapSuccess = new Map<String, List<String>>();
        for (Stagging__c s : staggingRecordssuccess) {
            if (!contentDocumentMapSuccess.containsKey(s.Linked_Entity_Id__c)) {
                contentDocumentMapSuccess.put(s.Linked_Entity_Id__c, new List<String>());
            }
            contentDocumentMapSuccess.get(s.Linked_Entity_Id__c).add(s.Content_Document_Id__c);
        }
      //  System.debug('Content Document Map (Success): ' + contentDocumentMapSuccess);

        List<Purge_Case__c> purgeCases = [
            SELECT Id, EmailMessage_Id__c, Case_Id__c, ContentDocument_Id__c, Failed_Ids_and_corresponding_error__c
            FROM Purge_Case__c 
            WHERE Status__c = 'Ready to Purge' AND Case_Id__c IN :caseIds
        ];
       // System.debug('Purge Cases fetched: ' + purgeCases);

        Map<String, List<String>> mapCaseWithContIdSuccess = new Map<String, List<String>>();
        for (Purge_Case__c p : purgeCases) {
            List<String> emailIds = p.EmailMessage_Id__c.split(',\n');
            List<String> contentDocIds = new List<String>();
            for (String emId : emailIds) {
                if (contentDocumentMapSuccess.containsKey(emId)) {
                    List<String> docs = contentDocumentMapSuccess.get(emId);
                    contentDocIds.addAll(docs);
                }
            }
            if (!mapCaseWithContIdSuccess.containsKey(p.Case_Id__c)) {
                mapCaseWithContIdSuccess.put(p.Case_Id__c, new List<String>());
            }
            mapCaseWithContIdSuccess.get(p.Case_Id__c).addAll(contentDocIds);
        }
       // System.debug('Map Case With Content Document ID (Success): ' + mapCaseWithContIdSuccess);

        Map<String, List<String>> contentDocumentMapFailure = new Map<String, List<String>>();
        Map<String, String> mapConIdwithError = new Map<String, String>();
        for (Stagging__c s : staggingRecordsFailure) {
            mapConIdwithError.put(s.Content_Document_Id__c, s.Error_Message__c);
            if (!contentDocumentMapFailure.containsKey(s.Linked_Entity_Id__c)) {
                contentDocumentMapFailure.put(s.Linked_Entity_Id__c, new List<String>());
            }
            contentDocumentMapFailure.get(s.Linked_Entity_Id__c).add(s.Content_Document_Id__c);
        }
        System.debug('Content Document Map (Failure): ' + contentDocumentMapFailure);

        Map<String, List<String>> mapCaseWithContIdFailure = new Map<String, List<String>>();
        for (Purge_Case__c p : purgeCases) {
            List<String> emailIds = p.EmailMessage_Id__c.split(',\n');
            List<String> contentDocIds = new List<String>();
            for (String emId : emailIds) {
                if (contentDocumentMapFailure.containsKey(emId)) {
                    List<String> docs = contentDocumentMapFailure.get(emId);
                    contentDocIds.addAll(docs);
                }
            }
            if (!mapCaseWithContIdFailure.containsKey(p.Case_Id__c)) {
                mapCaseWithContIdFailure.put(p.Case_Id__c, new List<String>());
            }
            mapCaseWithContIdFailure.get(p.Case_Id__c).addAll(contentDocIds);
        }
        System.debug('Map Case With Content Document ID (Failure): ' + mapCaseWithContIdFailure);

        List<Purge_Case__c> purgeCasesToUpdateToSuccess = new List<Purge_Case__c>();
        List<Purge_Case__c> purgeCasesToUpdateToFailure = new List<Purge_Case__c>();
        for (Purge_Case__c p : purgeCases) {
            List<String> emailIds = p.EmailMessage_Id__c.split(',\n');
            List<String> successEmailIds = MapingCaseIdWithEmailIdSuccess.get(p.Case_Id__c);
            if (!successEmailIds.isEmpty()) {
                p.Status__c = 'Success';
                purgeCasesToUpdateToSuccess.add(p);
            } else {
                List<String> failedEmailsIds = MapingCaseIdWithEmailIdFailed.get(p.Case_Id__c);
                List<String> contentDocIdsFailure = mapCaseWithContIdFailure.get(p.Case_Id__c);
                if (!contentDocIdsFailure.isEmpty()) {
                    p.Status__c = 'Failed';
                    p.Failed_Ids_and_corresponding_error__c = failedEmailsIds + '\n' + contentDocIdsFailure;
                    purgeCasesToUpdateToFailure.add(p);
                }
            }
        }
        System.debug('Purge Cases to update (Success): ' + purgeCasesToUpdateToSuccess);
        System.debug('Purge Cases to update (Failure): ' + purgeCasesToUpdateToFailure);

        update purgeCasesToUpdateToSuccess;
        update purgeCasesToUpdateToFailure;*/
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch process finished.');
    }
}