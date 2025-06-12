global class UpdatingPurgCaseComplete implements Database.Batchable<SObject>, Database.Stateful {
    
    global List<EmailMessageHtml__c> listEmailHtmls;
    
    global UpdatingPurgCaseComplete(List<EmailMessageHtml__c> listEmailHtmls){
        this.listEmailHtmls=listEmailHtmls;
    }
    
    global List<EmailMessageHtml__c> start(Database.BatchableContext BC) {
        return listEmailHtmls;
    }
    
    
    global void execute(Database.BatchableContext BC, List<EmailMessageHtml__c> scope) {
       /* List<String>emIds=new List<String>();
        Map<String,List<String>> MapingCaseIdWithEmailId=new Map<String,List<String>>();
        Map<String,String> mappingEmailIdWithError=new Map<String,String>();
        Map<String,List<String>> MapingCaseIdWithEmailIdSuccess=new Map<String,List<String>>();
        Map<String,List<String>> MapingCaseIdWithEmailIdFailed=new Map<String,List<String>>();
        for(EmailMessageHtml__c emHtmlRec:scope){
            
            emIds.add(emHtmlRec.EmailMessage_Id__c);
            
            if(MapingCaseIdWithEmailId.containsKey(emHtmlRec.Parent_Case_Id__c)) {
                MapingCaseIdWithEmailId.get(emHtmlRec.Parent_Case_Id__c).add(emHtmlRec.EmailMessage_Id__c);
            }else { 
                MapingCaseIdWithEmailId.put(emHtmlRec.Parent_Case_Id__c, new List<String>{emHtmlRec.EmailMessage_Id__c});  
            }
            
            if(emHtmlRec.Error_Message__c!=null){
                mappingEmailIdWithError.put(emHtmlRec.EmailMessage_Id__c,emHtmlRec.Error_Message__c);
            }
            
            if(emHtmlRec.Status__c=='Completed'){
                if (MapingCaseIdWithEmailIdSuccess.containsKey(emHtmlRec.Parent_Case_Id__c)) {
                    MapingCaseIdWithEmailIdSuccess.get(emHtmlRec.Parent_Case_Id__c).add(emHtmlRec.EmailMessage_Id__c);
                }else{
                    MapingCaseIdWithEmailIdSuccess.put(emHtmlRec.Parent_Case_Id__c, new List<String>{emHtmlRec.EmailMessage_Id__c});  
                }
            }
            if(emHtmlRec.Status__c=='Failed'){
                if (MapingCaseIdWithEmailIdFailed.containsKey(emHtmlRec.Parent_Case_Id__c)) {
                    MapingCaseIdWithEmailIdFailed.get(emHtmlRec.Parent_Case_Id__c).add(emHtmlRec.EmailMessage_Id__c);
                }else{  
                    MapingCaseIdWithEmailIdFailed.put(emHtmlRec.Parent_Case_Id__c,new List<String>{emHtmlRec.EmailMessage_Id__c});  
                }
            }
            
        }
        System.debug('Emailed Success are :'+MapingCaseIdWithEmailIdSuccess);
        System.debug('Emailed failed along with case Id are:'+MapingCaseIdWithEmailIdFailed);
        Set<String>caseIds=MapingCaseIdWithEmailId.keySet();
        
        
        
        List<Purge_Case__c> purgeCases = [SELECT Id, EmailMessage_Id__c,ContentDocument_Id__c, Case_Id__c, 	Failed_Content_Doc_Ids__c,Failed_Ids_and_corresponding_error__c
                                          FROM Purge_Case__c 
                                          WHERE Status__c = 'Ready to Purge' and Case_Id__c In: caseIds ];
       
        
        List<Purge_Case__c>listToUpdate=new List<Purge_Case__c>();
        
        for(Purge_Case__c p: purgeCases){
            
            List<String>emailIds=p.EmailMessage_Id__c.split(',\n');
            List<String>emailIdsAfterUpdate=MapingCaseIdWithEmailIdSuccess.get(p.Case_Id__c);
            
           if (!emailIds.isEmpty() && !emailIdsAfterUpdate.isEmpty()) {
    if (emailIds.size() != emailIdsAfterUpdate.size()) {
        // Fetch the list of failed email IDs
        List<String> failedEmailsIds = MapingCaseIdWithEmailIdFailed.get(p.Case_Id__c);
        
        // Check if failedEmailsIds is null or empty
        if (failedEmailsIds != null && !failedEmailsIds.isEmpty()) {
            System.debug('Case id is.......:' + p.Case_Id__c);
            System.debug('Failed emailIds are.......:' + failedEmailsIds + ' And corresponding EmailIds is.......:' + MapingCaseIdWithEmailIdFailed.get(p.Case_Id__c));

            String err = '';
            for (String emId : failedEmailsIds) {
                String errorMsg = mappingEmailIdWithError.containsKey(emId) ? mappingEmailIdWithError.get(emId) : '';
                err += emId;

                if (!String.isEmpty(errorMsg)) {
                    err += ' => ' + errorMsg + ', ';
                } else {
                    err += ', ';
                }
            }

            // Update the status and error field on the Purge_Case__c record
           // p.Status__c = 'Failed';
            p.Failed_Ids_and_corresponding_error__c = err;
             listToUpdate.add(p);
        }
        
    }
     
} 
           
            
        }
        
       Update listToUpdate;
        
    
            */    
        
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Finish Completed');
    }
}