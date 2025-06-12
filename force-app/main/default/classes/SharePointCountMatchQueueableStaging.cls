public class SharePointCountMatchQueueableStaging implements Queueable, Database.AllowsCallouts{
    private String emailRecordId;
    private string caseId;
    private integer emailRecordCount;
    
    public SharePointCountMatchQueueableStaging(string caseId,string emailRecordId, integer emailRecordCount) {
        this.emailRecordId = emailRecordId;
        this.caseId = caseId;
        this.emailRecordCount = emailRecordCount;
        System.debug('emailRecordId->'+emailRecordId);
        System.debug('caseId->'+caseId);
        System.debug('emailRecordCount->'+emailRecordCount);
    }
    
    public void execute(QueueableContext context) {
        System.debug('emailRecordId->'+emailRecordId);
        System.debug('caseId->'+caseId);
        System.debug('emailRecordCount->'+emailRecordCount);
        String driveId = Label.SharepointDriveId;
        List<Stagging__c> stagingUpdateList = new List<Stagging__c> ();
        Http httpCallOut=new Http();
        HttpRequest httpReq=new HttpRequest();
        Map<Id,integer> mapofEntityandFilesCount = new Map<Id, Integer>();
        
        String objectNameCase = 'Case';
        //EmailMessage emRec = [Select ParentId from EmailMessage where Id =: subFolderName];
        //String caseFolderName = emRec.ParentId;
        //system.debug('caseFolderName----------->'+caseFolderName);
        httpReq.setMethod('GET');
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('Accept','application/json');
        httpReq.setEndPoint('callout:Sharepoint/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+objectNameCase +'/'+caseId+'/'+emailRecordId+':/children');
        
        List<String>count=new List<String>();
        
        Integer emailMessageDetailsCount = 0;
        
        HttpResponse res=httpCallOut.send(httpReq);
        if(res.getStatusCode()==200){
            if(res.getBody()!=Null){
                String rBody=res.getBody();
                system.debug('Resonse'+rBody);
                Response result=(Response) JSON.deserialize(rBody, Response.class);
                //List<String>count=new List<String>();
                
                for(Item eachItem:result.value){
                    if(!(eachItem.Name.startsWith('EmailMessageDetails'))){
                        count.add(eachItem.Name);
                    } else if(eachItem.Name.startsWith('EmailMessageDetails') && eachItem.Name.contains(emailRecordId)){
                        emailMessageDetailsCount += 1;
                    }
                    
                }
                System.debug('Number of Child counts are:'+count.size());
                System.debug('Number of EmailMessageDetails items: ' + emailMessageDetailsCount);               
            }
            if(count.size() != emailRecordCount || emailMessageDetailsCount != 1){
                List<Stagging__c> stagingList = [Select id,status__c from Stagging__c where Linked_Entity_Id__c =: emailRecordId ];
                if(!stagingList.isEmpty()){
                    System.debug('stagingList------>'+stagingList);
                    for(Stagging__c stg: stagingList ){
                        System.debug('stg.Retry_Executed_Count__c------>'+stg.Retry_Executed_Count__c);
                        if(stg.Retry_Executed_Count__c <1){
                            stg.status__c = 'Retry Required';
                            stg.Retry_Executed_Count__c = stg.Retry_Executed_Count__c +1;
                            System.debug('stg.Retry_Executed_Count__c------>'+stg.Retry_Executed_Count__c);
                            stagingUpdateList.add(stg);
                        }
                        else{
                            stg.status__c = 'Failed';
                            stagingUpdateList.add(stg);
                        }
                        
                    }
                }
                
                // Retry Pending Jobs
                if(!stagingList.isEmpty()){
                    System.debug('stagingList------>'+stagingList);
                    for(Stagging__c stg: stagingList ){
                        if(stg.status__c == 'Retry Required'){
                            System.schedule('Schedule - 3' , ' 0 0 12-17 * * ? ', new SchedulableSharePointstagingCSV('Retry Required'));
                            System.schedule('Schedule - 4' , ' 0 0 12-17 * * ? ', new SchedulableSharePointstaging('Retry Required'));
                            stg.status__c = 'Retry Attempted';
                        }
                    }
                }
                
                if(!stagingUpdateList.isEmpty()){
                    System.debug('stagingUpdateList------>'+stagingUpdateList);
                    Database.Update(stagingUpdateList,False);
                }
            }          
        }
    }
    public class Item {
        public String createdDateTime;
        public String eTag;
        public String id;
        public String lastModifiedDateTime;
        public String name;
        public String webUrl;
        public String cTag;
        public String size;
        public Decorator decorator;
        public CreatedBy createdBy;
        public LastModifiedBy lastModifiedBy;
        public ParentReference parentReference;
        public FileSystemInfo fileSystemInfo;
        public Folder folder;
        public Shared shared;
        public File File;
    }
    
    public class Decorator {
        public String iconColor;
    }
    
    public class CreatedBy {
        public User user;
    }
    
    public class LastModifiedBy {
        public User user;
    }
    
    public class User {
        public String email;
        public String id;
        public String displayName;
    }
    
    public class ParentReference {
        public String driveType;
        public String driveId;
        public String id;
        public String name;
        public String path;
        public String siteId;
    }
    
    public class File {
        public String mimeType;
    }
    
    public class FileSystemInfo {
        public String createdDateTime;
        public String lastModifiedDateTime;
    }
    
    public class Folder {
        public Integer childCount;
    }
    
    public class Shared {
        public String scope;
    }
    
    public class Response {
        public List<Item> value;
    }
}