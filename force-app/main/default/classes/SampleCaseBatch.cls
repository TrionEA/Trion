public class SampleCaseBatch implements Database.Batchable<sObject>{
    /*
    private Id caseId;

    public SampleCaseBatch(Id caseId) {
        this.caseId = caseId;
    }
	*/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Subject, Status, ClosedDate
            FROM Case
            WHERE ClosedDate >= 2024-09-12T00:00:00Z  and ClosedDate < 2024-09-13T00:00:00Z
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope) {
        String caseId;
        String caseStatus;
        DateTime caseClosedDate;
        String subject;
        for (Case caseRecord : scope) {
            caseId = caseRecord.id;
            caseStatus = caseRecord.Status;
            caseClosedDate = caseRecord.ClosedDate;
            subject = caseRecord.Subject;
        }
        System.debug('String caseId--> '+caseId);
        System.debug('String caseStatus--> '+caseStatus);
        System.debug('String caseClosedDate--> '+caseClosedDate);
        System.debug('String subject--> '+subject);
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('SampleCaseBatch Class is completed.');
        
    }

}