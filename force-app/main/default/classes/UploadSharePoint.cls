Public class UploadSharePoint{
    
    
}


/*
public with sharing class UploadSharePoint implements Database.Batchable<sObject>{
    
    String Status;
    public List<EmailMessage_Html__b> start(Database.BatchableContext BC) {
        return [select EmailMessage_Id__c,Status__c,sObject__c from EmailMessage_Html__b where Status__c =: status limit 500];
        //System.debug('res.getStatusCode()=>' +res.getStatusCode());
    }
    
    public void execute(Database.BatchableContext BC, List<EmailMessage_Html__b> emList){
        
        for(EmailMessage_Html__b emhb:emList){
            string chunkid = emhb.Emailmessage_Id__c;
            SendCSVtoSharepointDK.fileMigration(chunkid);
        }
        
      //  SendCSVtoSharepointDK.fileMigration(stagingId);
        
        
    }
    
    public void finish(Database.BatchableContext BC){
       System.debug('Batch Is Completed');
    }
    
}
*/