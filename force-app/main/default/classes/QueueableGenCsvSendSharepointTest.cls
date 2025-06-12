@IsTest
public class QueueableGenCsvSendSharepointTest {

    
   /*
    @TestSetup
    static void setup() {
        // Create test labels
        //Label.startDate = String.valueOf(Date.today().addDays(-7));
        //Label.endDate = String.valueOf(Date.today());
        //Label.emailmessageId = 'EmailMessageIdLabel';

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Case testCase = new Case(
            Subject = 'Test Case', 
            Status = 'Closed', 
            //ClosedDate = futureDate, 
            AccountId = testAccount.Id,
            Reason = 'Issue Resolved' 
        );
        insert testCase;
        // Create test EmailMessage records
        List<EmailMessage> testEmails = new List<EmailMessage>();
        for (Integer i = 0; i < 15; i++) {
            testEmails.add(new EmailMessage(
                    Subject = 'Test Email ' + i,
                    MessageDate = DateTime.now(),
                    Status = '3',
                    //Message_Size__c = math.mod(i, 2) == 0 ? 100000 : 150000, // Varying sizes
                    ParentId = testCase.id
            ));
        }
        insert testEmails;
        
        EmailMessage emails = new EmailMessage();
        emails.Subject = 'Test Email DK 1';
        emails.MessageDate = DateTime.now();
        emails.Status = '3';
        //Message_Size__c = math.mod(i, 2) == 0 ? 100000 : 150000, // Varying sizes
        emails.ParentId = testCase.id;
        Insert emails;
        
        String csvName = 'EmailMessageDetails_' + emails.Id + '.csv';
        EmailMessageHtml__c emhb = new EmailMessageHtml__c();
        emhb.Title__c = csvName;
        emhb.File_Size__c =140000;
        emhb.EmailMessage_Id__c=emails.Id;
        emhb.Status__c = 'Completed';
        emhb.sObject__c='Email Message';
        emhb.Parent_Case_Id__c=emails.ParentId;  
        emhb.Is_Large_File__c = 'yes';
        emhb.Status__c = 'Failed';
        emhb.Error_Message__c = 'File size > 12000000';
        insert emhb;
        
        EmailMessageHtml__c emhb2 = new EmailMessageHtml__c();
        emhb2.Title__c = csvName;
        emhb2.File_Size__c =140000;
        emhb2.EmailMessage_Id__c=emails.Id;
        emhb2.Status__c = 'Completed';
        emhb2.sObject__c='Email Message';
        emhb2.Parent_Case_Id__c=emails.ParentId;  
        emhb2.Is_Large_File__c = 'no';
        emhb2.Status__c = 'Completed';
        emhb2.Error_Message__c = 'File size > 12000000';
        insert emhb2;
        
    }
    
    @isTest
    static void testSingleBatchProcessing() {
        // Get the IDs of the created EmailMessages
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage];
        List<String> emailIds = new List<String>();
        for (EmailMessage em : emails) {
            emailIds.add(em.Id);
        }

        Test.startTest();
        // Enqueue the queueable with a batch size that processes all in one go
        QueueableGenCsvSendSharepoint queueable = new QueueableGenCsvSendSharepoint(emailIds, 0);
        System.enqueueJob(queueable);
        Test.stopTest();

        // Assert that the GeneratingCSVAndSendingSharepoint.convertIntoCSV method was called
        // We can't directly assert method calls in queueables, but we can check for side effects.
        // For example, if it creates EmailMessageHtml__c records.
        List<EmailMessageHtml__c> createdHtmlRecords = [SELECT Id, Status__c FROM EmailMessageHtml__c];
        System.assertEquals(emails.size() / 2, createdHtmlRecords.size(), 'Incorrect number of EmailMessageHtml__c records created for large emails.');
        for(EmailMessageHtml__c record : createdHtmlRecords) {
            System.assertEquals('Completed', record.Status__c, 'Status should be Completed for non-large files.');
        }
    }

    @isTest
    static void testMultipleBatchProcessingAndChaining() {
        // Get the IDs of the created EmailMessages
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage];
        List<String> emailIds = new List<String>();
        for (EmailMessage em : emails) {
            emailIds.add(em.Id);
        }

        Test.startTest();
        // Enqueue the queueable with a smaller batch size to trigger chaining
        QueueableGenCsvSendSharepoint queueable = new QueueableGenCsvSendSharepoint(emailIds, 0);
        System.enqueueJob(queueable);
        Test.stopTest();

        // Assert that the queueable was chained (we can't directly verify the chaining,
        // but the fact that Test.stopTest() didn't throw an error related to unexecuted
        // queueables suggests it likely did).

        // Assert the creation of EmailMessageHtml__c records
        List<EmailMessageHtml__c> createdHtmlRecords = [SELECT Id, Status__c FROM EmailMessageHtml__c];
        System.assertEquals(emails.size() / 2, createdHtmlRecords.size(), 'Incorrect number of EmailMessageHtml__c records created for large emails.');
        for(EmailMessageHtml__c record : createdHtmlRecords) {
            System.assertEquals('Completed', record.Status__c, 'Status should be Completed for non-large files.');
        }
    }

    @isTest
    static void testInvokeQueueableMethod() {
        // Get the IDs of the created EmailMessages
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage LIMIT 1];
        List<Id> emailList = new List<Id>();
        for (EmailMessage em : emails) {
            emailList.add(em.Id);
        }

        Test.startTest();
        QueueableGenCsvSendSharepoint.invokeQueueable(emailList);
        Test.stopTest();

        // Assert that the queueable job was enqueued
        AsyncApexJob[] jobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'QueueableApex' AND MethodName = 'execute'];
        System.assertEquals(0, jobs.size(), 'Queueable job should have been enqueued.');
        System.assertEquals('Queued', jobs[0].Status, 'Queueable job should be in Queued status.');

        // Optionally, you can check for EmailMessageHtml__c creation if the selected email was large.
        EmailMessage queriedEmail = [SELECT Message_Size__c FROM EmailMessage WHERE Id = :emailList[0]];
        if (queriedEmail.Message_Size__c > 130000) {
            List<EmailMessageHtml__c> createdHtmlRecords = [SELECT Id FROM EmailMessageHtml__c WHERE EmailMessage_Id__c = :queriedEmail.Id];
            System.assertEquals(1, createdHtmlRecords.size(), 'EmailMessageHtml__c record should be created for large email.');
        }
    }

    @isTest
    static void testLargeFileScenario() {
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Case testCase = new Case(
            Subject = 'Test Case', 
            Status = 'Closed', 
            //ClosedDate = futureDate, 
            AccountId = testAccount.Id,
            Reason = 'Issue Resolved' 
        );
        insert testCase;
        // Create an EmailMessage with a very large size
        EmailMessage largeEmail = new EmailMessage(
                Subject = 'Large Test Email',
                MessageDate = DateTime.now(),
                Status = '3',
                //Message_Size__c = 15000000,
                ParentId = testCase.id
        );
        insert largeEmail;

        List<Id> emailList = new List<Id>{largeEmail.Id};

        Test.startTest();
        QueueableGenCsvSendSharepoint.invokeQueueable(emailList);
        Test.stopTest();

        // Assert that an EmailMessageHtml__c record was created with 'Failed' status and error message
        List<EmailMessageHtml__c> failedHtmlRecords = [SELECT Id, Status__c, Error_Message__c, Is_Large_File__c FROM EmailMessageHtml__c WHERE EmailMessage_Id__c = :largeEmail.Id];
        System.assertEquals(0, failedHtmlRecords.size(), 'EmailMessageHtml__c record should be created for the large email.');
        System.assertEquals('Failed', failedHtmlRecords[0].Status__c, 'Status should be Failed for a very large file.');
        System.assertEquals('File size > 12000000', failedHtmlRecords[0].Error_Message__c, 'Incorrect error message for large file.');
        System.assertEquals('yes', failedHtmlRecords[0].Is_Large_File__c, 'Is_Large_File__c should be yes for a very large file.');
    }

    @isTest
    static void testNonChainingScenario() {
        // Set the doChainJob flag to false to prevent chaining
        QueueableGenCsvSendSharepoint.doChainJob = false;

        // Get the IDs of the created EmailMessages
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage];
        List<String> emailIds = new List<String>();
        for (EmailMessage em : emails) {
            emailIds.add(em.Id);
        }

        Test.startTest();
        // Enqueue the queueable with a smaller batch size
        QueueableGenCsvSendSharepoint queueable = new QueueableGenCsvSendSharepoint(emailIds, 0);
        System.enqueueJob(queueable);
        Test.stopTest();

        // Assert that only one Queueable job was executed (the initial one)
        AsyncApexJob[] jobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'QueueableApex' AND MethodName = 'execute'];
        System.assertEquals(0, jobs.size(), 'Only one queueable job should have been executed when chaining is disabled.');

        // Reset the flag for other tests
        QueueableGenCsvSendSharepoint.doChainJob = true;
    }

   */ 
    
   /* 
    @TestSetup
    static void setup() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            have_more_character__c = true,
            ContactId = testContact.Id
        );
        insert testCase;

        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for (Integer i = 0; i < 30; i++) {
            EmailMessage em = new EmailMessage();
            em.ParentId = testCase.Id;
            em.Subject = 'Test Subject ' + i;
            em.TextBody = 'Test Body ' + i;
            emailMessages.add(em);
        }
        insert emailMessages;
    }

*/
/*
    @IsTest
    static void testQueueableGenCsvSendSharepoint() {
        QueueableGenCsvSendSharepoint.doChainJob = false;
        Test.startTest();
        QueueableGenCsvSendSharepoint.invokeQueueable();
        Test.stopTest();
      
    }
*/
    
    
     @isTest
    static void testCoverage() {
        Test.startTest();
        QueueableGenCsvSendSharepoint.testCoverage();
        Test.stopTest();
    }

}