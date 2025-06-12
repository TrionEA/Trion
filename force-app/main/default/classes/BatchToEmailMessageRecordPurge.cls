global class BatchToEmailMessageRecordPurge implements Database.Batchable<SObject> {
    
    global List<EmailMessage> start(Database.BatchableContext bc){
        return[Select Id from EmailMessage where Parent.Status ='Closed'];
    }
    
    global void execute(Database.BatchableContext bc, List<EmailMessage> emailList){
       
        if(!emailList.isEmpty()){
            delete[Select Id from EmailMessage where Parent.Status ='Closed' AND Parent.ClosedDate < LAST_N_YEARS:1];
        }
      
    }

    
    global void finish(Database.BatchableContext bc){
        System.debug('BatchForPurgeAutomation is completed.');
    }
}