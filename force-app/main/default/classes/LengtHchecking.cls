public class LengtHchecking {
    
    public static void meth1(){
        String container;
        Emailmessage emRec=[select id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, Message_Size__c,No_of_chars_in_emailmessae__c from emailmessage where id='02sVE000001lkLPYAY'];
        container=emrec.Headers+emrec.HtmlBody+emrec.TextBody+emrec.id+emrec.ParentId+emrec.ActivityId+emrec.CreatedById+emrec.CreatedDate+emrec.LastModifiedDate+emrec.LastModifiedById+emrec.SystemModstamp+emrec.Subject+emrec.name+emrec.FromName+emrec.FromAddress+emrec.ValidatedFromAddress+emrec.ToAddress+emrec.CcAddress+emrec.BccAddress+emrec.Incoming+emrec.HasAttachment+emrec.Status+emrec.MessageDate+emrec.IsDeleted+emrec.ReplyToEmailMessageId+emrec.IsPrivateDraft+emrec.IsExternallyVisible+emrec.MessageIdentifier+emrec.ThreadIdentifier+emrec.ClientThreadIdentifier+emrec.IsClientManaged+emrec.RelatedToId+emrec.IsTracked+emrec.IsOpened+emrec.FirstOpenedDate+emrec.LastOpenedDate+emrec.IsBounced+emrec.EmailTemplateId+emrec.Message_Size__c;
        
        //System.debug(container);
        System.debug('Length of characters is'+container.length());
        emrec.No_of_chars_in_emailmessae__c=container.length();
        Update emRec;
        
        
        
    }

}