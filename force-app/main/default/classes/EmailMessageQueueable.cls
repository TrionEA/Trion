public class EmailMessageQueueable implements Queueable {
    private List<EmailMessageHtml__c> emailMessages;
    private String processType;

    public EmailMessageQueueable(List<EmailMessageHtml__c> emailMessages, String processType) {
        this.emailMessages = emailMessages;
        this.processType = processType;
    }

    public void execute(QueueableContext context) {
        if (processType == 'PurgeCaseEmailsSK') {
            Database.executeBatch(new PurgeCaseEmailsSK(emailMessages));
        } else if (processType == 'UpdatingPurgCaseComplete') {
            Database.executeBatch(new UpdatingPurgCaseComplete(emailMessages));
        }
    }
}