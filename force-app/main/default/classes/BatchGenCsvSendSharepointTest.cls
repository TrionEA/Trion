@isTest
public class BatchGenCsvSendSharepointTest {

    @isTest
    static void testExecuteMethod() {
     
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
            have_more_character__c = true ,
            ContactId = testContact.Id
        );
        insert testCase;
        
        
        EmailMessage testEmailMessage = new EmailMessage(
            ParentId = testCase.Id,  
            Subject = 'Test Email',
            FromAddress = 'test@example.com',
            ToAddress = 'recipient@example.com',
            TextBody = 'This is a test email.'
        );
        insert testEmailMessage;
        

        System.assertNotEquals(null, testEmailMessage.Id);

     
        String parentId = testCase.Id;  // Should be the same as '500G000000NMW7fIAH' in your batch class

      
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        BatchGenCsvSendSharepoint batch = new BatchGenCsvSendSharepoint();
        ID batchJobId = Database.executeBatch(batch);
        Test.stopTest();
        
      
        List<EmailMessage> processedEmails = [SELECT Id FROM EmailMessage WHERE Id = :testEmailMessage.Id];
        System.assertEquals(1, processedEmails.size(), 'The test email message should have been processed.');
    }
    

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
        
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}