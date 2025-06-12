global class BatchtoGetCSVDataFromCase implements Database.Batchable<sObject>{
    
    global Database.QueryLocator Start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Case where Account.toBeDeleted__c =true';        
        return Database.getQueryLocator(query);
    }
    
    global  void  execute(Database.BatchableContext bc, List<Case> caseList){  
        String parentCaseId;
        for(Case ce:caseList){
            parentCaseId=ce.Id;
        }
        GetCsvUsingSPId.getSharepointId(parentCaseId);
        
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('finish');
    }
    
    
}