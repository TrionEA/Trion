public class GeneratingCsv_V2 {
    
    public static void converttoCsv(List<EmailMessage> emailList){
        
        String startDateLabel = Label.startDate; 
        String endDateLabel = Label.endDate; 
        
        Datetime startDate = Date.valueOf(startDateLabel);
        Datetime endDate = Date.valueOf(endDateLabel);
        List<Id>emIds=new List<Id>();
        for(EmailMessage em:emailList){
            emIds.add(em.id);
        }
        
        try {
            for (EmailMessage emRec : [SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, 
                                       TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, 
                                       ToAddress, CcAddress, BccAddress, Incoming, Status, MessageDate, ReplyToEmailMessageId, 
                                       IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, 
                                       ClientThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, 
                                       FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, SystemModstamp, IsDeleted, FileTest_Created_Date__c 
                                       FROM EmailMessage 
                                       WHERE Id IN :emIds 
                                       /*AND Parent.ClosedDate >= :startDate 
                                       AND Parent.ClosedDate <= :endDate*/]){
                                           
                                           String formattedCreatedDate = emRec.CreatedDate != null ? emRec.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') : '';
                                           String cleanedHtmlBody = emRec.HtmlBody != null ? emRec.HtmlBody.replaceAll('[\\n\\r]+', ' ') : 'Null';
                                           String cleanedTextBody = emRec.TextBody != null ? emRec.TextBody.replaceAll('[\\n\\r]+', ' ') : 'Null';
                                           String truncatedHtmlBody = cleanedHtmlBody.length() > 10000000 ? cleanedHtmlBody.substring(0, 10000000) : cleanedHtmlBody;
                                           
                                           String generatedCSVFile = 'Id,ParentId,ActivityId,CreatedById,CreatedDate,LastModifiedDate,LastModifiedById,TextBody,Headers,Subject,Name,FromName,FromAddress,ValidatedFromAddress,ToAddress,CcAddress,BccAddress,Incoming,Status,MessageDate,ReplyToEmailMessageId,IsPrivateDraft,IsExternallyVisible,MessageIdentifier,ThreadIdentifier,ClientThreadIdentifier,IsClientManaged,RelatedToId,IsTracked,IsOpened,FirstOpenedDate,LastOpenedDate,IsBounced,EmailTemplateId,FileTest_Created_Date__c,HtmlBody\n';
                                           
                                           String fileRow = '\"##  ' + emRec.Id + '\",\"##  '+ emRec.ParentId + '\",\"##  ' + emRec.ActivityId  + '\",\"##  '+ emRec.CreatedById  + '\",\"##  ' + formattedCreatedDate + '\",\"##  ' + emRec.LastModifiedDate  + '\",\"##  ' + emRec.LastModifiedById + '\",\"##  ' + emRec.SystemModstamp + '\",\"##  '+ cleanedTextBody + '\",\"##  ' + emRec.Headers + '\",\"##  ' + emRec.Subject + '\",\"##  ' + emRec.Name + '\",\"##  ' + emRec.FromName + '\",\"##  ' + emRec.FromAddress + '\",\"##  ' + emRec.ValidatedFromAddress + '\",\"##  ' + emRec.ToAddress + '\",\"##  ' + emRec.CcAddress + '\",\"##  ' + emRec.BccAddress + '\",\"##  ' + emRec.Incoming + '\",\"##  '  + emRec.Status + '\",\"##  ' + emRec.MessageDate + '\",\"##  '+ emRec.IsDeleted + '\",\"##  ' + emRec.ReplyToEmailMessageId + '\",\"##  ' + emRec.IsPrivateDraft + '\",\"##  ' + emRec.IsExternallyVisible + '\",\"##  ' + emRec.MessageIdentifier + '\",\"##  ' + emRec.ThreadIdentifier + '\",\"##  ' + emRec.ClientThreadIdentifier + '\",\"##  ' + emRec.IsClientManaged + '\",\"##  ' + emRec.RelatedToId + '\",\"##  ' + emRec.IsTracked + '\",\"##  ' + emRec.IsOpened + '\",\"##  ' + emRec.FirstOpenedDate + '\\",,\"##  ' + emRec.LastOpenedDate + '\",\"##  ' + emRec.IsBounced + '\",\"##  ' + emRec.EmailTemplateId + '\",\"##  ' + emRec.FileTest_Created_Date__c + '\",\"##  '  + truncatedHtmlBody  + '\",..';
                                           
                                           generatedCSVFile += fileRow;
                                           
                                           
                                           
                                           String csvContent = generatedCSVFile;
                                           Blob csvBlob = Blob.valueOf(csvContent);
                                           String csvName = 'EmailMessageDetails_' + emRec.Id + '.csv';
                                           String csvId = csvName.substring(20, 38);
                                           
                                           
                                           
                                           system.debug('From the query the id is' + emRec.Id );
                                           
                                           String sharepointFolderName = Label.SharepointfolderName;
                                           String encodedFileName = 'EmailMessageDetails_' + emRec.Id + '.csv';
                                           String driveId = Label.SharepointDriveId;
                                           String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
                                           String encodedObjectName = emRec.Id;
                                           String encodedParentCaseId = emRec.ParentId;
                                           
                                           
                                           GeneratedCsvUploadingToSP_V1.fileMigration(encodedParentCaseId, encodedObjectName, encodedFileName, csvBlob);
                                          /* 
                                           String endpoint = 'callout:Sharepoint/v1.0/drives/' + encodedDriveId + '/root:/' + sharepointFolderName + '/' + encodedParentCaseId + '/' + encodedObjectName + '/' + encodedFileName.replaceAll('\\+', '%20') + ':/content';
                                           
                                           Http httpCallout = new Http();
                                           HttpRequest req = new HttpRequest();
                                           
                                           req.setEndpoint(endpoint);
                                           req.setMethod('PUT');
                                           req.setHeader('Content-Type', 'text/csv'); 
                                           req.setHeader('Accept', 'application/json');
                                           
                                           req.setBodyAsBlob(csvBlob);
                                           HTTPResponse res = httpCallout.send(req);
                                           String jsonString = res.getBody();
                                           Integer statuscode = res.getStatusCode();
                                           
                                           System.debug('Response retrieved -> ' + res.getBody());
                                           System.debug('Status code -> ' + res.getStatusCode());
                                           System.debug('Status -> ' + res.getStatus());
                                           
                                           if (statuscode == 201 || statuscode == 200) {
                                               System.debug('res.getStatusCode()==> '+res.getStatusCode());
                                               //processSharePointResponse(jsonString, emRec);
                                           }
                                           */
                                       }
            
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
    
}