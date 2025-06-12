public class CountsFromSharePoint {
    Public static void getAccessToken(){
        
        string responseString = '';
        
        String accessToken;
        
        String fileName;
        String fileSpId;
        String fileSPWebUrl;
        String fileCreatedDateTime;
        String fileSPEtag;
        String fileSize;
        String fileType;
       
        //==========Generating Access Token=:
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.microsoftonline.com/c487bfd5-493f-43f0-b382-8da34b7b213b/oauth2/v2.0/token');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout(120000);
        
        String requestBody = 'grant_type=client_credentials&client_id=c6534941-5272-4d13-a86d-58a8ae871a72&client_secret=8ln8Q~vuDll8VoUHV~cXJzU6qweMa9WcV1lzBaq4&scope=https://graph.microsoft.com/.default';
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            TokenResponse tokenResponse = (TokenResponse) JSON.deserialize(res.getBody(), TokenResponse.class);
            // Do something with the deserialized tokenResponse object
            system.debug(res.getBody());
            accessToken=tokenResponse.access_token;
            //return tokenResponse.access_token;
        } 
        System.debug('String accessToken=> '+accessToken);
        
        
        //==========Get File Name From SF=:
        
        Datetime startDate = Datetime.valueOf(Label.StartDate);
        Datetime endDate = Datetime.valueOf(Label.EndDate);
       
        List<ContentDocumentLink> contentDocumentLinkList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN ( SELECT Id FROM EmailMessage WHERE Parent.ClosedDate >= :startDate AND Parent.ClosedDate <= :endDate AND Parent.Have_More_Character__c = false )LIMIT 50000];
        Set<Id> contDocIds = new Set<Id>();
       
        for(ContentDocumentLink linkVar: contentDocumentLinkList){
            contDocIds.add(linkVar.ContentDocumentId);
        }
        
        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument WHERE Id IN :contDocIds];
        System.debug(contentDocumentList.size());
        
        
        
        
        
        
        //==========Get Data From SP=:
        List<EmailMessage_Html__b> emailHtmlList=[Select EmailMessage_Id__c,Status__c,sObject__c,Parent_Case_Id__c from EmailMessage_Html__b  where EmailMessage_Id__c ='02sVE000000gCDCYA2' and sObject__c ='Email Message' and Status__c ='Not Started'];
        String caseId;
        String emailId;
        for(EmailMessage_Html__b emBig:emailHtmlList){
            caseId=emBig.Parent_Case_Id__c;
            emailId=emBig.EmailMessage_Id__c;
        }
        System.debug('String caseId=> '+caseId);
        System.debug('String caseId=> '+emailId);
        
        String driveId = Label.SharepointDriveId;
        String encodedDriveId = EncodingUtil.urlEncode(driveId, 'UTF-8');
        System.debug('String encodedDriveId=> '+encodedDriveId);
        
        Http httpCallout = new Http();
        HttpRequest req1 = new HttpRequest();
        String objectNameCase = 'Case';
        
        req1.setMethod('GET');
        req1.setHeader('Authorization', 'Bearer ' + accessToken);
        req1.setHeader('Content-Type', 'application/json');
        req1.setHeader('Accept', 'application/json');
        req1.setTimeout(120000);
        //req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase + '/'+ caseId + ':/children');
        //req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase +':/children'); 
        req1.setEndpoint('https://graph.microsoft.com/v1.0/sites/39544cbf-c240-4582-b6b4-6ec118d81851/drives/'+driveId+'/items/root:/'+ objectNameCase  +'/'+ caseId + '/' + emailId +':/children'); 
        HTTPResponse res1 = httpCallout.send(req1);
        System.debug('res1 Status Code=> '+res1.getStatus()); 
        System.debug('res1 Status Code=> '+res1.getStatusCode()); 
        
        
        if (res1.getStatusCode() == 200) {
            try {
                if (res1.getBody() != null) {
                    String jsonString = res1.getBody();
                    responseString = res1.getBody();
                    Response result = (Response) JSON.deserialize(jsonString, Response.class);
                    System.debug('EmailResponse: ' + result);
                    for(Item eachItem : result.value){
                        List<object> dataList=new List<object>();
                        fileName=eachItem.name;
                        fileSpId=eachItem.id;
                        fileSPWebUrl=eachItem.webUrl;
                        fileCreatedDateTime=eachItem.createdDateTime;
                        fileSPEtag=eachItem.eTag.substring(2, eachItem.eTag.length() - 4);
                        fileSize=eachItem.size;
                        fileType=eachItem.File.mimeType;
                        ResponseItem resp = new ResponseItem();
                        resp.name = eachItem.name;
                        resp.id = eachItem.id;
                        resp.webUrl = eachItem.webUrl;
                        resp.createdDateTime = eachItem.createdDateTime;
                        resp.eTag = eachItem.eTag.substring(2, eachItem.eTag.length() - 4);
                        resp.size = eachItem.size;
                        resp.fileType = eachItem.File.mimeType;
                        //fileData.responseItems.add(resp);
                        system.debug('response item '+resp);
                        system.debug(eachItem.name);
                        system.debug(eachItem.id);
                        system.debug(eachItem.webUrl);
                        system.debug(eachItem.createdDateTime);
                        system.debug(eachItem.eTag.substring(2, eachItem.eTag.length() - 4));
                        system.debug(eachItem.size);
                        system.debug(eachItem.File.mimeType);
                        
                        
                    }
                    //System.debug('Map<String,List<Object>> MapWeb==>' + fileData.resultMap);                          
                    //System.debug('Map<String,List<object>> MapWeb==>'+MapWeb);
                    //System.debug('List<object> dataList=>'+dataList);
                    
                } else {
                    System.debug('Response body is null or empty');
                }
            } catch (Exception e) {
                System.debug('Error deserializing JSON: ' + e.getMessage());
            }
        }
        
    }
    
    public class ResponseItem {
        public String createdDateTime;
        public String eTag;
        public String id;
        public String name;
        public String webUrl;
        public String size;
        public String fileType;
    }
    
    public class TokenResponse {
        public String access_token { get; set; }
        public String token_type { get; set; }
        public Integer expires_in { get; set; }
        public String scope { get; set; }
        public String soap_instance_url { get; set; }
        public String rest_instance_url { get; set; }
    }
    
    public class Item {
        //public string @microsoft.graph.downloadUrl;
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
        Public File File;
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
    
    Public class File{
        public string mimeType;
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