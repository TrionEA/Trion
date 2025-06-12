global class HtmlCleanerwithID implements
Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String emId = '02sVE000000gCCtYAM';
        return Database.getQueryLocator([
            SELECT EmailMessage_Id__c, Status__c, sObject__c 
            FROM EmailMessage_Html__b 
            WHERE EmailMessage_Id__c = :emId 
            AND Status__c = 'Not Started' 
            AND sObject__c = 'Email Message'
        ]);
    }    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
                Database.deleteImmediate(scope);
        
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('HtmlCleanerwithID is successfully completed.');
    }
     
}