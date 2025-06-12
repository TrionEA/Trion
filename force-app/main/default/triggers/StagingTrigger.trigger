trigger StagingTrigger on Stagging__c (After insert,After Update) {
    If(Trigger.IsAfter && Trigger.IsInsert){
        List<Stagging__c>listag=new List<Stagging__c>(); 
        for(Stagging__c s:Trigger.New){
            if(s.Status__c=='Not Started'){
                listag.add(s);
            }
        }
        
      Database.executeBatch(new FetchingDataFromStaging(listag));
    }
    if(Trigger.IsAfter && Trigger.isUpdate){
       List<Stagging__c>listagList=new List<Stagging__c>(); 
        for(Stagging__c s:Trigger.New){
            if(s.Status__c=='Completed' || s.Status__c=='Failed'){
                listagList.add(s);
            }
       
       }
        Database.executeBatch(new UpdatingContentforPurgeCase(listagList)); 
    /*If(Trigger.IsAfter && Trigger.isUpdate){
        List<Stagging__c>listSta=new List<Stagging__c>();
        for(Stagging__c s:Trigger.new){}
    }*/
    }
}