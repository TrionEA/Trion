public class Arch_ScheduleOneApexusingBatch_UTV1 implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext ctx){
        return Database.getQueryLocator([Select Id,Name from Account]);
    }
    public void execute(Database.BatchableContext bc, List<Account>accList){
    }
    public void finish(Database.BatchableContext bc){
        //system.debug('Hiii.....');
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = 
                          :bc.getJobId()];
        //then use the active job id and abort it
        system.abortJob(a.id);
        System.scheduleBatch(new Arch_ScheduleOneApexusingBatch_UTV1(), 'Scheduling for every 3 minutes' + String.valueOf(Datetime.now()) , 3);
    }
}