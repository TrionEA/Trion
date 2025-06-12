global class EmailMessageHtmlTriggerHandler implements Database.Batchable<SObject>, Database.Stateful{
    List<EmailMessageHtml__c>listEmailHtml=new List<EmailMessageHtml__c>();
    global EmailMessageHtmlTriggerHandler(List<EmailMessageHtml__c> listEmailHtml,String Status){
        this.listEmailHtml=listEmailHtml;
        
    }
    global List<EmailMessageHtml__c> start(Database.BatchableContext BC) {
     
       return listEmailHtml;
    }
 
   
    global void execute(Database.BatchableContext BC, List<EmailMessageHtml__c> scope) {
       
       
        
        
    }
 
   
    global void finish(Database.BatchableContext BC) {
       
}
    
}