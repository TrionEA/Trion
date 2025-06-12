@isTest
public class FileAndAttachmentsforLongChracEmailTest {
    
    @testSetup
    static void setup() {
        
        Case oldCase = new Case(Subject = 'Old Case');
        insert oldCase;
        
        Case newCase = new Case(Subject = 'New Case');
        insert newCase;
        
        
        List<EmailMessage> emails = new List<EmailMessage>();
        for (Integer i = 0; i < 3; i++) {
            EmailMessage email = new EmailMessage(
                ParentId = oldCase.Id,
                Subject = 'Test Email ' + i,
                FromName = 'Sender ' + i,
                FromAddress = 'sender' + i + '@example.com',
                ToAddress = 'recipient@example.com',
                TextBody = 'Test Text Body ' + i + ' ' + 'A'.repeat(1000),
                HtmlBody = '<p>Test HTML Body ' + i + '</p>',
                Status = '3'
            );
            emails.add(email);
        }
        insert emails;
        
       
        List<ContentDocument> documents = new List<ContentDocument>();
        for (Integer i = 0; i < 3; i++) {
            ContentVersion version = new ContentVersion(
                Title = 'Test Document ' + i,
                PathOnClient = 'TestDoc' + i + '.pdf',
                VersionData = Blob.valueOf('Test content for document ' + i)
            );
            insert version;
            
            ContentDocument doc = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :version.Id LIMIT 1];
            documents.add(doc);
            
            ContentDocumentLink link = new ContentDocumentLink(
                LinkedEntityId = emails[i].Id,
                ContentDocumentId = doc.Id,
                ShareType = 'I'
            );
            insert link;
        }
    }
    
    @isTest
    static void testFileAndAttachmentsForLongChracEmail() {
       
        Case oldCase = [SELECT Id FROM Case WHERE Subject = 'Old Case' LIMIT 1];
        Case newCase = [SELECT Id FROM Case WHERE Subject = 'New Case' LIMIT 1];
        
       
        Test.startTest();
       
           FileAndAttachmentsforLongChracEmail.testCov();
        Test.stopTest();
        
        
      
    }
}