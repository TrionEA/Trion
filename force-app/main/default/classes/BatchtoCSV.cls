global class BatchtoCSV implements Database.Batchable<sObject>{
    
    global Messaging.EmailFileAttachment csvAttachment;
    //global static List<Messaging.EmailFileAttachment> allAttachments = new List<Messaging.EmailFileAttachment>();
    String EmailMessageParentId;
    global Database.QueryLocator Start(Database.BatchableContext bc) {
        String query = 'SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, FileTest_Created_Date__c FROM EmailMessage WHERE Parent.Account.toBeDeleted__c = true';        
        return Database.getQueryLocator(query);
    }
    
    global  void  execute(Database.BatchableContext bc, List<EmailMessage> emList){        
        // Loop through each record and generate and send individual CSV files           
        //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();        
        for (EmailMessage em : emList) {
            EmailMessageParentId=em.ParentId;
            // Initialize CSV header row outside the loop
            String generatedCSVFile = 'Id,ParentId,ActivityId,CreatedById,CreatedDate,LastModifiedDate,LastModifiedById,SystemModstamp,TextBody,Headers,Subject,Name,FromName,FromAddress,ValidatedFromAddress,ToAddress,CcAddress,BccAddress,Incoming,HasAttachment,Status,MessageDate,IsDeleted,ReplyToEmailMessageId,IsPrivateDraft,IsExternallyVisible,MessageIdentifier,ThreadIdentifier,ClientThreadIdentifier,IsClientManaged,RelatedToId,IsTracked,IsOpened,FirstOpenedDate,LastOpenedDate,IsBounced,EmailTemplateId,FileTest_Created_Date__c,HtmlBody\n'; // Header row
            
            //String body = em.HtmlBody != null ? wrapText(em.HtmlBody, 80) : ''; // Adjust the character limit as needed
            String formattedCreatedDate = em.CreatedDate != null ? em.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') : '';
            String cleanedHtmlBody = em.HtmlBody != null ? em.HtmlBody.replaceAll('[\\n\\r]+', ' ') : '';
            String truncatedHtmlBody = cleanedHtmlBody.length() > 1000 ? cleanedHtmlBody.substring(0, 1000) : cleanedHtmlBody;           
            String fileRow = '\"' + em.Id + '\",\"' + em.ParentId + '\",\"' + em.ActivityId + '\",\"' + em.CreatedById + '\",\"' + formattedCreatedDate + '\",\"' + em.LastModifiedDate  + '\",\"' + em.LastModifiedById + '\",\"' + em.SystemModstamp + '\",\"' + em.TextBody + '\",\"' + em.Headers + '\",\"' + em.Subject + '\",\"' + em.Name + '\",\"' + em.FromName + '\",\"' + em.FromAddress + '\",\"' + em.ValidatedFromAddress + '\",\"' + em.ToAddress + '\",\"' + em.CcAddress + '\",\"' + em.BccAddress + '\",\"' + em.Incoming + '\",\"' + em.HasAttachment + '\",\"' + em.Status + '\",\"' + em.MessageDate + '\",\"'+ em.IsDeleted + '\",\"' + em.ReplyToEmailMessageId + '\",\"' + em.IsPrivateDraft + '\",\"' + em.IsExternallyVisible + '\",\"' + em.MessageIdentifier + '\",\"' + em.ThreadIdentifier + '\",\"' + em.ClientThreadIdentifier + '\",\"' + em.IsClientManaged + '\",\"' + em.RelatedToId + '\",\"' + em.IsTracked + '\",\"' + em.IsOpened + '\",\"' + em.FirstOpenedDate + '\",\"' + em.LastOpenedDate + '\",\"' + em.IsBounced + '\",\"' + em.EmailTemplateId + '\",\"' + em.FileTest_Created_Date__c + '\",\"'  +truncatedHtmlBody + '\",..';  // body.replaceAll('\"', '\"\"').replaceAll('\n', ' ').replaceAll('\r', '') + '\"'c;
            
            generatedCSVFile += fileRow; // Remove + '\n'                        
            //Create email attachment and send email inside the loop 
            csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = Blob.valueOf(generatedCSVFile);
            String csvName = 'EmailMessageDetails_' + em.Id + '.csv'; // Customize the file name with record ID
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            
            String csvString = csvBlob.toString();
            //Blob myBlob = Blob.valueOf(csvBlob);
            //String convertedString = myBlob.toString();

            //String csvString = EncodingUtil.base64Encode(csvBlob);
            //List<String> sendEmails = new List<String>();
            //sendEmails.add('chalumurisaikiran@enabledanalytics.com');
            //string csvBody=csvAttachment.getBody();
            // Set the record ID in the email subject
            //String subject = 'Email Message Details CSV - ';
            //email.setSubject(subject);
            //email.setToAddresses(sendEmails);
            //email.setPlainTextBody('Email Message details CSV');
            //allAttachments.add(csvAttachment);
            //email.setFileAttachments(allAttachments);
            //email.setFileAttachments(new Messaging.EmailFileAttachment[]{allAttachments});
            
            List<EmailMessage_Html__b> embList=new List<EmailMessage_Html__b>();
            
            EmailMessage_Html__b emhb=new EmailMessage_Html__b();
            emhb.Title__c = csvName;
            emhb.File_Size__c =csvAttachment.Body.Size();
            emhb.EmailMessage_Id__c=em.Id;
            emhb.Status__c = 'Not Started';
            emhb.sObject__c='Email Message';
            emhb.File_Body__c = csvString;
            emhb.Parent_Case_Id__c=EmailMessageParentId;            
            if(emhb.File_Size__c > 12000000){
                emhb.Is_Large_File__c = 'yes';
                emhb.Status__c = 'Failed';
                emhb.Error_Message__c = 'File size > 12000000';
            }
            else{
                emhb.Is_Large_File__c = 'no';
                emhb.Status__c = 'Not Started';
            }
            embList.add(emhb);
            
            System.debug('Email_Message_Html__b Title__c'+emhb.Title__c);
            System.debug('Email_Message_Html__b File_Size__c'+emhb.File_Size__c);
            System.debug('Email_Message_Html__b Emailmessage_Id__c'+emhb.Emailmessage_Id__c);
            System.debug('Email_Message_Html__b Is_Large_File__c'+emhb.Is_Large_File__c);
            System.debug('Email_Message_Html__b Status__c'+emhb.Status__c);
            System.debug('Email_Message_Html__b Error_Message__c'+emhb.Error_Message__c);
            System.debug('emhb.Parent_Case_Id__c'+emhb.Parent_Case_Id__c);
            
            if(embList.size() > 0){
                system.debug('embList-->'+embList);
                Database.insertImmediate(embList);
            }
            
            
        }
        //Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});            
    }
    global void finish(Database.BatchableContext bc) {
        system.debug('finish');
    }
    /*public String wrapText(String text, Integer maxLength) {
String[] words = text.split('\\s+');
String wrappedText = '';
Integer lineLength = 0;
for (String word : words) {
if (lineLength + word.length() <= maxLength) {
wrappedText += word + ' ';
lineLength += word.length() + 1; // Add 1 for the space
} else {
wrappedText += '\n' + word + ' ';
lineLength = word.length() + 1; // Reset line length for new line
}
}
return wrappedText.trim(); // Trim any trailing whitespace
}*/
}