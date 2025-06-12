trigger EmailMessageHtmlTrigger on EmailMessageHtml__c (After Insert,After Update) {
   
 /*   
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<EmailMessageHtml__c> emList1 = new List<EmailMessageHtml__c>();
        List<EmailMessageHtml__c> emList2 = new List<EmailMessageHtml__c>();
       
        for (EmailMessageHtml__c emHtmRec : Trigger.new) {
            if (emHtmRec.Status__c == 'Not Started') {
                emList1.add(emHtmRec);
            }
            if (emHtmRec.Status__c == 'Completed' || emHtmRec.Status__c == 'Failed') {
                emList2.add(emHtmRec);
            }
        }
        
        if (!emList1.isEmpty()) {
            System.enqueueJob(new EmailMessageQueueable(emList1, 'PurgeCaseEmailsSK'));
        }
        
        if (!emList2.isEmpty()) {
            System.enqueueJob(new EmailMessageQueueable(emList2, 'UpdatingPurgCaseComplete'));
        }
    }
*/
 
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
      
        List<EmailMessageHtml__c>emList1=new List<EmailMessageHtml__c>();
       
        For(EmailMessageHtml__c emHtmRec:Trigger.new){
            if(emHtmRec.Status__c=='Not Started'){
                emList1.add(emHtmRec);
            }
            
        }
        Database.executeBatch(new PurgeCaseEmailsSK(emList1)); 
    }
    if(Trigger.IsAfter && Trigger.IsUpdate){
        List<EmailMessageHtml__c>emList2=new List<EmailMessageHtml__c>();
        For(EmailMessageHtml__c emRec:Trigger.new){
            if(emRec.Status__c=='Completed' || emRec.Status__c=='Failed'){
                emList2.add(emRec);
            }
            Database.executeBatch(new UpdatingPurgCaseComplete(emList2));
        }
    }
    
           
}