public class ProcessEmailMessageBatch implements Queueable {
    public List<EmailMessage> batchList;

    public ProcessEmailMessageBatch(List<EmailMessage> batchList) {
        this.batchList = batchList;
    }

    public void execute(QueueableContext context) {
        for (EmailMessage emRec : batchList) {
            // Enqueue a new Queueable job for each EmailMessage record
            System.enqueueJob(new GeneratedCsvUploadingToSP_V1(emRec.Id));
        }
    }
}