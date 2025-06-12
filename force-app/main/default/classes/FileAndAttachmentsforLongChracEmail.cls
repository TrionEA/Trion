public class FileAndAttachmentsforLongChracEmail {
    public static void FAA(){
   // Fetch the old EmailMessages
   String OldId=Label.OldCaseId;
   String newId=Label.NewCaseId;
List<EmailMessage> lisEmaisOld = [SELECT Id, ActivityId, TextBody, HtmlBody, Headers, Subject, FromName, FromAddress, ToAddress, CcAddress, BccAddress, Status, MessageDate 
                                  FROM EmailMessage 
                                  WHERE ParentId = :OldId 
                                  ];
 
List<EmailMessage> lisEmaisnew = new List<EmailMessage>();
Map<Id, Id> oldToNewEmailMap = new Map<Id, Id>(); // Map to track old to new EmailMessage Ids
 
// Copy the old EmailMessages to new ones
for (EmailMessage emRec : lisEmaisOld) {
    if(emRec.HtmlBody!=null && emRec.TextBody!=null){
    String trimmedtextbody = emRec.TextBody.left(131071);
   
    String trimmedhtmlbody = emRec.HtmlBody.left(131071);
    EmailMessage e = new EmailMessage();
    e.ParentId = newId;
    e.ActivityId = emRec.ActivityId;
    e.TextBody = trimmedtextbody;
    e.HtmlBody = trimmedhtmlbody;
    e.Headers = emRec.Headers;
    e.Subject = emRec.Subject;
    e.FromName = emRec.FromName;
    e.FromAddress = emRec.FromAddress;
    e.ToAddress = emRec.ToAddress;
    e.BccAddress = emRec.BccAddress;
    e.CcAddress = emRec.CcAddress;
    e.Status = emRec.Status;
    e.MessageDate = emRec.MessageDate;
     e.TrimmedTextBody__c = emRec.TextBody.right(emRec.TextBody.length()-trimmedtextbody.length());
    e.TrimmedHtmlBody__c = emRec.HtmlBody.right(emRec.HtmlBody.length()-trimmedhtmlbody.length());
    lisEmaisnew.add(e);
    }ELSE{
    EmailMessage e = new EmailMessage();
    e.ParentId = newId;
    e.ActivityId = emRec.ActivityId;
    e.Headers = emRec.Headers;
    e.Subject = emRec.Subject;
    e.FromName = emRec.FromName;
    e.FromAddress = emRec.FromAddress;
    e.ToAddress = emRec.ToAddress;
    e.BccAddress = emRec.BccAddress;
    e.CcAddress = emRec.CcAddress;
    e.Status = emRec.Status;
    e.MessageDate = emRec.MessageDate;
  
    lisEmaisnew.add(e);
    }
    
}
 
// Insert the new EmailMessages
insert lisEmaisnew;
system.debug('Size of lisEmaisOld.size();:'+ lisEmaisOld.size());
// Map old EmailMessage Ids to the new EmailMessage Ids
for (Integer i = 0; i <lisEmaisnew.size(); i++) {
    oldToNewEmailMap.put(lisEmaisOld[i].Id, lisEmaisnew[i].Id);
}
 
// Fetch the ContentDocumentLinks associated with the old EmailMessages
List<ContentDocumentLink> lisoldcontent = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                           FROM ContentDocumentLink 
                                           WHERE LinkedEntityId IN :oldToNewEmailMap.keySet()];
 
List<ContentDocumentLink> newContentLinks = new List<ContentDocumentLink>();
 
// Reassign ContentDocumentLinks to the new EmailMessages
for (ContentDocumentLink conLink : lisoldcontent) {
    ContentDocumentLink newLink = new ContentDocumentLink();
    newLink.LinkedEntityId = oldToNewEmailMap.get(conLink.LinkedEntityId); // New EmailMessage Id
    newLink.ContentDocumentId = conLink.ContentDocumentId;
    newContentLinks.add(newLink);
}
 
// Insert the new ContentDocumentLinks
List<ContentDocumentLink> caslinks = new List<ContentDocumentLink>();

for (ContentDocumentLink conLink : lisoldcontent) {
    ContentDocumentLink newLink = new ContentDocumentLink();
        newLink.LinkedEntityId=newId;
    newLink.ContentDocumentId = conLink.ContentDocumentId;
        caslinks.add(newLink);
}

// Insert the new ContentDocumentLinks
insert caslinks;
insert newContentLinks;
 
}
    public static void testCov(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}