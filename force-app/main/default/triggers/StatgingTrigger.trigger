trigger StatgingTrigger on Stagging__c (After insert,After Update) {
    /* if (Trigger.IsAfter && Trigger.IsInsert) {
List<Stagging__c> listag = new List<Stagging__c>(); 
for (Stagging__c s : Trigger.New) {
if (s.Status__c == 'Not Started') {
listag.add(s);
}
}

if (!listag.isEmpty()) {
System.enqueueJob(new StagingQueueable(listag, false));
}
}

if (Trigger.IsAfter && Trigger.IsUpdate) {
List<Stagging__c> listagList = new List<Stagging__c>(); 
for (Stagging__c s : Trigger.New) {
if (s.Status__c == 'Completed' || s.Status__c == 'Failed') {
listagList.add(s);
}
}

if (!listagList.isEmpty()) {
System.enqueueJob(new StagingQueueable(listagList, true));
}
}
*/
    
    If(Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate)){
        List<Stagging__c>listag=new List<Stagging__c>(); 
        for(Stagging__c s:Trigger.New){
            if(s.Status__c=='Not Started' || s.Status__c=='Retry Required'){
                listag.add(s);
            }
        }
        
        Database.executeBatch(new FetchingDataFromStaging(listag));
    }
    if(Trigger.IsAfter && Trigger.isUpdate){
        List<Stagging__c>listagList=new List<Stagging__c>(); 
        for(Stagging__c s:Trigger.New){
            if(s.Status__c=='Completed' || s.Status__c=='Failed' || s.Status__c=='Retry Required'){
                listagList.add(s);
            }
            
        }
        
        if(listagList.size() > 0){
            Database.executeBatch(new UpdatingPurgeCaseContent(listagList)); 
        }
        /*If(Trigger.IsAfter && Trigger.isUpdate){
List<Stagging__c>listSta=new List<Stagging__c>();
for(Stagging__c s:Trigger.new){}
}*/
    }
}