global class CSVClass implements Database.Batchable<sObject>{
    
    global Messaging.EmailFileAttachment csvAttachment ;
    global static List<Messaging.EmailFileAttachment> allAttachments = new List<Messaging.EmailFileAttachment>();
    
    global Database.QueryLocator Start(Database.BatchableContext bc) {
        String query = 'select id,Subject,htmlbody, CreatedDate from EmailMessage where Parent.Account.toBeDeleted__c =true';
        return Database.getQueryLocator(query);
    }
    
    global  void  execute(Database.BatchableContext bc, List<EmailMessage> emList){
        
        List<EmailMessage_Html__b> embList=new List<EmailMessage_Html__b>();
        
        // Loop through each record and generate and send individual CSV files
        
        try{
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            EmailMessage_Html__b emhb=new EmailMessage_Html__b();

            for (EmailMessage em : emList) {
                // Initialize CSV header row outside the loop
                String generatedCSVFile = 'Id,Subject,CreatedDate,Body\n'; // Header row
                
                String body = em.HtmlBody != null ? em.HtmlBody.replaceAll('\\n', '').replaceAll('\\r', '') : '';
                String formattedCreatedDate = em.CreatedDate != null ? em.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') : '';
                String fileRow = em.Id + ',' + em.Subject + ',' + formattedCreatedDate + ',' + '<![CDATA[' + body + ']]>';
                generatedCSVFile += fileRow + '\n';
                
                // Create email attachment and send email inside the loop
                csvAttachment = new Messaging.EmailFileAttachment();
                Blob csvBlob = Blob.valueOf(generatedCSVFile);
                String csvName = 'EmailMessageDetails_' + em.Id + '.csv'; // Customize the file name with record ID
                csvAttachment.setFileName(csvName);
                csvAttachment.setBody(csvBlob);
                List<String> sendEmails = new List<String>();
                sendEmails.add('deepakkumar@enabledanalytics.com');
                
                // Set the record ID in the email subject
                String subject = 'Email Message Details CSV - ';
                email.setSubject(subject);
                email.setToAddresses(sendEmails);
                email.setPlainTextBody('Email Message details CSV');
                allAttachments.add(csvAttachment);
                email.setFileAttachments(allAttachments);
                //email.setFileAttachments(new Messaging.EmailFileAttachment[]{allAttachments});
                
                
               // for(Messaging.EmailFileAttachment eatt:allAttachments){
                    
                    //EmailMessage_Html__b emhb=new EmailMessage_Html__b();
                    emhb.Title__c = csvName;
                    emhb.File_Size__c = csvAttachment.Body.Size();
                    emhb.EmailMessage_Id__c=em.Id;
                    
                    if(emhb.File_Size__c > 12000000){
                        emhb.Is_Large_File__c = 'yes';
                        emhb.Status__c = 'Failed';
                        emhb.Error_Message__c = 'File size > 12000000';
                    }
                    else{
                        emhb.Is_Large_File__c = 'no';
                        emhb.Status__c = 'Not Started';
                    }
                    //embList.add(emhb);
                    
                    System.debug('Email_Message_Html__b Title__c'+emhb.Title__c);
                    System.debug('Email_Message_Html__b File_Size__c'+emhb.File_Size__c);
                    System.debug('Email_Message_Html__b Emailmessage_Id__c'+emhb.Emailmessage_Id__c);
                    System.debug('Email_Message_Html__b Is_Large_File__c'+emhb.Is_Large_File__c);
                    System.debug('Email_Message_Html__b Status__c'+emhb.Status__c);
                    System.debug('Email_Message_Html__b Error_Message__c'+emhb.Error_Message__c);
                    // insert embList;
                    // Database.insertImmediate(embList);
                    
                    
                //}
            }
            //Database.insertImmediate(embList);
            //insert embList;
             embList.add(emhb);
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});            
        } 
        catch(Exception e){
            System.debug('Exception caught');
        }
        if(!embList.isEmpty()){
            system.debug('embList-->'+embList);
            Database.insertAsync(embList);
        }
    }    
    global void finish(Database.BatchableContext bc){
        
        system.debug('finish');
        
    }
}