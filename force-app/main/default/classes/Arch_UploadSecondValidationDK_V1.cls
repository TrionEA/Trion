global class Arch_UploadSecondValidationDK_V1 implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select id, ParentId from EmailMessage where  Parent.CreatedDate =TODAY';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EmailMessage> emailList) {
        Set<Id> emailId = new Set<Id>();
        Set<Id> caseSetId = new Set<Id>();
        String emailIdHtml;
        String emailCaseId;
        String emailIdStagging;
        for(EmailMessage emList : emailList){
            emailId.add(emList.Id);     
            caseSetId.add(emList.ParentId);
        }
        
        //List<EmailMessageHTML__c> emailHtmlList = [Select Id, EmailMessage_Id__c, Parent_Case_Id__c From EmailMessageHTML__c where Parent_Case_Id__c =: caseSetId];
        List<EmailMessageHTML__c> emailHtmlList = [Select Id, EmailMessage_Id__c, Parent_Case_Id__c From EmailMessageHTML__c where Retry_Executed_Count__c = 1];
        For(EmailMessageHTML__c emailHtml : emailHtmlList){
            emailIdHtml = emailHtml.Id;        
            emailCaseId = emailHtml.Parent_Case_Id__c;
        }
        
        
        
        //List<Stagging__c> staggingList = [Select id, Chunk__c, Content_Document_Id__c, Linked_Entity_Id__c From Stagging__c where Linked_entity_id__c =: emailId];
        List<Stagging__c> staggingList = [Select id, Chunk__c, Content_Document_Id__c, Linked_Entity_Id__c From Stagging__c where Retry_Executed_Count__c = 1];
        For(Stagging__c stagingEmailId : staggingList){
            emailIdStagging = stagingEmailId.Id;
        }
        

        
        //ID jobId = System.enqueueJob(new Arch_SharePointSecondCountQueue(parentcaseid,emailid,mapofIdAttachmentCount.get(emailid)));
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}