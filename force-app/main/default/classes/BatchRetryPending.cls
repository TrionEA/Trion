global class BatchRetryPending implements Database.Batchable<sObject>{

    global Messaging.EmailFileAttachment csvAttachment;
    //global static List<Messaging.EmailFileAttachment> allAttachments = new List<Messaging.EmailFileAttachment>();
    String EmailMessageParentId;
    global Database.QueryLocator Start(Database.BatchableContext bc) {
        /*String closed='Closed';
        String startDate = Label.BCSVStartDate; 
        String endDate = Label.BCSVEndDate; 
        String query = 'SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, FileTest_Created_Date__c FROM EmailMessage where parent.ClosedDate >= '+startDate+' AND  Parent.ClosedDate  <= ' +endDate;        
        return Database.getQueryLocator(query);*/
        
        String query = 'SELECT Id, Status FROM Case WHERE Status = \'Closed\' AND ClosedDate < LAST_N_DAYS:90 AND CreatedDate > startDate AND CreatedDate < endDate ';
        
        /*String query = 'SELECT EmailMessage_Id__c, Parent_Case_Id__c, Status__c FROM EmailMessage_Html__b WHERE Status__c = 'Pending' AND Parent_Case_Id__c.Status = 'Closed' AND Parent_Case_Id__c.ClosedDate < LAST_N_DAYS:90 AND Parent_Case_Id__c.ClosedDate >= '+startDate+' AND  Parent_Case_Id__c.ClosedDate  <= ' +endDate'';*/
        
        return Database.getQueryLocator(query);
    }
    
    global  void  execute(Database.BatchableContext bc, List<EmailMessage> emailMessages){

		List<Case> caseToBeUpdated = new List<Case>();
        List<EmailMessage> retryEmails = new List<EmailMessage>();
        /*set<Id> caseIdSet = (new Map<Id,SObject>(scopeCases)).keySet();
        for(Case c:scopeCases){
            caseIdSet.add(c.Id);
        }*/
		set<ID> caseIdSet = new set<Id>();
        integer localcount = 0;
        system.debug('emailMessages----------->'+emailMessages);
        Map<Id,integer> mapofIdAttachmentCount = new Map<Id, Integer>();
        for(EmailMessage e : emailMessages){
            //caseIdSet.add(e.ParentId);
            caseIdSet.add(e.id);
        }
        List<Attachment> attList = [select Id, ParentId, Name, BodyLength from Attachment where ParentId IN: caseIdSet
                                    order by createddate asc];
        //List<ContentDocumentLink> cdlList = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: caseIdSet and ContentDocument.CreatedDate = LAST_N_DAYS:10 ];
        List<ContentDocumentLink> cdlList = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: caseIdSet ];
        system.debug('attList----------->'+attList);
            system.debug('cdlList----------->'+cdlList);
        if(!attList.isEmpty()){
            for(Attachment att : attList){
            if(!mapofIdAttachmentCount.keySet().contains(att.ParentId)){
                localcount = 1;
            }
            else{
                ++localcount;
            }
            mapofIdAttachmentCount.put(att.ParentId,localcount); //map of case Id and attachment and Content document records
        }
        }
        if(!cdlList.isEmpty()){
            for(ContentDocumentLink cdl : cdlList ){
            if(!mapofIdAttachmentCount.keySet().contains(cdl.LinkedEntityId)){
                localcount = 1;
            }
            else{
                ++localcount;
            }
            mapofIdAttachmentCount.put(cdl.LinkedEntityId,localcount); //map of case Id and attachment and Content document records
        }
        }
        system.debug('mapofIdAttachmentCount----------->'+mapofIdAttachmentCount);
        for(EmailMessage em :emailMessages){
            system.debug('em ID----------->'+em.Id);
            system.debug('em Parent Id----------->'+em.ParentId);
            //system.debug('mapofIdAttachmentCount.get(em.ParentId)----------->'+mapofIdAttachmentCount.get(em.ParentId));
            system.debug('mapofIdAttachmentCount.get(em.ParentId)----------->'+mapofIdAttachmentCount.get(em.id));
            //ID jobId = System.enqueueJob(new SharePointCountMatchQueueable(em.ParentId,em.Id,mapofIdAttachmentCount.get(em.ParentId)));
            ID jobId = System.enqueueJob(new SharePointCountMatchQueueable(em.ParentId,em.Id,mapofIdAttachmentCount.get(em.id)));
            system.debug('jobId----->'+jobId);
        }
        
        for (EmailMessage email : emailMessages) {
        try {
            uploadEmailToSharePoint(email.Id);
        } catch (Exception e) {
            System.debug('Error uploading email: ' + e.getMessage());
            retryEmails.add(email);
        }           
    }
      
    if (!retryEmails.isEmpty()) {
        for (EmailMessage retryEmail : retryEmails) {
            try {
                uploadEmailToSharePoint(retryEmail.Id);
            } catch (Exception e) {
                System.debug('Retry Error: Failed to upload email on retry: ' + e.getMessage());
            }
        }
    }
    updateEmailStatus(emailMessages);
	}
    
    @future(callout=true)
    public static void uploadEmailToSharePoint(/*EmailMessage email*/ Id emailMessageId) {
    try {
            EmailMessage email = [SELECT Id, Subject, FromAddress, ToAddress, TextBody, HtmlBody, ParentId FROM EmailMessage WHERE Id = :emailMessageId];
            List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :email.Id];
            
            if (documentLinks.isEmpty()) {
                /*throw new CustomException('No documents linked to the email.');*/
                System.debug('No documents linked to the email.');
            }
            
            for (ContentDocumentLink docLink : documentLinks) {
                ContentVersion contentVersion = [SELECT Id, VersionData, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId = :docLink.ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];
                
                Blob fileBody = contentVersion.VersionData;
                String fileName = contentVersion.Title + '.' + contentVersion.FileExtension;
                
                String sharepointFolderName = Label.BCSVSharePointFolderName;
                String driveId = Label.SharepointDriveId;
                String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
                String caseFolderName = email.ParentId; // Assuming ParentId is the caseId
        
                Http httpCallout = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/'+ sharepointFolderName + '/' + caseFolderName + ':/' + encodedFileName.replaceall('\\+', '%20') + ':/content');
                req.setMethod('PUT');
                req.setHeader('Content-Type', 'application/octet-stream');
                req.setHeader('Accept', 'application/json');
                req.setBodyAsBlob(fileBody);
                HTTPResponse res = httpCallout.send(req);
                if(res.getStatusCode() != 201 && res.getStatusCode() != 200) {
                   /*throw new CustomException('File upload failed. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody());*/
                    System.debug('File upload failed. Status Code: '+ res.getStatusCode() + ', Response: ' + res.getBody());
                        }
                    }
		}
     catch (Exception e) {
            System.debug('Exception caught in uploadEmailToSharePoint: ' + e.getMessage());
            Integration_Log_Error__c logError = new Integration_Log_Error__c(Name = 'Upload Fail', getMessage__c = e.getMessage());
            insert logError;
    		System.debug('Email uploaded to SharePoint: ' + emailMessageId);
			}
    }
    
    private void updateEmailStatus(List<EmailMessage> emails) {
    for (EmailMessage email : emails) {
        email.Status = 'Completed';
    }
    update emails;
}
    
    global void finish(Database.BatchableContext BC) {
        System.debug('BatchRetryPending completed at: ' + DateTime.now());
    }
}