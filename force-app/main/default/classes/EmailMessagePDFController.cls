public class EmailMessagePDFController {
    //@Future(callout=true)
    public List<EmailMessage> emailMessages { get; private set; }

    public EmailMessagePDFController() {
        String closed = '2014-05-01T00:00:00.000+05:30';
        Datetime testDate = Datetime.valueOf(closed.replace('T', ' ').replace('Z', ''));
        emailMessages = [SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, TextBody, HtmlBody, Headers, Subject, Name, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, ClientThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, FileTest_Created_Date__c FROM EmailMessage WHERE Parent.ClosedDate <= :testDate];
    }
}