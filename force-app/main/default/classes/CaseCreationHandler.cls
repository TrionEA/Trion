public without sharing class  CaseCreationHandler {
    
    public static void handleEmailMessageLinks(List<ContentDocumentLink> emailMessageLinks){
        System.debug('contentdocumentlinks'+emailMessageLinks);
        System.debug('contentdocumentlinks'+emailMessageLinks[0].LinkedEntityId);
        
        Set<Id>ParIds=new Set<ID>();
        Set<Id>contentDocLinks=new Set<ID>();
        For(ContentDocumentLink conLink:emailMessageLinks){
            
            if(!string.valueOf(conLink.LinkedEntityId).contains('0051M')){
                ParIds.ADD(conLink.LinkedEntityId);
                contentDocLinks.add(conLink.ContentDocumentId);
            }
            System.debug('linkedentityId:'+conLink.LinkedEntityId);
            
        }
        System.debug('ParIds;'+ParIds);
        EmailMessage emvar = [select Id, ParentId, ActivityId,Chekbox_for_reply__c, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress,Identifier__c, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, FileTest_Created_Date__c from EmailMessage where id in:ParIds Limit 1];
        
        case caseVar = [select id,CaseNumber, No_of_days__c, Status,ParentId from case where id =:emvar.ParentId Limit 1];//new case();
        List<EmailMessage> emailMessageList = NEW List<EmailMessage>();
        if( caseVar.Status == 'closed' && caseVar.No_of_days__c >2){
            
            Case c=new Case();
            List<Case> CaseList = NEW List<Case>();
            
            c.Status='New';
            c.ParentId=caseVar.ParentId;
            c.Description=emvar.TextBody;
            c.Subject=emvar.Subject;
            CaseList.add(c);
            
            Database.SaveResult[] srList0 = Database.insert(CaseList,false);                
            EmailMessage e=new EmailMessage();
            //   List<EmailMessage> emailMessageList = NEW List<EmailMessage>();
            e.ParentId = CaseList[0].Id;
            e.ToAddress=emvar.ToAddress;
            e.FromAddress=emvar.FromAddress;
            e.Subject=emvar.Subject;
            
            e.Chekbox_for_reply__c = true;
            emailMessageList.add(e);
            Database.SaveResult[] srList = Database.insert(emailMessageList,false);                           
            
        //}
        System.debug('contentDocLinks >>>>>>>>>>>>>>>>>>'+contentDocLinks);
        // ContentDocumentLink convar = NEW ContentDocumentLink();
        List<ContentDocumentLink> ContentDocumentLinkList = NEW List<ContentDocumentLink>();
        for(ContentDocumentLink con:[select id ,ContentDocumentId,LinkedEntityId from ContentDocumentLink where ContentDocumentId in:contentDocLinks]){
            ContentDocumentLink convar = NEW ContentDocumentLink();
            System.debug('con >>>>>>>>>>>>>>>>>>'+con);    
            System.debug('convar >>>>>>>>>>>>>>>>>>'+convar);
            convar.LinkedEntityId=e.Id;//emailMessageList[0].id;
            convar.ContentDocumentId=con.ContentDocumentId;
            insert convar;
            ContentDocumentLinkList.add(convar);
            System.debug('ContentDocumentLinkList >>>>>>>>>>>>>>>>>>'+ContentDocumentLinkList);
            
        }
        System.debug('Debug sujatha:::=>>>>>>>>>>>>>>>>>>>>>>');
        System.debug(ContentDocumentLinkList);
        //Insert ContentDocumentLinkList;
        }
    }
    
    
    
}