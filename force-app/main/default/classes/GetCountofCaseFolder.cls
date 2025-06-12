public class GetCountofCaseFolder {
    @future(callout=true)
    public static void httpCalloutCalling(){
        
        List<Stagging__c> stagingList = [select sObject__c, Chunk__c, Linked_Entity_Id__c, Content_Document_Id__c, Content_Version_Id__c, Status__c, Job_ID__c, Title__c, From_sObject__c
                                         from Stagging__c
                                         where Status__c = 'Completed'
                                         LIMIT 1];
        
        
        String driveId = Label.SharepointDriveId;
        System.debug('String driveId: ' + driveId);
        String subFolderName = stagingList[0].Linked_Entity_Id__c;
        
        Http httpCallOut=new Http();
        HttpRequest httpReq=new HttpRequest();
        String objectNameCase = 'Case';
        EmailMessage emRec = [Select ParentId from EmailMessage where Id =: subFolderName];
        String  caseFolderName = emRec.ParentId;
        system.debug('caseFolderName----->'+caseFolderName);
        httpReq.setMethod('GET');
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('Accept','application/json');
        httpReq.setEndPoint('callout:Sharepoint/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+objectNameCase +'/'+caseFolderName+':/children');
        
        HttpResponse res=httpCallOut.send(httpReq);
        if(res.getStatusCode()==200){
            if(res.getBody()!=Null){
                String rBody=res.getBody();
                system.debug('Resonse'+rBody);
                Response result=(Response) JSON.deserialize(rBody, Response.class);
                List<String>count=new List<String>();
                for(Item eachItem:result.value){
                    if(!(eachItem.Name.startsWith('EmailMessageDetails'))){
                        count.add(eachItem.Name);
                    }  
                    
                }
                System.debug('Number of Child counts are:'+count.size());
            }
        }
    }
    public static void triggerHttpCallout() {
        httpCalloutCalling( );
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