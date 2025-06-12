global class SharePointStagingBatchable_V2 implements Database.Batchable<sObject>{
    
    public SharePointStagingBatchable_V2(){
    }
    
    public List<EmailMessage> start(Database.BatchableContext BC) {
        String startDateLabel = Label.startDate;
        String endDateLabel = Label.endDate; 
        
        Datetime startDate = Date.valueOf(startDateLabel);
        Datetime endDate = DateTime.valueOf(endDateLabel);
         System.debug('SharePointStagingBatchable_V2 is startDateLabel' +startDateLabel);
         System.debug('SharePointStagingBatchable_V2 is endDateLabel' +endDateLabel);
         System.debug('SharePointStagingBatchable_V2 is startDate' +startDate);
         System.debug('SharePointStagingBatchable_V2 is endDate' +endDate);
        
       return [SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, 
                                       TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, 
                                       ToAddress, CcAddress, BccAddress, Incoming, Status, MessageDate, ReplyToEmailMessageId, 
                                       IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, 
                                       ClientThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, 
                                       FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, SystemModstamp, IsDeleted, FileTest_Created_Date__c FROM EmailMessage WHERE Parent.ClosedDate >= :startDate AND Parent.ClosedDate <= :endDate limit 500];
       // return [SELECT Id FROM EmailMessage WHERE ParentId IN (SELECT Id FROM Case WHERE have_more_character__c = true) AND Parent.ClosedDate >= 2024-08-29T00:00:00Z AND Parent.ClosedDate <= 2024-08-30T23:59:59Z  limit 500];
    }
    
    public void execute(Database.BatchableContext BC, List<EmailMessage> emailList){
        
        try{    
              System.debug('SharePointStagingBatchable_V2 is List<EmailMessage> emailList' +emailList);
            GeneratingCsv_V2.converttoCsv(emailList);
        }catch(exception e){
            System.debug('SharePointStagingBatchable_V2 exception e' +e.getMessage());
        }    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('SharePointStagingBatchable_V2 is finished');
    }
    
}