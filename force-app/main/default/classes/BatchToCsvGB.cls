global class BatchToCsvGB implements Database.Batchable<sObject>,  Database.Stateful{
      global List<EmailMessage_Html__b> embList = new List<EmailMessage_Html__b>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Subject, HtmlBody, CreatedDate FROM EmailMessage WHERE Parent.Account.toBeDeleted__c = true';
        return Database.getQueryLocator(query);
    }
    
  global void execute(Database.BatchableContext bc, List<EmailMessage> emList){
    try{
        for (EmailMessage em : emList) {
            System.debug('Processing EmailMessage Id: ' + em.Id);
            
            String generatedCSVFile = 'Id,Subject,CreatedDate,Body\n'; // Header row
            
            String body = em.HtmlBody != null ? em.HtmlBody.replaceAll('\\n', '').replaceAll('\\r', '') : '';
            String formattedCreatedDate = em.CreatedDate != null ? em.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') : '';
            String fileRow = em.Id + ',' + em.Subject + ',' + formattedCreatedDate + ',' + '<![CDATA[' + body + ']]>';
            generatedCSVFile += fileRow + '\n';
            
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = Blob.valueOf(generatedCSVFile);
            String csvName = 'EmailMessageDetails_' + em.Id + '.csv';
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            
            List<String> sendEmails = new List<String>();
            sendEmails.add('deepakkumar@enabledanalytics.com');
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String subject = 'Email Message Details CSV - ' + em.Id;
            email.setSubject(subject);
            email.setToAddresses(sendEmails);
            email.setPlainTextBody('Email Message details CSV');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            
            EmailMessage_Html__b emhb = new EmailMessage_Html__b();
            emhb.Title__c = csvName;
            emhb.File_Size__c = csvAttachment.Body.Size();
            emhb.EmailMessage_Id__c = em.Id;
             emhb.Status__c = 'Not Started';
            emhb.sObject__c='Email Message';
            
            if (emhb.File_Size__c > 12000000) {
                emhb.Is_Large_File__c = 'yes';
                emhb.Status__c = 'Failed';
                emhb.Error_Message__c = 'File size > 12000000';
            } else {
                emhb.Is_Large_File__c = 'no';
                emhb.Status__c = 'Not Started';
            }
            embList.add(emhb);
        }
        System.debug('embList size in Execute: ' + embList.size());

        system.debug('embList====>'+embList);
    } 
    catch(Exception e){
        System.debug('Exception caught: ' + e.getMessage());
    }
}
 global void finish(Database.BatchableContext bc) {
        try {
            System.debug('embList size in finish: ' + embList.size());
        system.debug('embList====>'+embList);
            if (!embList.isEmpty()) {
                // Inserting EmailMessage_Html__b records
                Database.insertImmediate(embList);
                System.debug('Records inserted successfully');
            } else {
                System.debug('No records to insert');
            }
        } catch (Exception e) {
            System.debug('Exception caught during finish: ' + e.getMessage());
        }
    }
}