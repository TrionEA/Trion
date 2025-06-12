trigger CaseCreation on ContentDocumentLink (after insert) {
  //  if (Trigger.isAfter && Trigger.isInsert) {
    //          CaseCreationHandler.handleEmailMessageLinks(Trigger.new);
    /*List<Id>ParIds=new List<ID>();
    list<ContentDocumentLink> condoclinkVar = trigger.new;
    For(ContentDocumentLink conLink:condoclinkVar){
        if (conLink.LinkedEntity.Type == 'EmailMessage'){
            ParIds.ADD(conLink.LinkedEntityId);
        }
    }
    EmailMessage emvar = [select Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, FileTest_Created_Date__c from EmailMessage where id=:condoclinkVar[0].linkedEntityId];
    if(emvar!= null){
        case caseVar = [select id,CaseNumber, No_of_days__c, Status,ParentId from case where id =:emvar.ParentId];//new case();
        //caseVar.CaseNumber = null;
        if( caseVar.Status == 'closed' && caseVar.No_of_days__c >2){
            
            Case c=new Case();
            c.Status='New';
            c.ParentId=caseVar.ParentId;
            c.Description=emvar.TextBody;
            c.Subject=emvar.Subject;
            insert c;
            EmailMessage e=new EmailMessage();
            e.ParentId = c.Id;
            e.ToAddress=emvar.ToAddress;
            e.FromAddress=emvar.FromAddress;
            e.Subject=emvar.Subject;
            insert e;
            
           
            ContentDocumentLink convar = NEW ContentDocumentLink();
            convar.LinkedEntityId = e.Id;
            convar.ContentDocumentId = condoclinkVar[0].ContentDocumentId;
            insert convar;
      
        }
        
    }
*/   // }  
}