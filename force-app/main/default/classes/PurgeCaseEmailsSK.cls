global class PurgeCaseEmailsSK implements Database.Batchable<SObject>, Database.Stateful {
 
    global List<EmailMessageHtml__c> listEmailHtmls;
    global PurgeCaseEmailsSK(List<EmailMessageHtml__c> listEmailHtmls){
        this.listEmailHtmls=listEmailHtmls;
    }
    global List<EmailMessageHtml__c> start(Database.BatchableContext BC) {
       //List<EmailMessageHtml__c> listEmailHtmls=[select Id, Name, Csv_Body__c, EmailMessage_Id__c, Error_Message__c, File_Body__c, File_Size__c, Is_Large_File__c, Job_ID__c, Parent_Case_Id__c, sObject__c, Status__c, Title__c from EmailMessageHtml__c where Status__c='Not Started'];
       return listEmailHtmls;
       
    }
 
   
    global void execute(Database.BatchableContext BC, List<EmailMessageHtml__c> scope) {
         /*Map<String,List<String>> MapingCaseIdWithEmailId=new  Map<String,List<String>>();
       
        for(EmailMessageHtml__c emHtRec:scope){
         if (MapingCaseIdWithEmailId.containsKey(emHtRec.Parent_Case_Id__c)) {
        List<String>emailIds = MapingCaseIdWithEmailId.get(emHtRec.Parent_Case_Id__c);
        emailIds.add(emHtRec.EmailMessage_Id__c);
        MapingCaseIdWithEmailId.put(emHtRec.Parent_Case_Id__c, emailIds);
       }
            else 
       {
    List<String> emailIds = new List<String>();
    emailIds.add(emHtRec.EmailMessage_Id__c);  
    MapingCaseIdWithEmailId.put(emHtRec.Parent_Case_Id__c, emailIds);  
		}
      }
        Set<String> caseIdKeys =MapingCaseIdWithEmailId.keySet();


       List<String> caseIdKeyList = new List<String>(caseIdKeys);
        List<Purge_Case__c> lispurgeCase=new List<Purge_Case__c>();
        for(integer i=0;i<MapingCaseIdWithEmailId.keySet().size();i++){
             Purge_Case__c P=new Purge_Case__c();
             P.Case_Id__c=caseIdKeyList[i];
             List<String>emIds=MapingCaseIdWithEmailId.get(caseIdKeyList[i]);
            p.EmailMessage_Id__c=String.join(emIds, ',\n');
            p.Status__c='Ready to Upload';
            lispurgeCase.add(p);
            System.debug('Email Id is:'+p.EmailMessage_Id__c);
            System.debug('XCase Id is:'+p.Case_Id__c);
        }
        System.debug('List of values to insert:'+lispurgeCase);
        System.debug('Map Values are :'+MapingCaseIdWithEmailId);
        insert lispurgeCase;
       
        */
        
    }
 
   
    global void finish(Database.BatchableContext BC) {
       
}
}