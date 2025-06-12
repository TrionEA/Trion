public class TriggerOnEmailhandler {
    Public  TriggerOnEmailhandler(List<EmailMessage>lisEmails){
        Set<Id>paIds=new Set<Id>();
        set<Id>emIds=new Set<Id>();
        for(EmailMessage emsg:lisEmails){
            emIds.add(emsg.id);
            paIds.add(emsg.parentId);
        }
        EmailMessage lis=[select Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, FileTest_Created_Date__c from EmailMessage where id in : emIds ];
          case caseVarlis = [select id,CaseNumber,accountId,contactId, No_of_days__c, Status,ParentId from case where id =:paIds and Status='closed' and No_of_days__c >2];//new case();
     
            Case c1=new Case();
            c1.ParentId=caseVarlis.id;
            c1.Status='New';
            c1.ContactId=caseVarlis.contactId;
            c1.AccountId=caseVarlis.accountId;
           
              insert c1;
           
      
               EmailMessage e=new EmailMessage();
            e.ParentId = c1.Id;
            e.ToAddress=lis.toaddress;
            e.FromAddress=lis.FromAddress;
            e.Subject=lis.Subject;
          	e.Status='5';
        e.TextBody=lis.TextBody;
        
        insert e;
            
     
        CreateCaseEmailMessageOnCaseClosed.createNewCase(lis.id,e.id);
    }
}