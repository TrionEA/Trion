public class StagingQueueable implements Queueable {
    private List<Stagging__c> stagingRecords;
    private Boolean isUpdate;

    public StagingQueueable(List<Stagging__c> records, Boolean isUpdate) {
        this.stagingRecords = records;
        this.isUpdate = isUpdate;
    }

    public void execute(QueueableContext context) {
        if (isUpdate) {
            Database.executeBatch(new UpdatingPurgeCaseContent(stagingRecords));
        } else {
            Database.executeBatch(new FetchingDataFromStaging(stagingRecords));
        }
    }
}