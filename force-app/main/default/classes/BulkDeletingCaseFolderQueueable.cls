public class BulkDeletingCaseFolderQueueable implements Queueable {
    private List<String> caseIds;
    
     private static final Integer BATCH_SIZE = 5;
    
   
    public BulkDeletingCaseFolderQueueable(List<String> caseIds) {
        this.caseIds = caseIds;
    }

    
    public void execute(QueueableContext context) {
        System.debug('Processing batch of Case IDs. Total IDs remaining: ' + caseIds.size());

       
        List<String> currentBatch = new List<String>();
        
       
        Integer limSize = Math.min(BATCH_SIZE, caseIds.size());
        for (Integer i = 0; i < limSize; i++) {
            currentBatch.add(caseIds[i]);
        }
        
       
        for (Integer i = limSize - 1; i >= 0; i--) {
            caseIds.remove(i);
        }

        
        
            System.enqueueJob(new DeletingCaseFolder(currentBatch));
        
        
        
        if (!caseIds.isEmpty()) {
            System.enqueueJob(new BulkDeletingCaseFolderQueueable(caseIds));
        }
    }
}