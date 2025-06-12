@isTest
public class Arch_UploadValidationBatchSkTest {
	 public class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"value": [{"name": "File1"}, {"name": "File2"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testBatchExecution() {
         Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
       Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact con=new Contact(lastName='Sujatha',Email='suja@gmail.com',accountId=testAccount.id);
        insert con;
        Case cse = new Case(
            Subject = 'Test Case', 
            AccountId = testAccount.Id, 
            Failed_Record__c = False,
            Reason = 'Issue Resolved',
           	Status='New'
        );
        insert cse;
        cse.Status='Closed';
        cse.Reason='Duplicate';
        cse.ContactId=con.id;
        cse.Issue_with__c='Client';
        update cse;
      
        
        EmailMessage emailMessage = new EmailMessage(
            ParentId = cse.Id,
            FromAddress = 'test@example.com',
            ToAddress = 'recipient@example.com',
            HtmlBody = 'Test Email Body',
            Status = '3'
        );
        insert emailMessage;
        
        Stagging__c stagingRecord = new Stagging__c(
            Linked_Entity_Id__c = emailMessage.Id,
            Retry_Executed_Count__c = 1,
            Upload_Failed__c = false
        );
        insert stagingRecord;
        
        
        Attachment attach1 = new Attachment();   	
        attach1.Name = 'Test##SP';
        Blob bodyBlobAttach1 = Blob.valueOf('Unit Test Attachment Body');
        attach1.Body = bodyBlobAttach1;
        attach1.ParentId = emailMessage.Id;
        insert attach1;                
        
        ContentVersion content = new ContentVersion(); 
        content.Title = 'Test##SP'; 
        content.PathOnClient = '/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData = bodyBlob; 
        content.Origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = emailMessage.Id;
        contentlink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: content.Id].ContentDocumentId;
        //contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
        Test.startTest();
        Arch_UploadValidationBatchSk batchInstance = new Arch_UploadValidationBatchSk();
        ID batchJobId = Database.executeBatch(batchInstance);
        Test.stopTest();
    }
}