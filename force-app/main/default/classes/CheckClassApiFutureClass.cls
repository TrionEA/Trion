public class CheckClassApiFutureClass {

    public static void checkId(){
        List<Staging__b> stagingList = [select sObject__c, Chunk__c, Linked_Entity_Id__c, Content_Document_Id__c, Content_Version_Id__c, Status__c, Job_ID__c, Title__c, From_sObject__c
                                            from Staging__b
                                            where Status__c = 'Not Started'];
        
        string  stagingId;
        
        for(Staging__b stb:stagingList){
            stagingId=stb.Chunk__c;
        }                                
                                        
       // ApiFutureCalling.fileMigration(stagingId);
        
        ApiFutureCalling api=new ApiFutureCalling();
      //  string fileSharePointId=api.fileMigration.eachItem.id;
      //  system.debug(' ApiFutureCalling.fileMigration' +fileSharePointId);
    }
}